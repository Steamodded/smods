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
                G.P_CENTERS[key].attributes = G.P_CENTERS[key].attributes or {}
                G.P_CENTERS[key].attributes[attribute.key] = true
            end
        end
    end
end

function Card:has_attribute(attribute)
    if not SMODS.Attributes[attribute] or not self.config.center.attributes then return false end
    if self.config.center.attributes[attribute] then return true end
    for _, att in ipairs(SMODS.Attributes[attribute].alias or {}) do
        if self.config.center.attributes[att] then return true end
    end
    return false
end

SMODS.Attribute({
    key = 'mult',
    keys = {
        'j_joker', 'j_greedy_joker', 'j_lusty_joker', 'j_wrathful_joker', 'j_gluttenous_joker',
        'j_jolly', 'j_zany', 'j_crazy', 'j_mad', 'j_droll',
        'j_half', 'j_ceremonial', 'j_mystic_summit', 'j_misprint', 'j_raised_fist',
        'j_fibonacci', 'j_abstract', 'j_gros_michel', 'j_even_steven', 'j_scholar', 'j_supernova',
        'j_ride_the_bus', 'j_green_joker', 'j_red_card', 'j_erosion', 'j_fortune_teller',
        'j_flash', 'j_popcorn', 'j_trousers', 'j_walkie_talkie', 'j_smiley',
        'j_swashbuckler', 'j_onyx_agate', 'j_shoot_the_moon', 'j_bootstraps'
    }
})

SMODS.Attribute({
    key = 'chips',
    keys = {
        'j_sly', 'j_wily', 'j_clever', 'j_devious', 'j_crafty',
        'j_banner', 'j_scary_face', 'j_odd_todd', 'j_scholar', 'j_runner',
        'j_ice_cream', 'j_blue_joker', 'j_hiker', 'j_square', 'j_stone',
        'j_bull', 'j_walkie_talkie', 'j_castle', 'j_arrowhead', 'j_wee',
        'j_stuntman'
    }
})

SMODS.Attribute({
    key = 'xmult',
    keys = {
        'j_stencil', 'j_loyalty_card', 'j_steel_joker', 'j_blackboard', 'j_constellation',
        'j_cavendish', 'j_card_sharp', 'j_madness', 'j_vampire', 'j_hologram',
        'j_baron', 'j_obelisk', 'j_photograph', 'j_lucky_cat', 'j_baseball',
        'j_ancient', 'j_ramen', 'j_campfire', 'j_acrobat', 'j_throwback',
        'j_bloodstone', 'j_glass', 'j_flower_pot', 'j_idol', 'j_seeing_double',
        'j_hit_the_road', 'j_duo', 'j_trio', 'j_family', 'j_order', 'j_tribe',
        'j_drivers_license', 'j_caino', 'j_triboulet', 'j_yorick'
    }
})

SMODS.Attribute({
    key = 'xchips',
})

SMODS.Attribute({
    key = 'score',
})

SMODS.Attribute({
    key = 'xscore',
})

SMODS.Attribute({
    key = 'blindsize'
})

SMODS.Attribute({
    key = 'xblindsize'
})

SMODS.Attribute({
    key = 'balance'
})

SMODS.Attribute({
    key = 'swap'
})

SMODS.Attribute({
    key = 'retrigger',
    keys = {
        'j_mime', 'j_dusk', 'j_hack', 'j_selzer', 'j_sock_and_buskin', 'j_hanging_chad'
    }
})

SMODS.Attribute({
    key = 'scaling',
    keys = {
        'j_ceremonial', 'j_selzer', 'j_ride_the_bus', 'j_egg', 'j_runner',
        'j_ice_cream', 'j_constellation', 'j_green_joker', 'j_red_card',
        'j_madness', 'j_square', 'j_vampire', 'j_hologram', 'j_rocket', 'j_turtle_bean',
        'j_obelisk', 'j_flash', 'j_lucky_cat',
        'j_popcorn', 'j_trousers', 'j_ramen', 'j_castle', 'j_campfire',
        'j_throwback', 'j_glass', 'j_wee', 'j_hit_the_road', 'j_caino', 'j_yorick'
    }
})

SMODS.Attribute({
    key = 'generation',
    keys = {
        'j_marble', 'j_8_ball', 'j_dna', 'j_sixth_sense', 'j_superposition',
        'j_seance', 'j_riff_raff', 'j_vagabond', 'j_hallucination', 'j_diet_cola',
        'j_certificate', 'j_invisible', 'j_cartomancer', 'j_perkeo'
    }
})

SMODS.Attribute({
    key = 'suit',
    keys = {
        'j_greedy_joker', 'j_lusty_joker', 'j_wrathful_joker', 'j_gluttenous_joker',
        'j_smeared', 'j_castle', 'j_ancient', 'j_seeing_double', 'j_blackboard', 'j_flower_pot', 'j_idol',
        'j_rough_gem', 'j_bloodstone', 'j_arrowhead', 'j_onyx_agate',
    }
})

