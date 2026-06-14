SMODS.CardModifiers = {}
SMODS.CardModifier = SMODS.GameObject:extend {
    obj_table = SMODS.CardModifiers,
    obj_buffer = {},
    set = 'Modifier',
    required_params = {
        'key', 'set'
    },
    rate = 0,
    atlas = 'stickers',
    pos = { x = 0, y = 0 },
    badge_colour = HEX 'FFFFFF',
    default_compat = true,
    compat_exceptions = {},
    sets = { Joker = true },
    needs_enable_flag = true,
    process_loc_text = function(self)
        G.localization.descriptions[self.set] = G.localization.descriptions[self.set] or {}
        SMODS.process_loc_text(G.localization.descriptions[self.set], self.key, self.loc_txt)
        SMODS.process_loc_text(G.localization.misc.labels, self.key, self.loc_txt, 'label')
    end,
    register = function(self)
        if self.registered then
            sendWarnMessage(('Detected duplicate register call on object %s'):format(self.key), self.set)
            return
        end
        SMODS.CardModifier.super.register(self)
        self.order = #self.obj_buffer
    end,
    inject = function(self)
        self.modifier_sprite = SMODS.create_sprite(0, 0, G.CARD_W, G.CARD_H, self.atlas, self.pos)
        G.shared_stickers[self.key] = self.modifier_sprite
        G.P_CENTER_POOLS[self.set] = G.P_CENTER_POOLS[self.set] or {}
        SMODS.insert_pool(G.P_CENTER_POOLS[self.set], self)
    end,
    apply = function(self, card)
        card.ability[self.set] = card.ability[self.set] or {}
        for i, v in pairs(card.ability[self.set]) do
            if v.key == self.key then return end
        end
        card.ability[self.set][#card.ability[self.set]+1] = copy_table(self.config) or {}
        card.ability[self.set][#card.ability[self.set]].key = self.key
        if type(self.on_apply) == "function" then
            self:on_apply(card)
        end
        if #card.ability[self.set] > SMODS.ModifierTypes[self.set].modifier_limit then
            if type(SMODS.CardModifiers[card.ability[self.set][1]].on_remove) == "function" then
                SMODS.CardModifiers[card.ability[self.set]]:on_remove(card)
            end
            table.remove(card[self.set], 1)
        end
    end
}

function Card:calculate_modifier(context, key)
    local mod = SMODS.CardModifiers[key]
    if self.ability[mod.set] and type(mod.calculate) == 'function' then
        for i, v in pairs(self.ability[mod.set]) do
            if v.key == key then
                local o = mod:calculate(self, context)
                if o then
                    if not o.card then o.card = self end
                    return o
                end
            end
        end
    end
end

function Card:add_modifier(modifier, bypass_check)
    local modifier = SMODS.CardModifiers[modifier]
    local in_sets = {}
    for i, v in pairs(SMODS.ModifierTypes[modifier.set].sets or {}) do
        if v == self.config.center.type then 
            in_sets = true 
            break 
        end
    end
    if bypass_check or in_sets then
        modifier:apply(self, true)
        SMODS.enh_cache:write(self, nil)
    end
end

function Card:remove_modifier(modifier)
    local modifier = SMODS.CardModifiers[modifier]
    if self.ability[modifier.set] then
        local c
        for i, v in pairs(self.ability[modifier.set]) do
            if v == modifier.key then c = i end
        end
        if c then
            if type(SMODS.CardModifiers[self.ability[modifier.set][c]].on_remove) == "function" then
                SMODS.CardModifiers[self.ability[modifier.set][c]]:on_remove(card)
            end
            self.ability[modifier.set][c] = nil
            SMODS.enh_cache:write(self, nil)
        end
    end
end

SMODS.ModifierTypes = {}
SMODS.ModifierType = SMODS.ObjectType:extend {
    obj_table = SMODS.ModifierTypes,
    obj_buffer = ctype_buffer,
    visible_buffer = {},
    set = 'ModifierType',
    required_params = {
        'key',
    },
    prefix_config = { key = false },
    collection_rows = { 6, 6 },
    register = function(self)
        SMODS.ModifierType.super.register(self)
        if self:check_dependencies() then
            -- this is duplicate information but it's more convenient to keep
            if not self.no_collection then SMODS.ModifierType.visible_buffer[#SMODS.ModifierType.visible_buffer + 1] = self.key end
        end
    end,
    inject = function(self)
        SMODS.ObjectType.inject(self)
        G.localization.descriptions[self.key] = G.localization.descriptions[self.key] or {}
        G.FUNCS['your_collection_' .. string.lower(self.key) .. 's'] = function(e)
            G.SETTINGS.paused = true
            G.FUNCS.overlay_menu {
                definition = self:create_UIBox_your_collection(),
            }
        end
    end,
    process_loc_text = function(self)
        SMODS.process_loc_text(G.localization.misc.dictionary, 'k_' .. string.lower(self.key), self.loc_txt, 'name')
        SMODS.process_loc_text(G.localization.misc.dictionary, 'b_' .. string.lower(self.key) .. '_cards',
            self.loc_txt, 'collection')
        SMODS.process_loc_text(G.localization.descriptions.Other, 'undiscovered_' .. string.lower(self.key),
            self.loc_txt, 'undiscovered')
    end,
    modifier_limit = 1,
    allowed_sets = { "Enhanced", "Default" }
}