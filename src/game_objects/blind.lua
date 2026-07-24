SMODS.Blinds = {}
SMODS.Blind = SMODS.GameObject:extend {
    obj_table = SMODS.Blinds,
    obj_buffer = {},
    class_prefix = 'bl',
    debuff = {},
    vars = {},
    config = {},
    dollars = 5,
    mult = 2,
    atlas = 'blind_chips',
    discovered = false,
    pos = { x = 0, y = 0 },
    required_params = {
        'key',
    },
    set = 'Blind',
    get_obj = function(self, key) return G.P_BLINDS[key] end,
    register = function(self)
        self.name = self.name or self.key
        SMODS.Blind.super.register(self)
    end,
    inject = function(self, i)
        -- no pools to query length of, so we assign order manually
        if not self.taken_ownership then
            self.order = 30 + i
        end
        self.blind_types = {
            self.boss and 'boss',
            self.big and 'big',
            self.small and 'small'
        }

        G.P_BLINDS[self.key] = self
        if self.modifies_draw then SMODS.Blinds.modifies_draw[self.key] = true end
    end
}
SMODS.Blind:take_ownership('eye', {
    set_blind = function(self, reset, silent)
        if not reset then
            G.GAME.blind.hands = {}
            for _, v in ipairs(G.handlist) do
                G.GAME.blind.hands[v] = false
            end
        end
    end
})
SMODS.Blind:take_ownership('wheel', {
    loc_vars = function(self)
        return { vars = { SMODS.get_probability_vars(self, 1, 7, 'wheel') } }
    end,
    collection_loc_vars = function(self)
        return { vars = { '1', '7' }}
    end,
    process_loc_text = function(self)
        local text = G.localization.descriptions.Blind[self.key].text[1]
        if string.sub(text, 1, 3) ~= '#1#' then
            G.localization.descriptions.Blind[self.key].text[1] = "#1#"..text
        end
        -- Is this too much hacky?
        G.localization.descriptions.Blind[self.key].text[1] = string.gsub(G.localization.descriptions.Blind[self.key].text[1], "7", "#2#")
        SMODS.Blind.process_loc_text(self)
    end,
    get_loc_debuff_text = function() return G.GAME.blind.loc_debuff_text end,
})

SMODS.Blinds.modifies_draw = {
    bl_serpent = true
}

function SMODS.normalize_bosses_used_table(bosses_used)
    local normalized = { boss = {}, small = {}, big = {} }
    local typed_keys = { boss = true, small = true, big = true }

    if type(bosses_used) == 'table' then
        for key, value in pairs(bosses_used) do
            if typed_keys[key] and type(value) == 'table' then
                for blind_key, count in pairs(value) do
                    normalized[key][blind_key] = count
                end
            elseif not typed_keys[key] and type(value) ~= 'table' then
                normalized.boss[key] = value
            end
        end
    end

    for key, blind in pairs(G.P_BLINDS or {}) do
        if blind.boss and normalized.boss[key] == nil then normalized.boss[key] = 0 end
        if blind.small and normalized.small[key] == nil then normalized.small[key] = 0 end
        if blind.big and normalized.big[key] == nil then normalized.big[key] = 0 end
    end

    return setmetatable(normalized, {
        __index = function(t, key)
            return t.boss[key] or t.big[key] or t.small[key]
        end,
        __newindex = function(t, key, value)
            rawset(t.boss, key, value)
        end
    })
end

function SMODS.add_boss_to_used_table(boss_key, type)
    if G.P_BLINDS[boss_key][type].allow_others then 
        G.GAME.bosses_used[type][boss_key] = G.GAME.bosses_used[type][boss_key] + 1
        return
    end
    for _, _type in pairs(G.P_BLINDS[boss_key].blind_types) do
        G.GAME.bosses_used[_type][boss_key] = G.GAME.bosses_used[_type][boss_key] + 1
    end
end

function SMODS.get_new_blind(blind_type)
    local ret_boss
    if SMODS.optional_features.object_weights then
        ret_boss = SMODS.poll_object({type = 'Blind', blind_type = blind_type, seed = blind_type or 'boss'})
    else
        ret_boss = pseudorandom_element(SMODS.create_blind_pool(blind_type), pseudoseed(blind_type or 'boss'))
    end
    SMODS.add_boss_to_used_table(ret_boss, blind_type or 'boss')
    return ret_boss
end

local blind_get_type = Blind.get_type
function Blind:get_type()
    if G.GAME.blind and self == G.GAME.blind then
        return G.GAME.blind_on_deck
    end
    if self.boss then return 'Boss'
    elseif self.big then return 'Big'
    elseif self.small then return 'Small'
    else return '' end
end

function Blind:is_type(blind_type)
    return self:get_type() == blind_type
end

function SMODS.reset_blind_choices(choices)
    G.GAME.round_resets.blind_order = {'Small', 'Big', 'Boss'} -- prepared for custom antes
    for _, k in ipairs(G.GAME.round_resets.blind_order) do
        choices[k] = nil
    end
    for _, k in ipairs(G.GAME.round_resets.blind_order) do
        choices[k] = SMODS.get_new_blind(string.lower(k))
    end
end
