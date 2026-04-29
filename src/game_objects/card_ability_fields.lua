SMODS.CARD_VALUE_TYPES = {
    ADDITIVE = "additive",
    MULTIPLICATIVE = "multiplicative"
}


-- Helper function to get a card's qfield-cached abilities, or if uncached just card.ability
function SMODS.get_card_abilities(card)
    if (card._qfield_cache or {}).abilities then
        return card._qfield_cache.abilities
    end
    local fallback = card.ability and {{t = card.ability}} or {}
    if not SMODS.set_quantum_cache(card) then return fallback end
    return (card._qfield_cache or {}).abilities or fallback
end


SMODS.CardAbilityFields = {}
SMODS.CardAbilityField = SMODS.GameObject:extend {
    obj_table = SMODS.CardAbilityFields,
    set = 'CardAbilityField',
    obj_buffer = {},
    required_params = {
        'key',
    },
    process_loc_text = function() end,
    inject = function(self)
        local inject_args = self.inject_args or {}
        if not inject_args.no_getter then
            local _getter = function (card, ...)
                local abilities = SMODS.get_card_abilities(card)
                return self:getter(abilities, card, ...)
            end
            Card["get_" .. self.key] = _getter
        end
        self.value_ref = self.value_ref or self.calc_key
        if self.value_ref then
            self.perma_value_ref = self.perma_value_ref or "perma_" .. self.value_ref
        end
        if not self.variant_refs then -- This is used mostly instead of the singular value_ref
            self.variant_refs = {self.value_ref}
        end
        if not self.default_value then
            if self.stacking_type == SMODS.CARD_VALUE_TYPES.ADDITIVE then self.default_value = 0
            elseif self.stacking_type == SMODS.CARD_VALUE_TYPES.MULTIPLICATIVE then self.default_value = 1 end
        end
        self.start_value = self.start_value or self.default_value
        self.value_offset = self.value_offset or 0
    end,
    scoring_card_areas = {
        play = true,
    },
    post_inject_class = function(self) end,
    calc_key = nil, -- e.g. "mult"
    value_ref = nil, -- property path relative to Card.ability, e.g. "x_chips"
    variant_refs = nil, -- list of the above, used for compat with e.g. Xmult / x_mult
    perma_value_ref = nil, -- ^ for permanent bonus
    stacking_type = SMODS.CARD_VALUE_TYPES.ADDITIVE,
    max_value = math.huge,
    min_value = -math.huge,
    start_value = nil,
    default_value = nil,
    value_offset = nil,
    getter = function (self, abilities, card, ...) -- abilities is of form {integer: {t = [ability table], key = [source obj key], qfield_key = [qfield key]}}
        -- if self.debuff then return self.default_value end
        local ret = self.start_value
        for _, ability_t in ipairs(abilities) do
            local ability = ability_t.t
            if self.stacking_type == SMODS.CARD_VALUE_TYPES.ADDITIVE then
                for _, v_ref in ipairs(self.variant_refs) do
                    local v = (table_get_subfield(ability or {}, v_ref) or self.default_value)
                    ret = ret + v + self.value_offset
                    if v ~= (self.default_value + self.value_offset) then break end -- Only apply value once
                end
            elseif self.stacking_type == SMODS.CARD_VALUE_TYPES.MULTIPLICATIVE then
                for _, v_ref in ipairs(self.variant_refs) do
                    local v = (table_get_subfield(ability or {}, v_ref) or self.default_value)
                    ret = ret * (v + self.value_offset)
                    if v ~= (self.default_value + self.value_offset) then break end -- Only apply value once
                end
            end
        end
        if self.stacking_type == SMODS.CARD_VALUE_TYPES.MULTIPLICATIVE then
            local base = (table_get_subfield(card.ability or {}, self.perma_value_ref) or 0)
            ret = ret * (base + 1)
        else
            ret = ret + (table_get_subfield(card.ability or {}, self.perma_value_ref) or 0)
        end
        return ret - self.value_offset
    end,
    insert_value = function (self, card, ret_table, ...)
        local abilities = SMODS.get_card_abilities(card)
        local value = self:getter(abilities, card, ...)
        if self.max_value >= value and value >= self.min_value and value ~= self.default_value then
            ret_table.playing_card = ret_table.playing_card or {}
            ret_table.playing_card[self.calc_key] = value
        end
    end
}

SMODS.CardAbilityField{
    key = "repetitions",
    calc_key = "repetitions",
    scoring_card_areas = {},
    insert_value = function (self, card, ret_table, ...)
        local abilities = SMODS.get_card_abilities(card)
        local reps = self:getter(abilities, card, ...)
        if reps > 0 then
            ret_table.seals = ret_table.seals or { card = card, message = localize('k_again_ex') }
            ret_table.seals.repetitions = (ret_table.seals.repetitions and ret_table.seals.repetitions + reps) or reps
        end
    end
}

SMODS.CardAbilityField{
    key = "chip_bonus",
    calc_key = "chips",
    getter = function(self, abilities, card, ...)
        local base = card.base.nominal or 0
        local ret = 0
        for _, ability_t in ipairs(abilities) do
            local ability = ability_t.t or {}
            if ability.effect == "Stone Card" or ((ability_t.qfield_key and SMODS.QuantumCardFields[ability_t.qfield_key].g_obj_table[ability_t.key] or {}).replace_base_card) then
                base = 0
            end
            ret = ret + (ability.chips or 0) + (ability.bonus or 0)
        end
        return base + ret + (card.ability.perma_chips or 0)
    end
}

