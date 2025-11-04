SMODS.TabDialogs = {}
SMODS.TabDialog = SMODS.UIBox:extend {
    obj_table = SMODS.TabDialogs,
    obj_buffer = {},
    key = 'tabdialog', -- Not sure how to make the LSP not complain about this.
    required_params = {
        'key',
    },

    g_funcs = {'back_func', 'opt_callback'},

    -- Tab-specific arguments
    content_alignment = nil,
    content_padding = nil,
    content_minh = nil,
    content_minw = nil,
    no_loop = nil,
    no_shoulders = nil,
    opt_callback = nil,
    scale = nil,
    snap_to_nav = nil,
    tab_colour = nil,
    text_scale = nil,
    -- func = function(self) end, -- -> table
    -- is_visible = function(self, args) end, -- -> bool

    set = "TabDialog",

    contents = function(self, args)
        args = args or {}
        local tabs = self:filter_visible_tabs(args or {})

        return create_tabs{
            tabs = tabs,

            no_loop = self.no_loop,
            no_shoulders = self.no_shoulders,
            opt_callback = self.opt_callback and self:func_key('opt_callback') or nil,
            padding = self.content_padding,
            scale = self.scale,
            snap_to_nav = self.snap_to_nav,
            tab_alignment = self.content_alignment,
            tab_colour = self.colour,
            tab_w = self.content_minw,
            tab_h = self.content_minh,
            text_scale = self.text_scale,
        }
    end,

    -- Returns all visible tabs which belong to `tab_dialog` as an array sorted by order correctly formatted to pass to create_tabs argument args.tabs.
    filter_visible_tabs = function(self, args)
        local tabs = {}
        local chosen_seen = nil
        for _, key in ipairs(SMODS.Tab.obj_buffer) do
            local tab = SMODS.Tabs[key]
            if tab.tab_dialog == self.key and (tab.is_visible == nil or (type(tab.is_visible) == 'function' and tab:is_visible(args or {}))) then
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

        if #tabs == 0 then
            sendDebugMessage("Tab Dialog '" .. self.key .. "' returned no matching tabs.", 'SMODS.TabDialog')
            return nil
        end

        if not chosen_seen then tabs[1].chosen = true end
        return tabs
    end,
}

SMODS.TabDialog {
    key = 'deck_info',
    content_minh = 8,
    snap_to_nav = true,
}

SMODS.TabDialog {
    key = 'run_info',
    content_minh = 8,
    snap_to_nav = true,
}

function G.UIDEF.deck_info(_show_remaining)
    return SMODS.TabDialogs.deck_info:create_UIBox({show_remaining = _show_remaining})
end

function G.UIDEF.run_info()
    return SMODS.TabDialogs.run_info:create_UIBox()
end
