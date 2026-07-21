SMODS.RunSelect = {
    Pages = {},
    Internals = {
        quick_start_text_functions = {},
        preview_texts = {
            preview_text_1 = {},
            preview_text_2 = {},
        },
        previous_button_text = '',
        next_button_text = '',
        pages = {},
        current_page = 1,
        select_areas = {},
        hover_index = 0,
    },
    Setup = {
        choices = {
            seed = '',
        },
    },
    Functions = {},
    Colours = {
        play = HEX('00BE67'),
        nav_button = HEX('3FC7EB'),
        seed_input = copy_table(G.C.UI.TEXT_INACTIVE),
        quick_start = G.C.ORANGE,
        waiting = G.C.RED,
    }
}

-- Replaces the New Run tab in the Play menu
function G.UIDEF.run_select_galdur(type)
    SMODS.RunSelect.Setup.choices = EMPTY(SMODS.RunSelect.Setup.choices)
    if not G.E_MANAGER.queues.run_select then
        G.E_MANAGER.queues.run_select = {}
    end
    G.PROFILES[G.SETTINGS.profile].last_choices = G.PROFILES[G.SETTINGS.profile].last_choices or {}
    if not G.SAVED_GAME then
        G.SAVED_GAME = get_compressed(G.SETTINGS.profile..'/'..'save.jkr')
        if G.SAVED_GAME ~= nil then G.SAVED_GAME = STR_UNPACK(G.SAVED_GAME) end
    end
    G.SETTINGS.current_setup = type
  
    for key, page in pairs(SMODS.RunSelect.Pages) do
        SMODS.RunSelect.Setup.choices[key] = page:set_default(G.PROFILES[G.SETTINGS.profile].last_choices[key])
    end
    SMODS.RunSelect.Setup.choices.seed = ''
    
    SMODS.RunSelect.Internals.current_page = 1
    SMODS.RunSelect.Functions.update_nav_bar()

    local t =
    {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR, minh = 6.6, minw = 6}, nodes={
        {n = G.UIT.C, nodes = {
            {n=G.UIT.R, config = {align = "cm", minw = 3}, nodes ={
                {n = G.UIT.O, config = {id = 'run_select', object = UIBox{
                    definition = SMODS.RunSelect.Functions.create_page(SMODS.RunSelect.Internals.pages[SMODS.RunSelect.Internals.current_page]),
                    config = {align = "cm", offset = {x=0,y=0}}
                }}},
            }},
            SMODS.RunSelect.Functions.nav_bar()
        }}
    }}

    return t
end

function SMODS.RunSelect.Functions.create_page(key)
    local page_def = SMODS.RunSelect.Pages[key]
    SMODS.RunSelect.Setup.choices[key] = SMODS.RunSelect.Setup.choices[key] or page_def:set_default(G.PROFILES[G.SETTINGS.profile].last_choices[key])
    SMODS.RunSelect.Functions.build_selection_areas(key)
    
    local deck_preview, stake_tower, other_preview
    if page_def.include_deck_preview then
        SMODS.RunSelect.Functions.build_preview_areas('deck_choice')
        deck_preview = SMODS.RunSelect.Functions.build_preview_ui('deck_choice', true)
        SMODS.RunSelect.Functions.populate_preview_ui('deck_choice', SMODS.RunSelect.Setup.choices.deck_choice, true)
    end
    if page_def.include_stake_tower then
        SMODS.RunSelect.Functions.build_stake_tower()
        stake_tower = SMODS.RunSelect.Functions.build_stake_tower_ui()
        SMODS.RunSelect.Functions.populate_stake_tower(SMODS.RunSelect.Setup.choices.stake_choice, true)
    end
    if page_def.automatic_preview then
        SMODS.RunSelect.Functions.build_preview_areas(key)
        other_preview = SMODS.RunSelect.Functions.build_preview_ui(key)
        SMODS.RunSelect.Functions.populate_preview_ui(key, SMODS.RunSelect.Setup.choices[key], true)
    end

    local previews = {n=G.UIT.C, nodes = {
        {n=G.UIT.R, nodes = {other_preview, stake_tower, deck_preview}}
    }}

    if page_def.random_select then
        previews.nodes[#previews.nodes+1] = {n = G.UIT.R, config={align = 'cm'}, nodes = {
            {n=G.UIT.C, config = {maxw = 2.5, minw = 2.5, minh = 0.6, r = 0.1, hover = true, ref_value = 1, button = 'random_type', page_key = page_def.key, colour = SMODS.RunSelect.Colours.nav_button, align = "cm", emboss = 0.1}, nodes = {
                {n=G.UIT.R, config = {align = 'cm'}, nodes = {{n=G.UIT.T, config={text = localize('run_select_'..page_def.key .. '_random'), scale = 0.4, colour = G.C.WHITE}}}},
                {n=G.UIT.R, config = {align = 'cm'}, nodes = {{n=G.UIT.C, config={func = 'set_button_pip', focus_args = { button = 'triggerright', set_button_pip = true, offset = {x=-0.2, y = 0.3} }}}}}            
            }}
        }}
    end

    local page_ui = page_def.definition or 
    page_def.pool and function()
        return {n=G.UIT.C, config = {padding = 0.1}, nodes ={   
                SMODS.RunSelect.Functions.build_selection_ui(key), 
                SMODS.RunSelect.Functions.create_page_cycle(key, page_def.amount)
            }}
        end
    or page_def.settings and function()
        local settings = page_def:settings()
        for _, node in ipairs(settings) do
            settings[_] = {n=G.UIT.R, config = {align = 'cm', padding = 0.1}, nodes = {node}}
        end
        return {n=G.UIT.C, config = {padding = 0.1}, nodes = {
                {n=G.UIT.R, config={align = "cm", minh = 0.5+G.CARD_H+G.CARD_H, minw = 8.7, colour = G.C.BLACK, padding = 0.15, r = 0.1, emboss = 0.05}, nodes = settings},
                {n=G.UIT.R, config={minh=0.8}}
            }}
        end

    return 
    {n=G.UIT.ROOT, config={align = "tm", minh = 3.8, colour = G.C.CLEAR}, nodes={
        page_ui(page_def), previews
    }}
end

