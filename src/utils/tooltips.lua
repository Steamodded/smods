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
    if not aut then return end
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
    self.type = self.ability.set
    SMODS.current_aut = aut
    for _, mod in ipairs(SMODS.mod_list) do
        if mod.can_load and mod.check_multi_box and type(mod.check_multi_box) == "function" then
            mod.check_multi_box(self)
        end
    end
    SMODS.current_aut = nil
    return aut
end

local l = Tag.get_uibox_table
function Tag:get_uibox_table(tag_sprite, vars_only)
    local tag_sprite = l(self, tag_sprite, vars_only)
    SMODS.current_aut = tag_sprite.ability_UIBox_table
    tag_sprite.type = 'Tag'
    self.type = 'Tag'
    for _, mod in ipairs(SMODS.mod_list) do
        if mod.can_load and mod.check_multi_box and type(mod.check_multi_box) == "function" then
            mod.check_multi_box(self)
        end
    end
    SMODS.current_aut = nil
    return tag_sprite
end

--- TOOLTIP CODE BELOW
function SMODS.remove_objects(t)
    local objects = SMODS.deepfind(t, 'object', 'i', false)
    for _, obj in ipairs(objects) do
        obj.table.object:remove()
    end
end

function G.UIDEF.card_h_popup(card)
    if not card.ability_UIBox_table then return end
    -- Remove any leftover tooltips
    if card.config.h_popup then card.config.h_popup = nil end

    SMODS.current_tooltip_card = card
    local AUT = card.ability_UIBox_table
    AUT.main.background_colour = AUT.main.background_colour or AUT.box_colours and AUT.box_colours[1] or nil
   
    local tooltip_container, bypass = SMODS.create_tooltip(card, AUT)
    bypass = bypass or {}

    -- Remove all DynaText/Sprite objects from elements that have been blocked
    for k, _ in pairs(bypass) do
        if AUT[k] then SMODS.remove_objects(AUT[k]) end
    end

    local function missing_section(type)
        sendWarnMessage(('%s\'s tooltip has not bypassed %s and is missing the %s container'):format(card.config.center_key, type, type))
    end

    -- Insert each section of the tooltip into the correct place
    if not bypass.name and AUT.name and type(AUT.name) == 'table' and next(AUT.name) then
        local name_container = SMODS.deepfind(tooltip_container, 'add_name', 'i', true)[1]
        if name_container then table.insert(name_container.objtree[#name_container.objtree-2].nodes, SMODS.create_tooltip_name(card, AUT)) else missing_section('name') end
    end
    
    if not bypass.main and AUT.main and next(AUT.main) then
        local main_container = SMODS.deepfind(tooltip_container, 'add_main', 'i', true)[1]
        AUT.main.main_box_flag = true
        if main_container then table.insert(main_container.objtree[#main_container.objtree-2].nodes, SMODS.create_tooltip_desc_boxes(card, {AUT.main})[1]) else missing_section('main') end
    end

    if not bypass.multi_box and AUT.multi_box and next(AUT.multi_box) then
        local multi_box_container = SMODS.deepfind(tooltip_container, 'add_multibox', 'i', true)[1] or SMODS.deepfind(tooltip_container, 'add_main', 'i')[1]
        local multi_boxes = SMODS.create_tooltip_desc_boxes(card, SMODS.get_multi_boxes(AUT.multi_box, AUT))
        if multi_box_container then
            for j = 1, #multi_boxes do
                table.insert(multi_box_container.objtree[#multi_box_container.objtree-2].nodes, multi_boxes[j])
            end
        else
            missing_section('multi_box')
        end
    end
    
    if not bypass.badges and card.prototype then
        local badge_container = SMODS.deepfind(tooltip_container, 'add_badges', 'i', true)[1]
        if badge_container then
            local badges = SMODS.gather_badges(card, AUT)
            if badges[1] then table.insert(badge_container.objtree[#badge_container.objtree-2].nodes, {n=G.UIT.R, config={align="cm", padding=0.03}, nodes=badges}) end
        else missing_section('badges') end
    end

    if not bypass.mod_badge and card.prototype then
        local badge_container = SMODS.deepfind(tooltip_container, 'add_mod_badge', 'i', true)[1] or SMODS.deepfind(tooltip_container, 'add_badges', 'i', true)[1]
        if badge_container then
            local badges = {}
            if AUT.card_type ~= 'Locked' and AUT.card_type ~= 'Undiscovered' then
                SMODS.create_mod_badges(card:prototype(), badges)
                if card.base then
                    SMODS.create_mod_badges(SMODS.Ranks[card.base.value], badges)
                    SMODS.create_mod_badges(SMODS.Suits[card.base.suit], badges)
                end
                badges.mod_set = nil
            end
            if badges[1] then table.insert(badge_container.objtree[#badge_container.objtree-2].nodes, {n=G.UIT.R, config={align="cm", padding=0.03}, nodes=badges}) end
        else missing_section('mod_badge') end
    end

    if not bypass.info and AUT.info then
        local info_boxes_container = SMODS.deepfind(tooltip_container, 'add_info', 'i', true)[1]
        if info_boxes_container then
            info_boxes_container.objtree[#info_boxes_container.objtree-2].config.func = 'show_infotip'
            info_boxes_container.objtree[#info_boxes_container.objtree-2].config.object = Moveable()
            info_boxes_container.objtree[#info_boxes_container.objtree-2].config.ref_table = {SMODS.create_info_boxes(card, AUT)}
        else missing_section('info_queue') end
    end

    if not bypass.card_credits and card.prototype then
        local obj = card:prototype()
        local credit_func = obj.set_card_credits or (obj.mod and obj.mod.set_card_credits)
        if credit_func then
            local credit_container = SMODS.deepfind(tooltip_container, 'add_credits', 'i', true)[1] or SMODS.deepfind(tooltip_container, 'add_badges', 'i', true)[1]
            if credit_container then
                table.insert(credit_container.objtree[#credit_container.objtree-2].nodes, credit_func(obj, card))
            end
        end
    end

    SMODS.current_tooltip_card = nil
    card.type = nil
    return tooltip_container
end

function SMODS.create_tooltip(card, aut)
    for _, mod in ipairs(SMODS.mod_list) do
        if mod.can_load and mod.custom_tooltip and mod.custom_tooltip.container and type(mod.custom_tooltip.container) == "function" then
            local res, bypass = mod.custom_tooltip.container(card, aut)
            if res then return res, bypass end
        end
    end

    -- Default container
    local card_type_background = aut.card_type == 'Locked' and G.C.BLACK or aut.card_type == 'Undiscovered' and darken(G.C.JOKER_GREY, 0.3) or darken(G.C.BLACK, 0.1)
    return {n=G.UIT.ROOT, config = {align = 'cm', colour = G.C.CLEAR}, nodes = {
        {n=G.UIT.C, config = {align = "cm", add_info = true}, nodes = {
            {n=G.UIT.R, config = {padding = 0.05, r = 0.12, colour = lighten(G.C.JOKER_GREY, 0.5), emboss = 0.07}, nodes = {
                {n=G.UIT.C, config = {align = "cm", padding = 0.07, r = 0.1, colour = adjust_alpha(card_type_background, 0.8), add_name = true, add_main = true, add_badges = true, add_credits = true}, nodes = {}}
            }}
        }}
    }}
end

function SMODS.create_tooltip_name(card, aut)
    for _, mod in ipairs(SMODS.mod_list) do
        if mod.can_load and mod.custom_tooltip and mod.custom_tooltip.name and type(mod.custom_tooltip.name) == "function" then
            local res = mod.custom_tooltip.name(card, aut.name)
            if res then return res end
        end
    end

    -- Default name
    return name_from_rows(aut.name, SMODS.is_playing_card(card) and G.C.WHITE or nil)
end

function SMODS.create_tooltip_desc_boxes(card, boxes)
    local final_boxes = {}
    for _, box in ipairs(boxes) do
        table.insert(final_boxes, SMODS.create_tooltip_desc_box(card, box, box.main_box_flag and 1 or _+1))
    end
    return final_boxes
end

function SMODS.create_tooltip_desc_box(card, box, multi_box_number)
    for _, mod in ipairs(SMODS.mod_list) do
        if mod.can_load and mod.custom_tooltip and mod.custom_tooltip.desc_box and type(mod.custom_tooltip.desc_box) == "function" then
            local res = mod.custom_tooltip.desc_box(card, box, multi_box_number)
            if res then return res end
        end
    end

    -- Default desc box
    return desc_from_rows(box)
end

function SMODS.create_info_queue(card, info_queue)
    for _, mod in ipairs(SMODS.mod_list) do
        if mod.can_load and mod.custom_tooltip and mod.custom_tooltip.info_queue and type(mod.custom_tooltip.info_queue) == "function" then
            local res, skip = mod.custom_tooltip.info_queue(card, info_queue)
            if skip then return end
            if res then return res end
        end
    end
    
    -- Default info queue element
    return {n=G.UIT.R, config = {align = "cm"}, nodes = {
        {n=G.UIT.R, config = {align = "cm", colour = lighten(G.C.JOKER_GREY, 0.5), r = 0.1, padding = 0.05, emboss = 0.05}, nodes = {
            info_tip_from_rows(info_queue, info_queue.name)
        }}
    }}
end

function SMODS.gather_badges(card, AUT)
    local badges = {}
    local obj = card:prototype()
   
    if AUT.badges.card_type or AUT.badges.force_rarity then
        local card_type = localize('k_' .. string.lower(AUT.card_type))
        if AUT.card_type == 'Joker' or (AUT.badges and AUT.badges.force_rarity) then 
            card_type = SMODS.Rarity:get_rarity_badge(card.config.center.rarity)
        end
        if AUT.card_type == 'Enhanced' then
            card_type = localize { type = 'name_text', key = card.config.center.key, set = 'Enhanced' }
        end
    
        card_type = (card.debuff and AUT.card_type ~= 'Enhanced') and localize('k_debuffed') or card_type

        if obj.set_card_type_badge or obj.type and obj.type.set_card_type_badge then
            if type(obj.set_card_type_badge) == 'function' then
                obj:set_card_type_badge(card, badges)
            elseif obj.type and type(obj.type.set_card_type_badge) == 'function' then
                obj.type:set_card_type_badge(obj, card, badges)
            end
        else
            badges[#badges + 1] = create_badge(card_type, get_type_colour(obj, card), SMODS.get_card_type_text_colour(AUT.card_type, obj, card), 1.2)
        end
    end
    if obj and obj.set_badges and type(obj.set_badges) == 'function' then
        obj:set_badges(card, badges)
    end
    if AUT.badges then
        for k, v in ipairs(AUT.badges) do
            if v:sub(v:len() - 14) == '_SMODS_INTERNAL' then
                if v:sub(1, 9) == 'negative_' then v = 'negative' else v = v:sub(1, v:find('_', v:find('_') + 1) - 1) end
            end
            badges[#badges + 1] = create_badge(localize(v, "labels"), get_badge_colour(v), SMODS.get_badge_text_colour(v))
        end
    end
    
    if obj and obj.pools then
        for k, v in pairs(SMODS.ObjectTypes) do
            if obj.pools[v.key] and type(v.set_badges) == "function" then
                v:set_badges(card, badges)
            end
        end
    end

    return badges
end

function SMODS.create_info_boxes(card, AUT)
    local info_boxes = {}
    for k, v in ipairs(AUT.info) do
        info_boxes[#info_boxes + 1] = SMODS.create_info_queue(card, v)
    end

    local count = #info_boxes
    local cols = count <= 3 and 1 or count <= 10 and 2 or count <= 24 and 3 or 4
    local nodes_per_col = math.ceil(#info_boxes / cols)

    local info_cols = {}
    for i = 0, cols - 1 do
        local col = {}
        for j = 1, nodes_per_col do
            local info_box = info_boxes[i * nodes_per_col + j]
            if info_box then
                table.insert(col, info_box)
            else
                break
            end
        end
        table.insert(info_cols, { n = G.UIT.C, config = { align = "cm" }, nodes = col })
    end

    return {n = G.UIT.R, config = { align = "cm", padding = 0.05, card_pos = card.T.x }, nodes = info_cols}
end