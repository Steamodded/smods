SMODS.CalculationEffects = {}
SMODS.CalculationEffectVariants = {} -- Only used for overlap checking when injecting
SMODS.CalculationEffect = SMODS.GameObject:extend {
    obj_table = SMODS.CalculationEffects,
    set = 'CalculationEffect',
    obj_buffer = {},
    required_params = {
        'key', 
        'order',
    },
    prefix_config = { key = false },
    process_loc_text = function() end,
    inject = function(self)
        self.key = string.lower(self.key)
        self.variants = self.variants or {}
        if self.variants[1] then
            for i=#self.variants, 1, -1 do
                local variant = self.variants[i]
                self.variants[variant] = true
                table.remove(self.variants, i)
            end
        end
        self.variants[self.key] = true
        for variant, _ in pairs(self.variants) do
            assert(not(SMODS.CalculationEffectVariants[variant]), ("SMODS.CalculationEffect '%s' injected with overlapping variant '%s'"):format(self.key, variant))
            SMODS.CalculationEffectVariants[variant] = true
        end
    end,
    post_inject_class = function (self)
        table.sort(self.obj_buffer, function (a, b) return SMODS.CalculationEffects[a].order < SMODS.CalculationEffects[b].order end)
    end,
    default_return = "amount", -- "amount"|"key"
    silent = false,
    variants = nil,
    func = function (self, effect, scored_card, key, amount, from_edition)
        if self.default_return == "key" then
            return key
        elseif self.default_return == "amount" then
            return {[key] = amount}
        end
        return nil
    end,
    check_context_flags = function (self, context, flags)
        for variant, _ in pairs(self.variants) do
            if flags[variant] then
                return true
            end
        end
        return false
    end,
    update_context_flags = nil, -- function (self, context, flags) end
}

SMODS.CalculationEffect {
    key = "pre_func",
    order = -10,
    func = function (self, effect, scored_card, key, amount, from_edition)
        effect.pre_func()
        return true
    end
}

SMODS.CalculationEffect {
    key = "dollars",
    order = 10,
    variants = { "h_dollars", "p_dollars" },
    func = function (self, effect, scored_card, key, amount, from_edition)
        if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
        SMODS.ease_dollars_calc = true
        local initial_dollars = G.GAME.dollars
        SMODS.dollars_changed = amount
        ease_dollars(amount, effect.instant)
        local final_amt = SMODS.dollars_changed
        SMODS.ease_dollars_calc = nil
        if not effect.remove_default_message then
            if effect.dollar_message then
                card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, effect.dollar_message)
            else
                card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'dollars', final_amt, percent)
            end
        end
        SMODS.calculate_context({
            money_altered = true,
            amount = final_amt,
            initial = initial_dollars,
            from_shop = (G.STATE == G.STATES.SHOP or G.STATE == G.STATES.SMODS_BOOSTER_OPENED or G.STATE == G.STATES.SMODS_REDEEM_VOUCHER) or nil,
            from_consumeable = (G.STATE == G.STATES.PLAY_TAROT) or nil,
            from_scoring = (G.STATE == G.STATES.HAND_PLAYED) or nil,
            from_cashout = SMODS.money_from_cashout or nil,
        })
        return true
    end
}


SMODS.CalculationEffect {
    key = "score",
    order = 20,
    variants = { "h_score" },
    func = function (self, effect, scored_card, key, amount, from_edition)
        if amount ~= 0 then
            if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
            SMODS.mod_score({ add = amount, card = effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, effect = effect, from_edition = from_edition })
            return true
        end
    end
}

SMODS.CalculationEffect {
    key = "xscore",
    order = 30,
    variants = { "x_score", "h_x_score", "h_xscore" },
    func = function (self, effect, scored_card, key, amount, from_edition)
        if amount ~= 1 then
            if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
            SMODS.mod_score({ mult = amount, card = effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, effect = effect, from_edition = from_edition })
            return true
        end
    end
}

