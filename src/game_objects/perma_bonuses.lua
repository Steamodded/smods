SMODS.PermaBonuses = {}
SMODS.PermaBonus = SMODS.GameObject:extend{
    set = "PermaBonus",
    obj_table = SMODS.PermaBonuses,
    obj_buffer = {},
    required_params = {
        'key',
        'apply_to',
    },
    prefix_config = { key = false },
    signed_value = false,
    signed_dollars = false,
    should_apply = function(self, card, calculation)
        if calculation == self.apply_to then return true end
    end,
    get_ui_value = function(self, card)
        return card.ability[self.key] and card.ability[self.key] ~= 0 and (card.ability[self.key] + (self.ui_mod or 0)) or nil
    end,
    upgrade = function(self, card, amount)
        card.ability[self.key] = card.ability[self.key] or 0
        card.ability[self.key] = card.ability[self.key] + (amount or 1)
    end,
    localize = function(self, value, desc_nodes)
        if self.signed_dollars then value = SMODS.signed_dollars(value)
        elseif self.signed_value then value = SMODS.signed(value) end
        localize{type = 'other', key = self.loc_key, nodes = desc_nodes, vars = {value}}
    end,
    inject = function(self)
        self.loc_key = self.loc_key or self.key
        self.vars_key = self.vars_key or self.key
    end,
    process_loc_text = function(self)
        SMODS.process_loc_text(G.localization.descriptions.Other, self.loc_key, self.loc_txt)
    end,
}

function SMODS.localize_perma_bonuses(specific_vars, desc_nodes)
    if not specific_vars then return end
    local used_keys = {}
    for _,_key in pairs(SMODS.PermaBonus.obj_buffer) do
        local PB = SMODS.PermaBonuses[_key]
        --perma_bonus text is handled by vanilla
        if _key ~= 'perma_bonus' and specific_vars[PB.vars_key] and not used_keys[PB.vars_key] then
            PB:localize(specific_vars[PB.vars_key], desc_nodes)
            used_keys[PB.vars_key] = true
        end
    end
end

function SMODS.set_perma_bonus(card, new_ability)
    for _,_key in ipairs(SMODS.PermaBonus.obj_buffer) do
        new_ability[_key] = card.ability and card.ability[_key] or 0
    end
end

function SMODS.get_perma_bonus_ui_vars(card)
    if not card.ability then return {} end
    local ret = {}
    for _,v in pairs(SMODS.PermaBonuses) do
        local bonus = v:get_ui_value(card)
        ret[v.vars_key] = ((ret[v.vars_key] or 0) + (bonus or 0) ~= 0 and (ret[v.vars_key] or 0) + (bonus or 0)) or nil
    end
    return ret
end

function SMODS.upgrade_perma_bonus(args)
    if type(args.keys) == 'string' then args.keys = {args.keys} end
    if type(args.keys) ~= 'table' or type(args.card) ~= 'table' then return end
    args.amount = args.amount or 1
    for _,key in ipairs(args.keys) do
        if SMODS.PermaBonuses[key] then
            if args.func then
                args.func(args.card, args.amount, args.from or {}, SMODS.PermaBonuses[key])
            else
                SMODS.PermaBonuses[key]:upgrade(args.card, args.amount, args.from or {})
            end
        end
    end
end

function Card:get_perma_bonus(calculation)
    local ret = (not calculation and {}) or 0
    for k,v in pairs(SMODS.PermaBonuses) do
        if not calculation then
            ret[k] = self.ability[k]
        elseif v:should_apply(self, calculation) then
            ret = ret + (self.ability[k] or 0)
        end
    end
    return ret
end

SMODS.PermaBonus({
    key = 'perma_bonus',
    apply_to = 'chips',
    vars_key = 'bonus_chips',
    loc_key = 'card_extra_chips',
    signed_value = true,
    get_ui_value = function(self, card)
        if not (card.ability and card.ability.bonus) then return end
        local bonus_chips = card.ability.bonus + (card.ability[self.key] or 0)
        return bonus_chips ~= 0 and bonus_chips or nil
    end
})
for _,pb in ipairs({
    {key = 'perma_x_chips', apply_to = 'x_chips', vars_key = 'bonus_x_chips', loc_key = 'card_extra_x_chips', ui_mod = 1},

    {key = 'perma_mult', apply_to = 'mult', vars_key = 'bonus_mult', loc_key = 'card_extra_mult', signed_value = true},
    {key = 'perma_x_mult', apply_to = 'x_mult', vars_key = 'bonus_x_mult', loc_key = 'card_extra_x_mult', ui_mod = 1},

    {key = 'perma_h_chips', apply_to = 'h_chips', vars_key = 'bonus_h_chips', loc_key = 'card_extra_h_chips', signed_value = true},
    {key = 'perma_h_x_chips', apply_to = 'h_x_chips', vars_key = 'bonus_h_x_chips', loc_key = 'card_extra_h_x_chips', ui_mod = 1},
    {key = 'perma_h_mult', apply_to = 'h_mult', vars_key = 'bonus_h_mult', loc_key = 'card_extra_h_mult', signed_value = true},
    {key = 'perma_h_x_mult', apply_to = 'h_x_mult', vars_key = 'bonus_h_x_mult', loc_key = 'card_extra_h_x_mult', ui_mod = 1},

    {key = 'perma_p_dollars', apply_to = 'p_dollars', vars_key = 'bonus_p_dollars', loc_key = 'card_extra_p_dollars', signed_dollars = true},
    {key = 'perma_h_dollars', apply_to = 'h_dollars', vars_key = 'bonus_h_dollars', loc_key = 'card_extra_h_dollars', signed_dollars = true},

    {key = 'perma_score', apply_to = 'score', vars_key = 'bonus_score', loc_key = 'card_extra_score', signed_value = true},
    {key = 'perma_h_score', apply_to = 'h_score', vars_key = 'bonus_h_score', loc_key = 'card_extra_h_score', signed_value = true},
    {key = 'perma_x_score', apply_to = 'x_score', vars_key = 'bonus_x_score', loc_key = 'card_extra_x_score', ui_mod = 1},
    {key = 'perma_h_x_score', apply_to = 'h_x_score', vars_key = 'bonus_h_x_score', loc_key = 'card_extra_h_x_score', ui_mod = 1},

    {key = 'perma_blind_size', apply_to = 'blind_size', vars_key = 'bonus_blind_size', loc_key = 'card_extra_blind_size', signed_value = true},
    {key = 'perma_h_blind_size', apply_to = 'h_blind_size', vars_key = 'bonus_h_blind_size', loc_key = 'card_extra_h_blind_size', signed_value = true},
    {key = 'perma_x_blind_size', apply_to = 'x_blind_size', vars_key = 'bonus_x_blind_size', loc_key = 'card_extra_x_blind_size', ui_mod = 1},
    {key = 'perma_h_x_blind_size', apply_to = 'h_x_blind_size', vars_key = 'bonus_h_x_blind_size', loc_key = 'card_extra_h_x_blind_size', ui_mod = 1},
}) do
    SMODS.PermaBonus(pb)
end

SMODS.PermaBonus({
    key = 'perma_repetitions',
    apply_to = 'repetitions',
    vars_key = 'bonus_repetitions',
    loc_key = 'card_extra_repetitions',
    localize = function(self, value, desc_nodes)
        localize{type = 'other', key = self.loc_key, nodes = desc_nodes, vars = {value, localize(value > 1 and 'b_retrigger_plural' or 'b_retrigger_single')}}
    end
})
