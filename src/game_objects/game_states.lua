SMODS.STATES = {
    BOOSTER_OPENED = "BOOSTER_OPENED",
    REDEEM_VOUCHER = "REDEEM_VOUCHER",
    USE_CONSUMABLE = "USE_CONSUMABLE",
    SHOP = "SHOP",
    ROUND_EVAL = "ROUND_EVAL",
    BLIND = "BLIND",
    BLIND_SELECT = "BLIND_SELECT"
}
SMODS.default_state = SMODS.STATES.BLIND_SELECT

SMODS.state_stack = {}

function SMODS.get_current_state()
    return #SMODS.state_stack > 0 and SMODS.state_stack[#SMODS.state_stack]
end

function SMODS.push_to_state_stack(state, args)
    table.insert(SMODS.state_stack, {state=state, args=args})
end

function SMODS.pop_from_state_stack(state, pop_duplicate)
    if #SMODS.state_stack < 1 then return end
    pop_duplicate = pop_duplicate == nil or pop_duplicate
    local index = #SMODS.state_stack
    while index > 0 and SMODS.state_stack[index].state == state do
        table.remove(SMODS.state_stack, index)
        index = index - 1
        if not pop_duplicate then
            index = 0
        end
    end
end

function SMODS.get_next_held_state(allow_duplicate)
    local index = #SMODS.state_stack - 1
    while index > 0 and SMODS.state_stack[index].state ~= SMODS.STATE do
        if allow_duplicate or SMODS.state_stack[index].state ~= SMODS.STATE then
            return SMODS.state_stack[index].state
        end
        index = index - 1
    end
    return nil
end

function SMODS.get_state_stack_index(state, exclude_latest)
    for i, state_table in ipairs(SMODS.state_stack) do
        if exclude_latest and i == #SMODS.state_stack then
            return nil
        end
        if state_table.state == state then
            return i
        end
    end
    return nil
end

function SMODS.clear_state_stack()
    SMODS.state_stack = {}
end

function SMODS.enter_state(new_state, enter_args, exit_args)
    local current_state = SMODS.STATE or G.STATE
    if current_state == new_state then return end
    local next_held_state = SMODS.get_next_held_state()
    enter_args = enter_args or {}
    enter_args.old_state = current_state
    local new_state_index = SMODS.get_state_stack_index(new_state)
    if new_state_index then
        if not enter_args.force_refresh then
            enter_args.from_hold = true
        end
    end 
    exit_args = exit_args or {}
    exit_args.new_state = exit_args.new_state or new_state
    local current_state_index = SMODS.get_state_stack_index(current_state, true)
    local exit_state_in_stack = not exit_args.from_hold and current_state_index -- If exit_args.from_hold is already true, this is irrelevant
    if exit_state_in_stack then
        exit_args.from_hold = true
    end
    if SMODS.GameStates[current_state] then
        SMODS.GameStates[current_state]:on_exit(exit_args)
        if not exit_args.from_hold or exit_state_in_stack then
            SMODS.pop_from_state_stack(current_state)
        end
    end
    G.STATE = new_state
    if SMODS.GameStates[new_state] then
        SMODS.STATE = new_state
        if next_held_state ~= new_state or (exit_args.from_hold and not exit_state_in_stack) then
            SMODS.push_to_state_stack(new_state, enter_args)
        end
        SMODS.GameStates[new_state]:on_enter(enter_args)
    end
end

function SMODS.exit_state(exit_args, enter_args, default)
    local current_state = SMODS.STATE or G.STATE
    local new_state
    local next_held_state = SMODS.get_next_held_state()
    default = default or {}
    default.enter_args = default.enter_args or {}
    if next_held_state then
        new_state = next_held_state
    else
        new_state = default.state_override or SMODS.default_state
    end
    exit_args = exit_args or {}
    exit_args.new_state = exit_args.new_state or new_state
    if SMODS.get_state_stack_index(current_state, true) then
        exit_args.from_hold = true
    end
    enter_args = enter_args or {}
    enter_args.old_state = current_state
    if SMODS.get_state_stack_index(new_state) then
        if not enter_args.force_refresh then
            enter_args.from_hold = true
        end
    end 
    if SMODS.GameStates[current_state] then
        SMODS.GameStates[current_state]:on_exit(exit_args)
        SMODS.pop_from_state_stack(current_state)
    end
    if #SMODS.state_stack < 1 then
        G.STATE = nil
        SMODS.STATE = nil
        SMODS.enter_state(new_state, default.enter_args)
        return
    end
    G.STATE = new_state
    if SMODS.GameStates[G.STATE] then
        SMODS.STATE = G.STATE
        SMODS.GameStates[G.STATE]:on_enter(enter_args)
    end