SMODS.CalculationEffect {
    key = "blind_size",
    order = 40,
    variants = { 'h_blind_size', 'blindsize', 'h_blindsize' },
    func = function (self, effect, scored_card, key, amount, from_edition)
        if amount ~= 0 then
            if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
            SMODS.mod_blind_size({ add = amount, card = effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, effect = effect, from_edition = from_edition })
            return true
        end
    end
}

SMODS.CalculationEffect {
    key = "xblind_size",
    order = 50,
    variants = { 'h_xblind_size', 'x_blind_size', 'h_x_blindsize', 'xblindsize', 'h_xblindsize', 'x_blindsize', 'h_x_blindsize' },
    func = function (self, effect, scored_card, key, amount, from_edition)
        if amount ~= 1 then
            if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
            SMODS.mod_blind_size({ mult = amount, card = effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, effect = effect, from_edition = from_edition })
            return true
        end
    end
}

SMODS.CalculationEffect {
    key = "message",
    order = 60,
    func = function (self, effect, scored_card, key, amount, from_edition)
        if not SMODS.no_resolve then
            if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
            if effect.retrigger_juice then juice_card(effect.retrigger_juice) end
            card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, effect)
            return true
        end
    end
}

SMODS.CalculationEffect {
    key = "func",
    order = 70,
    silent = true,
    func = function (self, effect, scored_card, key, amount, from_edition)
        effect.func()
        return true
    end
}

SMODS.CalculationEffect {
    key = "swap",
    order = 80,
    func = function (self, effect, scored_card, key, amount, from_edition)
        if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
        local old_mult = mult
        mult = mod_mult(hand_chips)
        hand_chips = mod_chips(old_mult)
        update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
        juice_card(scored_card)
        return true
    end
}

SMODS.CalculationEffect {
    key = "balance",
    order = 90,
    func = function (self, effect, scored_card, key, amount, from_edition)
        if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
        local total = mult + hand_chips
        mult = mod_mult(total/2)
        hand_chips = mod_chips(total/2)
        update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
        G.E_MANAGER:add_event(Event({
            func = (function()
                -- scored_card:juice_up()
                play_sound('gong', 0.94, 0.3)
                play_sound('gong', 0.94*1.5, 0.2)
                play_sound('tarot1', 1.5)
                ease_colour(G.C.UI_CHIPS, {0.8, 0.45, 0.85, 1})
                ease_colour(G.C.UI_MULT, {0.8, 0.45, 0.85, 1})
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    blockable = false,
                    blocking = false,
                    delay =  0.8,
                    func = (function()
                            ease_colour(G.C.UI_CHIPS, G.C.BLUE, 0.8)
                            ease_colour(G.C.UI_MULT, G.C.RED, 0.8)
                        return true
                    end)
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    blockable = false,
                    blocking = false,
                    no_delete = true,
                    delay =  1.3,
                    func = (function()
                        G.C.UI_CHIPS[1], G.C.UI_CHIPS[2], G.C.UI_CHIPS[3], G.C.UI_CHIPS[4] = G.C.BLUE[1], G.C.BLUE[2], G.C.BLUE[3], G.C.BLUE[4]
                        G.C.UI_MULT[1], G.C.UI_MULT[2], G.C.UI_MULT[3], G.C.UI_MULT[4] = G.C.RED[1], G.C.RED[2], G.C.RED[3], G.C.RED[4]
                        return true
                    end)
                }))
                return true
            end)
        }))
        if not effect.remove_default_message then
            if effect.balance_message then
                card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, effect.balance_message)
            else
                card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, {message = localize('k_balanced'), colour =  {0.8, 0.45, 0.85, 1}})
            end
        end
        delay(0.6)
        
        return true
    end
}

SMODS.CalculationEffect {
    key = "level_up",
    order = 100,
    func = function (self, effect, scored_card, key, amount, from_edition)
        if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
        local hand_type = effect.level_up_hand or G.GAME.last_hand_played
        SMODS.smart_level_up_hand(scored_card, hand_type, effect.instant, amount)
        return true
    end
}