function SMODS.RunSelect.Functions.nav_bar()
    local quick_select_text = {}
    for _, func in ipairs(SMODS.RunSelect.Internals.quick_start_text_functions) do
        local text = func()
        if text then table.insert(quick_select_text, text) end
    end
    
    local t = {n=G.UIT.R, config = {align = "cm", minw = 3, offset = {x=0, y=-5}, padding = 0.15}, nodes = {
        -- Previous Button
        {n = G.UIT.C, config={align='cm'}, nodes = {
            {n=G.UIT.C, config = {id = 'previous_selection', minw = 2, minh = 0.8, maxh = 0.8, r = 0.1, hover = true, ref_value = -1, colour = G.C.CLEAR, align = "cm"}, nodes = {
                {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                    {n=G.UIT.O, config={object = DynaText({string = {{ref_table = SMODS.RunSelect.Internals, ref_value = 'previous_button_text'}}, colours = {G.C.WHITE}, shadow = true, maxw = 1.8, pop_in_rate = 0, scale = 0.4, silent = true})}}
                }},
                {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                    {n=G.UIT.C, config={func = 'set_button_pip_prev', focus_args = { button = 'triggerleft', set_button_pip = true, offset = {x=-0.2, y = 0.3}}}}
                }}
            }}
        }},
        -- Seed Input
        {n=G.UIT.C, config={align = "cr", padding = 0.05}, nodes={
            {n=G.UIT.O, config={id = 'seed_input', align = "cm", object = UIBox{
                config = {offset = {x=0,y=0}, parent = e, type = 'cm'},
                definition = {n=G.UIT.ROOT, config={align = "cr", colour = G.C.CLEAR}, nodes={
                    {n=G.UIT.R, config={align = "cm", minw = 0.1}, nodes={
                        {n=G.UIT.C, config={maxw = 3.1}, nodes = {
                            create_text_input({id = 'run_select_seeded_input', w = 3, max_length = 8, all_caps = true, ref_table = SMODS.RunSelect.Setup.choices, ref_value = 'seed', prompt_text = localize('k_enter_seed'), colour = SMODS.RunSelect.Colours.seed_input, hooked_colour = darken(SMODS.RunSelect.Colours.seed_input, 0.3)})
                        }},
                        {n=G.UIT.C, config={align = "cm", minw = 0.1}},
                        UIBox_button({id = 'run_select_seeded_paste', label = localize('ml_paste_seed'), minw = 1, minh = 0.6, button = 'run_select_paste_seed', colour = SMODS.RunSelect.Colours.seed_input, scale = 0.3, col = true})
                    }}
                }},
            }}},
        }},
        -- Seed Toggle
        {n=G.UIT.C, config={align = "cm", minw = 2, id = 'run_setup_seed'}, nodes={
            {n=G.UIT.R, config={align='cr'}, nodes = {
                create_toggle{col = true, label = localize('run_setup_enable_seed'), label_scale = 0.25, w = 0, scale = 0.7, ref_table = SMODS.RunSelect.Setup.choices, ref_value = 'enable_seed', callback = SMODS.RunSelect.Functions.update_seed_input}
            }}
        }},
        -- Next Button
        {n = G.UIT.C, config={align='cm'}, nodes = {
            {n=G.UIT.C, config = {id = 'next_selection', minw = 2, minh = 0.8, maxh = 0.8, r = 0.1, hover = true, ref_value = 1, func = 'run_select_can_change_page',
            button = 'run_select_change_page', colour = SMODS.RunSelect.Colours.nav_button, align = "cm", emboss = 0.1}, nodes = {
                {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                    {n=G.UIT.O, config={object = DynaText({string = {{ref_table = SMODS.RunSelect.Internals, ref_value = 'next_button_text'}}, colours = {G.C.WHITE}, shadow = true, maxw = 1.8, pop_in_rate = 0, scale = 0.4, silent = true})}}
                }},
                {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                    {n=G.UIT.C, config={func = 'set_button_pip', focus_args = { button = 'x', set_button_pip = true, offset = {x=-0.2, y = 0.3}}}}
                }}
            }}
        }},
        -- Quick Start Button
        {n = G.UIT.C, config={align='cm'}, nodes = {
            {n=G.UIT.R, config = {maxw = 2, minw = 2, minh = 0.8, r = 0.1, hover = true, ref_value = 1,
            button = 'run_select_quick_start', colour = SMODS.RunSelect.Colours.quick_start, align = "cm", emboss = 0.1, tooltip = {text = quick_select_text} }, nodes = {
                {n = G.UIT.C, config = {align = 'cm'} , nodes = {
                    {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                        {n=G.UIT.T, config={text = localize('run_select_quick_start'), scale = 0.4, colour = G.C.WHITE}}
                    }},
                    {n=G.UIT.R, config = {align = 'cm'}, nodes = {
                        {n=G.UIT.C, config={func = 'set_button_pip', focus_args = {button = 'y', set_button_pip = true, offset = {x=-0.2, y = 0.3}}}
                    }}}
                }}
            }}
        }}
    }}
    
    return t
end

function SMODS.RunSelect.Functions.update_nav_bar(ui)
    local previous_active = SMODS.RunSelect.Internals.current_page > 1
    local prev_page_index = SMODS.RunSelect.Functions.get_page_key(-1)
    local next_page_index = SMODS.RunSelect.Functions.get_page_key(1)
    local final = SMODS.RunSelect.Internals.current_page == #SMODS.RunSelect.Internals.pages or next_page_index > #SMODS.RunSelect.Internals.pages
    SMODS.RunSelect.Internals.previous_button_text = previous_active and '< ' .. localize('run_select_'..SMODS.RunSelect.Internals.pages[prev_page_index]) or ''
    SMODS.RunSelect.Internals.next_button_text = final and localize('run_select_play') or (localize('run_select_'..SMODS.RunSelect.Internals.pages[next_page_index]) .. ' >')
    if not ui then return end

    local prev_button = ui.UIBox:get_UIE_by_ID('previous_selection')
    local next_button = ui.UIBox:get_UIE_by_ID('next_selection')

    prev_button.config.button = previous_active and 'run_select_change_page' or nil
    prev_button.config.emboss = previous_active and 0.1 or 0
    prev_button.config.hover = previous_active and true or false
    prev_button.config.colour = previous_active and SMODS.RunSelect.Colours.nav_button or G.C.CLEAR

    prev_button.children[1].children[1].config.object:remove()
    prev_button.children[1].children[1].config.object = DynaText({string = {{ref_table = SMODS.RunSelect.Internals, ref_value = 'previous_button_text'}}, colours = {G.C.WHITE}, shadow = true, maxw = 1.8, pop_in_rate = 0, scale = 0.4, silent = true})
    next_button.children[1].children[1].config.object:remove()
    next_button.children[1].children[1].config.object = DynaText({string = {{ref_table = SMODS.RunSelect.Internals, ref_value = 'next_button_text'}}, colours = {G.C.WHITE}, shadow = true, maxw = 1.8, pop_in_rate = 0, scale = 0.4, silent = true})
