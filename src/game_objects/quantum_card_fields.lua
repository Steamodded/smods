local function _general_quantum_getter(key, card, args)
    if not SMODS.optional_features.quantum_fields[key] then 
        return SMODS.QuantumCardFields[key].base_getter(card, args)
    end
    
end

local function _general_quantum_singular_is_func(key, card, args)
    if not SMODS.optional_features.quantum_fields[key] then return end
    
end

local function _general_quantum_plural_is_func(key, card, args)
    if not SMODS.optional_features.quantum_fields[key] then return end
    
end


local function _quantum_field_inject_getter(args) 
    local getter_func = function (self, _args)
        return _general_quantum_getter(args.key, self, _args)
    end
    local func_field = "get_" + args.key + "s"
    Card[func_field] = args.override_getter or getter_func
end

local function _quantum_field_inject_has_funcs(args) 
    local has_no_func = function (card)
        return 
    end
    local has_any_func = function (card)
        return 
    end
    local has_no_func_field = "has_no_" + args.key
    local has_any_func_field = "has_any_" + args.key
    SMODS[has_no_func_field] = args.override_has_no or has_no_func
    SMODS[has_any_func_field] = args.override_has_any or has_any_func
end

local function _quantum_field_inject_is_funcs(args) 
    local singular_is_func = function (self, _args)
        return _general_quantum_singular_is_func(args.key, self, _args)
    end
    local plural_is_func = function (self, _args)
        return _general_quantum_plural_is_func(args.key, self, _args)
    end
    local singular_func_field = args.func_prefix + "_" + args.key
    local plural_func_field = args.func_prefix + "_" + args.key + "s"
    Card[singular_func_field] = singular_is_func
    Card[plural_func_field] = plural_is_func
end

SMODS.QuantumCardFields = {}
SMODS.QuantumCardField = SMODS.GameObject:extend {
    obj_table = SMODS.QuantumCardFields,
    set = 'QuantumCardField',
    obj_buffer = {},
    required_params = {
        'key',
    },
    process_loc_text = function() end,
    inject = function(self)
        local inject_args = self.inject_args or {}
        if not inject_args.no_getter then
            _quantum_field_inject_getter({key = self.key, override_getter = self.override_getter})
        end
        if not inject_args.no_has_funcs then
            _quantum_field_inject_has_funcs({key = self.key, override_has_no = self.override_has_no, override_has_any = self.override_has_any})
        end
        if not inject_args.no_is_func then
            _quantum_field_inject_is_funcs({key = self.key, func_prefix = inject_args.is_func_prefix or "is"})
        end
    end,
    post_inject_class = function(self)
        
    end,
    base_getter = function (card, args) end
}

SMODS.QuantumCardField{
    key = "rank",
}

SMODS.QuantumCardField{
    key = "enhancement",
    inject_args = {
        is_func_prefix = "has"
    }
}

SMODS.QuantumCardField{
    key = "seal",
    inject_args = {
        is_func_prefix = "has"
    }
}

SMODS.QuantumCardField{
    key = "edition",
}

SMODS.QuantumCardField{
    key = "suit",
}
