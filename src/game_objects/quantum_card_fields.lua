-- General helpers
local _default_enabled = true

-- Returns card._qfield_cache.has
local function _general_quantum_has_func(card, args)
    if (card._qfield_cache or {}).has then
        return card._qfield_cache.has -- e.g. {rank = {any = true}, enhancement = {no = true}} 
    end
    args = args or {}
    card._qfield_cache = {
        has = {},
        get = {}
    }
    local context = {card_has_check = true, card = card, no_mod = false}
    local flags = args.flags or args
    for key, q_field in pairs(SMODS.QuantumCardFields) do
        card._qfield_cache.get[q_field.return_flag] = q_field:base_getter(card, args)
        card._qfield_cache.has[key] = {}
        context[q_field.has_context_flag] = true
    end
    for key, flag in pairs(flags) do
        context[key] = flag
    end
    if next(SMODS.optional_features.quantum_fields) then -- Only calculate the context if any quantum fields are toggled on
        SMODS.calculate_context(context) -- Card._qfield_cache.has is updated directly
    end 
    for key, q_field in pairs(SMODS.QuantumCardFields) do
        if (key == "rank" and card._qfield_cache.get.enhancements.m_stone) then card._qfield_cache.has[key].no = true end -- Todo : check if this explicit stone check is necessary
        for k, v in pairs(card._qfield_cache.get[q_field.return_flag]) do
            local obj = q_field.g_obj_table[k] or {}
            if obj["no_" .. key] then card._qfield_cache.has[key].no = true end 
            if obj["any_" .. key] then card._qfield_cache.has[key].any = true end
        end
        if card._qfield_cache.has[key].no and not card._qfield_cache.has[key].any then
            card._qfield_cache.get[q_field.return_flag] = {}
        end
    end
    return card._qfield_cache.has
end

function SMODS.set_quantum_cache(card)
    if card.playing_card then _general_quantum_has_func(card) 
    else return false end
    return true
end

function SMODS.clear_quantum_cache(card)
    if card._qfield_cache and not card._qfield_cache._clear_queued then
        G.E_MANAGER:add_event(Event({
            trigger = "immediate",
            blocking = false,
            blockable = false,
            func = function ()
                card._qfield_cache = nil
                return true
            end
        })) 
        card._qfield_cache._clear_queued = true
    end
end

