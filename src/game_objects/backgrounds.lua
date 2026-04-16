-- bg draw steps; allows for creating multilayered backgrounds
SMODS.BackgroundDrawSteps = {}
SMODS.BackgroundDrawStep = SMODS.GameObject:extend {
    obj_table = SMODS.BackgroundDrawSteps,
    obj_buffer = {},
    required_params = {
        'key',
        'order',
        'func',
    },
    -- func = function(bg) end,
    set = "Background Draw Step",
    register = function(self)
        if self.registered then
            sendWarnMessage(('Detected duplicate register call on object %s'):format(self.key), self.set)
            return
        end
        SMODS.BackgroundDrawStep.super.register(self)
    end,
    inject = function() end,
    post_inject_class = function(self)
        table.sort(self.obj_buffer, function(_self, _other) return self.obj_table[_self].order < self.obj_table[_other].order end)
    end,
}

SMODS.BackgroundDrawStep {
    key = "base",
    order = -math.huge,
    func = function(self)
        if self.children.base then
            self.children.base:draw_shader(self.shader or "dissolve")
        end
    end,
}


SMODS.BackgroundCanvas = Moveable:extend()

function SMODS.BackgroundCanvas:init(X, Y, W, H, prototype, alpha)
    Moveable.init(self, X, Y, W, H)

    self.states.collide.can = false
    self.states.hover.can = false
    self.states.drag.can = false
    self.states.click.can = false

    self.alpha = alpha
    self.canvas = SMODS.create_canvas()
    self.children = {}

    if prototype then
        self:set_active_bg(prototype)
    end
end

function SMODS.BackgroundCanvas:draw()
    if self.alpha == 0 then return end
    local fading = self.alpha ~= 1
    if fading then love.graphics.setCanvas(self.canvas) end
    for _, k in ipairs(SMODS.DrawStep.obj_buffer) do
        SMODS.BackgroundDrawSteps[k].func(self)
    end
    if fading then
        love.graphics.setCanvas()
        love.graphics.draw(self.canvas, 0, 0)
    end
end

function SMODS.BackgroundCanvas:set_sprites()
    self.children = self.children or {}
    local obj = self.prototype

    local atlas = obj.atlas or 'ui_1'
    local pos = obj.pos or {x = obj.atlas and 2 or 0, y = 0}
    self.children.base = SMODS.create_sprite(self.T.x, self.T.y, self.T.w, self.T.h, atlas, pos)
    self.children.base:set_alignment({
        major = self,
        type = 'cm',
        bond = 'Glued',
        offset = {x=0,y=0}
    })

    if obj.set_sprites and type(obj.set_sprites) == 'function' then
        obj:set_sprites(self)
    end
end

function SMODS.BackgroundCanvas:set_active_bg(prototype)
    self.prototype = prototype
    self.shader = prototype.shader

    if prototype.set_active and type(prototype.set_active) == "function" then
        prototype:set_active(self)
    end

    for _, v in pairs(self.children) do v:remove(); v = nil end
    self:set_sprites()
end

function SMODS.BackgroundCanvas:remove()
    for _, v in pairs(self.children) do v:remove(); v = nil end
    Moveable.remove(self)
end

function SMODS.BackgroundCanvas:update()
    local obj = self.prototype
    if obj.update and type(obj.update) == 'function' then
        obj:update(self)
    end
end

function SMODS.BackgroundCanvas:ease_alpha(target, delay)
    if target == self.alpha then return end
    target = math.min(1, math.max(target, 0))
    G.E_MANAGER:add_event(Event({
        trigger = "ease",
        ref_table = self,
        ref_value = "alpha",
        ease_to = target,
        delay = delay or 2,
    }))
end

SMODS.Backgrounds = {}
SMODS.Background = SMODS.GameObject:extend {
    obj_table = SMODS.Backgrounds,
    set = 'Background',
    obj_buffer = {},
    required_params = {
        'key',
    },
    send_vars = nil, -- same as Shader.send_vars
    select_background = nil, -- should this bg be used, works like SMODS.Sounds:select_music_track

    set_sprites = nil, -- sets sprites
    set_active = nil, -- runs when bg becomes active
    update = nil, -- runs on update

    inject = function(self)
        -- assert(self.shader or self.path, "Background " .. self.key .. " not given shader key or path")
        if self.path and (not self.shader) then
            SMODS.Shader.inject(self)
            self.shader = self.key
        end
    end,
    get_current_background = function(self)
        local track
        local maxp = -math.huge
        for _, v in ipairs(self.obj_buffer) do
            local s = self.obj_table[v]
            if type(s.select_background) == 'function' then
                local res = s:select_background()
                if res then
                    if type(res) ~= 'number' then res = 0 end
                    if res > maxp then track, maxp = v, res end
                end
            end
        end
        return track
    end
}

SMODS.splash_flash = 0
SMODS.Background {
    key = "splash",
    shader = "splash",
    select_background = function(self)
        if not G.STAGES.RUN then return -math.huge end
        if bwomp then return true end
    end
}

SMODS.Background {
    key = "background",
    shader = "background",
    select_background = function(self)
        if G.STAGES.RUN then return -math.huge end
    end
}