SMODS.SpriteStepCanvases = {} -- Canvases for different atlas sizes, helps preserve shader effects
SMODS.SpriteStepStorageCanvases = {} -- Same as SpriteStepCanvases, but acts as the temporary canvas when going across SpriteSteps
SMODS.SpriteStepQuad = love.graphics.newQuad(0,0,71,95,71,95)
SMODS.SpriteSteps = {}

SMODS.SpriteStep = SMODS.GameObject:extend {
	obj_table = SMODS.SpriteSteps,
	obj_buffer = {},
	order = 0,
	required_params = {
		'key',
		'func',
		'should_apply'
	},
	-- func = function(self, quad, raw_spr, sprite) end,
	-- should_apply = function(self, sprite) end,
	set = "Sprite Step",
	register = function(self)
		if self.registered then
			sendWarnMessage(('Detected duplicate register call on object %s'):format(self.key), self.set)
			return
		end
		SMODS.SpriteStep.super.register(self)
	end,
	inject = function() end,
	post_inject_class = function(self)
		table.sort(self.obj_buffer, function(_self, _other) return self.obj_table[_self].order < self.obj_table[_other].order end)
	end,
}

local function draw_storage(first, sprite, canvas)
	local vx, vy = sprite.sprite:getViewport()
	love.graphics.clear()
	if first then
		love.graphics.draw(
			sprite.atlas.image,
			sprite.sprite,vx,vy)
	else
		love.graphics.draw(canvas, 0, 0)
	end
end

local function draw_thingy(step, image, quad, sprite)
	local vx, vy = sprite.sprite:getViewport()
	love.graphics.clear()
	love.graphics.translate(vx,vy)
	step:func(image, quad, sprite)
end

local sds_hook = Sprite.draw_self
function Sprite:draw_self(overlay)
	-- Skip if no SpriteSteps are applicable
	local do_the_thing = false
	for i, k in ipairs(SMODS.SpriteStep.obj_buffer) do
		local step = SMODS.SpriteSteps[k]
		if step.should_apply and step:should_apply(self) or type(step.should_apply) == "nil" then do_the_thing = true break end
	end
	if not do_the_thing then sds_hook(self, overlay) return end

	love.graphics.push("all")

	-- Get Canvas to use
	local qx,qy = self.image_dims[1], self.image_dims[2]
	local canvas_name = qx.."_"..qy
	if not SMODS.SpriteStepCanvases[canvas_name] then
		SMODS.SpriteStepCanvases[canvas_name] = love.graphics.newCanvas(qx,qy)
		SMODS.SpriteStepStorageCanvases[canvas_name] = love.graphics.newCanvas(qx,qy)
	end
	local canvas = SMODS.SpriteStepCanvases[canvas_name]
	local storagecanvas = SMODS.SpriteStepStorageCanvases[canvas_name]

	local vx,vy = self.sprite:getViewport()

	SMODS.SpriteStepQuad:setViewport(vx,vy,self.scale.x,self.scale.y,qx,qy)

    love.graphics.setBlendMode("alpha", "premultiplied")
	local first = true
	for i, k in ipairs(SMODS.SpriteStep.obj_buffer) do
		local step = SMODS.SpriteSteps[k]
		if step.should_apply and step:should_apply(self) or type(step.should_apply) == "nil" then
			love.graphics.push()
			love.graphics.setColor(1,1,1,1)
			love.graphics.setShader()
			love.graphics.origin()
			storagecanvas:renderTo(draw_storage, first, self, canvas)
			canvas:renderTo(draw_thingy, step, storagecanvas, SMODS.SpriteStepQuad, self)
			love.graphics.pop()
			first = false
		end
	end
	
	love.graphics.pop()

	-- Draw with the new canvas
	local old_img = self.atlas.image
	self.atlas.image = canvas
	sds_hook(self, overlay)
	self.atlas.image = old_img
end