-- Returns card._qfield_cache.get, sanitized to use only string keys
local function _general_quantum_getter(card, args)
    if card._qfield_cache and card._qfield_cache.get then
        return card._qfield_cache.get
    end
    args = args or {}
    local context = {_quantum_getter = true, card = card, no_mod = false} -- _quantum_getter flag should not be referenced in practice (as it doesn't account for optional_features.quantum_fields), use specific "get_ranks" etc. flags instead
    local has = _general_quantum_has_func(card, args)
    for key, q_field in pairs(SMODS.QuantumCardFields) do 
        card._qfield_cache.get[q_field.return_flag] = (has[key].no and not has[key].any and {}) or (has[key].any and SMODS.shallow_copy(q_field.g_obj_table)) or card._qfield_cache.get[q_field.return_flag] -- If e.g. has.rank.no is true and .any not, default to no ranks, if any is true, default to all ranks, if neither, default to the values set by _general_quantum_has_func
        if SMODS.optional_features.quantum_fields[key] then
            context[q_field.get_context_flag] = true
        end
    end
    local flags = args.flags or args
    for key, flag in pairs(flags) do
        context[key] = flag
    end
    if next(SMODS.optional_features.quantum_fields) then -- Only calculate the context if any quantum fields are toggled on
        SMODS.calculate_context(context) -- Card._qfield_cache.get is updated directly
    end
    local eval = card._qfield_cache.get
    local ret = {}
    for key, q_field in pairs(SMODS.QuantumCardFields) do 
        ret[q_field.return_flag] = {} 
        for k, v in pairs(eval[q_field.return_flag]) do
            local new_key = type(k) == "table" and k.key or k
            if v then
                ret[q_field.return_flag][new_key] = true
                local obj = q_field.g_obj_table[new_key]
                if obj and q_field.cache_ability then
                    card._qfield_cache.abilities = card._qfield_cache.abilities or {}
                    local ability = SMODS.get_ability_from_obj(obj)
                    table.insert(card._qfield_cache.abilities, {t = ability, key = new_key, qfield_key = key})
                end
            else
                card._qfield_cache.get[q_field.return_flag][new_key] = nil
            end
        end
    end
    return ret
end

local function _general_quantum_singular_is_func(key, card, value, args, ...)
    return SMODS.QuantumCardFields[key].plural_is(card, {[value] = true}, args, ...)
end

local function _general_quantum_plural_is_func(key, card, values_map, args, ...)
    args = args or {}
    if card.debuff and not args.bypass_debuff then return false end
    local field_values = SMODS.QuantumCardFields[key].getter(card, ...)
    local is_wild = SMODS.QuantumCardFields[key].has_any(card, ...)

    for k, _ in pairs(field_values) do
        if values_map[k] then
            if not args.all then return true end
        else
            if args.all and not is_wild then return false
            elseif args.all then is_wild = false end
        end
    end
    return args.all
end

local function _general_quantum_calculate(key, card, context, ...)
    SMODS.push_to_context_stack(context, "quantum_card_fields.lua : _general_quantum_calculate")
    local values = SMODS.QuantumCardFields[key].getter(card, ...)
    local ret = {}
    for c_key, v in pairs(values) do
        local obj = SMODS.QuantumCardFields[key].g_obj_table[c_key]
        if obj.calculate and type(obj.calculate) == 'function' then
            SMODS.set_context_evaluee(obj)
            local o = obj:calculate(card, context)
            if o then
                if not o.card then o.card = card end
                ret[#ret+1] = {o}
            end
        end
    end
    SMODS.set_context_evaluee(card)
    SMODS.pop_from_context_stack(context, "quantum_card_fields.lua : _general_quantum_calculate")
    return ret
end

-- Inject helpers

local function _quantum_field_inject_getter(args, target_objects) 
    local getter_func = args.override_getter or function (card, ...)
        return _general_quantum_getter(card, ...)[args.key .. "s"]
    end
    local func_field = "get_" .. args.key .. "s"
    for _, target_obj in ipairs(target_objects) do
        target_obj[func_field] = getter_func
    end
    local field_object = SMODS.QuantumCardFields[args.key]
    field_object.getter = getter_func
end

local function _quantum_field_inject_has_funcs(args, target_objects) 
    local has_no_func = args.override_has_no or function (card, ...)
        local ret = _general_quantum_has_func(card, ...)[args.key] or {}
        return ret.no and not ret.any
    end
    local has_any_func = args.override_has_any or function (card, ...)
        return (_general_quantum_has_func(card, ...)[args.key] or {}).any
    end
    local has_no_func_field = "has_no_" .. args.key
    local has_any_func_field = "has_any_" .. args.key
    for _, target_obj in ipairs(target_objects) do
        target_obj[has_no_func_field] = has_no_func
        target_obj[has_any_func_field] = has_any_func
    end
    local field_object = SMODS.QuantumCardFields[args.key]
    field_object.has_no = has_no_func
    field_object.has_any = has_any_func
end

local function _quantum_field_inject_is_funcs(args, target_objects) 
    local singular_is_func = function (card, value, ...)
        return _general_quantum_singular_is_func(args.key, card, value, ...)
    end
    local plural_is_func = function (card, values_map, ...)
        return _general_quantum_plural_is_func(args.key, card, values_map, ...)
    end
    local singular_func_field = args.func_prefix .. "_" .. args.key
    local plural_func_field = args.func_prefix .. "_" .. args.key .. "s"
    for _, target_obj in ipairs(target_objects) do
        target_obj[singular_func_field] = singular_is_func
        target_obj[plural_func_field] = plural_is_func
    end
    local field_object = SMODS.QuantumCardFields[args.key]
    field_object.singular_is = singular_is_func
    field_object.plural_is = plural_is_func
end

local function _quantum_field_inject_calculate(args, target_objects)
    local calculate_func = args.override_calculate or function (card, context, ...)
        local ret = _general_quantum_calculate(args.key, card, context, ...)
        return SMODS.merge_effects(unpack(ret)) -- unsure if unpack is deprecated or not
    end
    local func_field = "calculate_" .. args.key
    for _, target_obj in ipairs(target_objects) do
        target_obj[func_field] = calculate_func
    end
    local field_object = SMODS.QuantumCardFields[args.key]
    field_object.calculate = calculate_func
end

-- Class

SMODS.QuantumCardFields = {}
SMODS.QuantumCardField = SMODS.GameObject:extend {
    obj_table = SMODS.QuantumCardFields,
    set = 'QuantumCardField',
    obj_buffer = {},
    required_params = {
        'key',
        'g_obj_table'
    },
    process_loc_text = function() end,
    inject = function(self)
        local inject_args = self.inject_args or {}
        local target_objects = self.target_objects or {}
        if not inject_args.no_getter then
            target_objects.getter = target_objects.getter or {Card}
            _quantum_field_inject_getter({key = self.key, override_getter = self.override_getter}, target_objects.getter)
        end
        if not inject_args.no_has_funcs then
            target_objects.has_funcs = target_objects.has_funcs or {SMODS}
            _quantum_field_inject_has_funcs({key = self.key, override_has_no = self.override_has_no, override_has_any = self.override_has_any}, target_objects.has_funcs)
        end
        if not inject_args.no_is_func then
            target_objects.is_funcs = target_objects.is_funcs or {Card}
            _quantum_field_inject_is_funcs({key = self.key, func_prefix = inject_args.is_func_prefix or "is"}, target_objects.is_funcs)
        end
        if not inject_args.no_calculate then
            target_objects.calculate = target_objects.calculate or {Card}
            _quantum_field_inject_calculate({key = self.key, override_calculate = self.override_calculate}, target_objects.calculate)
        end
        self.get_context_flag = self.get_context_flag or "get_" .. self.key .. "s"
        self.has_context_flag = self.has_context_flag or "has_" .. self.key
        self.return_flag = self.return_flag or self.key .. "s"
        SMODS.CONTEXT_TYPES[self.key] = self.get_context_flag
        SMODS.amount_return_flags[self.return_flag] = true
        SMODS.amount_return_flags["no_" .. self.key] = true
        SMODS.amount_return_flags["any_" .. self.key] = true
        if self.default_enabled then SMODS.optional_features.quantum_fields[self.key] = true end
        if not self.calc_key then self.calc_key = self.key end
    end,
    post_inject_class = function(self)
        
    end,
    default_enabled = _default_enabled,
    calc_key = nil,
    cache_ability = nil, -- Whether the _general_quantum_getter should cache the .config table of this qfield's object values into card._qfield_cache.abilities
    base_value_ref = nil, -- e.g. 'base.value' for Rank, 'config.center.key' for Enhancement, ...
    get_base_value = function (self, card) return table_get_subfield(card, self.base_value_ref) end,
    base_getter = function (self, card, _args) 
        local base = self:get_base_value(card)
        if base then return {[base] = "BASE"} end
        return {}
    end,
    getter = nil,       -- func defined by inject()
    has_no = nil,       -- func defined by inject()
    has_any = nil,      -- func defined by inject()
    singular_is = nil,  -- func defined by inject()
    plural_is = nil,    -- func defined by inject()
    calculate = nil,    -- func defined by inject()
}

SMODS.QuantumCardField{
    key = "rank",
    g_obj_table = SMODS.Ranks,
    base_value_ref = "base.value"
}

SMODS.QuantumCardField{
    key = "enhancement",
    g_obj_table = G.P_CENTERS,
    cache_ability = true,
    get_context_flag = "check_enhancement",
    inject_args = {
        is_func_prefix = "has"
    },
    target_objects = {
        getter = {Card, SMODS},
        is_funcs = {Card, SMODS}
    },
    base_value_ref = "config.center.key"
}

SMODS.QuantumCardField{
    key = "seal",
    calc_key = "seals",
    cache_ability = true,
    g_obj_table = G.P_SEALS,
    inject_args = {
        is_func_prefix = "has"
    },
    base_value_ref = "seal",
}

SMODS.QuantumCardField{
    key = "edition",
    cache_ability = true,
    g_obj_table = G.P_CENTERS,
    base_value_ref = "edition.key"
}

-- Todo : consider implementing quantum suits
-- SMODS.QuantumCardField{
--     key = "suit",
--     g_obj_table = SMODS.Suits,
--     base_value_ref = "base.suit"
-- }

SMODS.QuantumCardField{
    key = "sticker",
    g_obj_table = SMODS.Stickers,
    inject_args = {
        is_func_prefix = "has"
    },
    base_getter = function (self, card, _args) 
        local stickers = {}
        local abilities = SMODS.get_card_abilities(card)
        for _, key in ipairs(SMODS.Sticker.obj_buffer) do
            for _, ability_t in ipairs(abilities) do
                if ability_t.t[key] then -- .t is the actual ability table
                    stickers[key] = "BASE"
                    break
                end
            end
        end
        return stickers
    end,
}


SMODS.Seal:take_ownership("Red", {
    calculate = function (self, card, context)
        if context.repetition then
            return {
                message = localize('k_again_ex'),
                repetitions = 1,
                card = card
            }
        end
    end
})

SMODS.Seal:take_ownership("Purple", {
    calculate = function (self, card, context)
        if context.discard and context.other_card == card and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = (function()
                    SMODS.add_card({set = "Tarot", area = G.consumeables, key_append = "8ba"})
                    G.GAME.consumeable_buffer = 0
                    return true
                end)}))
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_plus_tarot'), colour = G.C.PURPLE})
            return nil, true
        end
    end
})

-- Todo : reset_idol_card() etc. may need to be updated