SMODS.Tabs = {}
SMODS.Tab = SMODS.GameObject:extend {
    obj_table = SMODS.Tabs,
    obj_buffer = {},
    required_params = {
        'key',
        'tab_dialog',
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
    tab_dialog = 'deck_info',
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
    tab_dialog = 'deck_info',
    order = 10,
    func = function(self)
        return G.UIDEF.view_deck()
    end,
}

SMODS.Tab{
    key = 'poker_hands',
    tab_dialog = 'run_info',
    order = 0,
    chosen = true,
    func = function(self)
        return create_UIBox_current_hands()
    end,
}

SMODS.Tab{
    key = 'blinds',
    tab_dialog = 'run_info',
    order = 10,
    func = function(self)
        return G.UIDEF.current_blinds()
    end,
}

SMODS.Tab{
    key = 'vouchers',
    tab_dialog = 'run_info',
    order = 20,
    func = function(self)
        return G.UIDEF.used_vouchers()
    end,
}

SMODS.Tab{
    key = 'stake',
    tab_dialog = 'run_info',
    order = 30,
    func = function(self)
        return G.UIDEF.current_stake()
    end,
    is_visible = function(self, args)
        return G.GAME.stake > 1
    end,
}
