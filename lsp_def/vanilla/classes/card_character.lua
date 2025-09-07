---@meta

---@class Card_Character: Moveable
---@overload fun(args: {X?: number, Y?: number, W?: number, H?: number}): Card_Character
Card_Character = {}
Card_Character.__index = Card_Character
Card_Character.super = Moveable

---@param self Card_Character
---@param args {X?: number, Y?: number, W?: number, H?: number}
---@return Card_Character
function Card_Character:__call(args) end

---@param self Card_Character
---@param args {X?: number, Y?: number, W?: number, H?: number}
function Card_Character:init(args) end

---@param self Card_Character
---@param dt number
--- Modes the Card_Character.
function Card_Character:move(dt) end

---@param self Card_Character
--- Hard sets Card_Character VT.
function Card_Character:hard_set_VT() end

---@param self Card_Character
--- Aligns the Card_Character.
function Card_Character:align() end

---@param self Card_Character
---@param button string 
---@param func? string
---@param colour? table
---@param update_func? string
---@param snap_to? boolean
---@param yoff? number
--- Adds a button onto the Card_Character.
function Card_Character:add_button(button, func, colour, update_func, snap_to, yoff) end

---@param self Card_Character
---@param text_key? string
---@param align? string
---@param loc_vars table
--- Adds a speech bubble for the Card_Character
function Card_Character:add_speech_bubble(text_key, align, loc_vars) end

---@param self Card_Character
--- Removes any buttons from the Card_Character.
function Card_Character:remove_button() end

---@param self Card_Character
--- Removes any speech bubbles from the Card_Character.
function Card_Character:remove_speech_bubble() end

---@param self Card_Character
---@param n number
---@param not_first? boolean
--- Makes the Card_Character say stuff.
function Card_Character:say_stuff(n, not_first) end

---@param self Card_Character
---@param dt number
--- Draws the Card_Character.
function Card_Character:draw(dt) end

---@param self Card_Character
--- Removes the Card_Character.
function Card_Character:remove() end
