SMODS.Tabs = {}
SMODS.Tab = SMODS.GameObject:extend {
    obj_table = SMODS.Tabs,
    obj_buffer = {},
    required_params = {
        'key',
        'tab_group',
        'order',
        'func',
    },
    chosen = false,
    -- func = function(self) end, -- -> table
    -- is_visible = function(self, args) end, -- -> bool

    set = "Tab",
    register = function(self)
        if self.registered then
            sendWarnMessage(('Detected duplicate register call on object %s'):format(self.key), self.set)
            return
        end
        SMODS.Tab.super.register(self)
    end,
    inject = function() end,
    post_inject_class = function(self)
        table.sort(self.obj_buffer, function(_self, _other) return self.obj_table[_self].order < self.obj_table[_other].order end)
    end,
}

SMODS.Tab{
    key = 'remaining',
    tab_group = 'deck_info',
    order = 0,
    chosen = true,
    func = function(self)
        return G.UIDEF.view_deck(true)
    end,
    is_visible = function(self, args)
        return args.show_remaining
    end,
}

SMODS.Tab{
    key = 'full_deck',
    tab_group = 'deck_info',
    order = 10,
    func = function(self)
        return G.UIDEF.view_deck()
    end,
}

SMODS.Tab{
    key = 'poker_hands',
    tab_group = 'run_info',
    order = 0,
    chosen = true,
    func = function(self)
        return create_UIBox_current_hands()
    end,
}

SMODS.Tab{
    key = 'blinds',
    tab_group = 'run_info',
    order = 10,
    func = function(self)
        return G.UIDEF.current_blinds()
    end,
}

SMODS.Tab{
    key = 'vouchers',
    tab_group = 'run_info',
    order = 20,
    func = function(self)
        return G.UIDEF.used_vouchers()
    end,
}

SMODS.Tab{
    key = 'stake',
    tab_group = 'run_info',
    order = 30,
    func = function(self)
        return G.UIDEF.current_stake()
    end,
    is_visible = function(self, args)
        return G.GAME.stake > 1
    end,
}

-- Returns all visible tabs which belong to `tab_group` as an array sorted by order correctly formatted to pass to create_tabs argument args.tabs.
function SMODS.filter_visible_tabs(tab_group, args)
    local tabs = {}
    local chosen_seen = nil
    for _, key in ipairs(SMODS.Tab.obj_buffer) do
        local tab = SMODS.Tabs[key]
        if tab.tab_group == tab_group and (tab.is_visible == nil or (type(tab.is_visible) == 'function' and tab:is_visible(args or {}))) then
            local chosen = not chosen_seen and tab.chosen or nil
            chosen_seen = chosen_seen or chosen
            tabs[#tabs+1] = {
                label = localize('b_' .. tab.key),
                order = tab.order,
                chosen = chosen,
                tab_definition_function = function() return tab:func() end,
            }
        end
    end
    if not chosen_seen and #tabs > 0 then tabs[1].chosen = true end
    return tabs
end

-- Returns a UIBox with all visible tabs from `tab_group` rendered.
function SMODS.generate_tabs_uibox(tab_group, args)
    local tabs = SMODS.filter_visible_tabs(tab_group, args)
    if #tabs > 0 then
        return create_UIBox_generic_options{
            contents = {create_tabs{
                tabs = tabs,
                tab_h = 8,
                snap_to_nav = true,
            }}
        }
    else
        sendDebugMessage("Tab group '" .. tab_group .. "' returned no matching tabs.", 'SMODS.Tabs')
    end
    return {n = G.UIT.ROOT, config = {align="cm", colour = {G.C.GREY[1], G.C.GREY[2], G.C.GREY[3],0.7}}, nodes = {
        {n=G.UIT.R, config={padding = 0.0, align = "cm", colour = G.C.CLEAR}, nodes={
            {n=G.UIT.T, config={config={text='!ERROR!', scale=1, colour=G.C.UI.TEXT_DARK}}}
        }}
    }}
end

function G.UIDEF.deck_info(_show_remaining)
    return SMODS.generate_tabs_uibox('deck_info', {show_remaining = _show_remaining})
end

function G.UIDEF.run_info()
    return SMODS.generate_tabs_uibox('run_info')
end
