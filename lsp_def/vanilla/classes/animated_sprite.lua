---@meta

---@class AnimatedSprite: Sprite
---@overload fun(X: number, Y: number, W: number, H: number, new_sprite_atlas: love.Image, sprite_pos: {x: number, y: number}|table): AnimatedSprite
AnimatedSprite = {}
AnimatedSprite.__index = AnimatedSprite
AnimatedSprite.super = Sprite

---@param self AnimatedSprite
---@param X number
---@param Y number
---@param W number
---@param H number
---@param new_sprite_atlas love.Image
---@param sprite_pos {x: number, y: number}|table
---@return AnimatedSprite
function AnimatedSprite:__call(X, Y, W, H, new_sprite_atlas, sprite_pos) end

---@param self AnimatedSprite
---@param X number
---@param Y number
---@param W number
---@param H number
---@param new_sprite_atlas love.Image
---@param sprite_pos {x: number, y: number}|table
function AnimatedSprite:init(X, Y, W, H, new_sprite_atlas, sprite_pos) end

---@param self AnimatedSprite
--- Rescales AnimatedSprite.
function AnimatedSprite:rescale() end

---@param self AnimatedSprite
--- Resets AnimatedSprite.
function AnimatedSprite:reset() end

---@param self AnimatedSprite
---@param sprite_pos {x: number, y: number}
--- Sets sprite position for the AnimatedSprite.
function AnimatedSprite:set_sprite_pos(sprite_pos) end

---@param self AnimatedSprite
---@return {[1]: number, [2]: number, [3]: number, [4]: number} self.RETS.get_pos_pixel
--- Returns texture information of the AnimatedSprite. 
function AnimatedSprite:get_pos_pixel() end

---@param self AnimatedSprite
--- Draws the AnimatedSprite.
function AnimatedSprite:draw_self() end

---@param self AnimatedSprite
--- Animates the AnimatedSprite.
function AnimatedSprite:animate() end

---@param self AnimatedSprite
--- Removes the AnimatedSprite.
function AnimatedSprite:remove() end
