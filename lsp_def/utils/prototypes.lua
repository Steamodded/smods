---@meta

---Returns the prototype object of this blind.
---@return SMODS.Blind|table
function Blind:prototype() end

---Returns the prototype object of this deck.
---@return SMODS.Back|table
function Back:prototype() end

---Returns the prototype object of this tag.
---@return SMODS.Tag|table
function Tag:prototype() end

---Map of keys for card prototypes to their corresponding SMODS game object class.
---@type table<string,SMODS.GameObject|table>
SMODS.card_prototype_map = {}

---@alias card_prototype_args
---| 'center'
---| 'enhancement'
---| 'edition'
---| 'sticker'
---| 'seal'
---| 'rank'
---| 'suit'
---| 'rarity'
---| 'card'

---Returns the prototype object of a property of this card.
---@param self Card
---@param obj_type card_prototype_args Card property, returns the center if `nil`
---@return nil
---@overload fun(self: Card):SMODS.Center|table?
---@overload fun(self: Card, obj_type: 'center'|'enhancement'):SMODS.Center|table
---@overload fun(self: Card, obj_type: 'edition'):SMODS.Edition|table?
---@overload fun(self: Card, obj_type: 'seal'):SMODS.Seal|table?
---@overload fun(self: Card, obj_type: 'rank'):SMODS.Rank|table?
---@overload fun(self: Card, obj_type: 'suit'):SMODS.Suit|table?
---@overload fun(self: Card, obj_type: 'rarity'):SMODS.Rarity|table?
---@overload fun(self: Card, obj_type: 'card'):{name:string,value:string,suit:string,pos:{x:integer,y:integer}}|table?
---@overload fun(self: Card, obj_type: 'sticker'|'stickers'):table<string,SMODS.Sticker|table>?
function Card:prototype(obj_type) end

---Returns the key of this blind.
---@return string
function Blind:get_key() end

---Returns the key of this deck.
---@return string
function Back:get_key() end

---Returns the key of this tag.
---@return string
function Tag:get_key() end

---Returns the prototype object of a property of this card.
---@param self Card
---@param obj_type card_prototype_args Card property, returns the center if `nil`
---@return string
---@overload fun(self: Card, obj_type: 'sticker'|'stickers'):string[]
function Card:prototype(obj_type) end
