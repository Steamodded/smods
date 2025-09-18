---@meta

---@class Particles: Moveable
---@overload fun(X: number, Y: number, W: number, H: number, config?: table): Particles
Particles = {}
Particles.__index = Particles
Particles.super = Moveable

---@param self Particles
---@param X number
---@param Y number
---@param W number
---@param H number
---@param config? table
---@return Particles
function Particles:__call(X, Y, W, H, config) end

---@param self Particles
---@param X number
---@param Y number
---@param W number
---@param H number
---@param config? table
function Particles:init(X, Y, W, H, config) end

---@param self Particles
---@param dt number
--- Draws the Particles.
function Particles:update(dt) end

---@param self Particles
---@param dt number
--- Moves the Particles.
function Particles:move(dt) end

---@param self Particles
---@param delay? number
---@param to? number
--- Fade the Particles.
function Particles:fade(delay, to) end

---@param self Particles
---@param alpha? number
--- Draws the Particles.
function Particles:draw(alpha) end

---@param self Particles
--- Removes the Particles.
function Particles:remove() end
