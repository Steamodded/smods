---@meta

---@class Moveable: Node
---@overload fun(X: number, Y: number, W: number, H: number): Moveable
---@overload fun(X?: {T:{X: number, Y: number, W: number, H: number}}): Moveable
Moveable = {}
Moveable.__index = Moveable
Moveable.super = Node

---@param self Moveable
---@param X {T:{X: number, Y: number, W: number, H: number}}|number
---@param Y number
---@param W number
---@param H number
---@return Moveable
function Moveable:__call(X,Y,W,H) end

---@param self Moveable
---@param X {T:{X: number, Y: number, W: number, H: number}}|number
---@param Y number
---@param W number
---@param H number
function Moveable:init(X,Y,W,H) end

---@param self Moveable
--- Draws Moveable. 
function Moveable:draw() end

---@param self Moveable
---@param args {major: Moveable, bond: string, offset: table, type: string}
--- Sets the alignment of moveable using roles
--- 
--- **major** The moveable this moveable will attach to\
--- **bond** The bond type, either 'Strong' or 'Weak'. Strong instantly adjusts VT, Weak manually calculates VT changes\
--- **offset** {x , y} offset from the alignment\
--- **type** the alignment type. Vertical options: c - center, t - top, b - bottom. Horizontal options: l - left, m - middle, r - right. i for inner
function Moveable:set_alignment(args) end

---@param self Moveable
--- Aligns Node to major. 
function Moveable:align_to_major() end

---@param self Moveable
---@param X number
---@param Y number
---@param W number
---@param H number
--- Hard sets Node transform. 
function Moveable:hard_set_T(X, Y, W, H) end

---@param self Moveable
--- Hard sets card VT. 
function Moveable:hard_set_VT() end

---@param self Moveable
---@param offset {x: number, y: number}
--- Drags the Moveable. 
function Moveable:drag(offset) end

---@param self Moveable
---@param amount number
---@param rot_amt number
--- Controls juice amount for the Moveable. 
function Moveable:juice_up(amount, rot_amt) end

---@param self Moveable
---@param dt number 
--- Controls the juice movement for the Moveable.
function Moveable:move_juice(dt) end

---@param self Moveable
---@param dt number
--- Controls the movement of the Moveable. 
function Moveable:move(dt) end

---@param self Moveable
function Moveable:lr_clamp() end

---@param self Moveable
---@param major_tab table 
--- Glues Moveable to major. 
function Moveable:glue_to_major(major_tab) end

---@param self Moveable
---@param dt number
--- Moves Moveable with major.
function Moveable:move_with_major(dt) end

---@param self Moveable
---@param dt number
--- Controls the x and y movement of the Moveable.
function Moveable:move_xy(dt) end

---@param self Moveable
---@param dt number
--- Controls the scale of the Moveable.
function Moveable:move_scale(dt) end

---@param self Moveable
---@param dt number 
--- Controls the width and height of the Moveable. 
function Moveable:move_wh(dt) end

---@param self Moveable
---@param dt number 
---@param vel {x: number, y: number}
--- Controls rotational movement of the Moveable.
function Moveable:move_r(dt, vel) end

---@param self Moveable
--- Calculates shadow parrallax.
function Moveable:calculate_parrallax() end

---@param self Moveable
---@param args table
--- Sets the role of this Moveable.
function Moveable:set_role(args) end

---@param self Moveable
---@return table major
--- Returns the major for this Moveable.
function Moveable:get_major() end

---@param self Moveable
--- Removes this Moveable.
function Moveable:remove() end