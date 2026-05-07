------- UI DEFS 
function SMODS.create_CanvasContainer_BlindSelect(run_info)
    local ui_out
    if run_info then
        
    else
        -- Needs to set G.blind_prompt_box
        ui_out = {
            n=G.UIT.ROOT,
            config={},
            nodes={}
        }
    end
    return ui_out
end

------- API CODE SMODS.AntePath 
SMODS.AntePaths = {}
SMODS.AntePath = SMODS.GameObject:extend {
    set = 'AntePath',
    obj_table = SMODS.AntePaths,
    obj_buffer = {},
    required_parameters = {
        'key',
    },
    inject = function(self)

    end,
    create_data = function (self)
        -- Vanilla Blind structure
        -- "Small" -> "Big" -> "Boss"
        local boss_type = (G.GAME.round_resets.ante)%G.GAME.win_ante == 0 and G.GAME.round_resets.ante > 0 and "Showdown" or "Boss"
        local path_data = {
            key = "vanilla",
            active_node = 1,
            nodes = {
                SMODS.APNode {
                    index = 1,
                    hidden = true,
                    selected = true,
                },
                SMODS.APNode {
                    index = 2,
                    callbacks = {
                        {key = "enter_blind", triggers = {selected = true}},
                        {key = "evaluate_round", triggers = {defeated = true}},
                        {key = "enter_shop", triggers = {cashed_out = true}},
                        {key = "enter_blind_select", triggers = {shop_ended = true}},
                        {key = "create_tag", triggers = {skipped = true}},
                    },
                    blinds = {"bl_small"},
                    tags = {get_next_tag_key()},
                    next_nodes_indices = {[3] = true}
                },
                SMODS.APNode {
                    index = 3,
                    callbacks = {
                        {key = "enter_blind", triggers = {selected = true}},
                        {key = "evaluate_round", triggers = {defeated = true}},
                        {key = "enter_shop", triggers = {cashed_out = true}},
                        {key = "enter_blind_select", triggers = {shop_ended = true}},
                        {key = "create_tag", triggers = {skipped = true}},
                    },
                    blinds = {"bl_big"},
                    tags = {get_next_tag_key()},
                    next_nodes_indices = {[4] = true}
                },
                SMODS.APNode {
                    index = 4,
                    callbacks = {
                        {key = "enter_blind", triggers = {selected = true}},
                        {key = "ante_up", triggers = {defeated = true}},
                        {key = "evaluate_round", triggers = {defeated = true}},
                        {key = "enter_blind_select", triggers = {shop_ended = true}},
                        {key = "next_ante_path", triggers = {cashed_out = true}},
                        {key = "enter_shop", triggers = {cashed_out = true}},
                    },
                    blinds = {SMODS.get_new_blind({[boss_type] = true})}, -- Todo : Replace with correct function
                }
            }
        }
        return path_data
    end,
    create_ui = function (self)
        -- Vanilla Blind select UI
        local canvas_container = UIBox {
            definition = {n=G.UIT.ROOT, colour = G.C.CLEAR, padding = 0.2},
            config = {align="cm", offset = {x=0,y=G.ROOM.T.y + 29}, major = G.ROOM_ATTACH, bond = 'Weak'},
            nodes = {
                SMODS.create_CanvasContainer_BlindSelect()
            }
        }
        return canvas_container
    end,
    create_run_info_ui = function (self)
        -- Vanilla Run Info Blind Tab UI
        local canvas_container = UIBox {
            definition = {n=G.UIT.ROOT, colour = G.C.CLEAR, padding = 0.2},
            config = {align="cm", offset = {x=0,y=G.ROOM.T.y}, major = G.ROOM_ATTACH, bond = 'Weak'},
            nodes = {
                SMODS.create_CanvasContainer_BlindSelect(true)
            }
        }
        return canvas_container
    end,
    create_callback_ui = function (self, cb_key, ap_node, ap_node_UIE)
        if not cb_key or not SMODS.APNodeCallbacks[cb_key] then return end
        return SMODS.APNodeCallbacks[cb_key]:create_ui(ap_node, ap_node_UIE)
    end
}

SMODS.AntePath {
    key = "vanilla",
}

