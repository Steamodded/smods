local M = {}

local Base = {}
setmetatable(Base, Base)
M.Base = Base

local CanvasHelper = {}
setmetatable(CanvasHelper, CanvasHelper)
M.CanvasHelper = CanvasHelper

local bigFont = love.graphics.newFont(150)
local rgFont = love.graphics.newFont(16) -- For debug

local function textScaleHelper(lines, x, y, w, h, centery)
    love.graphics.push("all")
    local font = bigFont
    love.graphics.setFont(font)
    local fheight = font:getHeight()
    local nh = 0
    local nw = 0
    local params = {}
    if type(lines) == "string" then
        lines = {lines}
    end
    for _, v in ipairs(lines) do
        local mod, text
        if type(v) == "table" then
            mod = v[2] or 1
            text = v[1]
        else
            mod = 1
            text = v
        end
        nh = nh + fheight * mod
        nw = math.max(nw, font:getWidth(text) * mod)
        table.insert(params, {text = text, mod = mod})
    end
    local scalex = w / nw
    local scaley = h / nh
    local scale = math.min(scalex, scaley)
    -- TODO: If nessicary, allow centering horizontally
    if centery and scaley > scalex then
        y = y + (h - nh * scale) / 2
    end
    if scale > 1 then sendWarnMessage("Font scale is larger than actual size! (" .. tostring(scale) .."x) If this happens in a real situation, you need to update the font size or it will be blurry.", "PreflightSharedUI") end
    for _, v in ipairs(params) do
        local mod = scale * v.mod
        love.graphics.push()
        love.graphics.scale(mod)
        love.graphics.print(v.text, x / mod, y / mod)
        y = y + fheight * mod
        love.graphics.pop()
    end
    love.graphics.pop()
end
M.textScaleHelper = textScaleHelper

function CanvasHelper:setConf(conf)
    assert(type(conf.width) == "number", "Must provide a width")
    assert(type(conf.height) == "number", "Must provide a width")
    assert(conf.width > 0, "Width must be greater than 0")
    assert(conf.height > 0, "Height must be greater than 0")
    assert(type(conf.x) == "number", "Must provide a x")
    assert(type(conf.x) == "number", "Must provide a y")
    local dirty = self.dirty
    if self.conf.width ~= conf.width then dirty = true end
    if self.conf.height ~= conf.height then dirty = true end
    self.dirty = dirty
    self.conf = conf
    self.configured = true
end

function CanvasHelper:draw(dt)
    assert(self.configured, "Attempted to draw canvas that has not been configured " .. self.name)
    if self.dirty then -- TODO: Can we be dirty but not need to clear the canvas?
        self.canvas = love.graphics.newCanvas(self.conf.width, self.conf.height)
    end
    love.graphics.push("all")
    love.graphics.setCanvas(self.canvas)
    self.child:draw(dt, self.dirty)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.canvas, self.conf.x, self.conf.y)
end

function CanvasHelper:__call(child, name)
    name = name or "Unknown"
    assert(type(name) == "string", "Name must be a string")
    local res = setmetatable({}, {__index = CanvasHelper})
    res.conf = {}
    res.configured = false
    res.child = child
    res.name = name
    return res
end

function Base:draw(dt)
    if not love.graphics.isActive() then return end
    local dirty = self:checkSize()
    if dirty then
        dirty = true
        if self.header then
            local width = self.w
            local x = 0
            if not self.header.child.full then width = width - self.padx * 2 x = self.padx end
            self.header:setConf{width = width, height = self.pady, x = x, y = 0}
        end
        if self.body then
            local width = self.w - self.padx * 2
            local height = self.h - self.pady * 2
            self.body:setConf{width = width, height = height, x = self.padx, y = self.pady}
        end
    end
    love.graphics.clear(unpack(self.conf.bg))
    love.graphics.setColor(unpack(self.conf.fg))

    if self.header then
        self.header:draw(dt, dirty)
        love.graphics.setColor(unpack(self.conf.fg))
    end
    if self.body then
        self.body:draw(dt, dirty)
        love.graphics.setColor(unpack(self.conf.fg))
    end
    if self.conf.debug or PREFLIGHT_DEV then self:debug(dt) end
    love.graphics.present()
end

function Base:checkSize()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if self.w ~= w or self.h ~= h then
        self.w = w
        self.h = h
        self.padx = self.conf.padx / 100 * w
        self.pady = self.conf.pady / 100 * h
        return true
    end
    return false
end

function Base:debug(dt)
    love.graphics.push()
    love.graphics.setFont(rgFont)
    love.graphics.setColor(0, 1, 1, 0.75)
    love.graphics.rectangle("line", self.padx, self.pady, self.w - self.padx * 2, self.h - self.pady * 2)
    love.graphics.print("FPS: " .. love.timer.getFPS() .. "\nDT: " .. dt, 0, 0)
    local x, y = love.mouse.getPosition()
    love.graphics.print("(" .. x .. ", " .. y .. ")", x + 15, y + 15)
    love.graphics.pop()
end

function Base:loop()
    love.event.pump()

    for e, a, b, c in love.event.poll() do
        if e == "quit" then
            return 1
        elseif e == "keypressed" and a == "escape" then
            return 1
        elseif e == "keypressed" and a == "t" then
            return 0
        end
    end
    local dt = love.timer.step()
    self:draw(dt)
end

function Base:__call(conf)
    conf = conf or {}
    local res = setmetatable({}, {__index = self})
    res.conf = conf
    conf.bg = conf.bg or {0,0,0,1}
    conf.fg = conf.fg or {1,1,1,1}
    conf.padx = conf.padx or 3
    conf.pady = conf.pady or 10
    if conf.header and type(conf.header.draw) == "function" then
        self.header = CanvasHelper(conf.header, "Header")
    end
    if conf.body and type(conf.body.draw) == "function" then
        self.body = CanvasHelper(conf.body, "Body")
    end
    return res
end

return M