end

SMODS.state_queue = {}

function SMODS.queue_state(new_state, enter_args, exit_args)
    SMODS.state_queue[#SMODS.state_queue+1] = {state = new_state, enter_args = enter_args, exit_args = exit_args}
end

function SMODS.advance_state_queue(instant)
    if #SMODS.state_queue < 1 then
        return
    end
    local func = function()
        local queue_table = table.remove(SMODS.state_queue, 1)
        SMODS.enter_state(queue_table.state, queue_table.enter_args, queue_table.exit_args)
        return true
    end
    if instant then
        func()
    else
        G.E_MANAGER:add_event(Event({
            trigger = "immediate",
            func = func
        }))
    end
end

function SMODS.clear_state_queue()
    SMODS.state_queue = {}
end


local delete_run_clear_state_stuff = function ()
    SMODS.STATE = nil
    SMODS.clear_state_stack()
    SMODS.clear_state_queue()
end

local _delete_run_ref = Game.delete_run
function Game:delete_run()
    local ret = _delete_run_ref(self)
    delete_run_clear_state_stuff()
    return ret
end

SMODS.GameStates = {}
SMODS.GameState = SMODS.GameObject:extend{
    set = 'GameState',
    obj_table = SMODS.GameStates,
    obj_buffer = {},
    required_parameters = {
        'key',
    },
    inject = function (self, i)
        
    end,
    on_enter = function (self, args) end,
    on_exit = function (self, args) end,
    on_load = function (self) end,
    update = function (self, dt) end,
    ease_background_colour = nil, -- function
    exit_after_use_card = false, -- Used for consumable states like SMODS.STATES.REDEEM_VOUCHER
    exit_after_end_consumable = false, -- Used for booster-like states like SMODS.STATES.BOOSTER_OPENED
}

SMODS.GameState {
    key = SMODS.STATES.BOOSTER_OPENED,
    update = function (self, dt)
        SMODS.OPENED_BOOSTER.config.center:update_pack(dt)
    end,
    exit_after_end_consumable = true,
}

function SMODS.in_booster()
    local held_state = SMODS.get_next_held_state()
    return SMODS.STATE == SMODS.STATES.BOOSTER_OPENED or ((SMODS.GameStates[SMODS.STATE] or {}).holds_booster and held_state == SMODS.STATES.BOOSTER_OPENED)
end

SMODS.GameState {
    key = SMODS.STATES.REDEEM_VOUCHER,
    exit_after_use_card = true,
    holds_booster = true,
}

SMODS.GameState {
    key = SMODS.STATES.USE_CONSUMABLE,
    on_enter = function (self, args)
        if G.buttons then G.buttons:remove(); G.buttons = nil end
    end,
    exit_after_use_card = true,
    holds_booster = true,
}

SMODS.GameState {
    key = SMODS.STATES.SHOP,
    on_load = function ()
        G.shop = G.shop or UIBox{
            definition = G.UIDEF.shop(),
            config = {align='tmi', offset = {x=0,y=G.ROOM.T.y+11},major = G.hand, bond = 'Weak'}
        }
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = (function()
                G.SHOP_SIGN.alignment.offset.y = -15 -- Counteracts the immediate event inside G.UIDEF.shop()
                return true
            end)
        }))
        
        if G.load_shop_jokers then 
            G.shop_jokers:load(G.load_shop_jokers)
            for k, v in ipairs(G.shop_jokers.cards) do
                create_shop_card_ui(v)
                if v.ability.consumeable then v:start_materialize(nil, true) end
                for _kk, vvv in ipairs(G.GAME.tags) do
                    if vvv:apply_to_run({type = 'store_joker_modify', card = v}) then break end
                end
            end
            G.load_shop_jokers = nil
        end

        if G.load_shop_vouchers then
            G.shop_vouchers:load(G.load_shop_vouchers)
            for k, v in ipairs(G.shop_vouchers.cards) do
                create_shop_card_ui(v)
                v:start_materialize(nil, true)
            end
            G.load_shop_vouchers = nil
        end

        if G.load_shop_booster then 
            G.shop_booster:load(G.load_shop_booster)
            for k, v in ipairs(G.shop_booster.cards) do
                create_shop_card_ui(v)
                v:start_materialize(nil, true)
            end
            G.load_shop_booster = nil
        end
    end,
    on_enter = function (self, args)
        args = args or {}
        G.CONTROLLER.locks.toggle_shop = nil
        if args.force_refresh then
            self:on_exit()
        elseif args.from_hold then
            if G.shop then 
                -- Extracted from G.FUNCS.use_card()
                G.shop.alignment.offset.y = G.shop.alignment.offset.py or -5.3
                G.shop.alignment.offset.py = nil
                G.SHOP_SIGN.alignment.offset.y = 0

                if not args.no_shop_calc then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.2,
                        blockable = false,
                        func = function()
                            if math.abs(G.shop.T.y - G.shop.VT.y) < 3 then
                                G.ROOM.jiggle = G.ROOM.jiggle + 3
                                if not args.no_sound then play_sound('cardFan2') end
                                for i = 1, #G.GAME.tags do
                                    G.GAME.tags[i]:apply_to_run({type = 'shop_start'})
                                end
                                return true
                            end
                        end
                    }))
                    SMODS.calculate_context({starting_shop = true, from_hold = true})
                end
                G.CONTROLLER:snap_to({node = G.shop:get_UIE_by_ID('next_round_button')})
                G.E_MANAGER:add_event(Event({ func = function() save_run(); return true end}))
            else
                args.force_refresh = true
                self:on_enter(args)
            end
            return
        end
        stop_use()
        G.STATE_COMPLETE = true
        ease_background_colour_blind(G.STATES.SHOP)
        local shop_exists = not not G.shop
        G.shop = G.shop or UIBox{
            definition = G.UIDEF.shop(),
            config = {align='tmi', offset = {x=0,y=G.ROOM.T.y+11},major = G.hand, bond = 'Weak'}
        }
        -- Moved here from G.FUNCS.cash_out()
        G.GAME.current_round.jokers_purchased = 0
        G.GAME.shop_free = nil
        G.GAME.shop_d6ed = nil
        -------
        G.E_MANAGER:add_event(Event({
            func = function()
                G.shop.alignment.offset.y = -5.3
                G.shop.alignment.offset.x = 0
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    blockable = false,
                    func = function()
                        if math.abs(G.shop.T.y - G.shop.VT.y) < 3 then
                            G.ROOM.jiggle = G.ROOM.jiggle + 3
                            if not args.no_sound then play_sound('cardFan2') end
                            for i = 1, #G.GAME.tags do
                                G.GAME.tags[i]:apply_to_run({type = 'shop_start'})
                            end
                            local nosave_shop = nil
                            if not shop_exists then
                                if G.load_shop_jokers then 
                                    nosave_shop = true
                                    G.shop_jokers:load(G.load_shop_jokers)
                                    for k, v in ipairs(G.shop_jokers.cards) do
                                        create_shop_card_ui(v)
                                        if v.ability.consumeable then v:start_materialize() end
                                        for _kk, vvv in ipairs(G.GAME.tags) do
                                            if vvv:apply_to_run({type = 'store_joker_modify', card = v}) then break end
                                        end
                                    end
                                    G.load_shop_jokers = nil
                                else
                                    for i = 1, G.GAME.shop.joker_max - #G.shop_jokers.cards do
                                        G.shop_jokers:emplace(create_card_for_shop(G.shop_jokers))
                                    end
                                end

                                if G.load_shop_vouchers then
                                    nosave_shop = true
                                    G.shop_vouchers:load(G.load_shop_vouchers)
                                    for k, v in ipairs(G.shop_vouchers.cards) do
                                        create_shop_card_ui(v)
                                        v:start_materialize()
                                    end
                                    G.load_shop_vouchers = nil
                                else
                                    local vouchers_to_spawn = 0
                                    for _,_ in pairs(G.GAME.current_round.voucher.spawn) do vouchers_to_spawn = vouchers_to_spawn + 1 end
                                    if vouchers_to_spawn < G.GAME.starting_params.vouchers_in_shop + (G.GAME.modifiers.extra_vouchers or 0) then
                                        SMODS.get_next_vouchers(G.GAME.current_round.voucher)
                                    end
                                    for _, key in ipairs(G.GAME.current_round.voucher or {}) do
                                        if G.P_CENTERS[key] and G.GAME.current_round.voucher.spawn[key] then
                                            SMODS.add_voucher_to_shop(key)
                                        end
                                    end
                                end

                                if G.load_shop_booster then 
                                    nosave_shop = true
                                    G.shop_booster:load(G.load_shop_booster)
                                    for k, v in ipairs(G.shop_booster.cards) do
                                        create_shop_card_ui(v)
                                        v:start_materialize()
                                    end
                                    G.load_shop_booster = nil
                                else
                                    for i=1, G.GAME.starting_params.boosters_in_shop + (G.GAME.modifiers.extra_boosters or 0) do
                                        G.GAME.current_round.used_packs = G.GAME.current_round.used_packs or {}
                                        if not G.GAME.current_round.used_packs[i] then
                                            G.GAME.current_round.used_packs[i] = get_pack('shop_pack').key
                                        end

                                        if G.GAME.current_round.used_packs[i] ~= 'USED' then 
                                            local card = Card(G.shop_booster.T.x + G.shop_booster.T.w/2,
                                            G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[G.GAME.current_round.used_packs[i]], {bypass_discovery_center = true, bypass_discovery_ui = true})
                                            create_shop_card_ui(card, 'Booster', G.shop_booster)
                                            card.ability.booster_pos = i
                                            card:start_materialize()
                                            G.shop_booster:emplace(card)
                                        end
                                    end

                                    for i = 1, #G.GAME.tags do
                                        G.GAME.tags[i]:apply_to_run({type = 'voucher_add'})
                                    end
                                    for i = 1, #G.GAME.tags do
                                        G.GAME.tags[i]:apply_to_run({type = 'shop_final_pass'})
                                    end
                                end
                            end

                            if not nosave_shop then SMODS.calculate_context({starting_shop = true}) end
                            G.CONTROLLER:snap_to({node = G.shop:get_UIE_by_ID('next_round_button')})
                            if not nosave_shop then G.E_MANAGER:add_event(Event({ func = function() save_run(); return true end})) end
                            return true
                        end
                    end
                }))
                return true
            end
        }))
    end,
    on_exit = function (self, args)
        args = args or {}
        G.CONTROLLER.locks.toggle_shop = true
        if args.from_hold then
            if G.shop and not G.shop.alignment.offset.py then
                G.shop.alignment.offset.py = G.shop.alignment.offset.y
                G.shop.alignment.offset.y = G.ROOM.T.y + 29
                if not args.leave_shop_sign then
                    G.SHOP_SIGN.alignment.offset.y = -15
                end
            end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.5,
                func = function ()
                    G.CONTROLLER.locks.toggle_shop = nil
                    return true
                end
            }))
            return
        end
        stop_use()
        if G.shop then
            SMODS.calculate_context({ending_shop = true})
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    G.shop.alignment.offset.y = G.ROOM.T.y + 29
                    G.SHOP_SIGN.alignment.offset.y = -15
                    return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.5,
                func = function()
                    G.shop:remove()
                    G.shop = nil
                    G.SHOP_SIGN:remove()
                    G.SHOP_SIGN = nil
                    G.STATE_COMPLETE = false
                    G.CONTROLLER.locks.toggle_shop = nil
                    return true
                end
            }))
        else 
            G.CONTROLLER.locks.toggle_shop = false
        end
    end,
}