function SMODS.get_ante_path()
    return SMODS.ANTE_PATH and SMODS.AntePaths[SMODS.ANTE_PATH.key] or SMODS.AntePaths["vanilla"]
end

function SMODS.get_ap_node(index)
    return SMODS.ANTE_PATH and SMODS.ANTE_PATH.nodes and SMODS.ANTE_PATH.nodes[index]
end

function SMODS.save_ante_path()
    if not SMODS.ANTE_PATH then return {} end
    local nodes_table = {}
    for _, ap_node in ipairs(SMODS.ANTE_PATH.nodes) do
        table.insert(nodes_table, ap_node:save())
    end
    local ante_path_table = {
        key = SMODS.ANTE_PATH.key,
        active_node = SMODS.ANTE_PATH.active_node,
        nodes = nodes_table,
    }
    return ante_path_table
end

function SMODS.load_ante_path(ante_path_table)
    for i, ap_node_table in ipairs(ante_path_table.nodes) do
        ante_path_table.nodes[i] = SMODS.APNode{node_table = ap_node_table}
    end
    SMODS.set_ante_path(ante_path_table)
end

function SMODS.next_ante_path()
    SMODS.set_ante_path(SMODS.get_ante_path():create_data())
end

function SMODS.set_ante_path(data)
    SMODS.ANTE_PATH = data
end

function SMODS.set_active_ap_node(ap_node)
    if type(ap_node) == "number" then
        SMODS.ANTE_PATH.active_node = ap_node
    else
        SMODS.ANTE_PATH.active_node = ap_node.index
    end
end

function SMODS.get_active_ap_node()
    return SMODS.get_ap_node(SMODS.ANTE_PATH.active_node)
end

local start_run_ref = Game.start_run
function Game:start_run(args)
    start_run_ref(self, args)
    local saveTable = args.savetext
    if saveTable and saveTable.ANTE_PATH then
        SMODS.load_ante_path(saveTable.ANTE_PATH)
    end
end

local save_run_ref = save_run
function save_run()
    save_run_ref()
    G.ARGS.save_run.ANTE_PATH = recursive_table_cull(SMODS.save_ante_path())
end

local delete_run_ref = Game.delete_run
function Game:delete_run()
    delete_run_ref(self)
    SMODS.ANTE_PATH = nil
end

------- API CODE Object.APNode
SMODS.APNode = Object:extend()
function SMODS.APNode:init(...)
    local args = {...}

    if args.node_table then
        self:load(args.node_table)
        return
    end

    self.index = args.index
    self.hidden = args.hidden
    self.selected = args.selected or false

    self:set_callbacks(args.callbacks or {})
    self:set_blinds(args.blinds or {})
    self:set_tags(args.tags or {})

    self:set_next_nodes(args.next_nodes_indices or {})
end

function SMODS.APNode:set_callbacks(cbs)
    self.callbacks = {}
    for _, cb in ipairs(cbs) do
        table.insert(self.callbacks, {
            key = cb.key,
            triggers = cb.triggers,
            called = cb.called or false,
            ignore_hold = cb.ignore_hold or false
        })
    end
end

function SMODS.APNode:set_blinds(blinds)
    self.blinds = {}
    for _, blind_key in ipairs(blinds) do
        table.insert(self.blinds, {
            key = blind_key,
            used = false,
        })
    end
end

function SMODS.APNode:set_tags(tags)
    self.tags = {}
    for _, tag_key in ipairs(tags) do
        table.insert(self.tags, {
            key = tag_key,
            used = false,
        })
    end
end

function SMODS.APNode:trigger_callbacks(trigger_type)
    if not trigger_type then return end
    local hold = false
    for _, cb in ipairs(self.callbacks) do
        local callback = SMODS.APNodeCallbacks[cb.key]
        if not cb.called and (not hold or cb.ignore_hold) and cb.triggers[trigger_type] then
            cb.called = true
            hold = hold or callback:on_callback(self, cb, trigger_type)
        end
    end
end

function SMODS.APNode:get_blind(keep)
    local blind_tuple
    for _, tup in ipairs(self.blinds) do
        if not tup.used then
            blind_tuple = tup
            break
        end
    end
    local blind = blind_tuple.key
    if blind and not keep then blind_tuple.used = true end
    return blind
end

