-- TODO: create smods attributes:
    -- xmult
    -- xchips
    -- retriggers
    -- scaling
    -- generation
    -- spades
    -- clubs
    -- hearts
    -- diamonds
    -- hand_type
    -- rank
    -- copying
    -- generate
    -- food
    -- space
    -- discard
    -- economy

SMODS.Attributes = {}
SMODS.Attribute = SMODS.GameObject:extend {
    obj_table = SMODS.Attributes,
    set = 'Attribute',
    obj_buffer = {},
    required_params = {
        'key',
    },
    prefix_config = { key = false },
    process_loc_text = function() end,
    inject = function(self)
        self.key = string.lower(self.key)
        self.keys = self.keys or {}
    end,
    post_inject_class = function(self)
        for _, attribute in pairs(SMODS.Attributes) do        
            if attribute.alias then
                for _, alias in ipairs(attribute.alias) do
                    if SMODS.Attributes[alias] then
                        SMODS.Attributes[alias].alias = SMODS.merge_lists({SMODS.Attributes[alias].alias or {}, {attribute.key}})
                    end
                end
            end
        end
    end
}

function SMODS.get_attribute_pool(attribute, seen)
    local att = SMODS.Attributes[attribute] or {}
    local out = att.keys or {}
    seen = seen or {}
    if not seen[attribute] and att.alias then
        seen[attribute] = true
        for _, alias in ipairs(att.alias) do
            out = SMODS.merge_lists({out, SMODS.get_attribute_pool(alias, seen)})
        end
    end
    return out
end

function SMODS.add_attribute(attribute_key, object_keys)
    assert(SMODS.Attributes[attribute_key], "SMODS.add_attribute called with invaled attribute_key."..SMODS.log_crash_info(debug.getinfo(2)))
    SMODS.Attributes[attribute_key].keys = SMODS.merge_lists({SMODS.Attributes[attribute_key].keys, object_keys})
end

function SMODS.populate_attributes()
    for _, attribute in pairs(SMODS.Attributes) do
        for _, key in ipairs(attribute.keys) do
            if G.P_CENTERS[key] then
                G.P_CENTERS[key].attributes = SMODS.merge_lists({G.P_CENTERS[key].attributes or {}, {attribute.key}})
            end
        end
    end
end

SMODS.Attribute({
    key = 'mult',
    keys = {
        'j_joker', 'j_greedy_joker', 'j_lusty_joker', 'j_wrathful_joker', 'j_gluttenous_joker',
        'j_jolly', 'j_zany', 'j_crazy', 'j_mad', 'j_droll',
        'j_half', 'j_ceremonial', 'j_mystic_summit', 'j_misprint', 'j_raised_fist',
        'j_fibonacci', 'j_abstract', 'j_gros_michel', 'j_even_steven', 'j_scholar',
        'j_ride_the_bus', 'j_green_joker', 'j_red_card', 'j_erosion', 'j_fortune_teller',
        'j_flash', 'j_popcorn', 'j_trousers', 'j_walkie_talkie', 'j_smiley',
        'j_swashbuckler', 'j_onyx_agate', 'j_shoot_the_moon', 'j_bootstraps', 'c_eris'
    }
})

SMODS.Attribute({
    key = 'chips',
    keys = {
        'j_sly', 'j_wily', 'j_clever', 'j_devious', 'j_crafty',
        'j_banner', 'j_scary_face', 'j_odd_todd', 'j_scholar', 'j_runner',
        'j_ice_cream', 'j_blue_joker', 'j_hiker', 'j_square', 'j_stone',
        'j_bull', 'j_walkie_talkie', 'j_castle', 'j_arrowhead', 'j_wee',
        'j_stuntman', 'c_eris'
    }
})