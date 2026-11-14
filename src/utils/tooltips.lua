function SMODS.fake_card(center)
    local ability = copy_table(center.config)
    ability.set = center.set
    ability.name = center.name
    ability.x_mult = center.config.Xmult or center.config.x_mult
    if ability.name == 'To Do List' then
        ability.to_do_poker_hand = 'High Card'
    end
    if ability.name == "Invisible Joker" then 
        ability.invis_rounds = 0
    end
    if ability.name == 'To Do List' then
        local _poker_hands = {}
        for k, v in pairs(G.GAME.hands) do
            if SMODS.is_poker_hand_visible(k) and k ~= ability.to_do_poker_hand then _poker_hands[#_poker_hands+1] = k end
        end
        ability.to_do_poker_hand = pseudorandom_element(_poker_hands, pseudoseed('to_do'))
    end
    if ability.name == 'Caino' then 
        ability.caino_xmult = 1
    end
    if ability.name == 'Yorick' then 
        ability.yorick_discards = ability.extra.discards
    end
    if ability.name == 'Loyalty Card' then 
        ability.burnt_hand = 0
        ability.loyalty_remaining = ability.extra.every
    end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       

    return {ability = ability, config = {center = center}, bypass_lock = true}
end

function SMODS.add_multi_box(args)
    local aut = SMODS.current_aut
    aut.multi_box = aut.multi_box or {}
    aut.box_starts = aut.box_starts or {}
    aut.box_ends = aut.box_ends or {}
    aut.box_colours = aut.box_colours or {}
    aut.info = aut.info or {}
    args = type(args) == 'table' and args or {key = args}
    local _c = G.P_CENTERS[args.key]
    args.set = args.set or _c and _c.set or 'Other'
    local vars, info, starts, ends, colours = {}, {}, {}, {}, {}
    if _c then
        local res = {}
        if _c.loc_vars and type(_c.loc_vars) == 'function' then
            res = _c:loc_vars(info, _c:create_fake_card()) or {}
            vars = res.vars or {}
            local j = 1
            starts = SMODS.merge_lists({{res.main_start}, res.box_starts})
            ends = SMODS.merge_lists({{res.main_end}, res.box_ends})
            -- Format box_colours correctly
            vars.box_colours = vars.box_colours or {}
            vars.box_colours[1] = vars.box_colours[1] or res.background_colour
            colours = vars.box_colours
        else
            SMODS.new_multibox = true
            local res, ms, me = Card.generate_UIBox_ability_table(SMODS.fake_card(_c), true)
            generate_card_ui(_c, nil, nil, _c.set, {}, nil, ms ,me)
            vars = res or SMODS.new_multibox.vars
            info = SMODS.new_multibox.info
            starts[1] = SMODS.new_multibox.ms
            ends[1] = SMODS.new_multibox.me
            SMODS.new_multibox = nil
        end
    end
    args.vars = args.vars or vars
    local loc_target = args.loc_target and {args.loc_target} or G.localization.descriptions[args.set][args.key]
    if not args.loc_target then
        if type(loc_target.text) == 'table' and type(loc_target.text[1]) == 'table' then
            loc_target = loc_target.text_parsed
        else
            loc_target = {loc_target.text_parsed}
        end
    end
    for box_it, _box in ipairs(loc_target) do
        local box = {}
        for j, line in ipairs(_box) do
            local final_line = SMODS.localize_box(line, args)
            box[#box+1] = final_line
        end
        box.flags = args.flags or {}
        aut.multi_box[#aut.multi_box+1] = box
        aut.box_starts[#aut.multi_box] = starts[box_it]
        aut.box_ends[#aut.multi_box] = ends[box_it]
        box.background_colour = colours[box_it] or args.background_colour or G.C.UI.BACKGROUND_WHITE
    end
    -- SMODS.remove_objects(aut.name)
    for _, v in ipairs(info or {}) do
        generate_card_ui(v, aut)
    end
    
end

function SMODS.get_multi_boxes(multi_box, AUT)
    local multi_boxes = {}
    if multi_box then
        for i, box in ipairs(multi_box) do
            box.background_colour = box.background_colour or AUT.box_colours and AUT.box_colours[i+1] or nil
            if AUT.box_starts and AUT.box_starts[i] then table.insert(box, 1, AUT.box_starts[i]) end
            if AUT.box_ends and AUT.box_ends[i] then table.insert(box, AUT.box_ends[i]) end
        end
    end
    return multi_box
end

local loc = Card.generate_UIBox_ability_table
function Card:generate_UIBox_ability_table(v)
    if v then return loc(self, v) end
    local aut = loc(self)
    SMODS.current_aut = aut
    for _, mod in ipairs(SMODS.mod_list) do
        if mod.can_load and mod.check_multi_box and type(mod.check_multi_box) == "function" then
            mod.check_multi_box(self)
        end
    end
    SMODS.current_aut = nil
    return aut
end