end

function SMODS.RunSelect.Functions.update_seed_input(value)
    if value then
        SMODS.RunSelect.Colours.seed_input = HEX('3FC7EB')
    else
        SMODS.RunSelect.Colours.seed_input = copy_table(G.C.UI.TEXT_INACTIVE)
    end
    local args = G.OVERLAY_MENU:get_UIE_by_ID('run_select_seeded_input').children[1].children[1].config.ref_table
    args.colour = SMODS.RunSelect.Colours.seed_input
    args.hooked_colour = darken(SMODS.RunSelect.Colours.seed_input, 0.3)
    G.OVERLAY_MENU:get_UIE_by_ID('run_select_seeded_paste').config.colour = SMODS.RunSelect.Colours.seed_input
    G.OVERLAY_MENU:get_UIE_by_ID('run_select_seeded_input_prompt').config.colour = lighten(copy_table(SMODS.RunSelect.Colours.seed_input),0.4)
end

G.FUNCS.set_button_pip_prev = function(e)
    if SMODS.RunSelect.Internals.current_page > 1 then
        G.FUNCS.set_button_pip(e)
    elseif e.children.button_pip then
        e.children.button_pip:remove()
        e.children.button_pip = nil
    end
end

G.FUNCS.run_select_can_change_page = function(e)
    local page_def = SMODS.RunSelect.Pages[SMODS.RunSelect.Internals.pages[SMODS.RunSelect.Internals.current_page]]
    if page_def.can_continue then
        if not page_def:can_continue() then
            e.config.button = nil
            e.config.colour = SMODS.RunSelect.Colours.waiting
            return
        end
    end

    local next_page_index = SMODS.RunSelect.Functions.get_page_key(1)
    local final = SMODS.RunSelect.Internals.current_page == #SMODS.RunSelect.Internals.pages or next_page_index > #SMODS.RunSelect.Internals.pages
    local next_button_text = final and localize('run_select_play') or (localize('run_select_'..SMODS.RunSelect.Internals.pages[next_page_index]) .. ' >')

    if next_button_text ~= SMODS.RunSelect.Internals.next_button_text then
        SMODS.RunSelect.Internals.next_button_text = next_button_text
        e.children[1].children[1].config.object:remove()
        e.children[1].children[1].config.object = DynaText({string = {{ref_table = SMODS.RunSelect.Internals, ref_value = 'next_button_text'}}, colours = {G.C.WHITE}, shadow = true, maxw = 1.8, pop_in_rate = 0, scale = 0.4, silent = true})
        e.children[1].children[1].config.object.ui_object_updated = true
    end

    e.config.button = final and 'run_select_start_run' or 'run_select_change_page'
    e.config.colour =  final and SMODS.RunSelect.Colours.play or SMODS.RunSelect.Colours.nav_button
end

G.FUNCS.run_select_change_page = function(e)
    SMODS.RunSelect.Functions.change_page(e)
end

G.FUNCS.run_select_start_run = function(e)
    SMODS.RunSelect.Functions.start_run()
end

G.FUNCS.run_select_quick_start = function(e)
    SMODS.RunSelect.Functions.start_run(true)
end

G.FUNCS.random_type = function(e)
    local page_def = SMODS.RunSelect.Pages[e.config.page_key]
    page_def:choose_random()    
end

G.FUNCS.run_select_paste_seed = function(e)
  G.CONTROLLER.text_input_hook = e.UIBox:get_UIE_by_ID('run_select_seeded_input').children[1].children[1]
  G.CONTROLLER.text_input_id = 'run_select_seeded_input'
  for i = 1, string.len(SMODS.RunSelect.Setup.choices.seed or '') do
    G.FUNCS.text_input_key({key = 'right'})
  end
  for i = 1, string.len(SMODS.RunSelect.Setup.choices.seed or '') do
      G.FUNCS.text_input_key({key = 'backspace'})
  end
  local clipboard = (G.F_LOCAL_CLIPBOARD and G.CLIPBOARD or love.system.getClipboardText()) or ''
  for i = 1, #clipboard do
    local c = clipboard:sub(i,i)
    G.FUNCS.text_input_key({key = c})
  end
  G.FUNCS.text_input_key({key = 'return'})
end


function SMODS.RunSelect.Functions.start_run(_quick_start)
    local run_args = {}
    SMODS.RunSelect.Functions.clean_up()
    
    local access = _quick_start and G.PROFILES[G.SETTINGS.profile].last_choices or SMODS.RunSelect.Setup.choices
    for k, v in pairs(access) do
        run_args[k] = v
    end

    if SMODS.RunSelect.Setup.choices.enable_seed then
        run_args.seed = SMODS.RunSelect.Setup.choices.seed
    else
        run_args.seed = nil
    end

    G.PROFILES[G.SETTINGS.profile].last_choices = copy_table(run_args)
    G:save_settings()
    
    run_args.deck_choice = {name = G.P_CENTERS[run_args.deck_choice].name}
    run_args.stake_choice = G.P_STAKES[run_args.stake_choice].order
    
    G.FUNCS.start_run(nil, run_args)
end

local start_run = Game.start_run
function Game:start_run(args)
    start_run(self, args)
    if args.savetext then return end
    for _, value in ipairs(SMODS.RunSelectPage.obj_buffer) do
        local page = SMODS.RunSelect.Pages[value]
        if (not page.optional or (page.optional and page:optional())) and page.start_run and type(page.start_run) == 'function' and (not page.pool or G.PROFILES[G.SETTINGS.profile].last_choices[value])  then
            page:start_run(G.PROFILES[G.SETTINGS.profile].last_choices[value])
        end
    end
end

