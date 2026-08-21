SMODS.add_round_eval_row = function(args)
    args = args or {}
    local width = G.round_eval.T.w - 0.51
    local scale = 0.9

    if not args.bypass_row_limit then
        total_cashout_rows = (total_cashout_rows or 0) + 1
        if total_cashout_rows > 7 then
            return
        end
    end

    if not args.bypass_divider and not G.round_eval.divider_added then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.25,
            func = function()
                local spacer = {
                    n = G.UIT.R,
                    config = { align = "cm", minw = width },
                    nodes = {
                        { n = G.UIT.O, config = { object = DynaText({ string = { '......................................' }, colours = { G.C.WHITE }, shadow = true, float = true, y_offset = -30, scale = 0.45, spacing = 13.5, font = G.LANGUAGES['en-us'].font, pop_in = 0 }) } }
                    }
                }
                G.round_eval:add_child(spacer,
                    G.round_eval:get_UIE_by_ID(args.bonus and 'bonus_round_eval' or 'base_round_eval'))
                return true
            end
        }))
        delay(0.6)
        G.round_eval.divider_added = true
    end


    delay(0.2)

    G.E_MANAGER:add_event(Event({
        trigger = 'before',
        delay = 0.5,
        func = function()
            --Add the far left text and context first:
            local left_text = {}
            if args.name == 'blind1' then
                local stake_sprite = get_stake_sprite(G.GAME.stake or 1, 0.5)
                local obj = G.GAME.blind.config.blind
                local blind_sprite = SMODS.create_sprite(0, 0, 1.2, 1.2, obj.atlas or 'blind_chips',
                    copy_table(G.GAME.blind.pos), obj.sprite_args)
                blind_sprite:define_draw_steps({
                    { shader = 'dissolve', shadow_height = 0.05 },
                    { shader = 'dissolve' }
                })
                table.insert(left_text,
                    { n = G.UIT.O, config = { w = 1.2, h = 1.2, object = blind_sprite, hover = true, can_collide = false } })

                table.insert(left_text,
                    args.saved and
                    {
                        n = G.UIT.C,
                        config = { padding = 0.05, align = 'cm' },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = 'cm' },
                                nodes = {
                                    { n = G.UIT.O, config = { object = DynaText({ string = { ' ' .. (type(G.GAME.saved_text) == 'string' and (G.localization.misc.dictionary[G.GAME.saved_text] and localize(G.GAME.saved_text) or G.GAME.saved_text) or localize('ph_mr_bones')) .. ' ' }, colours = { G.C.FILTER }, shadow = true, pop_in = 0, scale = 0.5 * scale, silent = true }) } }
                                }
                            }
                        }
                    }
                    or {
                        n = G.UIT.C,
                        config = { padding = 0.05, align = 'cm' },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = 'cm' },
                                nodes = {
                                    { n = G.UIT.O, config = { object = DynaText({ string = { ' ' .. localize('ph_score_at_least') .. ' ' }, colours = { G.C.UI.TEXT_LIGHT }, shadow = true, pop_in = 0, scale = 0.4 * scale, silent = true }) } }
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { align = 'cm', minh = 0.8 },
                                nodes = {
                                    { n = G.UIT.O, config = { w = 0.5, h = 0.5, object = stake_sprite, hover = true, can_collide = false } },
                                    { n = G.UIT.T, config = { text = G.GAME.blind.chip_text, scale = scale_number(G.GAME.blind.chips, scale, 100000), colour = G.C.RED, shadow = true } }
                                }
                            }
                        }
                    })
            elseif string.find(args.name, 'tag') then
                local blind_sprite = SMODS.create_sprite(0, 0, 0.7, 0.7, 'tags', copy_table(args.pos))
                blind_sprite:define_draw_steps({
                    { shader = 'dissolve', shadow_height = 0.05 },
                    { shader = 'dissolve' }
                })
                blind_sprite:juice_up()
                table.insert(left_text,
                    { n = G.UIT.O, config = { w = 0.7, h = 0.7, object = blind_sprite, hover = true, can_collide = false } })
                table.insert(left_text,
                    { n = G.UIT.O, config = { object = DynaText({ string = { args.condition }, colours = { G.C.UI.TEXT_LIGHT }, shadow = true, pop_in = 0, scale = 0.4 * scale, silent = true }) } })
            elseif args.name == 'hands' then
                table.insert(left_text,
                    { n = G.UIT.T, config = { text = args.disp or args.dollars, scale = 0.8 * scale, colour = G.C.BLUE, shadow = true, juice = true } })
                table.insert(left_text,
                    { n = G.UIT.O, config = { object = DynaText({ string = { " " .. localize { type = 'variable', key = 'remaining_hand_money', vars = { G.GAME.modifiers.money_per_hand or 1 } } }, colours = { G.C.UI.TEXT_LIGHT }, shadow = true, pop_in = 0, scale = 0.4 * scale, silent = true }) } })
            elseif args.name == 'discards' then
                table.insert(left_text,
                    { n = G.UIT.T, config = { text = args.disp or args.dollars, scale = 0.8 * scale, colour = G.C.RED, shadow = true, juice = true } })
                table.insert(left_text,
                    { n = G.UIT.O, config = { object = DynaText({ string = { " " .. localize { type = 'variable', key = 'remaining_discard_money', vars = { G.GAME.modifiers.money_per_discard or 0 } } }, colours = { G.C.UI.TEXT_LIGHT }, shadow = true, pop_in = 0, scale = 0.4 * scale, silent = true }) } })
            elseif string.find(args.name, 'custom') then
                if args.number then
                    table.insert(left_text,
                        { n = G.UIT.T, config = { text = args.number, scale = args.number_scale or 0.8 * scale, colour = args.number_colour or G.C.FILTER, shadow = true, juice = true } })
                end
                table.insert(left_text,
                    { n = G.UIT.O, config = { object = DynaText({ string = { "" .. args.text }, colours = { args.text_colour or G.C.UI.TEXT_LIGHT }, shadow = true, pop_in = 0, scale = args.text_scale or 0.4 * scale, silent = true }) } })
            elseif string.find(args.name, 'joker') and JoyousSpring and JoyousSpring.is_monster_card(args.card) then
                local joy_loc_string = localize { type = 'name_text', set = args.card.config.center.set, key = args.card.config.center.key }
                table.insert(left_text,
                    { n = G.UIT.O, config = { object = DynaText({ string = joy_loc_string, colours = { JoyousSpring.get_name_color(args.card.config.center.key) or G.C.JOY.NORMAL }, shadow = true, pop_in = 0, scale = (0.6 * scale) - 0.006 * #joy_loc_string, silent = true }) } })
            elseif string.find(args.name, 'joker') then
                local loc_opts = args.loc_opts or {}
                local vars = loc_opts.vars
                if not vars and type(args.card.config.center.loc_vars) == "function" then
                    local res = args.card.config.center:loc_vars({}, args.card)
                    vars = res.name_vars or res.vars or {}
                end
                table.insert(left_text,
                    { n = G.UIT.O, config = { object = DynaText({ string = loc_opts.text or localize { type = 'name_text', set = loc_opts.set or args.card.config.center.set, key = loc_opts.key or args.card.config.center.key, vars = vars }, colours = { loc_opts.text_colour or G.C.FILTER }, shadow = true, pop_in = 0, scale = (loc_opts.scale or 0.6) * scale, silent = true }) } })
            elseif args.name == 'interest' then
                table.insert(left_text,
                    { n = G.UIT.T, config = { text = num_dollars, scale = 0.8 * scale, colour = G.C.MONEY, shadow = true, juice = true } })
                table.insert(left_text,
                    { n = G.UIT.O, config = { object = DynaText({ string = { " " .. localize { type = 'variable', key = 'interest', vars = { G.GAME.interest_amount, 5, G.GAME.interest_amount * G.GAME.interest_cap / 5 } } }, colours = { G.C.UI.TEXT_LIGHT }, shadow = true, pop_in = 0, scale = 0.4 * scale, silent = true }) } })
            end
            local full_row = {
                n = G.UIT.R,
                config = { align = "cm", minw = 5 },
                nodes = {
                    { n = G.UIT.C, config = { padding = 0.05, minw = width * 0.55, minh = 0.61, align = "cl" }, nodes = left_text },
                    { n = G.UIT.C, config = { padding = 0.05, minw = width * 0.45, align = "cr" },              nodes = { { n = G.UIT.C, config = { align = "cm", id = 'dollar_' .. args.name }, nodes = {} } } }
                }
            }

            if args.name == 'blind1' then
                G.GAME.blind:juice_up()
            end
            G.round_eval:add_child(full_row,
                G.round_eval:get_UIE_by_ID(args.bonus and 'bonus_round_eval' or 'base_round_eval'))
            play_sound('cancel', args.pitch or 1)
            play_sound('highlight1', (1.5 * args.pitch) or 1, 0.2)
            if args.card then args.card:juice_up(0.7, 0.46) end
            return true
        end
    }))
    local dollar_row = 0
    if num_dollars > 60 or num_dollars < -60 then
        if num_dollars < 0 then --if negative
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.38,
                func = function()
                    G.round_eval:add_child(
                        {
                            n = G.UIT.R,
                            config = { align = "cm", id = 'dollar_row_' .. (dollar_row + 1) .. '_' .. args.name },
                            nodes = {
                                { n = G.UIT.O, config = { object = DynaText({ string = { localize('$') .. format_ui_value(num_dollars) }, colours = { G.C.RED }, shadow = true, pop_in = 0, scale = 0.65, float = true }) } }
                            }
                        },
                        G.round_eval:get_UIE_by_ID('dollar_' .. args.name))
                    play_sound('coin3', 0.9 + 0.2 * math.random(), 0.7)
                    play_sound('coin6', 1.3, 0.8)
                    return true
                end
            }))
        else --if positive
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.38,
                func = function()
                    G.round_eval:add_child(
                        {
                            n = G.UIT.R,
                            config = { align = "cm", id = 'dollar_row_' .. (dollar_row + 1) .. '_' .. args.name },
                            nodes = {
                                { n = G.UIT.O, config = { object = DynaText({ string = { localize('$') .. format_ui_value(num_dollars) }, colours = { G.C.MONEY }, shadow = true, pop_in = 0, scale = 0.65, float = true }) } }
                            }
                        },
                        G.round_eval:get_UIE_by_ID('dollar_' .. args.name))

                    play_sound('coin3', 0.9 + 0.2 * math.random(), 0.7)
                    play_sound('coin6', 1.3, 0.8)
                    return true
                end
            }))
            --asdf
        end
    else
        local dollars_to_loop
        if num_dollars < 0 then dollars_to_loop = (num_dollars * -1) + 1 else dollars_to_loop = num_dollars end
        for i = 1, dollars_to_loop do
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.18 - ((num_dollars > 20 and 0.13) or (num_dollars > 9 and 0.1) or 0),
                func = function()
                    if i % 30 == 1 then
                        G.round_eval:add_child(
                            { n = G.UIT.R, config = { align = "cm", id = 'dollar_row_' .. (dollar_row + 1) .. '_' .. args.name }, nodes = {} },
                            G.round_eval:get_UIE_by_ID('dollar_' .. args.name))
                        dollar_row = dollar_row + 1
                    end

                    local r
                    if i == 1 and num_dollars < 0 then
                        r = { n = G.UIT.T, config = { text = '-', colour = G.C.RED, scale = ((num_dollars < -20 and 0.28) or (num_dollars < -9 and 0.43) or 0.58), shadow = true, hover = true, can_collide = false, juice = true } }
                        play_sound('coin3', 0.9 + 0.2 * math.random(), 0.7 - (num_dollars < -20 and 0.2 or 0))
                    else
                        if num_dollars < 0 then
                            r = { n = G.UIT.T, config = { text = localize('$'), colour = G.C.RED, scale = ((num_dollars > 20 and 0.28) or (num_dollars > 9 and 0.43) or 0.58), shadow = true, hover = true, can_collide = false, juice = true } }
                        else
                            r = { n = G.UIT.T, config = { text = localize('$'), colour = G.C.MONEY, scale = ((num_dollars > 20 and 0.28) or (num_dollars > 9 and 0.43) or 0.58), shadow = true, hover = true, can_collide = false, juice = true } }
                        end
                    end
                    play_sound('coin3', 0.9 + 0.2 * math.random(), 0.7 - (num_dollars > 20 and 0.2 or 0))

                    if args.name == 'blind1' then
                        G.GAME.current_round.dollars_to_be_earned = G.GAME.current_round.dollars_to_be_earned:sub(2)
                    end

                    G.round_eval:add_child(r, G.round_eval:get_UIE_by_ID('dollar_row_' ..
                        (dollar_row) .. '_' .. args.name))
                    G.VIBRATION = G.VIBRATION + 0.4
                    return true
                end
            }))
        end
    end
end
