-- General helpers

local function _general_quantum_getter(key, card, args)
    local default_values = SMODS.QuantumCardFields[key]:base_getter(card, args) or {}
    if not SMODS.optional_features.quantum_fields[key] then 
        return default_values
    end

    local flags = args.flags or {}
    local context = {["get_" + key + "s"] = true, card = self, [key + "s"] = default_values, no_mod = false}
    for key, flag in pairs(flags) do
        context[key] = flag
    end

    local eval = SMODS.calculate_context(context) or {}

    local ret = {}
    for k, v in pairs(eval[key + "s"]) do
        if v then
            local key = type(k) == "table" and k.key or k
            ret[key] = true
        end
    end

    return ret
end


-- Todo : Check whether Stone + Wild enhancements need to be taken ownership of to set .any_suit / .no_rank, etc.
local function _general_quantum_has_no_func(key, card, _args)
    local other_fields_values = {}
    for other_key, obj in pairs(SMODS.QuantumCardFields) do
        if other_key ~= key then
            other_fields_values[other_key] = obj.getter(card)
        end
    end
    local has_no = false
    local check_field_no = "no_" + key
    local check_field_any = "any_" + key
    for other_key, other_values in pairs(other_fields_values) do
        local other_field_obj_table = SMODS.QuantumCardFields[other_key].g_obj_table
        for k, v in pairs(other_values) do
            if v and other_field_obj_table[k] and other_field_obj_table[k][check_field_no] then
                has_no = true
            end
            if v and other_field_obj_table[k] and other_field_obj_table[k][check_field_any] then
                return false -- 'any' overrules 'no' -> like Wild overruling Stone
            end
        end
    end
    return has_no
end

local function _general_quantum_has_any_func(key, card, _args)
    local other_fields_values = {}
    for other_key, obj in pairs(SMODS.QuantumCardFields) do
        if other_key ~= key then
            other_fields_values[other_key] = obj.getter(card)
        end
    end
    local check_field = "any_" + key
    for other_key, other_values in pairs(other_fields_values) do
        local other_field_obj_table = SMODS.QuantumCardFields[other_key].g_obj_table
        for k, v in pairs(other_values) do
            if v and other_field_obj_table[k] and other_field_obj_table[k][check_field] then
                return true
            end
        end
    end
    return false
end

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

-- Inject helpers

local function _quantum_field_inject_getter(args, target_objects) 
    local getter_func = function (self, ...)
        return _general_quantum_getter(args.key, self, ...)
    end
    local func_field = "get_" + args.key + "s"
    for _, target_obj in ipairs(target_objects) do
        target_obj[func_field] = args.override_getter or getter_func
    end
    local field_object = SMODS.QuantumCardFields[args.key]
    field_object.getter = args.override_getter or getter_func
end

local function _quantum_field_inject_has_funcs(args, target_objects) 
    local has_no_func = function (card, ...)
        return _general_quantum_has_no_func(args.key, card, ...)
    end
    local has_any_func = function (card, ...)
        return _general_quantum_has_any_func(args.key, card, ...)
    end
    local has_no_func_field = "has_no_" + args.key
    local has_any_func_field = "has_any_" + args.key
    for _, target_obj in ipairs(target_objects) do
        target_obj[has_no_func_field] = args.override_has_no or has_no_func
        target_obj[has_any_func_field] = args.override_has_any or has_any_func
    end
    local field_object = SMODS.QuantumCardFields[args.key]
    field_object.has_no = args.override_has_no or has_no_func
    field_object.has_any = args.override_has_any or has_any_func
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
    end,
    post_inject_class = function(self)
        
    end,
    base_value_ref = nil, -- e.g. 'base.value' for Rank, 'config.center.key' for Enhancement
    base_getter = function (self, card, _args) 
        return (self.has_no(card, _args) and {}) or {[table_get_subfield(card, self.base_value_ref)] = true}
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
    g_obj_table = G.P_SEALS,
    inject_args = {
        is_func_prefix = "has"
    },
    base_value_ref = "seal"
}

SMODS.QuantumCardField{
    key = "edition",
    g_obj_table = G.P_CENTERS,
    base_value_ref = "edition.key"
}

SMODS.QuantumCardField{
    key = "suit",
    g_obj_table = SMODS.Suits,
    base_value_ref = "base.suit"
}

SMODS.QuantumCardField{
    key = "sticker",
    g_obj_table = SMODS.Stickers,
}

