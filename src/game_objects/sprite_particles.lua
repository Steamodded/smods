SMODS.SPRITE_PARTICLES = {}

local _sprite_update_hook = function (self, ...)
    local obj = SMODS.SpriteParticles[self.sprite_particle_key]
    Sprite.update(self, ...)
    obj:update(self, self.particle_parent)
end

SMODS.SpriteParticles = {}
SMODS.SpriteParticle = SMODS.GameObject:extend {
    obj_table = SMODS.SpriteParticles,
    obj_buffer = {},
    set = 'SpriteParticle',
    get_obj = function(self, key) return SMODS.SpriteParticles[key] end,
    inject = function(self) end,
    prefix_config = {
        shader = false,
    },
    shader = nil,
    sound = nil, -- sound code, table<key=key, per=per, vol=vol>, or func(self, sprite, args)
    life_time = nil,
    should_remove = function (self, sprite, card)
        if not self.life_time then return true end
        local speed = sprite.game_speed_dependent and G.SETTINGS.GAMESPEED or 1
        if G.TIMERS.REAL - sprite.spawn_time > self.life_time / speed  then
            return true
        end
        return false
    end,
    spawn = function (self, args)
        args = args or {}
        local atlas = SMODS.get_atlas(self.atlas)
        local card = args.card
        local w = args.w or card and (card.VT.w * (atlas.px / 71)) or G.CARD_W * (atlas.px / 71)
        local h = args.h or card and (card.VT.h * (atlas.py / 95)) or G.CARD_H * (atlas.py / 95)
        local offset = {
            x = (args.centered and (card and card.VT.w/2.0 - w/2 or -w/2) or 0),
            y = (args.centered and (card and card.VT.h/2.0 - h/2 or -h/2) or 0)
        }
        local x = (card and card.VT.x or args.x or 0) + offset.x
        local y = (card and card.VT.y or args.y or 0) + offset.y
        local sprite = SMODS.create_sprite(x, y, w, h, self.atlas, self.pos)
        sprite.sprite_particle_key = self.key
        sprite.custom_draw = true
        sprite.update = _sprite_update_hook
        sprite.spawn_time = G.TIMERS.REAL
        sprite.game_speed_dependent = args.game_speed_dependent
        if card then
            sprite.particle_parent = card
            card.sprite_particles = card.sprite_particles or {}
            table.insert(card.sprite_particles, sprite)
            card.children[sprite] = sprite
            sprite.states.hover = card.states.hover
            sprite.states.click = card.states.click
            sprite.states.collide.can = false
            sprite:set_role({major = card, role_type = 'Minor', draw_major = card, offset = offset, xy_bond = "Strong"})
        else
            table.insert(SMODS.SPRITE_PARTICLES, sprite)
        end

        if self.sound then
            if type(self.sound) == "string" then
                play_sound(self.sound, 1.0, 1.0)
            elseif type(self.sound) == "table" then
                play_sound(self.sound.key, self.sound.per or 1.0, self.sound.vol or 1.0)
            elseif type(self.sound) == "function" then
                self:sound(sprite, args)
            end
        end
        return sprite
    end,
    remove_sprite = function (self, sprite, card)
        if card then
            card.children[sprite] = nil
            table.remove(card.sprite_particles, SMODS.get_index(card.sprite_particles, sprite))
        else
            table.remove(SMODS.SPRITE_PARTICLES, SMODS.get_index(SMODS.SPRITE_PARTICLES, sprite))
        end
        sprite:remove()
    end,
    update = function (self, sprite, card) 
        if self:should_remove(sprite, card) then
            self:remove_sprite(sprite, card)
        end
    end,
    draw = function (self, sprite, card)
        if self.shader then
           sprite:draw_shader(self.shader) 
        else 
            sprite:draw()
        end
    end
}

function SMODS.spawn_sprite_particle(particle_key, args)
    if SMODS.SpriteParticle.obj_table[particle_key] then
        return SMODS.SpriteParticle.obj_table[particle_key]:spawn(args)
    else
        sendWarnMessage(string.format("Invalid SpriteParticle key '%s'.", particle_key), "utils")
    end
end