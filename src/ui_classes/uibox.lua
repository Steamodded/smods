SMODS.UIBoxes = {}

SMODS.UIBox = SMODS.GameObject:extend {
    obj_table = SMODS.UIBoxes,
    obj_buffer = {},
    required_params = {
        'key',
    },

    set = "UIBox",

    --- Array of functions to add to G.FUNCS.
    g_funcs = {'back_func'},

    -- UIBox-specific arguments
    back_button = nil,
    back_colour = nil,
    back_delay = nil,
    back_id = nil,
    back_label = nil,
    bg_colour = nil,
    colour = nil,
    minw = nil,
    no_back = nil,
    no_pip = nil,
    outline_colour = nil,
    padding = nil,
    snap_back = nil,

    back_func = function(self, e)
        return G.FUNCS.exit_overlay_menu(e)
    end,

    contents = function(self, args)
        return nil
    end,

    register = function(self)
        if self.registered then
            sendWarnMessage(('Detected duplicate register call on object %s'):format(self.key), self.set)
            return
        end

        SMODS.UIBox.super.register(self)

        -- Add dialog functions to G.FUNCS so we can refer back to them by func_key()
        for _, v in ipairs(self.g_funcs) do
            if self[v] and type(self[v]) == "function" then
                G.FUNCS[self:func_key(v)] = function(e) return self[v](self, e) end
            end
        end
    end,

    inject = function() end,
    post_inject_class = function(self)
        table.sort(self.obj_buffer, function(_self, _other) return self.obj_table[_self].order < self.obj_table[_other].order end)
    end,

    --- Generates the G.FUNCS key for a function tied to this UIBox.
    func_key = function(self, func_name)
        return "SMODS_" .. self.set .. "_" .. self.key .. '_' .. func_name
    end,

    --- Generates an optional, dynamic infotip to show with the UIBox.
    generate_infotip = function(self, args)
        return nil
    end,

        -- Creates a tab dialog.
    create_UIBox = function(self, args)
        return create_UIBox_generic_options{
            back_button = self.back_button,
            back_colour = self.back_colour,
            back_delay = self.back_delay,
            back_func = self.back_func and self:func_key('back_func') or nil,
            back_id = self.back_id,
            back_label = self.back_label and localize(self.back_label) or localize('b_back'),
            bg_colour = self.bg_colour,
            colour = self.colour,
            infotip = self:generate_infotip(args),
            minw = self.minw,
            no_back = self.no_back,
            no_pip = self.no_back,
            outline_colour = self.outline_colour,
            padding = self.padding,
            snap_back = self.snap_back,

            contents = {self:contents(args)},
        }
    end
}