function SMODS.RunSelect.Functions.get_page_key(change)
    local next_page = SMODS.RunSelect.Internals.current_page+change
    local valid_page = false
    while not valid_page and SMODS.RunSelect.Internals.pages[next_page] do
        local page = SMODS.RunSelect.Pages[SMODS.RunSelect.Internals.pages[next_page]]
        if page and page.optional then
            valid_page = page:optional()
        else
            valid_page = true
        end
        if valid_page then return next_page end
        next_page = next_page + change
    end
    return next_page
end

function SMODS.RunSelect.Functions.change_page(ui)
    SMODS.RunSelect.Functions.clean_up()
    SMODS.RunSelect.Internals.current_page = SMODS.RunSelect.Functions.get_page_key(ui.config.ref_value)
    SMODS.RunSelect.Functions.update_nav_bar(ui)

    local current_selector_page = ui.UIBox:get_UIE_by_ID('run_select')
    if not current_selector_page then return end
    current_selector_page.config.object:remove()
    current_selector_page.config.object = UIBox{
        definition = SMODS.RunSelect.Functions.create_page(SMODS.RunSelect.Internals.pages[SMODS.RunSelect.Internals.current_page]),
        config = {offset = {x=0,y=0}, parent = current_selector_page, type = 'cm'}
    }
    current_selector_page.UIBox:recalculate()
end

function SMODS.RunSelect.Functions.build_selection_areas(key)
    local page_def = SMODS.RunSelect.Pages[key]
    local dim = page_def.sprite_size or {w = G.CARD_W, h = G.CARD_H}

    if next(SMODS.RunSelect.Internals.select_areas) then
        for i, area in ipairs(SMODS.RunSelect.Internals.select_areas) do
            for j=1, #G.I.CARDAREA do
                if area == G.I.CARDAREA[j] then
                    table.remove(G.I.CARDAREA, j)
                    SMODS.RunSelect.Internals.select_areas[i] = nil
                end
            end
        end
    end

    SMODS.RunSelect.Internals.select_areas = {}
    for i=1, page_def.amount do
        SMODS.RunSelect.Internals.select_areas[i] = CardArea(G.ROOM.T.w, G.ROOM.T.h, dim.w, dim.h, 
        {card_limit = 5, type = page_def.area_type or 'title_2', highlight_limit = 0, deck_height = 0.75, thin_draw = 1, run_select = key, run_select_deck_preview = page_def.area_type == 'deck'})
    end
end