SMODS.CalculationEffect {
    key = "extra",
    order = 400,
    silent = true,
    func = function (self, effect, scored_card, key, amount, from_edition)
        return SMODS.calculate_effect(amount, scored_card)
    end
}

SMODS.CalculationEffect {
    key = "saved",
    order = 120,
    silent = true,
    func = function (self, effect, scored_card, key, amount, from_edition)
        SMODS.saved = amount
        G.GAME.saved_text = amount
        return self.key
    end,
    update_context_flags = function (self, context, flags)
        context.game_over = false
    end
}

SMODS.CalculationEffect {
    key = "effect",
    order = 130,
    silent = true,
    func = function (self, effect, scored_card, key, amount, from_edition)
        return true
    end
}

--#region key_return_flags
SMODS.CalculationEffect {
    key = "prevent_debuff",
    order = 140,
    silent = true,
    default_return = "key",
}

SMODS.CalculationEffect {
    key = "add_to_hand",
    order = 150,
    silent = true,
    default_return = "key",
}

SMODS.CalculationEffect {
    key = "remove_from_hand",
    order = 160,
    silent = true,
    default_return = "key",
}

SMODS.CalculationEffect {
    key = "return_to_hand",
    order = 170,
    silent = true,
    default_return = "key",
}

SMODS.CalculationEffect {
    key = "stay_flipped",
    order = 180,
    silent = true,
    default_return = "key",
}

SMODS.CalculationEffect {
    key = "prevent_stay_flipped",
    order = 190,
    silent = true,
    default_return = "key",
}

SMODS.CalculationEffect {
    key = "prevent_trigger",
    order = 200,
    default_return = "key",
}
--#endregion

