SMODS.CalculateEffects = {}
SMODS.CalculateEffect = SMODS.GameObject:extend {
    obj_table = SMODS.CalculateEffects,
    set = 'CalculateEffect',
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
                self.variants[self.variants[i]] = true
                table.remove(self.variants, i)
            end
        end
        self.variants[self.key] = true
    end,
    post_inject_class = function (self)
        table.sort(self.obj_buffer, function (a, b) return SMODS.CalculateEffects[a].order < SMODS.CalculateEffects[b].order end)
    end,
    return_key = nil,
    return_amount = true,
    silent = false,
    default_amount = nil,
    variants = nil,
    calculate = function (self, effect, scored_card, key, amount, from_edition)
        return (self.return_key and key) or (self.return_amount and {[key] = amount}) or nil
    end,
    should_calculate = function (self, amount)
        return amount ~= self.default_amount
    end
}

SMODS.CalculateEffect {
    key = "pre_func",
    order = -10,
    calculate = function (self, effect, scored_card, key, amount, from_edition)
        effect.pre_func()
        return true
    end
}

SMODS.CalculateEffect {
    key = "dollars",
    order = 10,
    variants = { "h_dollars", "p_dollars" },
    calculate = function (self, effect, scored_card, key, amount, from_edition)
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

SMODS.CalculateEffect {
    key = "xscore",
    order = 20,
    variants = { "x_score", "h_x_score", "h_xscore" },
    default_amount = 1,
    calculate = function (self, effect, scored_card, key, amount, from_edition)
        if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
        SMODS.mod_score({ mult = amount, card = effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, effect = effect, from_edition = from_edition })
        return true
    end
}

SMODS.CalculateEffect {
    key = "score",
    order = 30,
    default_amount = 0,
    variants = { "h_score" },
    calculate = function (self, effect, scored_card, key, amount, from_edition)
        if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
        SMODS.mod_score({ add = amount, card = effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, effect = effect, from_edition = from_edition })
        return true
    end
}

SMODS.CalculateEffect {
    key = "xblind_size",
    order = 40,
    default_amount = 1,
    variants = { 'h_xblind_size', 'x_blind_size', 'h_x_blindsize', 'xblindsize', 'h_xblindsize', 'x_blindsize', 'h_x_blindsize' },
    calculate = function (self, effect, scored_card, key, amount, from_edition)
        if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
        SMODS.mod_blind_size({ mult = amount, card = effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, effect = effect, from_edition = from_edition })
        return true
    end
}

SMODS.CalculateEffect {
    key = "blind_size",
    order = 50,
    default_amount = 0,
    variants = { 'h_blind_size', 'blindsize', 'h_blindsize' },
    calculate = function (self, effect, scored_card, key, amount, from_edition)
        if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
        SMODS.mod_blind_size({ add = amount, card = effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, effect = effect, from_edition = from_edition })
        return true
    end
}

SMODS.CalculateEffect {
    key = "message",
    order = 60,
    should_calculate = function (self, amount)
        return not SMODS.no_ressolve
    end,
    calculate = function (self, effect, scored_card, key, amount, from_edition)
        if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
        if effect.retrigger_juice then juice_card(effect.retrigger_juice) end
        card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, effect)
        return true
    end
}

SMODS.CalculateEffect {
    key = "func",
    order = 70,
    silent = true,
    calculate = function (self, effect, scored_card, key, amount, from_edition)
        effect.func()
        return true
    end
}

SMODS.CalculateEffect {
    key = "swap",
    order = 80,
    calculate = function (self, effect, scored_card, key, amount, from_edition)
        if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
        local old_mult = mult
        mult = mod_mult(hand_chips)
        hand_chips = mod_chips(old_mult)
        update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
        juice_card(scored_card)
        return true
    end
}