function SMODS.RunSelect.Functions.build_selection_ui(key)
    local page_def = SMODS.RunSelect.Pages[key]
    local dim = {math.min(page_def.grid_size[1], math.ceil(#page_def.pool/page_def.grid_size[2])), page_def.grid_size[2]}
    local ui_nodes = {}
    local count = 1
    local pool_size = #page_def.pool
    for row=1, dim[1] do
        local row_container = {n=G.UIT.R, config = {minw = 5}, nodes = {}}
        for col=1, dim[2] do
            if count > pool_size then break end
            local col_node = {n=G.UIT.O, config = {object = SMODS.RunSelect.Internals.select_areas[count], focus_args = {snap_to = true}}}
            table.insert(row_container.nodes, col_node)
            count = count + 1
        end
        table.insert(ui_nodes, row_container)
    end

    SMODS.RunSelect.Functions.populate_selection_ui(key, 1)

    return {n=G.UIT.R, config={align = "cm", minh = 0.45+G.CARD_H+G.CARD_H, colour = G.C.BLACK, padding = 0.15, r = 0.1, emboss = 0.05}, nodes=ui_nodes}
end

function SMODS.RunSelect.Functions.populate_selection_ui(key, page)
    local page_def = SMODS.RunSelect.Pages[key]
    local areas = SMODS.RunSelect.Internals.select_areas
    
    local card_size = page_def.sprite_size or {w = G.CARD_W, h = G.CARD_H}
    local count = 1 + (page - 1) * page_def.amount
    
    for i=1, (page_def.amount or 10) do
        if count > #page_def.pool then return end
        local stack_size = page_def.stack_size
        if SMODS.config.run_select_performance then stack_size = math.min(5, stack_size) end
        for j=1, stack_size do
            local card = page_def.create_selection_card and page_def:create_selection_card(page_def.pool[count].key, j, areas[i]) 
            or Card(areas[i].T.x, areas[i].T.y, card_size.w, card_size.h, nil, page_def.pool[count])
            card.params.run_select_selection_choice = {i, key}

            areas[i]:emplace(card)
        end
        count = count + 1
    end
end

local cycler = function(args)
    args = args or {}
    args.left = args.left or '<'
    args.right = args.right or '>'
    args.colour = args.colour or SMODS.RunSelect.Colours.nav_button
    args.button_colour = args.button_colour or G.C.WHITE
    args.button = args.button or 'cycler_default'
    args.switch_func = args.switch_func
    args.hover = args.hover or true
    args.object_table = args.object_table -- REQUIRED
    args.page_size = args.page_size -- REQUIRED
    args.page_label = args.page_label -- REQUIRED
    args.label_colour = args.label_colour or G.C.WHITE
    args.scale = args.scale or 0.5
    args.button_w = args.button_w or 3
    args.w = args.w or 8
    args.shadow = args.shadow or true
    args.total_pages = math.ceil(SMODS.table_size(args.object_table)/args.page_size)

    local page_cycler_values = {}

    if not args.page_label then
        page_cycler_values = {page = 1}
        page_cycler_values.text = localize('k_page')..' '..page_cycler_values.page..'/'..args.total_pages
        args.page_label = page_cycler_values
    end 

    local cycler = {n=G.UIT.R, config = {align = 'cm', minh = args.h or nil}, nodes = {
        SMODS.table_size(args.object_table) > args.page_size and {n=G.UIT.C, config={pass_through = args, switch_func = args.switch_func, r = 0.1, colour = args.colour, minw = args.button_w * args.scale, align = 'tm', shadow = args.shadow, direction = -1, button = args.button, hover = args.hover, minh = 0.5}, nodes = {
            {n=G.UIT.T, config = {text = args.left, scale = args.scale, colour = args.button_colour}}
        }} or nil,
        SMODS.table_size(args.object_table) > args.page_size and {n=G.UIT.C, config = {align = 'cm', minw = args.w * args.scale}, nodes = {
            {n=G.UIT.O, config = {object = DynaText({string = {{ref_table = args.page_label, ref_value = 'text'}}, scale = args.scale, colours = {args.label_colour}, pop_in_rate = 0, silent = true})}}
        }} or nil,
        SMODS.table_size(args.object_table) > args.page_size and {n=G.UIT.C, config={pass_through = args, switch_func = args.switch_func, r = 0.1, colour = args.colour, minw = args.button_w * args.scale, align = 'tm', shadow = args.shadow, direction = 1, button = args.button, hover = args.hover, minh = 0.5}, nodes = {
            {n=G.UIT.T, config = {text = args.right, scale = args.scale, colour = args.button_colour}}
        }} or nil,
    }}

    return cycler
end

G.FUNCS.cycler_default = function(e)
    local args = e.config.pass_through
    local page_from = e.config.pass_through.page_label.page
    local page_to = e.config.pass_through.page_label.page + e.config.direction
    if page_to == 0 then page_to = args.total_pages
    elseif page_to > args.total_pages then page_to = 1 end
    e.config.pass_through.page_label.page = page_to
    e.config.pass_through.page_label.text = localize('k_page')..' '..e.config.pass_through.page_label.page..'/'..args.total_pages
    
    if e.config.switch_func and type(e.config.switch_func) == 'function' then
        e.config.switch_func({from = page_from, to = page_to})
    end
end

function SMODS.RunSelect.Functions.create_page_cycle(key, count_per_page)
    local page_def = SMODS.RunSelect.Pages[key]
    local cycler_text = {}
    local total_pages = math.ceil(#page_def.pool / count_per_page)
    for i=1, total_pages do
        table.insert(cycler_text, localize('k_page')..' '..i..' / '..total_pages)
    end

    local switch_func = function(args)
        SMODS.RunSelect.Functions.clean_up(true)
        SMODS.RunSelect.Functions.populate_selection_ui(key, args.to)
    end

    local cycle = cycler({
        object_table = page_def.pool,
        page_size = count_per_page,
        key = page_def.key..'_select_cycle',
        switch_func = switch_func,
        h = 0.8
    })

    return {n=G.UIT.R, config = {align = 'cm'}, nodes = {cycle}}
end

function SMODS.RunSelect.Functions.build_preview_areas(key)
    local page_def = SMODS.RunSelect.Pages[key]
    if SMODS.RunSelect.Internals.preview_area then
        for i=1, #G.I.CARDAREA do
            if SMODS.RunSelect.Internals.preview_area == G.I.CARDAREA[i] then
                table.remove(G.I.CARDAREA, i)
                SMODS.RunSelect.Internals.preview_area = nil
            elseif SMODS.RunSelect.Internals.preview_area_holding == G.I.CARDAREA[i] then
                table.remove(G.I.CARDAREA, i)
                SMODS.RunSelect.Internals.preview_area_holding = nil
            end
        end
    end

    SMODS.RunSelect.Internals.preview_area = CardArea(15.475, 0, G.CARD_W * (page_def.selection_limit > 1 and 1.5 or 1), G.CARD_H,
    {card_limit = page_def.preview_size or page_def.selection_limit, type = page_def.area_type or 'title_2', highlight_limit = 0, run_select_deck_preview = page_def.area_type == 'deck'})
    SMODS.RunSelect.Internals.preview_area_holding = CardArea(15.475+2*G.CARD_W, -2*G.CARD_H, G.CARD_W, G.CARD_H,
    {card_limit = page_def.preview_size or page_def.selection_limit, type = page_def.area_type or 'title_2', highlight_limit = 0})
end

function SMODS.RunSelect.Functions.update_preview_texts(page_def)
    local preview_texts = SMODS.split_string(page_def.selected_text and page_def:selected_text(SMODS.RunSelect.Setup.choices[page_def.key]) or localize('run_select_nothing'))
    for i, text in ipairs(preview_texts) do
        SMODS.RunSelect.Internals.preview_texts['preview_text_'..i] = text
        if not G.OVERLAY_MENU then return end
        local dyna_text_container = G.OVERLAY_MENU:get_UIE_by_ID('preview_text_'..i)
        if not dyna_text_container then return end
        dyna_text_container.config.object.scale = 0.7/math.max(1, string.len(text)/8)
    end
end

function SMODS.RunSelect.Functions.build_preview_ui(key, deck_preview)
    local page_def = SMODS.RunSelect.Pages[key]
    local preview_texts = SMODS.split_string(page_def.selected_text and page_def:selected_text(SMODS.RunSelect.Setup.choices[page_def.key]) or localize('run_select_nothing'))

    for i, text in ipairs(preview_texts) do
        SMODS.RunSelect.Internals.preview_texts[(deck_preview and 'deck_' or '')..'preview_text_'..i] = text
    end

    local preview_area_node = {n=G.UIT.R, config = {align = 'tm'}, nodes = {
        {n=G.UIT.O, config = {align = 'cm', object = SMODS.RunSelect.Internals.preview_area}}
    }}

    return {n=G.UIT.C, config = {align = "tm", padding = 0.1}, nodes ={
        {n = G.UIT.R, config = {minh = 5.95, minw = 3, maxw = 3, colour = G.C.BLACK, r=0.1, align = "bm", padding = 0.15, emboss=0.05}, nodes = {
            {n = G.UIT.R, config = {align = "bm", minh = 0.6, maxw = 2.8}, nodes = {
                {n=G.UIT.O, config = {id = (deck_preview and 'deck_' or '')..'preview_text_1', object = DynaText({
                    string = {{ref_table = SMODS.RunSelect.Internals.preview_texts, ref_value = (deck_preview and 'deck_' or '')..'preview_text_1'}},
                    scale = 0.7/math.max(1, string.len(SMODS.RunSelect.Internals.preview_texts[(deck_preview and 'deck_' or '')..'preview_text_1'])/8),
                    colours = {G.C.GREY}, pop_in_rate = 5, silent = true, non_recalc = true
                })}}
            }},
            {n = G.UIT.R, config = {align = "tm", minh = 0.6, maxw = 2.8}, nodes = {
                {n=G.UIT.O, config = {id = (deck_preview and 'deck_' or '')..'preview_text_2', object = DynaText({
                    string = {{ref_table = SMODS.RunSelect.Internals.preview_texts, ref_value = (deck_preview and 'deck_' or '')..'preview_text_2'}},
                    scale = 0.7/math.max(1, string.len(SMODS.RunSelect.Internals.preview_texts[(deck_preview and 'deck_' or '')..'preview_text_2'])/8),
                    colours = {G.C.GREY}, pop_in_rate = 5, silent = true, non_recalc = true
                })}}
            }},
            {n = G.UIT.R, config = {align = "cm", minh = 0.2}},
                preview_area_node,
            {n = G.UIT.R, config = {minh = 0.8, align = 'bm'}, nodes = {
                {n=G.UIT.O, config = {object = DynaText({
                    string = {localize('run_select_selected')},
                    colours = {G.C.GREY},
                    scale = 0.75,
                    silent = true
                })}}
            }},
        }}
    }}
end 

function SMODS.RunSelect.Functions.populate_preview_ui(key, to_add, silent, _remove)
    if SMODS.config.run_select_performance then silent = true end
    local page_def = SMODS.RunSelect.Pages[key]
    if page_def.selection_limit == 1 and not _remove then
        if G.E_MANAGER.queues.run_select then G.E_MANAGER:clear_queue('run_select') end
        remove_all(SMODS.RunSelect.Internals.preview_area.cards)
        SMODS.RunSelect.Internals.preview_area.cards = {}
        remove_all(SMODS.RunSelect.Internals.preview_area_holding.cards)
        SMODS.RunSelect.Internals.preview_area_holding.cards = {}
    end

    if _remove then
        to_add:remove()
        SMODS.RunSelect.Functions.update_preview_texts(page_def)
        return
    end

    if not SMODS.RunSelect.Setup.choices[page_def.key] or (type(SMODS.RunSelect.Setup.choices[page_def.key]) == 'table' and not next(SMODS.RunSelect.Setup.choices[page_def.key])) then
        return
    end

    local preview_area = SMODS.RunSelect.Internals.preview_area
    local holding_area = SMODS.RunSelect.Internals.preview_area_holding
    
    local stack_size = page_def.preview_size or page_def.stack_size
    if SMODS.config.run_select_performance then stack_size = math.min(5, stack_size) end
    local card_size = page_def.sprite_size or {w = G.CARD_W, h = G.CARD_H}
    if type(to_add) == 'table' then
        local temp = {}
        for k, _ in pairs(to_add) do table.insert(temp, k) end
        to_add = temp
        stack_size = #to_add
    end
    for j=1, stack_size do
        local card = page_def.create_selection_card and page_def:create_selection_card(type(to_add) == 'table' and to_add[j] or to_add, j, preview_area) 
        or Card(preview_area.T.x, preview_area.T.y, card_size.w, card_size.h, nil, G.P_CENTERS[type(to_add) == 'table' and to_add[j] or to_add])
        card.params.run_select_preview_card = page_def.key
        if silent then
            preview_area:emplace(card)
        else
            holding_area:emplace(card)
            G.E_MANAGER:add_event(Event({
                func = (function()
                    play_sound('card1', math.random()*0.2 + 0.99, 0.35)
                    if holding_area.cards and preview_area.cards then preview_area:draw_card_from(holding_area) end
                    return true
                end)
            }), 'run_select')
        end
    end
    SMODS.RunSelect.Functions.update_preview_texts(page_def)
end

function SMODS.RunSelect.Functions.build_stake_tower()
    if SMODS.RunSelect.Internals.stake_tower then
        for i=1, #G.I.CARDAREA do
            if SMODS.RunSelect.Internals.stake_tower == G.I.CARDAREA[i] then
                table.remove(G.I.CARDAREA, i)
                SMODS.RunSelect.Internals.stake_tower = nil
            elseif SMODS.RunSelect.Internals.stake_tower_holding == G.I.CARDAREA[i] then
                table.remove(G.I.CARDAREA, i)
                SMODS.RunSelect.Internals.stake_tower_holding = nil
            end
        end
    end

    SMODS.RunSelect.Internals.stake_tower =  CardArea(G.ROOM.T.w * 0.656, G.ROOM.T.y, 3.4*14/41, 3.4*14/41, 
        {type = 'deck', highlight_limit = 0, draw_layers = {'card'}, thin_draw = 1, run_select_stake_tower = true})
    SMODS.RunSelect.Internals.stake_tower_holding =  CardArea(G.ROOM.T.w * 0.656, G.ROOM.T.y, 3.4*14/41, 3.4*14/41, 
        {type = 'deck', highlight_limit = 0, run_select_stake_tower = true})
end

function SMODS.RunSelect.Functions.build_stake_tower_ui()
    return
    {n=G.UIT.C, config = {align = "tm", padding = 0.1}, nodes ={
        {n = G.UIT.C, config = {minh = 5.95, minw = 1.5, maxw = 1.5, colour = G.C.BLACK, r=0.1, align = "bm", padding = 0.05, emboss=0.05}, nodes = {
            {n=G.UIT.R, config={align = "cm"}, nodes={
                {n = G.UIT.O, config = {object = SMODS.RunSelect.Internals.stake_tower}}
            }},
            {n=G.UIT.R, config={minh=0.2}}
        }}
    }}
end

local function order_applied_stakes(stake_chain, stake)
    local ordered_chain = {}
    for i,v in ipairs(G.P_CENTER_POOLS.Stake) do
        if stake_chain[i] and v.key ~= stake then
            ordered_chain[#ordered_chain+1] = v.key
        end
    end
    ordered_chain[#ordered_chain+1] = stake
    return ordered_chain
end

function SMODS.RunSelect.Functions.populate_stake_tower(stake, silent)
    if SMODS.config.run_select_performance then silent = true end
    remove_all(SMODS.RunSelect.Internals.stake_tower.cards)
    SMODS.RunSelect.Internals.stake_tower.cards = {}
    remove_all(SMODS.RunSelect.Internals.stake_tower_holding.cards)
    SMODS.RunSelect.Internals.stake_tower_holding.cards = {}
    local page_def = SMODS.RunSelect.Pages.stake_choice
    stake = page_def:set_default(stake)
    local applied_stakes = order_applied_stakes(SMODS.build_stake_chain(G.P_STAKES[stake]), stake)

    for i, stake_key in ipairs(applied_stakes) do
        local card = page_def:create_selection_card(stake_key, nil, SMODS.RunSelect.Internals.stake_tower_holding)
        card.params.run_select_stake_tower = {G.P_STAKES[stake_key].order, stake_key}
        card.params.hover = #applied_stakes - i
        card.children.back.states.collide.can = true
        SMODS.RunSelect.Internals.stake_tower_holding:emplace(card)

        if not silent then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.02,
                func = (function()
                    play_sound('chips2', math.random()*0.2 + 0.99, 0.35)
                    if SMODS.RunSelect.Internals.stake_tower.cards then SMODS.RunSelect.Internals.stake_tower:draw_card_from(SMODS.RunSelect.Internals.stake_tower_holding) end
                    return true
                end)
            }), 'run_select')
        else
            SMODS.RunSelect.Internals.stake_tower:draw_card_from(SMODS.RunSelect.Internals.stake_tower_holding)
        end
    end
end

function SMODS.RunSelect.Functions.clean_up(early)
    if G.E_MANAGER.queues.run_select then G.E_MANAGER:clear_queue('run_select') end
    for j = 1, #SMODS.RunSelect.Internals.select_areas do
        if SMODS.RunSelect.Internals.select_areas[j].cards then
            remove_all(SMODS.RunSelect.Internals.select_areas[j].cards)
            SMODS.RunSelect.Internals.select_areas[j].cards = {}
        end
    end
    if early then return end
    if SMODS.RunSelect.Internals.stake_tower and SMODS.RunSelect.Internals.stake_tower.cards then
        remove_all(SMODS.RunSelect.Internals.stake_tower.cards)
        SMODS.RunSelect.Internals.stake_tower.cards = {}
        remove_all(SMODS.RunSelect.Internals.stake_tower_holding.cards)
        SMODS.RunSelect.Internals.stake_tower_holding.cards = {}
    end
    if SMODS.RunSelect.Internals.preview_area and SMODS.RunSelect.Internals.preview_area.cards then
        remove_all(SMODS.RunSelect.Internals.preview_area.cards)
        SMODS.RunSelect.Internals.preview_area.cards = {}
        remove_all(SMODS.RunSelect.Internals.preview_area_holding.cards)
        SMODS.RunSelect.Internals.preview_area_holding.cards = {}
    end
end

-- Function Hooks
local card_stop_hover = Card.stop_hover
function Card:stop_hover()
    if self.params.stake then
        SMODS.RunSelect.Internals.hover_index = 0
    end
    card_stop_hover(self)
end

function SMODS.RunSelect.Functions.grab_tooltips(set, key)
    local info_queue = {}
    local loc_target = G.localization.descriptions[set][key]
    for _, lines in ipairs(loc_target.text_parsed) do
        for _, part in ipairs(lines) do
            if part.control.T then 
                info_queue[#info_queue+1] = G.P_CENTERS[part.control.T] or G.P_TAGS[part.control.T] or {
                    set = part.control.T_set or 'Other',
                    key = part.control.T,
                    vars = part.control.T_vars and parse_tooltip_vars(part.control.T_vars) or {}
                }
            end
        end
    end
    return info_queue
end

function SMODS.RunSelect.Functions.create_info_nodes(info_queue, c, row)
    if (not c.config.center.unlocked and not c.params.stake) or c.params.stake_chip_locked then return {} end

    local info_queue = SMODS.RunSelect.Functions.grab_tooltips(c.config.center.set, c.config.center.key)
    if c.config.center.loc_vars and type(c.config.center.loc_vars) == 'function' then
        c.config.center:loc_vars(info_queue, c.config.center)
    end
        
    local tooltips = {}
    local total_tooltips = #info_queue
    local column_count = total_tooltips == 0 and 0 or total_tooltips <= 3 and 1 or total_tooltips <= 8 and 2 or total_tooltips <= 18 and 3 or 4
    if column_count == 3 and c.T.x < G.ROOM.T.w*0.6 then column_count = 2 end
    local nodes_per_col = math.ceil(total_tooltips/column_count)
    
    local function create_info_tooltip(tooltip_data)
        local desc = generate_card_ui(tooltip_data, {main = {},info = {},type = {},name = 'done',badges = {}, from_detailed_tooltip = true}, nil, tooltip_data.set, nil)
        return {n=row and G.UIT.C or G.UIT.R, config={align = 'cm'}, nodes={
            {n=G.UIT.R, config={align = "cm", colour = lighten(G.C.JOKER_GREY, 0.5), r = 0.1, padding = 0.05, emboss = 0.05}, nodes={
                info_tip_from_rows(desc.info[1], desc.info[1].name),
            }}
        }}
    end
    
    for i = 0, column_count-1 do
        local tooltip_group = {}
        for j = 1, nodes_per_col do
            local tooltip_data = info_queue[i*nodes_per_col+j]
            if tooltip_data then
                table.insert(tooltip_group, create_info_tooltip(tooltip_data))
            else break end
        end
        table.insert(tooltips, {n=row and G.UIT.R or G.UIT.C, (c.T.x > G.ROOM.T.w*0.4) and column_count-i or i+1, config = {align="cm", padding = 0.05}, nodes = tooltip_group})
    end

    return tooltips
end


local card_hover_ref = Card.hover
function Card:hover()
    if (self.params.run_select_selection_choice or self.params.run_select_preview_card) and self.config.center.set == 'Back' and (not self.states.drag.is or G.CONTROLLER.HID.touch) and not self.no_ui and not G.debug_tooltip_toggle then
        self:juice_up(0.05, 0.03)
        play_sound('paper1', math.random()*0.2 + 0.99, 0.35)

        local back = Back(self.config.center)
        local tooltips = SMODS.RunSelect.Functions.create_info_nodes({}, self)
     
        local badges = {n=G.UIT.C, config = {colour = G.C.CLEAR, align = 'cm'}, nodes = {}}
        SMODS.create_mod_badges(self.config.center, badges.nodes)
        if badges.nodes.mod_set then badges.nodes.mod_set = nil end

        self.config.h_popup = {n=G.UIT.C, config={align = 'cm', padding = 0.1}, nodes = {
            next(tooltips) and {n=G.UIT.C, config={align='cm', padding=0.1}, nodes = tooltips} or nil
        }}

        table.insert(self.config.h_popup.nodes, (self.T.x > G.ROOM.T.w*0.4) and 2 or 1,
            {n=G.UIT.C, config={align='cm', padding = 0.1}, nodes = {
                {n=G.UIT.C, config={align = "cm", minh = 1.5, r = 0.1, colour = G.C.L_BLACK, padding = 0.1, outline=1}, nodes={
                    {n=G.UIT.R, config={align = "cm", r = 0.1, minw = 3, maxw = 4, minh = 0.4}, nodes={
                        {n=G.UIT.O, config={object = DynaText({string = back:get_name(),maxw = 4, colours = {G.C.WHITE}, shadow = true, bump = true, scale = 0.5, pop_in = 0, silent = true})}}
                    }},
                    {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, minh = 1.3, maxh = 3, minw = 3, maxw = 4, r = 0.1}, nodes={
                        {n=G.UIT.O, config={object = UIBox{definition = back:generate_UI(), config = {offset = {x=0,y=0}}}}}
                    }},
                    badges.nodes[1] and {n=G.UIT.R, config={align = "cm", r = 0.1, minw = 3, maxw = 4, minh = 0.4}, nodes={badges}},
                }}
            }}
        )
            
        self.config.h_popup_config = self:align_h_popup()
        Node.hover(self)
        return
    elseif (self.params.run_select_selection_choice or self.params.run_select_stake_tower) and self.params.stake and (not self.states.drag.is or G.CONTROLLER.HID.touch) and not self.no_ui and not G.debug_tooltip_toggle then
        SMODS.RunSelect.Internals.hover_index = self.params.hover or 0
        self:juice_up(0.05, 0.03)
        play_sound('paper1', math.random()*0.2 + 0.99, 0.35)
        local stake = G.P_STAKES[self.config.center.key]

        local tooltips = SMODS.RunSelect.Functions.create_info_nodes({}, self, true)
        
        local badges = {n=G.UIT.R, config = {colour = G.C.CLEAR, align = 'cm', padding = 0.05}, nodes = {}}
        SMODS.create_mod_badges(stake, badges.nodes)
        if badges.nodes.mod_set then badges.nodes.mod_set = nil end

        local stake_desc
        if self.params.stake_chip_locked then
            local number_applied_stakes = #stake.applied_stakes
            local string_output = localize('run_select_locked_stake_message')
            for i,v in ipairs(stake.applied_stakes) do
                string_output = string_output .. localize({type='name_text', set='Stake', key=v}) .. (i < number_applied_stakes and localize('run_select_locked_stake_and') or '')
            end
            local split = SMODS.split_string(string_output)

            stake_desc = {n=G.UIT.C, config={align = "cm", padding = 0.05, r = 0.1, colour = G.C.L_BLACK}, nodes={
                {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={{n=G.UIT.T, config={text = localize('run_select_locked_stake'), scale = 0.35, colour = G.C.WHITE}}}},
                {n=G.UIT.R, config={align = "cm", padding = 0.03, colour = G.C.WHITE, r = 0.1, minh = 1, minw = 3}, nodes={
                    {n=G.UIT.R, config={align='cm'}, nodes={{n=G.UIT.T, config={text = split[1], scale = 0.3, colour = G.C.UI.TEXT_DARK}}}},
                    {n=G.UIT.R, config={align='cm'}, nodes={{n=G.UIT.T, config={text = split[2], scale = 0.3, colour = G.C.UI.TEXT_DARK}}}}
                }}
            }}
        else
            stake_desc = G.UIDEF.stake_description(self.config.center.order)
            stake_desc.nodes[2].config.minw = 3
        end
        
        if badges.nodes[1] then table.insert(stake_desc.nodes, badges) end

        self.config.h_popup = {n = G.UIT.C, config={align='cm', colour = G.C.CLEAR}, nodes = {
            {n=G.UIT.R, config={align='cm'}, nodes = {
                {n=G.UIT.R, config={align = "cm", minh = 1.5, r = 0.1, colour = G.C.L_BLACK, padding = 0.05, outline=1}, nodes ={
                    {n=G.UIT.C, config={align = "cm", padding = 0}, nodes={stake_desc}}
                }},
            }},
            next(tooltips) and {n=G.UIT.R, config={align='cm', padding=0.1}, nodes = tooltips},
        }}

        self.config.h_popup_config = self:align_h_popup()
        Node.hover(self)
        return
    elseif self.params.run_select_selection_choice or self.params.run_select_preview_card then
        local page = SMODS.RunSelect.Pages[self.params.run_select_preview_card or self.params.run_select_selection_choice[2]]
        if page.card_hover and type(page.card_hover) == 'function' then
            return page:card_hover(self)
        end
    end
    card_hover_ref(self) 
end

local card_click_ref = Card.click
function Card:click() 
    if self.params.stake and not self.params.stake_chip_locked and self.params.run_select_selection_choice then
        SMODS.RunSelect.Pages.stake_choice:handle_choice(self.params.stake)
    elseif self.params.run_select_selection_choice and self.config.center.unlocked ~= false and self.config.center.discovered ~= false then
        local page = SMODS.RunSelect.Pages[self.params.run_select_selection_choice[2]]
        if page.card_click and type(page.card_click) == 'function' then
            return page:card_click(self)
        else
            page:handle_choice(self)
        end
    elseif self.params.run_select_preview_card then
        if self.params.run_select_preview_card == 'deck_choice' then return end
        local page = SMODS.RunSelect.Pages[self.params.run_select_preview_card]
        if page.preview_click and type(page.preview_click) == 'function' then
            return page:preview_click(self)
        else
            page:handle_choice(self, true)
        end
    else
        card_click_ref(self)
    end
end

local card_area_align_ref = CardArea.align_cards
function CardArea:align_cards()
    if self.config.run_select_stake_tower then -- align chips vertically in chip tower
        local deck_height = 4.7/math.max(24,#self.cards)
        for k, card in ipairs(self.cards) do
            if not card.states.drag.is then
                card.T.x = self.T.x + 0.5*(self.T.w - card.T.w)
                card.T.y = self.T.y + deck_height - (#self.cards - k + (k <= SMODS.RunSelect.Internals.hover_index and 4 or 0))*deck_height
            end
            card.rank = 0
        end
    elseif self.config.run_select_deck_preview then -- deck preview grows vertically
        for k, card in ipairs(self.cards) do
            if not card.states.drag.is then
                card.T.x = self.T.x + 0.5*(self.T.w - card.T.w)
                card.T.y = self.T.y + 0.5*(self.T.h - card.T.h) + (self.shadow_parrallax.y*(self.config.deck_height or 0.25)/52*(#self.cards/2 - k))
            end
        end
    else
        card_area_align_ref(self)
    end
end