SMODS.Attribute({
    key = 'diamonds',
    keys = {
        'j_greedy_joker', 'j_smeared', 'j_rough_gem'
    }
})

SMODS.Attribute({
    key = 'hearts',
    keys = {
        'j_lusty_joker', 'j_smeared', 'j_bloodstone'
    }
})

SMODS.Attribute({
    key = 'spades',
    keys = {
        'j_wrathful_joker', 'j_smeared', 'j_arrowhead', 'j_blackboard'
    }
})

SMODS.Attribute({
    key = 'clubs',
    keys = {
        'j_gluttenous_joker', 'j_smeared', 'j_onyx_agate', 'j_seeing_double', 'j_blackboard'
    }
})

SMODS.Attribute({
    key = 'hand_type',
    keys = {
        'j_jolly', 'j_zany', 'j_crazy', 'j_mad', 'j_droll',
        'j_sly', 'j_wily', 'j_clever', 'j_devious', 'j_crafty',
        'j_four_fingers', 'j_supernova', 'j_runner', 'j_superposition',
        'j_todo_list', 'j_seance', 'j_shortcut', 'j_obelisk', 'j_trousers',
        'j_duo', 'j_trio', 'j_family', 'j_order', 'j_tribe',
        'j_burnt', 'j_card_sharp', 'j_space'
    }
})

SMODS.Attribute({
    key = 'rank',
    keys = {
        'j_8_ball', 'j_raised_fist', 'j_fibonacci', 'j_hack', 'j_even_steven',
        'j_odd_todd', 'j_scholar', 'j_sixth_sense', 'j_superposition', 'j_cloud_9',
        'j_mail', 'j_walkie_talkie', 'j_wee', 'j_idol', 'j_hit_the_road', 'j_baron',
        'j_shoot_the_moon', 'j_triboulet'
    }
})

SMODS.Attribute({
    key = 'ace',
    keys = {
        'j_fibonacci', 'j_odd_todd', 'j_scholar', 'j_superposition'
    }
})

SMODS.Attribute({
    key = 'two',
    keys = {
        'j_fibonacci', 'j_hack', 'j_even_steven', 'j_wee'
    }
})

SMODS.Attribute({
    key = 'three',
    keys = {
        'j_fibonacci', 'j_hack', 'j_odd_todd'
    }
})

SMODS.Attribute({
    key = 'four',
    keys = {
        'j_hack', 'j_even_steven', 'j_walkie_talkie'
    }
})

SMODS.Attribute({
    key = 'five',
    keys = {
        'j_fibonacci', 'j_hack', 'j_odd_todd'
    }
})

SMODS.Attribute({
    key = 'six',
    keys = {
        'j_even_steven', 'j_sixth_sense'
    }
})

SMODS.Attribute({
    key = 'seven',
    keys = {
        'j_odd_todd'
    }
})

SMODS.Attribute({
    key = 'eight',
    keys = {
        'j_8_ball', 'j_even_steven', 'j_fibonacci'
    }
})

SMODS.Attribute({
    key = 'nine',
    keys = {
        'j_odd_todd', 'j_cloud_9'
    }
})

SMODS.Attribute({
    key = 'ten',
    keys = {
        'j_even_steven', 'j_walkie_talkie'
    }
})

SMODS.Attribute({
    key = 'jack',
    keys = {
        'j_hit_the_road'
    }
})

SMODS.Attribute({
    key = 'queen',
    keys = {
        'j_shoot_the_moon', 'j_triboulet'
    }
})

SMODS.Attribute({
    key = 'king',
    keys = {
        'j_baron', 'j_triboulet'
    }
})

SMODS.Attribute({
    key = 'face',
    keys = {
        'j_scary_face', 'j_pareidolia', 'j_business', 'j_ride_the_bus',
        'j_faceless', 'j_midas_mask', 'j_photograph', 'j_reserved_parking',
        'j_smiley', 'j_sock_and_buskin', 'j_caino'
    }
})

SMODS.Attribute({
    key = 'copying',
    keys = {
        'j_blueprint', 'j_brainstorm',
    }
})

SMODS.Attribute({
    key = 'food',
    keys = {
        'j_gros_michel', 'j_cavendish', 'j_ice_cream', 'j_ramen', 'j_turtle_bean', 'j_popcorn', 'j_selzer',
        'j_egg', 'j_diet_cola'
    }
})

SMODS.Attribute({
    key = 'space',
    keys = {
        'j_supernova', 'j_space', 'j_constellation', 'j_rocket', 'j_satellite', 'j_astronomer'
    }
})