SMODS.CardAbilityField{
    key = "chip_mult",
    calc_key = "mult",
    getter = function(self, abilities, card, ...)
        local ret = 0
        for _, ability_t in ipairs(abilities) do
            local ability = ability_t.t or {}
            if ability.effect == "Lucky Card" then
                if SMODS.pseudorandom_probability(card, 'lucky_mult', 1, 5) then
                    card.lucky_trigger = true
                    ret = ret + ability.mult
                end
            else
                ret = ret + (ability.mult or 0)
            end
        end
        return ret + (card.ability.perma_mult or 0)
    end
}

SMODS.CardAbilityField{
    key = "chip_x_mult",
    stacking_type = SMODS.CARD_VALUE_TYPES.MULTIPLICATIVE,
    calc_key = "x_mult",
    variant_refs = {"x_mult", "Xmult"},
}

SMODS.CardAbilityField{
    key = "chip_h_mult",
    calc_key = "h_mult",
    scoring_card_areas = {hand = true},
}

SMODS.CardAbilityField{
    key = "chip_h_x_mult",
    stacking_type = SMODS.CARD_VALUE_TYPES.MULTIPLICATIVE,
    default_value = 0,
    start_value = 1,
    value_offset = 1,
    value_ref = "h_x_mult",
    calc_key = "x_mult",
    scoring_card_areas = {hand = true},
}

SMODS.CardAbilityField{
    key = "chip_x_bonus",
    stacking_type = SMODS.CARD_VALUE_TYPES.MULTIPLICATIVE,
    calc_key = "x_chips",
}

SMODS.CardAbilityField{
    key = "chip_h_bonus",
    calc_key = "h_chips",
    scoring_card_areas = {hand = true},
}

SMODS.CardAbilityField{
    key = "chip_h_x_bonus",
    stacking_type = SMODS.CARD_VALUE_TYPES.MULTIPLICATIVE,
    value_ref = "h_x_chips",
    calc_key = "x_chips",
    scoring_card_areas = {hand = true},
}

SMODS.CardAbilityField{
    key = "h_dollars",
    calc_key = "h_dollars",
    scoring_card_areas = {hand = true},
}

SMODS.CardAbilityField{
    key = "p_dollars",
    calc_key = "p_dollars",
    getter = function (self, abilities, card, ...) 
        local ret = 0
        -- Todo : check if this should even be supported (generic p_dollars is supported via obj.config tables already -> function needed?)
        for key, q_field in pairs(SMODS.QuantumCardFields) do
            local values = q_field.getter(card)
            for k, v in pairs(values) do
                local obj = q_field.g_obj_table[k] or {}
                if obj.get_p_dollars and type(obj.get_p_dollars) == 'function' then
                    ret = ret + obj:get_p_dollars(card)
                end
            end
        end
        if card:has_seal("Gold") then
            ret = ret +  3
        end
        for _, ability_t in ipairs(abilities) do
            local ability = ability_t.t or {}
            if ability.effect == "Lucky Card" then
                if SMODS.pseudorandom_probability(card, 'lucky_money', 1, 15) then
                    card.lucky_trigger = true
                    ret = ret + (ability.p_dollars or 0)
                end
            else
                ret = ret + (ability.p_dollars or 0)
            end
        end
        if ret ~= 0 then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + ret
            G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
        end
        return ret + (card.ability.perma_p_dollars or 0)
    end
}

SMODS.CardAbilityField{
    key = "bonus_score",
    calc_key = "score",
}

SMODS.CardAbilityField{
    key = "bonus_x_score",
    calc_key = "x_score",
    stacking_type = SMODS.CARD_VALUE_TYPES.MULTIPLICATIVE
}

SMODS.CardAbilityField{
    key = "bonus_h_score",
    calc_key = "h_score",
    scoring_card_areas = {hand = true},
}

SMODS.CardAbilityField{
    key = "bonus_h_x_score",
    calc_key = "h_x_score",
    scoring_card_areas = {hand = true},
    stacking_type = SMODS.CARD_VALUE_TYPES.MULTIPLICATIVE
}

SMODS.CardAbilityField{
    key = "bonus_blind_size",
    calc_key = "blind_size",
}

SMODS.CardAbilityField{
    key = "bonus_x_blind_size",
    calc_key = "x_blind_size",
    stacking_type = SMODS.CARD_VALUE_TYPES.MULTIPLICATIVE
}

SMODS.CardAbilityField{
    key = "bonus_h_blind_size",
    value_ref = "h_blind_size",
    calc_key = "blind_size",
    scoring_card_areas = {hand = true},
}

SMODS.CardAbilityField{
    key = "bonus_h_x_blind_size",
    value_ref = "h_x_blind_size",
    calc_key = "x_blind_size",
    scoring_card_areas = {hand = true},
    stacking_type = SMODS.CARD_VALUE_TYPES.MULTIPLICATIVE
}


-- Helper function to get a sanitized ability table
function SMODS.get_ability_from_obj(obj)
    local ability
    local config = obj.config
    if config then
        ability = {}
        for key, ca_field in pairs(SMODS.CardAbilityFields) do
            for _, variant in ipairs(ca_field.variant_refs) do
                if config[variant] then
                    ability[ca_field.value_ref] = config[variant]
                    break
                end
            end
        end
        ability.name = obj.name
        ability.effect = obj.effect
        ability.set = obj.set
        ability.h_size = config.h_size or 0
        ability.d_size = config.d_size or 0
        ability.extra = copy_table(config.extra) or nil
        ability.extra_value = 0
        ability.type = config.type or ''
    end
    return ability
end