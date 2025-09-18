---@meta

---@class Sprite: Moveable
---@overload fun(X: number, Y: number, W: number, H: number, new_sprite_atlas: love.Image, sprite_pos: {x: number, y: number}|table): Sprite
Sprite = {}
Sprite.__index = Sprite
Sprite.super = Moveable

---@param self Sprite
---@param X number
---@param Y number
---@param W number
---@param H number
---@param new_sprite_atlas love.Image
---@param sprite_pos {x: number, y: number}|table
---@return Sprite
function Sprite:__call(X, Y, W, H, new_sprite_atlas, sprite_pos) end

---@param self Sprite
---@param X number
---@param Y number
---@param W number
---@param H number
---@param new_sprite_atlas love.Image
---@param sprite_pos {x: number, y: number}|table
function Sprite:init(X, Y, W, H, new_sprite_atlas, sprite_pos) end

---@param self Sprite
--- Resets Sprite atlas and position.
function Sprite:reset() end

---@param self Sprite
---@param sprite_pos {x: number, y: number, v?: number}
--- Sets the sprite position.
function Sprite:set_sprite_pos(sprite_pos) end

---@param self Sprite
---@return {[1]: number, [2]: number, [3]: number, [4]: number} self.RETS.get_pos_pixel
--- Returns texture information of the sprite. 
function Sprite:get_pos_pixel() end

---@param self Sprite
---@return {[1]: number, [2]: number} self.image_dims
--- Returns image width and height.
function Sprite:get_image_dims() end

---@class Sprite.DrawStep
---@field shader? string|"dissolve" Shader to draw. Defaults to `"dissolve"`.
---@field shadow_height? number Height of the shadow.
---@field send? table Variables to send to the shader.
---@field no_tilt? boolean Sets if the shader should account for hover tilt.
---@field other_obj? Moveable Draws the step onto the provided Moveable.
---@field ms? number Moveable scale.
---@field mr? number Moveable rotation.
---@field mx? number Moveable x offset.
---@field my? number Moveable y offset.

---@param self Sprite
---@param draw_step_definitions Sprite.DrawStep[]
--- Defines draw steps for the Sprite.
function Sprite:define_draw_steps(draw_step_definitions) end

---@param self Sprite
---@param _shader string Shader to draw.
---@param _shadow_height? number Shadow height.
---@param _send? table[] Custom variables to send to the shader.
---@param _no_tilt? boolean Sets if the shader should account for hover tilt.
---@param other_obj? Moveable Draws the shader onto the provided Moveable.
---@param ms? number Moveable scale.
---@param mr? number Moveable rotation.
---@param mx? number Moveable x offset.
---@param my? number Moveable y offset.
---@param custom_shader? boolean Sets if the shader gets sent default values.
---@param tilt_shadow? number Tilt of the shadow.
--- Draws the shader.
function Sprite:draw_shader(_shader, _shadow_height, _send, _no_tilt, other_obj, ms, mr, mx, my, custom_shader, tilt_shadow) end

---@param self Sprite
---@param overlay? table Color overlay.
--- Draws the Sprite image.
function Sprite:draw_self(overlay) end

---@param self Sprite
---@param overlay? table
--- Draws the Sprite and any additional shaders.
function Sprite:draw(overlay) end

---@param self Sprite
---@param other_obj Moveable
---@param ms? number Moveable scale.
---@param mr? number Moveable rotation.
---@param mx? number Moveable x offset.
---@param my? number Moveable y offset.
--- Draws Sprite from another Moveable.
function Sprite:draw_from(other_obj, ms, mr, mx, my) end

---@param self Sprite
--- Removes the Sprite.
function Sprite:remove() end