function SMODS.APNode:get_tag(keep)
    local tag_tuple
    for _, tup in ipairs(self.tags) do
        if not tup.used then
            tag_tuple = tup
            break
        end
    end
    local tag = tag_tuple.key
    if tag and not keep then tag_tuple.used = true end
    return tag
end

function SMODS.APNode:set_next_nodes(nni)
    self.next_nodes_indices = nni or {}
end

function SMODS.APNode:save()
    local node_table = {
        index = self.index,
        hidden = self.hidden,
        callbacks = self.callbacks,
        blinds = self.blinds,
        tags = self.tags,
        selected = self.selected,
        next_nodes_indices = self.next_nodes_indices,
    }
    return node_table
end

function SMODS.APNode:load(node_table)
    self.index = node_table.index
    self.hidden = node_table.hidden
    self.callbacks = node_table.callbacks or {}
    self.blinds = node_table.blinds or {}
    self.tags = node_table.tags or {}
    self.selected = node_table.selected or false
    self.next_nodes_indices = node_table.next_nodes_indices or {}
end

------- API CODE GameObject.APNodeCallback
SMODS.APNodeCallbacks = {}
SMODS.APNodeCallback = SMODS.GameObject:extend {
    set = 'APNodeCallback',
    obj_table = SMODS.APNodeCallbacks,
    obj_buffer = {},
    required_parameters = {
        'key',
        'on_callback',
    },
    inject = function(self)

    end,
    create_ui = function (self, ap_node, ap_node_UIE)
    end
}

SMODS.APNodeCallback {
    key = "enter_blind",
    on_callback = function (self, ap_node, cb, trigger_type)
        -- Change game state to ap_node:get_blind()
        SMODS.enter_state(SMODS.STATES.BLIND, {key = ap_node:get_blind(), trigger_callbacks = true})
        return true
    end,
    create_ui = function (self, ap_node, ap_node_UIE)
        return SMODS.GUI.bt_callback_enter_blind(ap_node, ap_node_UIE)
    end
}

function SMODS.GUI.bt_callback_enter_blind(ap_node, ap_node_UIE)
    return {}
end

SMODS.APNodeCallback {
    key = "evaluate_round",
    on_callback = function (self, ap_node, cb, trigger_type)
        -- Create cashout and evaluate round 
        SMODS.enter_state(SMODS.STATES.ROUND_EVAL, {trigger_callbacks = true})
        return true
    end,
    create_ui = function (self, ap_node, ap_node_UIE)
        return SMODS.GUI.bt_callback_evaluate_round(ap_node, ap_node_UIE)
    end
}

function SMODS.GUI.bt_callback_evaluate_round(ap_node, ap_node_UIE)
    return {}
end

SMODS.APNodeCallback {
    key = "enter_shop",
    on_callback = function (self, ap_node, cb, trigger_type)
        -- Change game state to shop
        SMODS.enter_state(SMODS.STATES.SHOP, {trigger_callbacks = true})
        return true
    end,
    create_ui = function (self, ap_node, ap_node_UIE)
        return SMODS.GUI.bt_callback_enter_shop(ap_node, ap_node_UIE)
    end
}

function SMODS.GUI.bt_callback_enter_shop(ap_node, ap_node_UIE)
    return {}
end

SMODS.APNodeCallback {
    key = "enter_blind_select",
    on_callback = function (self, ap_node, cb, trigger_type)
        -- Change game state to blind select
        SMODS.enter_state(SMODS.STATES.BLIND_SELECT)
        return true
    end,
    create_ui = function (self, ap_node, ap_node_UIE)
        return nil
    end
}

SMODS.APNodeCallback {
    key = "ante_up",
    on_callback = function (self, ap_node, cb, trigger_type)
        -- Ante up
        SMODS.ante_end = true
        ease_ante(1)
        SMODS.ante_end = nil
        check_for_unlock({type = 'ante_up', ante = G.GAME.round_resets.ante + 1})
        -- Moved here from G.FUNCS.cash_out() -> Might have to be moved again for better timing
        G.GAME.round_resets.blind_ante = G.GAME.round_resets.ante
        ------
        return false
    end,
    create_ui = function (self, ap_node, ap_node_UIE)
        return SMODS.GUI.bt_callback_ante_up(ap_node, ap_node_UIE)
    end
}