SMODS.Attribute({
    key = 'discard',
    keys = {
        'j_banner', 'j_mystic_summit', 'j_delayed_grat', 'j_burglar', 'j_faceless',
        'j_green_joker', 'j_mail', 'j_drunkard', 'j_trading', 'j_ramen', 'j_castle',
        'j_merry_andy', 'j_hit_the_road', 'j_burnt', 'j_yorick'
    }
})

SMODS.Attribute({
    key = 'economy',
    keys = {
        'j_credit_card', 'j_chaos', 'j_delayed_grat', 'j_business', 'j_egg',
        'j_faceless', 'j_todo_list', 'j_cloud_9', 'j_rocket', 'j_gift',
        'j_reserved_parking', 'j_mail', 'j_to_the_moon', 'j_golden',
        'j_trading', 'j_ticket', 'j_rough_gem', 'j_matador', 'j_satellite'
    }
})

SMODS.Attribute({
    key = 'chance',
    keys = {
        'j_8_ball', 'j_gros_michel', 'j_business', 'j_space', 'j_cavendish',
        'j_hallucination', 'j_reserved_parking', 'j_bloodstone', 
    }
})

SMODS.Attribute({
    key = 'mod_chance',
    keys = {
        'j_oops'
    }
})

SMODS.Attribute({
    key = 'tarot',
    keys = {
        'j_8_ball', 'j_superposition', 'j_vagabond', 'j_hallucination', 'j_fortune_teller', 'j_cartomancer'
    }
})

SMODS.Attribute({
    key = 'planet',
    keys = {
        'j_astronomer', 'j_constellation', 'j_satellite'
    }
})

SMODS.Attribute({
    key = 'spectral',
    keys = {
        'j_sixth_sense', 'j_seance'
    }
})

SMODS.Attribute({
    key = 'joker',
    keys = { "j_abstract", "j_riff_raff", "j_swashbuckler", 'j_invisible' }
})

SMODS.Attribute({
    key = 'joker_slot',
    keys = { "j_stencil" }
})

SMODS.Attribute({
    key = 'destroy_card',
    keys = { "j_ceremonial", "j_madness", "j_trading" }
})

SMODS.Attribute({
    key = 'passive',
    keys = {
        'j_four_fingers', 'j_credit_card', 'j_chaos', 'j_pareidolia', 'j_splash', 
        'j_shortcut', 'j_to_the_moon', 'j_juggler', 'j_drunkard', 'j_troubadour',
        'j_smeared', 'j_ring_master', 'j_oops', 'j_astronomer'
    }
})

SMODS.Attribute({
    key = 'hands',
    keys = { "j_loyalty_card", "j_burglar", "j_troubadour", "j_dusk", "j_acrobat", "j_dna", "j_vagabond" }
})

SMODS.Attribute({
    key = 'reset',
    keys = { "j_obelisk", "j_campfire", "j_hit_the_road", "j_ride_the_bus" }
})

SMODS.Attribute({
    key = 'enhancements',
    keys = { "j_ticket", "j_marble", "j_steel_joker", "j_vampire", "j_midas_mask", "j_stone", "j_lucky_cat", "j_glass", "j_drivers_license" }
})

SMODS.Attribute({
    key = 'modify_card',
    keys = { "j_pareidolia", "j_hiker", "j_vampire", "j_midas_mask" }
})

SMODS.Attribute({
    key = 'prevents_death',
    keys = { "j_mr_bones" }
})

SMODS.Attribute({
    key = 'seals',
    keys = { "j_certificate" }
})

SMODS.Attribute({
    key = 'editions'
})

SMODS.Attribute({
    key = 'tag',
    keys = { 'j_diet_cola' }
})

SMODS.Attribute({
    key = 'skip',
    keys = { 'j_throwback' }
})

SMODS.Attribute({
    key = 'hand_size',
    keys = { "j_juggler", "j_turtle_bean", "j_troubadour", "j_merry_andy", "j_stuntman" }
})

SMODS.Attribute({
    key = 'reroll',
    keys = { "j_chaos", "j_flash" }
})

SMODS.Attribute({
    key = 'sell_value',
    keys = { "j_egg", "j_swashbuckler", "j_ceremonial", "j_gift" }
})

SMODS.Attribute({
    key = 'full_deck',
    keys = { "j_steel_joker", "j_cloud_9", "j_erosion", "j_stone", "j_drivers_license" }
})

SMODS.Attribute({
    key = 'on_sell',
    keys = {
        'j_luchador', 'j_diet_cola', 'j_invisible'
    }
})

SMODS.Attribute({
    key = 'boss_blind',
    keys = {
        'j_rocket', 'j_luchador', 'j_campfire', 'j_matador', 'j_chicot'
    }
})

SMODS.Attribute({
    key = 'perma_bonus',
    keys = {
        'j_hiker'
    }
})