SMODS.CalculateEffect {
    key = "balance",
    order = 90,
    calculate = function (self, effect, scored_card, key, amount, from_edition)
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

SMODS.CalculateEffect {
    key = "level_up",
    order = 100,
    calculate = function (self, effect, scored_card, key, amount, from_edition)
        if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
        local hand_type = effect.level_up_hand or G.GAME.last_hand_played
        SMODS.smart_level_up_hand(scored_card, hand_type, effect.instant, amount)
        return true
    end
}

SMODS.CalculateEffect {
    key = "extra",
    order = 110,
    silent = true,
    calculate = function (self, effect, scored_card, key, amount, from_edition)
        return SMODS.calculate_effect(amount, scored_card)
    end
}

SMODS.CalculateEffect {
    key = "saved",
    order = 120,
    silent = true,
    calculate = function (self, effect, scored_card, key, amount, from_edition)
        SMODS.saved = amount
        G.GAME.saved_text = amount
        return self.key
    end
}

SMODS.CalculateEffect {
    key = "effect",
    order = 130,
    silent = true,
    calculate = function (self, effect, scored_card, key, amount, from_edition)
        return true
    end
}

--#region key_return_flags
SMODS.CalculateEffect {
    key = "prevent_debuff",
    order = 140,
    silent = true,
    return_key = true,
}

SMODS.CalculateEffect {
    key = "add_to_hand",
    order = 150,
    silent = true,
    return_key = true,
}

SMODS.CalculateEffect {
    key = "remove_from_hand",
    order = 160,
    silent = true,
    return_key = true,
}

SMODS.CalculateEffect {
    key = "return_to_hand",
    order = 170,
    silent = true,
    return_key = true,
}

SMODS.CalculateEffect {
    key = "stay_flipped",
    order = 180,
    silent = true,
    return_key = true,
}

SMODS.CalculateEffect {
    key = "prevent_stay_flipped",
    order = 190,
    silent = true,
    return_key = true,
}

SMODS.CalculateEffect {
    key = "prevent_trigger",
    order = 200,
    return_key = true,
}
--#endregion

SMODS.CalculateEffect {
    key = "modify",
    order = 210,
    calculate = function (self, effect, scored_card, key, amount, from_edition)
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
    end
}

--#region amount_return_flags
SMODS.CalculateEffect {
    key = "remove",
    order = 220,
    silent = true,
}

SMODS.CalculateEffect {
    key = "debuff_text",
    order = 230,
    silent = true,
}

SMODS.CalculateEffect {
    key = "cards_to_draw",
    order = 240,
    silent = true,
}

SMODS.CalculateEffect {
    key = "numerator",
    order = 250,
    silent = true,
}

SMODS.CalculateEffect {
    key = "denominator",
    order = 260,
    silent = true,
}

SMODS.CalculateEffect {
    key = "no_destroy",
    order = 270,
    silent = true,
}

SMODS.CalculateEffect {
    key = "replace_scoring_name",
    order = 280,
}

SMODS.CalculateEffect {
    key = "replace_display_name",
    order = 290,
}

SMODS.CalculateEffect {
    key = "replace_poker_hands",
    order = 300,
}

SMODS.CalculateEffect {
    key = "override",
    order = 310,
}

SMODS.CalculateEffect {
    key = "shop_create_flags",
    order = 320,
}

SMODS.CalculateEffect {
    key = "booster_create_flags",
    order = 330,
}

SMODS.CalculateEffect {
    key = "override_value",
    order = 340,
}

SMODS.CalculateEffect {
    key = "override_scalar_value",
    order = 350,
}

SMODS.CalculateEffect {
    key = "override_scalar",
    order = 360,
}

SMODS.CalculateEffect {
    key = "override_reset_value",
    order = 370,
}

SMODS.CalculateEffect {
    key = "override_message",
    order = 380,
}

SMODS.CalculateEffect {
    key = "post",
    order = 390,
}
--#endregion

SMODS.CalculateEffect {
    key = "debuff",
    order = 400,
    silent = true,
    calculate = function (self, effect, scored_card, key, amount, from_edition)
        return { [self.key] = amount, debuff_source = scored_card }
    end
}