function SMODS.GUI.bt_callback_ante_up(ap_node, ap_node_UIE)
    return {}
end

SMODS.APNodeCallback {
    key = "create_tag",
    on_callback = function (self, ap_node, cb, trigger_type)
        -- Create tag(s) from ap_node:get_tag()
        add_tag(ap_node:get_tag())
        return false
    end,
    create_ui = function (self, ap_node, ap_node_UIE)
        return SMODS.GUI.bt_callback_create_tag(ap_node, ap_node_UIE)
    end
}

function SMODS.GUI.bt_callback_create_tag(ap_node, ap_node_UIE)
    return {}
end

SMODS.APNodeCallback {
    key = "next_ante_path",
    on_callback = function (self, ap_node, cb, trigger_type)
        G.E_MANAGER:add_event(Event{
            trigger = "immediate",
            func = function ()
                SMODS.next_ante_path()
                return true
            end
        })
        return false
    end,
    create_ui = function (self, ap_node, ap_node_UIE)
        return nil
    end
}

------- API CODE GameObject.APNodeButton
SMODS.APNodeButtons = {}
SMODS.APNodeButton = SMODS.GameObject:extend {
    set = 'APNodeButton',
    obj_table = SMODS.APNodeButtons,
    obj_buffer = {},
    required_parameters = {
        'key',
        'on_click',
    },
    inject = function(self)
        if type(self.on_click) ~= "function" then
            sendWarnMessage(("APNodeButton injected with invalid function '%s'"):format(self.on_click))
        end
    end,
    create_ui = function (self, ap_node, ap_node_UIE)

    end,
    on_click = function (self, ap_node)
        
    end
}

SMODS.APNodeButton {
    key = "select",
    on_click = function (self, ap_node)
        SMODS.set_active_ap_node(ap_node)
        ap_node:trigger_callbacks("selected")
    end,
}

SMODS.APNodeButton {
    key = "skip",
    on_click = function (self, ap_node)
        SMODS.set_active_ap_node(ap_node)
        ap_node:trigger_callbacks("skipped")
    end,
}

SMODS.APNodeButton {
    key = "reroll",
    on_click = function (self, ap_node)
        -- Reroll Blind
    end,
}

------- API CODE OVERRIDES


--[[
blind_states and loc_blind_states

Game:update(dt) -> This;
    if G.prev_small_state ~= G.GAME.round_resets.blind_states.Small or
    G.prev_large_state ~= G.GAME.round_resets.blind_states.Big or
    G.prev_boss_state ~= G.GAME.round_resets.blind_states.Boss or G.RESET_BLIND_STATES then ...
can probably be ignored and replaced with own system
    
Game:start_run() -> get_next_tag_key() is called, besides that; blind_states is set
]]
function reset_blinds()
    G.GAME.round_resets.boss_rerolled = false
end

SMODS.Joker:take_ownership("j_matador", {
    check_for_unlock = function (self, args)
        return G.GAME.current_round.hands_played == 1 and G.GAME.current_round.discards_left == G.GAME.round_resets.discards and G.GAME.blind:is_type("Boss")
    end
})

SMODS.Joker:take_ownership("j_hanging_chad", {
    check_for_unlock = function (self, args)
        return G.GAME.last_hand_played == self.unlock_condition.extra and G.GAME.blind:is_type("Boss")
    end
})

-- Create Blind Select UI -> Not used in SMODS.STATES.BLIND_SELECT.on_enter()
function create_UIBox_blind_select() end

-- Run Info Tab 
function G.UIDEF.current_blinds()
    return SMODS.get_ante_path():create_run_info_ui()
end

-- Blind Choice Handler
function G.FUNCS.blind_choice_handler(e)

end

-- Cash Out -> Functionality is handled by custom SMODS.GameStates and APNodeCallbacks
function G.FUNCS.cash_out(e)
    if SMODS.get_current_state().args.trigger_callbacks then
        SMODS.get_active_ap_node():trigger_callbacks("cashed_out")
    end
end

