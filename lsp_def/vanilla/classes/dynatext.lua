---@meta

---@class DynaText: Moveable
---@overload fun(config: {X: number, Y: number, W: number, H: number}|table): DynaText
DynaText = {}
DynaText.__index = DynaText
DynaText.super = Moveable

---@param self DynaText
---@param config {X: number, Y: number, W: number, H: number}|table
---@return DynaText
function DynaText:__call(config) end

---@param self DynaText
---@param config {X: number, Y: number, W: number, H: number}|table
function DynaText:init(config) end

---@param self DynaText
---@param dt number
--- Updates the DynaText.
function DynaText:update(dt) end

---@param self DynaText
---@param first_pass? boolean
--- Updates the text of the DynaText.
function DynaText:update_text(first_pass) end

---@param self DynaText
---@param pop_out_timer? number 
--- Pops out the DynaText text.
function DynaText:pop_out(pop_out_timer) end

---@param self DynaText
---@param pop_in_timer? number
function DynaText:pop_in(pop_in_timer) end

---@param self DynaText
--- Aligns the letter of the DynaText.
function DynaText:align_letters() end

---@param self DynaText
---@param amt? number
--- Sets the text to quiver.
function DynaText:set_quiver(amt) end

---@param self DynaText
---@param amt? number
--- Sets the text to pulse.
function DynaText:pulse(amt) end

---@param self DynaText
--- Draws the DynaText.
function DynaText:draw() end
