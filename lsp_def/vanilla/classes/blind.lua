---@meta

---@class Blind: Moveable
---@overload fun(X: number, Y: number, W: number, H: number): Blind
---@overload fun(X: {T:{X: number, Y: number, W: number, H: number}}): Blind
Blind = {}
Blind.__index = Blind
Blind.super = Moveable

---@param self Blind
---@param X {T:{X: number, Y: number, W: number, H: number}}|number
---@param Y number
---@param W number
---@param H number
---@return Blind
function Blind:__call(X,Y,W,H) end

---@param self Blind
---@param X {T:{X: number, Y: number, W: number, H: number}}|number
---@param Y number
---@param W number
---@param H number
function Blind:init(X,Y,W,H) end

---@param self Blind
---@param blind_col? Color Defaults to the Blind's main color.
--- Changes the background colors based on `blind_col`.
function Blind:change_colour(blind_col) end

---@param self Blind
--- Sets the Blind's description text.
function Blind:set_text() end

---@param self Blind
---@param blind SMODS.Blind|table
---@param reset? boolean
---@param silent? boolean
--- Sets the Blind up.
function Blind:set_blind(blind, reset, silent) end

---@param self Blind
---@param first? boolean Unused in vanilla.
--- Sets the debuff alert text.
function Blind:alert_debuff(first) end

---@param self Blind
---@return string
--- Returns the debuff text for this Blind.
function Blind:get_loc_debuff_text() end

---@param self Blind
---@param silent? boolean
--- Handles the animations and effect reversion when the Blind is defeated.
function Blind:defeat(silent) end

---@param self Blind
---@return "Small"|"Big"|"Boss"|string
--- Returns the Blind's type
function Blind:get_type() end

---@param self Blind
--- Handles the effect reversion when the blind is disabled.
function Blind:disable() end

---@param self Blind
--- Wiggles the Blind's sprite.
function Blind:wiggle() end

---@param self Blind
---@param _a? number
---@param _b? number
--- Juices the Blind's sprite.
function Blind:juice_up(_a, _b) end

---@param self Blind
--- Handles hover logic for this Blind.
function Blind:hover() end

---@param self Blind
--- Handles lgoci when the Blind is no longer hovered.
function Blind:stop_hover() end

---@param self Blind
--- Draws the Blind's sprite.
function Blind:draw() end

---@param self Blind
--- Handles Blind logic when the "Play" button is pressed.
function Blind:press_play() end

---@param self Blind
---@param cards table
---@param poker_hands table
---@param text string
---@param mult number
---@param hand_chips number
---@param scoring_hand Card[]
---@return number? mult
---@return number? hand_chips
---@return boolean? modded
--- Handles Blind logic for hand modification before scoring.
function Blind:modify_hand(cards, poker_hands, text, mult, hand_chips, scoring_hand) end

---@param self Blind
---@param cards table
---@param hand table
---@param handname string
---@param check? boolean
--- Handles Blind logic when checking if the played hand should be debuffed.
function Blind:debuff_hand(cards, hand, handname, check) end

---@param self Blind
--- Handles Blind logic when a card is drawn to hand.
function Blind:drawn_to_hand() end

---@param self Blind
---@param to_area CardArea
---@param card Card
---@param from_area CardArea
---@return boolean? 
--- Handles Blind logic when checking if a card should remain face down when drawn.
function Blind:stay_flipped(to_area, card, from_area) end

---@param self Blind
---@param card Card
---@param from_blind? boolean
--- Handles Blind logic when checking if a card should be debuffed.
function Blind:debuff_card(card, from_blind) end

---@param self Blind
---@param context CalcContext
--- Calculates the Blind. 
function Blind:calculate(context) end

---@param self Blind
---@param dt number
--- Moves the Blind.
function Blind:move(dt) end

---@param self Blind
---@param w? number
---@param h? number
--- Changes the dimensions of this Blind.
function Blind:change_dim(w, h) end

---@param self Blind
--- Aligns the Blind and Blind's sprite.
function Blind:align() end

---@param self Blind
---@return table
--- Returns a table representing this Blind to be saved.
function Blind:save() end

---@param self Blind
---@param blindTable table
--- Loads the blind based on provided `blindTable`.
function Blind:load(blindTable) end