-- TODO : move to lovely patches
function G.FUNCS.evaluate_round()
    total_cashout_rows = 0
    local pitch = 0.95
    local dollars = 0

    if not G.GAME.blind then
        add_round_eval_row({dollars = G.GAME.default_eval_dollars or 0, name='???', pitch = pitch}) -- TODO: Check name
        pitch = pitch + 0.06
        dollars = dollars + (G.GAME.default_eval_dollars or 0)
    elseif G.GAME.chips - G.GAME.blind.chips >= 0 then
        add_round_eval_row({dollars = G.GAME.blind.dollars, name='blind1', pitch = pitch})
        pitch = pitch + 0.06
        dollars = dollars + G.GAME.blind.dollars
    else
        add_round_eval_row({dollars = 0, name='blind1', pitch = pitch, saved = true})
        pitch = pitch + 0.06
    end

    delay(0.2)
    G.E_MANAGER:add_event(Event({
        func = function()
            ease_background_colour_blind(G.STATES.ROUND_EVAL, '')
            return true
        end
    }))
    SMODS.calculate_context{round_eval = true}
    G.GAME.selected_back:trigger_effect({context = 'eval'})

    if G.GAME.current_round.hands_left > 0 and not G.GAME.modifiers.no_extra_hand_money then
        add_round_eval_row({dollars = G.GAME.current_round.hands_left*(G.GAME.modifiers.money_per_hand or 1), disp = G.GAME.current_round.hands_left, bonus = true, name='hands', pitch = pitch})
        pitch = pitch + 0.06
        dollars = dollars + G.GAME.current_round.hands_left*(G.GAME.modifiers.money_per_hand or 1)
    end
    if G.GAME.current_round.discards_left > 0 and G.GAME.modifiers.money_per_discard then
        add_round_eval_row({dollars = G.GAME.current_round.discards_left*(G.GAME.modifiers.money_per_discard), disp = G.GAME.current_round.discards_left, bonus = true, name='discards', pitch = pitch})
        pitch = pitch + 0.06
        dollars = dollars +  G.GAME.current_round.discards_left*(G.GAME.modifiers.money_per_discard)
    end
    local i = 0
    for _, area in ipairs(SMODS.get_card_areas('jokers')) do
            for _, _card in ipairs(area.cards) do
            local ret = _card:calculate_dollar_bonus()
    
            -- TARGET: calc_dollar_bonus per card
            if ret then
                i = i+1
                add_round_eval_row({dollars = ret, bonus = true, name='joker'..i, pitch = pitch, card = _card})
                pitch = pitch + 0.06
                dollars = dollars + ret
            end
        end
    end
    for i = 1, #G.GAME.tags do
        local ret = G.GAME.tags[i]:apply_to_run({type = 'eval'})
        if ret then
            add_round_eval_row({dollars = ret.dollars, bonus = true, name='tag'..i, pitch = pitch, condition = ret.condition, pos = ret.pos, tag = ret.tag})
            pitch = pitch + 0.06
            dollars = dollars + ret.dollars
        end
    end
    if G.GAME.dollars >= 5 and not G.GAME.modifiers.no_interest then
        add_round_eval_row({bonus = true, name='interest', pitch = pitch, dollars = G.GAME.interest_amount*math.min(math.floor(G.GAME.dollars/5), G.GAME.interest_cap/5)})
        pitch = pitch + 0.06
        if (not G.GAME.seeded and not G.GAME.challenge) or SMODS.config.seeded_unlocks then
            if G.GAME.interest_amount*math.min(math.floor(G.GAME.dollars/5), G.GAME.interest_cap/5) == G.GAME.interest_amount*G.GAME.interest_cap/5 then 
                G.PROFILES[G.SETTINGS.profile].career_stats.c_round_interest_cap_streak = G.PROFILES[G.SETTINGS.profile].career_stats.c_round_interest_cap_streak + 1
            else
                G.PROFILES[G.SETTINGS.profile].career_stats.c_round_interest_cap_streak = 0
            end
        end
        check_for_unlock({type = 'interest_streak'})
        dollars = dollars + G.GAME.interest_amount*math.min(math.floor(G.GAME.dollars/5), G.GAME.interest_cap/5)
    end

    pitch = pitch + 0.06

    if total_cashout_rows > 7 then
        local total_hidden = total_cashout_rows - 7
    
        G.E_MANAGER:add_event(Event({
            trigger = 'before',delay = 0.38,
            func = function()
                local hidden = {n=G.UIT.R, config={align = "cm"}, nodes={
                    {n=G.UIT.O, config={object = DynaText({
                        string = {localize{type = 'variable', key = 'cashout_hidden', vars = {total_hidden}}}, 
                        colours = {G.C.WHITE}, shadow = true, float = false, 
                        scale = 0.45,
                        font = G.LANGUAGES['en-us'].font, pop_in = 0
                    })}}
                }}
    
                G.round_eval:add_child(hidden, G.round_eval:get_UIE_by_ID('bonus_round_eval'))
                return true
            end
        }))
    end
    add_round_eval_row({name = 'bottom', dollars = dollars})