SMODS.GameState {
    key = SMODS.STATES.ROUND_EVAL,
    on_enter = function (self, args)
        args = args or {}
        if args.force_refresh then
            self:on_exit()
        elseif args.from_hold then
            if G.round_eval then
                G.round_eval.alignment.offset.y = G.round_eval.alignment.offset.py
                G.round_eval.alignment.offset.py = nil
            else
                args.force_refresh = true
                self:on_enter(args)
            end
            return
        end
        G.E_MANAGER:add_event(Event({
            trigger = "immediate",
            func = function ()
                stop_use()
                G.STATE_COMPLETE = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        save_run()
                        ease_background_colour_blind(G.STATES.ROUND_EVAL)
                        G.round_eval = UIBox{
                            definition = create_UIBox_round_evaluation(),
                            config = {align="bm", offset = {x=0,y=G.ROOM.T.y + 19},major = G.hand, bond = 'Weak'}
                        }
                        G.round_eval.alignment.offset.x = 0
                        G.E_MANAGER:add_event(Event({
                            trigger = 'immediate',
                            func = function()
                                if G.round_eval.alignment.offset.y ~= -7.8 then
                                    G.round_eval.alignment.offset.y = -7.8
                                else
                                    if math.abs(G.round_eval.T.y - G.round_eval.VT.y) < 3 then
                                        G.ROOM.jiggle = G.ROOM.jiggle + 3
                                        play_sound('cardFan2')
                                        delay(0.1)
                                        G.FUNCS.evaluate_round()
                                        return true
                                    end
                                end
                            end}))
                        return true
                    end
                }))
                return true
            end
        }))
    end,
    on_exit = function (self, args)
        args = args or {}
        if args.from_hold then
            if G.round_eval and not G.round_eval.alignment.offset.py then
                G.round_eval.alignment.offset.py = G.round_eval.alignment.offset.y
                G.round_eval.alignment.offset.y = G.ROOM.T.y + 29
            end
            return
        end
        stop_use()
        if G.round_eval then
            G.round_eval.alignment.offset.y = G.ROOM.T.y + 15
            G.round_eval.alignment.offset.x = 0
            G.deck:shuffle('cashout'..G.GAME.round_resets.ante)
            G.deck:hard_set_T()
            delay(0.3)
            G.GAME.current_round.discards_left = math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards)
            G.GAME.current_round.hands_left = (math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands))
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    if G.round_eval then
                        G.round_eval:remove()
                        G.round_eval = nil
                    end
                    -- G.STATE_COMPLETE = false
                    return true
                end
            }))
            ease_dollars(G.GAME.current_round.dollars)
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.GAME.previous_round.dollars = G.GAME.dollars
                    return true
                end
            }))
            play_sound("coin7")
            G.VIBRATION = G.VIBRATION + 1
        end
        
        ease_chips(0)
        if G.GAME.round_resets.blind_states.Boss == 'Defeated' then 
            G.GAME.round_resets.blind_ante = G.GAME.round_resets.ante
            G.GAME.round_resets.blind_tags.Small = get_next_tag_key()
            G.GAME.round_resets.blind_tags.Big = get_next_tag_key()
        end
        reset_blinds()
        delay(0.6)
    end,
}

