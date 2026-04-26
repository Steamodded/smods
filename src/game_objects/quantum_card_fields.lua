-- General helpers

-- Returns card._qfield_cache.has
local function _general_quantum_has_func(card, args)
    if (card._qfield_cache or {}).has then
        return card._qfield_cache.has -- e.g. {rank = {any = true}, enhancement = {no = true}} 
    end
    card._qfield_cache = {
        has = {},
        get = {}
    }
    local context = {card_has_check = true, card = self, no_mod = false}
    local flags = args.flags or {}
    for key, q_field in pairs(SMODS.QuantumCardFields) do
        card._qfield_cache.get[key + "s"] = q_field:base_getter(card, args)
        card._qfield_cache.has[key] = {}
        context[q_field.has_context_flag] = true
    end
    for key, flag in pairs(flags) do
        context[key] = flag
    end
    local eval = SMODS.calculate_context(context) or {} -- {rank = {any = true}}
    return eval
end

-- Todo : Update this to be a complete quantum context and use card field caching
-- Returns card._qfield_cache.get
local function _general_quantum_getter(card, args)
    if card._qfield_cache and card._qfield_cache.get then
        return card._qfield_cache.get
    end
    local context = {_quantum_getter = true, card = self, no_mod = false} -- _quantum_getter flag should not be referenced in practice (as it doesn't account for optional_features.quantum_fields), use specific "get_ranks" etc. flags instead
    local has = _general_quantum_has_func(card, args)
    for key, q_field in pairs(SMODS.QuantumCardFields) do 
        card._qfield_cache.get[key + "s"] = (has[key].no and not has[key].any and {}) or (has[key].any and SMODS.shallow_copy(q_field.g_obj_table)) or card._qfield_cache.get[key + "s"] -- If e.g. has.rank.no is true and .any not, default to no ranks, if any is true, default to all ranks, if neither, default to the values set by _general_quantum_has_func
        if SMODS.optional_features.quantum_fields[key] then
            context[q_field.get_context_flag] = true
        end
    end
    local flags = args.flags or {}
    for key, flag in pairs(flags) do
        context[key] = flag
    end    
    local eval = SMODS.calculate_context(context) or {} -- {ranks = {...}, ...}

    local ret = {}
    for key, q_field in pairs(SMODS.QuantumCardFields) do 
        ret[key + "s"] = {} 
        for k, v in pairs(eval[key + "s"]) do
            if v then
                local new_key = type(k) == "table" and k.key or k
                ret[key + "s"][new_key] = true
                local obj = q_field.g_obj_table[new_key]
                if obj and q_field.cache_ability then
                    card._qfield_cache.abilities = card._qfield_cache.abilities or {}
                    card._qfield_cache.abilities[#card._qfield_cache.abilities+1] = {t = copy_table(obj.config) or {}, key = new_key, q_field_key = key}
                end
            end
        end
    end
    return ret
end

-- Todo : Check whether Stone + Wild enhancements need to be taken ownership of to set .any_suit / .no_rank, etc.
-- ! This function cannot support quantum field values; As in, a QUANTUM Stone card will NOT count as 'no_rank=true'.
-- This is necessary because has_no is called in the base_getter -> a loop would be caused if has_no depended on quantum values.
-- Todo : Merge this into the general getter context: base_getter just returns default value = "BASE", if 'no_rank' is returned in getter context, and def val still equals "BASE", remove it.
-- local function _general_quantum_has_no_func(key, card, _args)
--     local other_fields_values = {}
--     for other_key, obj in pairs(SMODS.QuantumCardFields) do
--         if other_key ~= key then
--             other_fields_values[other_key] = obj.get_base_value(card)
--         end
--     end
--     local has_no = false
--     local check_field_no = "no_" + key
--     local check_field_any = "any_" + key
--     for other_key, other_values in pairs(other_fields_values) do
--         local other_field_obj_table = SMODS.QuantumCardFields[other_key].g_obj_table
--         for k, v in pairs(other_values) do
--             if v and other_field_obj_table[k] and other_field_obj_table[k][check_field_no] then
--                 has_no = true
--             end
--             if v and other_field_obj_table[k] and other_field_obj_table[k][check_field_any] then
--                 return false -- 'any' overrules 'no' -> like Wild overruling Stone
--             end
--         end
--     end
--     return has_no
-- end

-- local function _general_quantum_has_any_func(key, card, _args)
--     local other_fields_values = {}
--     for other_key, obj in pairs(SMODS.QuantumCardFields) do
--         if other_key ~= key then
--             other_fields_values[other_key] = obj.getter(card)
--         end
--     end
--     local check_field = "any_" + key
--     for other_key, other_values in pairs(other_fields_values) do
--         local other_field_obj_table = SMODS.QuantumCardFields[other_key].g_obj_table
--         for k, v in pairs(other_values) do
--             if v and other_field_obj_table[k] and other_field_obj_table[k][check_field] then
--                 return true
--             end
--         end
--     end
--     return false
-- end

local function _general_quantum_singular_is_func(key, card, value, _args)
    return SMODS.QuantumCardFields[key].plural_is(card, {[value] = true}, (_args or {}).all, _args)
end

local function _general_quantum_plural_is_func(key, card, values_map, all, ...)
    local field_values = SMODS.QuantumCardFields[key].getter(card, ...)
    local is_wild = SMODS.QuantumCardFields[key].has_any(card, ...)

    for k, _ in pairs(field_values) do
        if values_map[k] then
            if not all then return true end
        else
            if all and not is_wild then return false
            elseif all then is_wild = false end
        end
    end
    return all
end

local function _general_quantum_calculate(key, card, context, effects, ...)
    local values = SMODS.QuantumCardFields[key].getter(card, ...)
    local ret = {}
    -- Todo : insert ret correctly into effects
    for c_key, v in pairs(values) do
        local obj = SMODS.QuantumCardFields[key].g_obj_table[c_key]
        if obj.calculate and type(obj.calculate) == 'function' then
            SMODS.set_context_evaluee(obj) -- Todo : Make sure this doesn't unintentionally skip other card's enhancements/etc
            local o = obj:calculate(self, context)
            if o then
                if not o.card then o.card = self end
                ret[#ret+1] = o
            end
        end
    end
    SMODS.set_context_evaluee(card)
    return ret
end

-- Inject helpers

local function _quantum_field_inject_getter(args, target_objects) 
    local getter_func = args.override_getter or function (self, ...)
        return _general_quantum_getter(self, ...)[args.key + "s"]
    end
    local func_field = "get_" + args.key + "s"
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
    local has_no_func_field = "has_no_" + args.key
    local has_any_func_field = "has_any_" + args.key
    for _, target_obj in ipairs(target_objects) do
        target_obj[has_no_func_field] = has_no_func
        target_obj[has_any_func_field] = has_any_func
    end
    local field_object = SMODS.QuantumCardFields[args.key]
    field_object.has_no = has_no_func
    field_object.has_any = has_any_func
end

local function _quantum_field_inject_is_funcs(args, target_objects) 
    local singular_is_func = function (self, value, ...)
        return _general_quantum_singular_is_func(args.key, self, value, ...)
    end
    local plural_is_func = function (self, values_map, ...)
        return _general_quantum_plural_is_func(args.key, self, values_map, ...)
    end
    local singular_func_field = args.func_prefix + "_" + args.key
    local plural_func_field = args.func_prefix + "_" + args.key + "s"
    for _, target_obj in ipairs(target_objects) do
        target_obj[singular_func_field] = singular_is_func
        target_obj[plural_func_field] = plural_is_func
    end
    local field_object = SMODS.QuantumCardFields[args.key]
    field_object.singular_is = singular_is_func
    field_object.plural_is = plural_is_func
end

local function _quantum_field_inject_calculate(args, target_objects)
    local calculate_func = args.override_calculate or function (self, context, ...)
        return _general_quantum_calculate(args.key, self, context, ...)
    end
    local func_field = "calculate_" + args.key
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
        self.get_context_flag = self.get_context_flag or "get_" + self.key + "s"
        self.has_context_flag = self.has_context_flag or "has_" + self.key
        SMODS.CONTEXT_TYPES[self.key] = self.get_context_flag
        SMODS.amount_return_flags[self.key + "s"] = true
        SMODS.amount_return_flags["no_" + self.key] = true
        SMODS.amount_return_flags["any_" + self.key] = true
    end,
    post_inject_class = function(self)
        
    end,
    cache_ability = nil, -- Whether the _general_quantum_getter should cache the .config table of this qfield's object values into card._qfield_cache.abilities
    base_value_ref = nil, -- e.g. 'base.value' for Rank, 'config.center.key' for Enhancement, ...
    get_base_value = function (self, card) return table_get_subfield(card, self.base_value_ref) end,
    base_getter = function (self, card, _args) 
        return {[self:get_base_value(card)] = "BASE"}
    end
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
    cache_ability = true,
    g_obj_table = G.P_SEALS,
    inject_args = {
        is_func_prefix = "has"
    },
    base_value_ref = "seal"
}

SMODS.QuantumCardField{
    key = "edition",
    cache_ability = true,
    g_obj_table = G.P_CENTERS,
    base_value_ref = "edition.key"
}

-- SMODS.QuantumCardField{
--     key = "suit",
--     g_obj_table = SMODS.Suits,
--     base_value_ref = "base.suit"
-- }

SMODS.QuantumCardField{
    key = "sticker",
    g_obj_table = SMODS.Stickers,
}

-- Todo : Consider adding a SMODS.CardAbilityField class to generalize x_mult/h_x_mult/etc.