SMODS.Stake.get_applied = function()
    if G.STAGE ~= G.STAGES.RUN or not G.GAME.applied_stakes then return {} end
    local ret = {}
    for _, stake in ipairs(G.GAME.applied_stakes or {}) do
        local prototype = G.P_CENTER_POOLS.Stake[stake]
        if prototype then
            ret[prototype.key] = prototype
        end
    end
    return ret
end

SMODS.Challenge.get_current = function()
    return G.GAME.challenge_tab
end

SMODS.Rarity.get_prototype_object = function(card)
    if type(card.prototype) ~= "function" then return end
    local rarity = card:prototype().rarity
    rarity = ({ "Common", "Uncommon", "Rare", "Legendary" })[rarity] or rarity
    return SMODS.Rarities[rarity]
end

SMODS.Center.get_prototype_object = function(card)
    return card.config.center
end

SMODS.Back.get_prototype_object = function(back)
    return back.effect.center
end

SMODS.Seal.get_prototype_object = function(card)
    return card.seal and G.P_SEALS[card.seal]
end

SMODS.Suit.get_prototype_object = function(card)
    return card.base and SMODS.Suits[card.base.suit]
end

SMODS.Rank.get_prototype_object = function(card)
    return card.base and SMODS.Ranks[card.base.value]
end

SMODS.Tag.get_prototype_object = function(tag)
    return tag.key and G.P_TAGS[tag.key] or
        tag.config and tag.config.tag and G.P_TAGS[tag.config.tag.key] -- tag sprites
end

SMODS.Edition.get_prototype_object = function(card)
    return card.edition and G.P_CENTERS[card.edition.key]
end

SMODS.Sticker.get_stickers = function(card)
    local stickers = {}
    for key, prototype in pairs(SMODS.Stickers) do
        if (key == 'pinned' and card.pinned) or card.ability[key] then
            stickers[key] = prototype
        end
    end
    return next(stickers) and stickers or nil
end

SMODS.Sticker.get_prototype_object = function(card)
    return SMODS.Sticker.get_stickers(card)
end

SMODS.Blind.get_prototype_object = function(blind)
    return blind.config.blind
end

function Blind:prototype()
    return SMODS.Blind.get_prototype_object(self)
end

function Back:prototype()
    return SMODS.Back.get_prototype_object(self)
end

function Tag:prototype()
    return SMODS.Tag.get_prototype_object(self)
end

SMODS.card_prototype_map = {
    center = SMODS.Center,
    enhancement = SMODS.Center,
    edition = SMODS.Edition,
    seal = SMODS.Seal,
    sticker = SMODS.Sticker,
    stickers = SMODS.Sticker,
    rank = SMODS.Rank,
    suit = SMODS.Suit,
    rarity = SMODS.Rarity,
}

function Card:prototype(obj_type)
    local class = SMODS.card_prototype_map[obj_type]
    if class then
        return class.get_prototype_object(self)
    end

    if obj_type == "card" then
        return self.config.card
    end

    if obj_type ~= nil then
        sendWarnMessage(("Card.prototype called with invalid class %s"):format(obj_type), "Card")
    end
    return SMODS.Center.get_prototype_object(self)
end
