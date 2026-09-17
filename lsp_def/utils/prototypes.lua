---@meta

---Returns the prototype object of this blind.
---@return SMODS.Blind|table
function Blind:prototype() end

---Returns the prototype object of this deck.
---@return SMODS.Back|table
function Back:prototype()
    return SMODS.Back.get_prototype_object(self)
end

---Returns the prototype object of this tag.
---@return SMODS.Tag|table
function Tag:prototype()
    return SMODS.Tag.get_prototype_object(self)
end

---Map of keys for card prototypes to their corresponding SMODS game object class.
---@type table<string,SMODS.GameObject|table>
SMODS.card_prototype_map = {}

---@alias card_prototype_args
---| 'center'
---| 'enhancement'
---| 'edition'
---| 'seal'
---| 'rank'
---| 'suit'
---| 'rarity'
---| 'card'

---Returns the prototype object of a property of this card.
---@param obj_type card_prototype_args? Card property, returns the center if `nil`
---@return table|SMODS.GameObject?
---@overload fun(obj_type: 'sticker'|'stickers'):table<string,SMODS.Sticker|table>?
function Card:prototype(obj_type) end