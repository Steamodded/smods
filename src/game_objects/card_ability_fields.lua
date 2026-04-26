SMODS.CARD_VALUE_TYPES = {
    ADDITIVE = "additive",
    MULTIPLICATIVE = "multiplicative"
}

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
                local abilities = card._qfield_cache and card._qfield_cache.abilities or {{t = card.ability}}
                return self:getter(abilities, card, ...)
            end
            Card["get_" + self.key] = _getter
        end
        self.value_ref = self.value_ref or self.calc_key
        if self.value_ref then
            self.perma_value_ref = self.perma_value_ref or "perma_" + self.value_ref
        end
    end,
    scoring_card_areas = {
        play = true,
    },
    post_inject_class = function(self) end,
    calc_key = nil, -- e.g. "mult"
    value_ref = nil, -- property path relative to Card.ability, e.g. "x_chips"
    perma_value_ref = nil, -- ^ for permanent bonus
    stacking_type = SMODS.CARD_VALUE_TYPES.ADDITIVE,
    getter = function (self, abilities, card, ...) -- abilities is of form {integer: {t = [ability table], key = [source obj key], qfield_key = [qfield key]}}
        if self.debuff then return 0 end
        local ret = 0
        for _, ability_t in ipairs(abilities) do
            local ability = ability_t.t
            if self.stacking_type == SMODS.CARD_VALUE_TYPES.ADDITIVE then
                ret = ret + table_get_subfield(ability or {}, self.value_ref) or 0
            elseif self.stacking_type == SMODS.CARD_VALUE_TYPES.MULTIPLICATIVE then
                local base = table_get_subfield(ability or {}, self.value_ref) or 0
                ret = SMODS.multiplicative_stacking(ret, base)
            end
        end
        if self.stacking_type == SMODS.CARD_VALUE_TYPES.MULTIPLICATIVE then
            ret = SMODS.multiplicative_stacking(ret, table_get_subfield(card.ability or {}, self.value_ref) or 0)
        else
            ret = ret + table_get_subfield(card.ability or {}, self.perma_value_ref) or 0
        end
        return ret
    end,
    insert_value = function (self, card, ret_table, ...)
        local abilities = card._qfield_cache and card._qfield_cache.abilities or {{t = card.ability}}
        local value = self:getter(abilities, ...)
        ret_table.playing_card = ret_table.playing_card or {}
        ret_table.playing_card[self.calc_key] = value
    end
}


-- Todo : make these use card._qfield_cache.abilities

SMODS.CardAbilityField{
    key = "repetitions",
    calc_key = "repetitions",
    scoring_card_areas = {},
    insert_value = function (self, card, ret_table, ...)
        local abilities = card._qfield_cache and card._qfield_cache.abilities or {{t = card.ability}}
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
        local base = card.base.nominal
        local ret = 0
        for _, ability_t in ipairs(abilities) do
            local ability = ability_t.t or {}
            if ability.effect == "Stone Card" or ((ability_t.qfield_key and SMODS.QuantumCardFields[ability_t.qfield_key].g_obj_table[ability_t.key] or {}).replace_base_card) then
                base = 0
            end
            ret = ret + ability.chips
        end
        return base + ret + card.ability.perma_chips
    end
}

SMODS.CardAbilityField{
    key = "chip_mult",
    calc_key = "mult",
    getter = function(self, abilities, card, ...)
        local ret = 0
        for _, ability_t in ipairs(abilities) do
            local ability = ability_t.t or {}
            if ability.effect == "Lucky Card" and SMODS.pseudorandom_probability(card, 'lucky_mult', 1, 5) then
                card.lucky_trigger = true
                ret = ret + ability.mult
            end
            ret = ret + ability.mult
        end
        return ret + card.ability.perma_mult
    end
}

SMODS.CardAbilityField{
    key = "chip_x_mult",
    stacking_type = SMODS.CARD_VALUE_TYPES.MULTIPLICATIVE,
    calc_key = "x_mult",
}

SMODS.CardAbilityField{
    key = "chip_h_mult",
    calc_key = "h_mult",
    scoring_card_areas = {hand = true},
}

SMODS.CardAbilityField{
    key = "chip_h_x_mult",
    stacking_type = SMODS.CARD_VALUE_TYPES.MULTIPLICATIVE,
    calc_key = "h_x_mult",
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
    calc_key = "h_x_chips",
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
        -- local obj = G.P_SEALS[card.seal] or {}
        -- if obj.get_p_dollars and type(obj.get_p_dollars) == 'function' then
        --     ret = ret + obj:get_p_dollars(card)
        for _, ability_t in ipairs(abilities) do
            local ability = ability_t.t or {}
            if ability_t.key == "Gold" and ability_t.qfield_key == "seal" then
                ret = ret +  3
            end
            if ability.effect == "Lucky Card" and SMODS.pseudorandom_probability(card, 'lucky_money', 1, 15) then
                card.lucky_trigger = true
                ret = ret + ability.p_dollars
            end
            ret = ret + ability.p_dollars
        end
        if ret ~= 0 then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + ret
            G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
        end
        return ret + card.ability.perma_p_dollars
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
    calc_key = "h_blind_size",
    scoring_card_areas = {hand = true},
}

SMODS.CardAbilityField{
    key = "bonus_h_x_blind_size",
    calc_key = "h_x_blind_size",
    scoring_card_areas = {hand = true},
    stacking_type = SMODS.CARD_VALUE_TYPES.MULTIPLICATIVE
}
