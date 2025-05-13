---@meta

---@class CardArea: Moveable
---@overload fun(X: number, Y: number, W: number, H: number, config?: table): CardArea
CardArea = {}
CardArea.__index = CardArea
CardArea.super = Moveable

--- Consumable CardArea
G.consumeables = CardArea(0, 0, 2.3*G.CARD_W, 0.95*G.CARD_H, {card_limit = 2, type = 'joker', highlight_limit = 1})
--- Joker CardArea
G.jokers = CardArea(0, 0, 4.9*G.CARD_W, 0.95*G.CARD_H, {card_limit = 5, type = 'joker', highlight_limit = 1})
--- Discard CardArea
G.discard = CardArea(0, 0, G.CARD_W, G.CARD_H, {card_limit = 500, type = 'discard'})
--- Voucher CardArea
G.vouchers = CardArea(0, 0, G.CARD_W, G.CARD_H, {type = 'discard', card_limit = 1e308})
--- Deck CardArea
G.deck = CardArea(0, 0, 5.3*G.CARD_W, 0.95*G.CARD_H, {type = 'deck', card_limit = 52})
--- Hand CardArea
G.hand = CardArea(0, 0, 6*G.CARD_W, 0.95*G.CARD_H, {type = 'hand', card_limit = 8})
--- Played CardArea
G.play = CardArea(0, 0, 5.3*G.CARD_W, 0.95*G.CARD_H, {type = 'play', card_limit = 5})

---@param self CardArea
---@param X number
---@param Y number
---@param W number
---@param H number
---@param config table
---@return CardArea
function CardArea:__call(X, Y, W, H, config) end

---@param self CardArea
---@param X number
---@param Y number
---@param W number
---@param H number
---@param config table
function CardArea:init(X, Y, W, H, config) end

---@param self CardArea
---@param card Card
---@param location string
---@param stay_flipped? boolean
--- Adds provided `card` into the CardArea
function CardArea:emplace(card, location, stay_flipped) end

---@param self CardArea
---@param card? Card
---@param discarded_only? boolean 
---@return Card?
--- Removes provided `card` from the CardArea.
--- Defaults to removing the first card in the CardArea, or last if `discarded_only` is `true`.
function CardArea:remove_card(card, discarded_only) end

---@param self CardArea
---@param delta number
--- Changes the size of the CardArea by `delta`.
function CardArea:change_size(delta) end

---@param self CardArea
---@param card? Card Unused in vanilla
---@return boolean
--- Checks if cards within the CardArea can be highlighted.
function CardArea:can_highlight(card) end

---@param self CardArea
---@param card Card
---@param silent? boolean
--- Adds provided `card` to the CardArea's `highlighted` table.
function CardArea:add_to_highlighted(card, silent) end

---@param self CardArea
--- Parses the highlighted cards for the poker hand and updates the hand text.
--- Only called for `G.hand`.
function CardArea:parse_highlighted() end

---@param self CardArea
---@param card Card
---@param force? boolean
--- Removes provided `card` from highlighted. 
function CardArea:remove_from_highlighted(card, force) end

---@param self CardArea
--- Unhighlights all cards.
function CardArea:unhighlight_all() end

---@param self CardArea
--- Sets all of the card's ranks, and sets if the cards can be dragged or collided with.
function CardArea:set_ranks() end

---@param self CardArea
---@param dt number
--- Controls the movement of the CardArea.
function CardArea:move(dt) end

---@param self CardArea
---@param dt number
--- Updates the CardArea.
function CardArea:update(dt) end

---@param self CardArea
--- Draws the CardArea.
function CardArea:draw() end

---@param self CardArea
--- Aligns the card within the CardArea.
function CardArea:align_cards() end

---@param self CardArea
---@param X number
---@param Y number
---@param W number
---@param H number
--- Hard sets the CardArea transform.
function CardArea:hard_set_T(X, Y, W, H) end

---@param self CardArea
--- Hard sets the transform for all cards within this CardArea.
function CardArea:hard_set_cards() end

---@param self CardArea
---@param _seed? string
--- Shuffles the cards within this CardArea.
function CardArea:shuffle(_seed) end

---@param self CardArea
---@param method? "desc"|"asc"|"suit desc"|"suit asc"|"order" [[
--- "desc": Descending order \
--- "asc": Ascending order \
--- "suit desc": Descending Order based on suit nominal \
--- "suit asc": Ascending order based on suit nominal \
--- "order": Based on the card's internal order \
---]]
--- Sorts the cards based on provided `method` or `self.config.sort`.
function CardArea:sort(method) end

---@param self CardArea
---@param area CardArea
---@param stay_flipped? boolean Unused in this function
---@param discarded_only? boolean 
---@return true? # Returns `nil` if a card could not be drawn.
--- Draws a card from provided `area` and emplaces them into this CardArea.
function CardArea:draw_card_from(area, stay_flipped, discarded_only) end

---@param self CardArea
--- Handle button presses for this CardArea.
function CardArea:click() end

---@param self CardArea
---@return table
--- Saves the CardArea.
function CardArea:save() end

---@param self CardArea
---@param cardAreaTable table
--- Loads the CardArea.
function CardArea:load(cardAreaTable) end

---@param self CardArea
--- Removes the CardArea.
function CardArea:remove() end