end

-- Needs to be patched..
function new_round()
    -- .. because of this;
    -- local blhash = '' 
    -- if G.GAME.round_resets.blind == G.P_BLINDS.bl_small then
    --     G.GAME.round_resets.blind_states.Small = 'Current'
    --     G.GAME.current_boss_streak = 0
    --     blhash = 'S'
    -- elseif G.GAME.round_resets.blind == G.P_BLINDS.bl_big then
    --     G.GAME.round_resets.blind_states.Big = 'Current'
    --     G.GAME.current_boss_streak = 0
    --     blhash = 'B'
    -- else
    --     G.GAME.round_resets.blind_states.Boss = 'Current'
    --     blhash = 'L'
    -- end
    -- G.GAME.subhash = (G.GAME.round_resets.ante)..(blhash)
    -- G.GAME.blind:set_blind(G.GAME.round_resets.blind)
end

-- end_round() TODO : move to lovely patches
function end_round()
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.2,
        func = function()
            G.GAME.blind.in_blind = false
            local game_over = true
            local game_won = false
            G.RESET_BLIND_STATES = true
            G.RESET_JIGGLES = true
            if G.GAME.chips - G.GAME.blind.chips >= 0 then
                game_over = false
            end
            -- context.end_of_round calculations
            SMODS.saved = false
            G.GAME.saved_text = nil
            SMODS.calculate_context({end_of_round = true, game_over = game_over, beat_boss = G.GAME.blind.boss })
            if SMODS.saved then game_over = false end
            -- TARGET: main end_of_round evaluation
            if G.GAME.round_resets.ante == G.GAME.win_ante and G.GAME.blind:is_type("Boss") then
                game_won = true
                G.GAME.won = true
            end
            if game_over then
                G.STATE = G.STATES.GAME_OVER
                if not G.GAME.won and not G.GAME.seeded and not G.GAME.challenge then 
                    G.PROFILES[G.SETTINGS.profile].high_scores.current_streak.amt = 0
                end
                G:save_settings()
                G.FILE_HANDLER.force = true
                G.STATE_COMPLETE = false
            else
                G.GAME.unused_discards = (G.GAME.unused_discards or 0) + G.GAME.current_round.discards_left
                if G.GAME.blind and G.GAME.blind.config.blind then 
                    discover_card(G.GAME.blind.config.blind)
                end

                if G.GAME.blind:is_type("Boss") then
                    local _handname, _played, _order = 'High Card', -1, 100
                    for k, v in pairs(G.GAME.hands) do
                        if v.played > _played or (v.played == _played and _order > v.order) then 
                            _played = v.played
                            _handname = k
                        end
                    end
                    G.GAME.current_round.most_played_poker_hand = _handname
                end

                if G.GAME.blind:is_type("Boss") and not G.GAME.seeded and not G.GAME.challenge  then
                    G.GAME.current_boss_streak = G.GAME.current_boss_streak + 1
                    check_and_set_high_score('boss_streak', G.GAME.current_boss_streak)
                end
                
                if G.GAME.current_round.hands_played == 1 then 
                    inc_career_stat('c_single_hand_round_streak', 1)
                else
                    if not G.GAME.seeded and not G.GAME.challenge  then
                        G.PROFILES[G.SETTINGS.profile].career_stats.c_single_hand_round_streak = 0
                        G:save_settings()
                    end
                end

                check_for_unlock({type = 'round_win'})
                set_joker_usage()
                if game_won and not G.GAME.win_notified then
                    G.GAME.win_notified = true
                    G.E_MANAGER:add_event(Event({
                        trigger = 'immediate',
                        blocking = false,
                        blockable = false,
                        func = (function()
                            if SMODS.GameStates[G.STATE] and SMODS.GameStates[G.STATE].check_win then
                                win_game()
                                G.GAME.won = true
                                return true
                            end
                        end)
                    }))
                end
                for _,v in ipairs(SMODS.get_card_areas('playing_cards', 'end_of_round')) do
                    SMODS.calculate_end_of_round_effects({ cardarea = v, end_of_round = true, beat_boss = G.GAME.blind.boss })
                end

                G.FUNCS.draw_from_hand_to_discard()
                if G.GAME.blind:is_type("Boss") then
                    G.GAME.voucher_restock = nil
                    if G.GAME.modifiers.set_eternal_ante and (G.GAME.round_resets.ante == G.GAME.modifiers.set_eternal_ante) then 
                        for k, v in ipairs(G.jokers.cards) do
                            v:set_eternal(true)
                        end
                    end
                    if G.GAME.modifiers.set_joker_slots_ante and (G.GAME.round_resets.ante == G.GAME.modifiers.set_joker_slots_ante) then 
                        G.jokers.config.card_limit = 0
                    end
                    delay(0.4)
                end
                G.FUNCS.draw_from_discard_to_deck()
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.3,
                    func = function()
                        if SMODS.get_current_state().args.trigger_callbacks then
                            SMODS.get_active_ap_node():trigger_callbacks("defeated")
                        end
                        G.STATE_COMPLETE = false

                        if G.GAME.round_resets.blind == G.P_BLINDS.bl_small then
                            -- TODO : Check/Replace blind_states
                            G.GAME.round_resets.blind_states.Small = 'Defeated'
                        elseif G.GAME.round_resets.blind == G.P_BLINDS.bl_big then
                            G.GAME.round_resets.blind_states.Big = 'Defeated'
                        else
                            G.GAME.current_round.voucher = SMODS.get_next_vouchers()
                            G.GAME.round_resets.blind_states.Boss = 'Defeated'
                            for k, v in ipairs(G.playing_cards) do
                                v.ability.played_this_ante = nil
                            end
                        end

                        if G.GAME.round_resets.temp_handsize then G.hand:change_size(-G.GAME.round_resets.temp_handsize); G.GAME.round_resets.temp_handsize = nil end
                        if G.GAME.round_resets.temp_reroll_cost then G.GAME.round_resets.temp_reroll_cost = nil; calculate_reroll_cost(true) end

                        reset_idol_card()
                        reset_mail_rank()
                        reset_ancient_card()
                        reset_castle_card()
                        for _, mod in ipairs(SMODS.mod_list) do
                            if mod.reset_game_globals and type(mod.reset_game_globals) == 'function' then
                                mod.reset_game_globals(false)
                            end
                        end
                        for k, v in ipairs(G.playing_cards) do
                            v.ability.discarded = nil
                            v.ability.forced_selection = nil
                        end
                    return true
                    end
                }))
            end
            return true
        end
    }))
end

-- get_blind_main_colour() -> replace using own system for blind_states
function get_blind_main_colour(blind)

end

-- Toggle Shop -> Functionality is handled by custom SMODS.GameStates and APNodeCallbacks
function G.FUNCS.toggle_shop(e)
    if SMODS.get_current_state().args.trigger_callbacks then
        SMODS.get_active_ap_node():trigger_callbacks("shop_ended")
    end
end

-- Select Blind -> Replaced by SMODS.GameStates.BLIND:on_enter()
function G.FUNCS.select_blind(e) end

-- Skip Blind (-> use own func in UI defs)
function G.FUNCS.skip_blind(e) end

-- Reroll Boss (-> use own func in UI defs)
function G.FUNCS.reroll_boss(e) end

function G.FUNCS.reroll_boss_button(e) end

ease_bg_col_bl_ref = ease_background_colour_blind
function ease_background_colour_blind(state, blind_override)
    if SMODS.GameStates[state] and SMODS.GameStates[state].ease_background_colour then
        return SMODS.GameStates[state]:ease_background_colour(blind_override)
    end
    return ease_bg_col_bl_ref(state, blind_override)
end