SMODS.CalculationEffect {
    key = "modify",
    order = 210,
    func = function (self, effect, scored_card, key, amount, from_edition)
        if SMODS.context_stack[#SMODS.context_stack].context.modify_final_cashout then
            if effect.cashout_row then
                effect.cashout_row.bonus = true
                effect.cashout_row.pitch = SMODS.cashout_pitch
                effect.cashout_row.dollars = effect.cashout_row.dollars or amount
                add_round_eval_row(effect.cashout_row)
            else
                add_round_eval_row({dollars = amount, bonus = true, name='joker'..SMODS.cashout_index, pitch = SMODS.cashout_pitch, card = scored_card})
            end
        end
        return {[self.key] = amount}
    end,
    update_context_flags = function (self, context, flags)
        if context.modify_ante then context.modify_ante = flags.modify end
        if context.drawing_cards then context.amount = math.max(flags.modify, 0) end
        if context.modify_final_cashout then
            context.amount = flags.modify + (not flags.override and context.amount)
            SMODS.cashout_dollars = context.amount
            SMODS.cashout_index = SMODS.cashout_index + 1
            SMODS.cashout_pitch = SMODS.cashout_pitch + 0.06
            flags.modify = nil
        end
    end
}

--#region amount_return_flags
SMODS.CalculationEffect {
    key = "remove",
    order = 220,
    silent = true,
}

SMODS.CalculationEffect {
    key = "debuff_text",
    order = 230,
    silent = true,
}

SMODS.CalculationEffect {
    key = "cards_to_draw",
    order = 240,
    silent = true,
    update_context_flags = function (self, context, flags)
        context.amount = flags.cards_to_draw
    end
}

SMODS.CalculationEffect {
    key = "numerator",
    order = 250,
    silent = true,
    update_context_flags = function (self, context, flags)
        context.numerator = flags.numerator
    end
}

SMODS.CalculationEffect {
    key = "denominator",
    order = 260,
    silent = true,
    update_context_flags = function (self, context, flags)
        context.denominator = flags.denominator
    end
}

SMODS.CalculationEffect {
    key = "no_destroy",
    order = 270,
    silent = true,
}

SMODS.CalculationEffect {
    key = "replace_scoring_name",
    order = 280,
    check_context_flags = function (self, context, flags) 
        return context.evaluate_poker_hand and SMODS.CalculationEffect.check_context_flags(self, context, flags)
    end,
    update_context_flags = function (self, context, flags)
        context.scoring_name = flags.replace_scoring_name
        context.display_name = flags.replace_scoring_name
    end
}

SMODS.CalculationEffect {
    key = "replace_display_name",
    order = 290,
    check_context_flags = function (self, context, flags) 
        return context.evaluate_poker_hand and SMODS.CalculationEffect.check_context_flags(self, context, flags)
    end,
    update_context_flags = function (self, context, flags)
        context.poker_hands = flags.replace_poker_hands
    end
}

SMODS.CalculationEffect {
    key = "replace_poker_hands",
    order = 300,
    check_context_flags = function (self, context, flags) 
        return context.evaluate_poker_hand and SMODS.CalculationEffect.check_context_flags(self, context, flags)
    end,
    update_context_flags = function (self, context, flags)
        context.scoring_name = flags.replace_scoring_name
        context.display_name = flags.replace_scoring_name
    end
}

SMODS.CalculationEffect {
    key = "override",
    order = 310,
}

SMODS.CalculationEffect {
    key = "shop_create_flags",
    order = 320,
}

SMODS.CalculationEffect {
    key = "booster_create_flags",
    order = 330,
}

SMODS.CalculationEffect {
    key = "override_value",
    order = 340,
    variants = { "override_reset_value" },
    check_context_flags = function (self, context, flags) 
        return (context.scaling_card or context.resetting_card) and SMODS.CalculationEffect.check_context_flags(self, context, flags)
    end,
    update_context_flags = function (self, context, flags)
        local relev = context.scaling_card and "value" or "reset_value"
        local override_value = flags.override_value or flags.override_reset_value
        if not context.block_overrides.value then
            if type(override_value) == 'table' then
                context[relev] = override_value.value or (context.scaling_card and context.value) or nil
                SMODS.calculate_effect(override_value, flags.scored_card)
            else
                context[relev] = override_value
            end
        end
        flags.override_value = nil
    end
}

SMODS.CalculationEffect {
    key = "override_scalar",
    order = 350,
    variants = { "override_scalar_value" },
    check_context_flags = function (self, context, flags) 
        return context.scaling_card and SMODS.CalculationEffect.check_context_flags(self, context, flags)
    end,
    update_context_flags = function (self, context, flags)
        if not context.block_overrides.scalar then
            local override_scalar = flags.override_scalar_value or flags.override_scalar
            if type(override_scalar) == 'table' then
                context.scalar = override_scalar.value or context.scalar
                SMODS.calculate_effect(override_scalar, flags.scored_card)
            else
                context.scalar = override_scalar
            end
        end
        flags.override_scalar, flags.override_scalar_value = nil, nil
    end
}

SMODS.CalculationEffect {
    key = "override_message",
    order = 370,
    check_context_flags = function (self, context, flags) 
        return (context.scaling_card or context.resetting_card) and SMODS.CalculationEffect.check_context_flags(self, context, flags)
    end,
    update_context_flags = function (self, context, flags)
        if not context.block_overrides.message then
            if context.scaling_card then
                context.scaling_message = SMODS.merge_defaults(flags.override_message, context.scaling_message)
            elseif context.resetting_card then
                context.reset_message = SMODS.merge_defaults(flags.override_message, context.reset_message)
            end
        end
        flags.override_message = nil
    end
}

SMODS.CalculationEffect {
    key = "post",
    order = 380,
    check_context_flags = function (self, context, flags) 
        return (context.scaling_card or context.resetting_card) and SMODS.CalculationEffect.check_context_flags(self, context, flags)
    end,
    update_context_flags = function (self, context, flags)
        flags.post.source = flags.scored_card
        flags.post_effects = flags.post_effects or {}
        table.insert(flags.post_effects, flags.post)
        flags.post = nil
    end
}
--#endregion

SMODS.CalculationEffect {
    key = "debuff",
    order = 390,
    silent = true,
    func = function (self, effect, scored_card, key, amount, from_edition)
        return { [self.key] = amount, debuff_source = scored_card }
    end
}