SMODS.GameState {
    key = SMODS.STATES.BLIND,
    on_enter = function (self, args)
        args = args or {}
        if args.force_refresh then
            self:on_exit()
        elseif args.from_hold then
            G.GAME.facing_blind = true
            if args.leave_data then
                save_run()
                G.STATE = G.STATES.SELECTING_HAND
                G.CONTROLLER:recall_cardarea_focus('hand')
                return
            end
            local data = SMODS.state_stack[#SMODS.state_stack].data
            ease_chips(data.chips)
            G.GAME.blind:set_blind(G.P_BLINDS[data.blind_key], nil, true)
            G.GAME.blind.chips = data.blind_chips
            G.GAME.blind.chip_text = number_format(data.blind_chips)
            ease_hands_played(G.GAME.current_round.hands_left - data.hands_left)
            G.GAME.current_round.hands_played = data.hands_played
            ease_discard(G.GAME.current_round.discards_left - data.discards_left)
            G.GAME.current_round.discards_used = data.discards_used
            local hand_cards = SMODS.get_cards_by_sort_ids(data.hand_cards, {G.playing_cards})
            local discarded_cards = SMODS.get_cards_by_sort_ids(data.discarded_cards, {G.playing_cards})
            for _, pcard_sort_id in ipairs(data.hand_cards) do
                local pcard = hand_cards[pcard_sort_id]
                if pcard and not pcard.removed then
                    draw_card(G.deck, G.hand, nil, nil, nil, pcard)
                    pcard.ability.forced_selection = data.forced_selection[pcard_sort_id]
                end
            end
            for _, pcard_sort_id in ipairs(data.discarded_cards) do
                local pcard = discarded_cards[pcard_sort_id]
                if pcard and not pcard.removed then
                    draw_card(G.deck, G.discard, nil, nil, nil, pcard)
                    pcard.ability.discarded = true
                end
            end
            save_run()
            G.STATE = G.STATES.SELECTING_HAND
            G.CONTROLLER:recall_cardarea_focus('hand')
            return
        end
        G.E_MANAGER:add_event(Event({
            trigger = "immediate",
            func = function ()
                stop_use()
                G.GAME.facing_blind = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        ease_round(1)
                        inc_career_stat('c_rounds', 1)
                        if _DEMO then
                            G.SETTINGS.DEMO_ROUNDS = (G.SETTINGS.DEMO_ROUNDS or 0) + 1
                            inc_steam_stat('demo_rounds')
                            G:save_settings()
                        end
                        G.GAME.round_resets.blind = G.P_BLINDS[args.key]
                        G.GAME.round_resets.blind_states[G.GAME.blind_on_deck] = 'Current'
                        delay(0.2)
                        return true
                end}))
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        new_round()
                        return true
                    end
                }))
                return true
            end
        }))
    end,
    on_exit = function (self, args)
        args = args or {}
        G.GAME.facing_blind = nil
        if args.from_hold or args.no_defeat then
            if G.HUD_blind and not args.leave_HUD_blind then
                G.HUD_blind.alignment.offset.py = G.HUD_blind.alignment.offset.y
                G.HUD_blind.alignment.offset.y = -10
            end
            if args.from_hold then
                local data = {
                    blind_key = G.GAME.blind.config.blind.key,
                    hand_cards = {},
                    forced_selection = {},
                    discarded_cards = {},
                    chips = G.GAME.chips,
                    blind_chips = G.GAME.blind.chips,
                    hands_left = G.GAME.current_round.hands_left,
                    hands_played = G.GAME.current_round.hands_played,
                    discards_left = G.GAME.current_round.discards_left,
                    discards_used = G.GAME.current_round.discards_used,
                }
                for _, pcard in ipairs(G.hand.cards) do
                    data.hand_cards[#data.hand_cards+1] = pcard.sort_id
                    if pcard.ability.forced_selection then
                        data.forced_selection[pcard.sort_id] = true
                    end
                end
                for _, pcard in ipairs(G.discard.cards) do
                    data.discarded_cards[#data.discarded_cards+1] = pcard.sort_id
                end
                SMODS.state_stack[#SMODS.state_stack].data = data
            end
            if not args.leave_data then
                G.FUNCS.draw_from_hand_to_discard()
                G.FUNCS.draw_from_discard_to_deck()
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    blockable = false,
                    delay = 0.7,
                    func = function ()
                        G.GAME.blind:disable()
                        if G.buttons then G.buttons:remove(); G.buttons = nil end         
                        return true
                    end
                }))
                for k, v in ipairs(G.playing_cards) do
                    v.ability.discarded = nil
                    v.ability.forced_selection = nil
                end
                delay(0.4)
            end
            return
        end
        G.E_MANAGER:add_event(Event({
            trigger = "immediate",
            blocking = false,
            func = function ()
                if args.new_state == SMODS.STATES.ROUND_EVAL then -- Precise vanilla timing -> called from end_round()
                    if G.round_eval and G.round_eval.alignment.offset.y == -7.8 and math.abs(G.round_eval.T.y - G.round_eval.VT.y) < 3 then
                        G.E_MANAGER:add_event(Event({
                            trigger = "immediate",
                            func = function ()
                                G.E_MANAGER:add_event(Event({
                                    trigger = 'before',
                                    blocking = false,
                                    delay = 1.3*math.min(G.GAME.blind.dollars+2, 7)/2*0.15 + 0.5,
                                    func = function()
                                        G.GAME.blind:defeat()
                                        return true
                                    end
                                }))
                                delay(0.2)
                                return true
                            end
                        }))
                        return true
                    end
                else
                    G.FUNCS.draw_from_hand_to_discard()
                    G.FUNCS.draw_from_discard_to_deck()
                    G.E_MANAGER:add_event(Event({
                        trigger = "after",
                        blockable = false,
                        blocking = false,
                        delay = 0.7,
                        func = function ()
                            G.GAME.blind:defeat()
                            return true
                        end
                    }))
                    for k, v in ipairs(G.playing_cards) do
                        v.ability.discarded = nil
                        v.ability.forced_selection = nil
                    end
                    delay(0.4)
                    return true
                end
            end
        }))
    end,
    ease_background_colour = function (self, blind_override)
        local blindname = ((blind_override or (G.GAME.blind and G.GAME.blind.name ~= '' and G.GAME.blind.name)) or 'Small Blind')
        blindname = (blindname == '' and 'Small Blind' or blindname)
        
        local boss_col = G.C.BLACK
        for k, v in pairs(G.P_BLINDS) do
            if v.name == blindname then
                if v.boss and v.boss.showdown or v.blind_types and v.blind_types.Showdown then
                    ease_background_colour{new_colour = G.C.BLUE, special_colour = G.C.RED, tertiary_colour = darken(G.C.BLACK, 0.4), contrast = 3}
                    return
                end
                boss_col = v.boss_colour or G.C.BLACK
            end
        end
        ease_background_colour{new_colour = lighten(mix_colours(boss_col, G.C.BLACK, 0.3), 0.1), special_colour = boss_col, contrast = 2}
    end
}

SMODS.GameState {
    key = SMODS.STATES.BLIND_SELECT,
    on_enter = function (self, args)
        args = args or {}
        if args.force_refresh then
            self:on_exit()
        elseif args.from_hold then
            if G.blind_select then
                G.blind_select.alignment.offset.y = G.blind_select.alignment.offset.py
                G.blind_select.alignment.offset.py = nil
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.3,
                    func = function ()
                        if not args.no_sound then play_sound('cancel') end
                        return true
                    end
                }))
            else
                args.force_refresh = true
                self:on_enter(args)
            end
            return
        end
        G.E_MANAGER:add_event(Event({
            trigger = "immediate",
            func = function()
                stop_use()
                ease_background_colour_blind(SMODS.STATES.BLIND_SELECT)
                G.E_MANAGER:add_event(Event({ func = function() save_run(); return true end}))
                G.CONTROLLER.interrupt.focus = true
                G.E_MANAGER:add_event(Event({ func = function()
                    G.E_MANAGER:add_event(Event({
                        trigger = 'immediate',
                        func = function()
                            play_sound('cancel')
                            G.blind_select = UIBox{
                                definition = create_UIBox_blind_select(),
                                config = {align="bmi", offset = {x=0,y=G.ROOM.T.y + 29},major = G.hand, bond = 'Weak'}
                            }
                            G.blind_select.alignment.offset.y = 0.8-(G.hand.T.y - G.jokers.T.y) + G.blind_select.T.h
                            G.ROOM.jiggle = G.ROOM.jiggle + 3
                            G.blind_select.alignment.offset.x = 0
                            G.CONTROLLER.lock_input = false
                            for i = 1, #G.GAME.tags do
                                G.GAME.tags[i]:apply_to_run({type = 'immediate'})
                            end
                            for i = 1, #G.GAME.tags do
                                if G.GAME.tags[i]:apply_to_run({type = 'new_blind_choice'}) then break end
                            end
                            return true
                        end
                    }))
                    return true
                end}))
                return true
            end
        }))
    end,
    on_exit = function (self, args)
        args = args or {}
        if args.from_hold then
            if G.blind_select and not G.blind_select.alignment.offset.py then
                G.blind_select.alignment.offset.py = G.blind_select.alignment.offset.y
                G.blind_select.alignment.offset.y = G.ROOM.T.y + 39
            end
            return
        end
        G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext1').config.object.pop_delay = 0
        G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext1').config.object:pop_out(5)
        G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext2').config.object.pop_delay = 0
        G.blind_prompt_box:get_UIE_by_ID('prompt_dynatext2').config.object:pop_out(5) 

        G.E_MANAGER:add_event(Event({
            trigger = 'before', delay = 0.2,
            func = function()
                G.blind_prompt_box.alignment.offset.y = -10
                G.blind_select.alignment.offset.y = 40
                G.blind_select.alignment.offset.x = 0
                return true
        end}))
        G.E_MANAGER:add_event(Event({
            trigger = "immediate",
            func = function ()
                G.blind_select:remove()
                G.blind_prompt_box:remove()
                G.blind_select = nil
                return true
            end
        }))

    end,
}