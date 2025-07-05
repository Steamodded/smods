SMODS.DrawSteps = {}
SMODS.DrawStep = SMODS.GameObject:extend {
    obj_table = SMODS.DrawSteps,
    obj_buffer = {},
    required_params = {
        'key',
        'order',
        'func',
    },
    layers = {
        card = true,
        both = true,
    },
    -- func = function(card, layer) end,
    set = "Draw Step",
    register = function(self)
        if self.registered then
            sendWarnMessage(('Detected duplicate register call on object %s'):format(self.key), self.set)
            return
        end
        SMODS.DrawStep.super.register(self)
    end,
    inject = function() end,
    post_inject_class = function(self)
        table.sort(self.obj_buffer, function(_self, _other) return self.obj_table[_self].order < self.obj_table[_other].order end)
    end,
    conditions = {},
    check_individual_condition = function(self, card, layer, k, v)
        if k == 'vortex' then return not not card.vortex == v end
        if k == 'facing' then return card.sprite_facing == v end
        if k == 'front_hidden' then return not not card.front_hidden == v end
        return true
    end,
    check_conditions = function(self, card, layer)
        if not self.layers[layer] then return end
        for k,v in pairs(self.conditions) do
            if not self:check_individual_condition(card, layer, k, v) then return end
        end
        return true
    end
}

SMODS.DrawStep {
    key = 'shadow',
    order = -1000,
    layers = { shadow = true, both = true },
    func = function(self)
        self.ARGS.send_to_shader = self.ARGS.send_to_shader or {}
        self.ARGS.send_to_shader[1] = math.min(self.VT.r*3, 1) + math.sin(G.TIMERS.REAL/28) + 1 + (self.juice and self.juice.r*20 or 0) + self.tilt_var.amt
        self.ARGS.send_to_shader[2] = G.TIMERS.REAL

        for k, v in pairs(self.children) do
            v.VT.scale = self.VT.scale
        end
    
        G.shared_shadow = self.sprite_facing == 'front' and self.children.center or self.children.back
    
        --Draw the shadow
        if not self.no_shadow and G.SETTINGS.GRAPHICS.shadows == 'On' and((self.ability.effect ~= 'Glass Card' and not self.greyed and self:should_draw_shadow() ) and ((self.area and self.area ~= G.discard and self.area.config.type ~= 'deck') or not self.area or self.states.drag.is)) then
            self.shadow_height = 0*(0.08 + 0.4*math.sqrt(self.velocity.x^2)) + ((((self.highlighted and self.area == G.play) or self.states.drag.is) and 0.35) or (self.area and self.area.config.type == 'title_2') and 0.04 or 0.1)
            G.shared_shadow:draw_shader('dissolve', self.shadow_height)
        end
    end,
}

SMODS.DrawStep {
    key = 'focused_ui_1',
    order = -100,
    func = function(self)
        if self.area ~= G.hand then 
            if self.children.focused_ui then self.children.focused_ui:draw() end
        end
    end,
}

SMODS.DrawStep {
    key = 'tilt',
    order = -50,
    func = function(self)
        -- for all hover/tilting:
        self.tilt_var = self.tilt_var or {mx = 0, my = 0, dx = self.tilt_var.dx or 0, dy = self.tilt_var.dy or 0, amt = 0}
        local tilt_factor = 0.3
        if self.states.focus.is then
            self.tilt_var.mx, self.tilt_var.my = G.CONTROLLER.cursor_position.x + self.tilt_var.dx*self.T.w*G.TILESCALE*G.TILESIZE, G.CONTROLLER.cursor_position.y + self.tilt_var.dy*self.T.h*G.TILESCALE*G.TILESIZE
            self.tilt_var.amt = math.abs(self.hover_offset.y + self.hover_offset.x - 1 + self.tilt_var.dx + self.tilt_var.dy - 1)*tilt_factor
        elseif self.states.hover.is then
            self.tilt_var.mx, self.tilt_var.my = G.CONTROLLER.cursor_position.x, G.CONTROLLER.cursor_position.y
            self.tilt_var.amt = math.abs(self.hover_offset.y + self.hover_offset.x - 1)*tilt_factor
        elseif self.ambient_tilt then
            local tilt_angle = G.TIMERS.REAL*(1.56 + (self.ID/1.14212)%1) + self.ID/1.35122
            self.tilt_var.mx = ((0.5 + 0.5*self.ambient_tilt*math.cos(tilt_angle))*self.VT.w+self.VT.x+G.ROOM.T.x)*G.TILESIZE*G.TILESCALE
            self.tilt_var.my = ((0.5 + 0.5*self.ambient_tilt*math.sin(tilt_angle))*self.VT.h+self.VT.y+G.ROOM.T.y)*G.TILESIZE*G.TILESCALE
            self.tilt_var.amt = self.ambient_tilt*(0.5+math.cos(tilt_angle))*tilt_factor
        end
    end,
}

SMODS.DrawStep {
    key = 'particles',
    order = -40,
    func = function(self)
        --Any particles
        if self.children.particles then self.children.particles:draw() end
    end,
}

SMODS.DrawStep {
    key = 'tags_buttons',
    order = -30,
    func = function(self)
        --Draw any tags/buttons
        if self.children.price then self.children.price:draw() end
        if self.children.buy_button then
            if self.highlighted then
                self.children.buy_button.states.visible = true
                self.children.buy_button:draw()
                if self.children.buy_and_use_button then 
                    self.children.buy_and_use_button:draw()
                end
            else
                self.children.buy_button.states.visible = false
            end
        end
        if self.children.use_button and self.highlighted then self.children.use_button:draw() end
    end,
} 

SMODS.DrawStep {
    key = 'vortex',
    order = -20,
    func = function(self)
        if self.facing == 'back' then 
            self.children.back:draw_shader('vortex')
        else
            self.children.center:draw_shader('vortex')
            if self.children.front then 
                self.children.front:draw_shader('vortex')
            end
        end

        love.graphics.setShader()
    end,
    conditions = { vortex = true },
}

SMODS.DrawStep {
    key = 'center',
    order = -10,
    func = function(self, layer)
        --Draw the main part of the card
        if (self.edition and self.edition.negative and not self.delay_edition) or (self.ability.name == 'Antimatter' and (self.config.center.discovered or self.bypass_discovery_center)) then
            self.children.center:draw_shader('negative', nil, self.ARGS.send_to_shader)
        elseif not self:should_draw_base_shader() then
            -- Don't render base dissolve shader.
        elseif not self.greyed then
            self.children.center:draw_shader('dissolve')
        end

         --If the card is not yet discovered
         if not self.config.center.discovered and (self.ability.consumeable or self.config.center.unlocked) and not self.config.center.demo and not self.bypass_discovery_center then
            local shared_sprite = (self.ability.set == 'Edition' or self.ability.set == 'Joker') and G.shared_undiscovered_joker or G.shared_undiscovered_tarot
            local scale_mod = -0.05 + 0.05*math.sin(1.8*G.TIMERS.REAL)
            local rotate_mod = 0.03*math.sin(1.219*G.TIMERS.REAL)

            shared_sprite.role.draw_major = self
            if (self.config.center.undiscovered and not self.config.center.undiscovered.no_overlay) or not( SMODS.UndiscoveredSprites[self.ability.set] and SMODS.UndiscoveredSprites[self.ability.set].no_overlay) then 
                shared_sprite:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod, rotate_mod)
            else
                if SMODS.UndiscoveredSprites[self.ability.set] and SMODS.UndiscoveredSprites[self.ability.set].overlay_sprite then
                    SMODS.UndiscoveredSprites[self.ability.set].overlay_sprite:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod, rotate_mod)
                end
            end
        end

        if self.ability.name == 'Invisible Joker' and (self.config.center.discovered or self.bypass_discovery_center) then
            if self:should_draw_base_shader() then
                self.children.center:draw_shader('voucher', nil, self.ARGS.send_to_shader)
            end
        end

        local center = self.config.center
        if center.draw and type(center.draw) == 'function' then
            center:draw(self, layer)
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.DrawStep {
    key = 'front',
    order = 0,
    func = function(self, layer)
        --Draw the main part of the card
        if (self.edition and self.edition.negative and not self.delay_edition) or (self.ability.name == 'Antimatter' and (self.config.center.discovered or self.bypass_discovery_center)) then
            if self.children.front and (self.ability.delayed or (self.ability.effect ~= 'Stone Card' and not self.config.center.replace_base_card)) then
                self.children.front:draw_shader('negative', nil, self.ARGS.send_to_shader)
            end
        elseif not self:should_draw_base_shader() then
            -- Don't render base dissolve shader.
        elseif not self.greyed then
            if self.children.front and (self.ability.delayed or (self.ability.effect ~= 'Stone Card' and not self.config.center.replace_base_card)) then
                self.children.front:draw_shader('dissolve')
            end
        end

        local center = self.config.center
        if center.set == 'Default' or center.set == 'Enhanced' and not center.replace_base_card then
            if not center.no_suit then
                local suit = SMODS.Suits[self.base.suit] or {}
                if suit.draw and type(suit.draw) == 'function' then
                    suit:draw(self, layer)
                end
            end
            if not center.no_rank then
                local rank = SMODS.Ranks[self.base.value] or {}
                if rank.draw and type(rank.draw) == 'function' then
                    rank:draw(self, layer)
                end
            end
        end
    end,
    conditions = { vortex = false, facing = 'front', front_hidden = false },
}
SMODS.DrawStep {
    key = 'card_type_shader',
    order = 10,
    func = function(self)
        if (self.ability.set == 'Voucher' or self.config.center.demo) and (self.ability.name ~= 'Antimatter' or not (self.config.center.discovered or self.bypass_discovery_center)) then
            if self:should_draw_base_shader() then
                self.children.center:draw_shader('voucher', nil, self.ARGS.send_to_shader)
            end
        end
        if (self.ability.set == 'Booster' or self.ability.set == 'Spectral') and self:should_draw_base_shader() then
            self.children.center:draw_shader('booster', nil, self.ARGS.send_to_shader)
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.DrawStep {
    key = 'edition',
    order = 20,
    func = function(self, layer)
        if self.edition and not self.delay_edition then
            for k, v in pairs(G.P_CENTER_POOLS.Edition) do
                if self.edition[v.key:sub(3)] and v.shader then
                    if type(v.draw) == 'function' then
                        v:draw(self, layer)
                    else
                        self.children.center:draw_shader(v.shader, nil, self.ARGS.send_to_shader)
                        if self.children.front and self.ability.effect ~= 'Stone Card' and not self.config.center.replace_base_card then
                            self.children.front:draw_shader(v.shader, nil, self.ARGS.send_to_shader)
                        end
                    end
                end
            end
        end
        if (self.edition and self.edition.negative) or (self.ability.name == 'Antimatter' and (self.config.center.discovered or self.bypass_discovery_center)) then
            self.children.center:draw_shader('negative_shine', nil, self.ARGS.send_to_shader)
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.DrawStep {
    key = 'seal',
    order = 30,
    func = function(self, layer)
        local seal = G.P_SEALS[self.seal] or {}
        if type(seal.draw) == 'function' then
            seal:draw(self, layer)
        elseif self.seal then
            G.shared_seals[self.seal].role.draw_major = self
            G.shared_seals[self.seal]:draw_shader('dissolve', nil, nil, nil, self.children.center)
            if self.seal == 'Gold' then G.shared_seals[self.seal]:draw_shader('voucher', nil, self.ARGS.send_to_shader, nil, self.children.center) end
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.DrawStep {
    key = 'stickers',
    order = 40,
    func = function(self, layer)
        if self.sticker and G.shared_stickers[self.sticker] then
            G.shared_stickers[self.sticker].role.draw_major = self
            G.shared_stickers[self.sticker]:draw_shader('dissolve', nil, nil, nil, self.children.center)
            G.shared_stickers[self.sticker]:draw_shader('voucher', nil, self.ARGS.send_to_shader, nil, self.children.center)
        elseif (self.sticker_run and G.shared_stickers[self.sticker_run]) and G.SETTINGS.run_stake_stickers then
            G.shared_stickers[self.sticker_run].role.draw_major = self
            G.shared_stickers[self.sticker_run]:draw_shader('dissolve', nil, nil, nil, self.children.center)
            G.shared_stickers[self.sticker_run]:draw_shader('voucher', nil, self.ARGS.send_to_shader, nil, self.children.center)
        end

        for k, v in pairs(SMODS.Stickers) do
            if self.ability[v.key] then
                if v and v.draw and type(v.draw) == 'function' then
                    v:draw(self, layer)
                else
                    G.shared_stickers[v.key].role.draw_major = self
                    G.shared_stickers[v.key]:draw_shader('dissolve', nil, nil, nil, self.children.center)
                    G.shared_stickers[v.key]:draw_shader('voucher', nil, self.ARGS.send_to_shader, nil, self.children.center)
                end
            end
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.DrawStep {
    key = 'soul',
    order = 50,
    func = function(self)
        if self.ability.name == 'The Soul' and (self.config.center.discovered or self.bypass_discovery_center) then
            local scale_mod = 0.05 + 0.05*math.sin(1.8*G.TIMERS.REAL) + 0.07*math.sin((G.TIMERS.REAL - math.floor(G.TIMERS.REAL))*math.pi*14)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^3
            local rotate_mod = 0.1*math.sin(1.219*G.TIMERS.REAL) + 0.07*math.sin((G.TIMERS.REAL)*math.pi*5)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^2

            G.shared_soul.role.draw_major = self
            G.shared_soul:draw_shader('dissolve',0, nil, nil, self.children.center,scale_mod, rotate_mod,nil, 0.1 + 0.03*math.sin(1.8*G.TIMERS.REAL),nil, 0.6)
            G.shared_soul:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod, rotate_mod)
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.DrawStep {
    key = 'floating_sprite',
    order = 60,
    func = function(self)
        if self.config.center.soul_pos and (self.config.center.discovered or self.bypass_discovery_center) then
            local scale_mod = 0.07 + 0.02*math.sin(1.8*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL - math.floor(G.TIMERS.REAL))*math.pi*14)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^3
            local rotate_mod = 0.05*math.sin(1.219*G.TIMERS.REAL) + 0.00*math.sin((G.TIMERS.REAL)*math.pi*5)*(1 - (G.TIMERS.REAL - math.floor(G.TIMERS.REAL)))^2

            if type(self.config.center.soul_pos.draw) == 'function' then
                self.config.center.soul_pos.draw(self, scale_mod, rotate_mod)
            elseif self.children.floating_sprite then
                if self.ability.name == 'Hologram' then
                    self.hover_tilt = self.hover_tilt*1.5
                    self.children.floating_sprite:draw_shader('hologram', nil, self.ARGS.send_to_shader, nil, self.children.center, 2*scale_mod, 2*rotate_mod)
                    self.hover_tilt = self.hover_tilt/1.5
                else
                    self.children.floating_sprite:draw_shader('dissolve',0, nil, nil, self.children.center,scale_mod, rotate_mod,nil, 0.1 + 0.03*math.sin(1.8*G.TIMERS.REAL),nil, 0.6)
                    self.children.floating_sprite:draw_shader('dissolve', nil, nil, nil, self.children.center, scale_mod, rotate_mod)
                end
            end
            if self.edition then 
                local edition = G.P_CENTERS[self.edition.key]
                if edition.apply_to_float and self.children.floating_sprite then
                    self.children.floating_sprite:draw_shader(edition.shader, nil, nil, nil, self.children.center, scale_mod, rotate_mod)                    
                end
            end
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.DrawStep {
    key = 'debuff',
    order = 70,
    func = function(self)
        if self.debuff then
            self.children.center:draw_shader('debuff', nil, self.ARGS.send_to_shader)
            if self.children.front and (self.ability.delayed or (self.ability.effect ~= 'Stone Card' and not self.config.center.replace_base_card)) then
                self.children.front:draw_shader('debuff', nil, self.ARGS.send_to_shader)
            end
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.DrawStep {
    key = 'greyed',
    order = 80,
    func = function(self)
        if self.greyed then
            self.children.center:draw_shader('played', nil, self.ARGS.send_to_shader)
            if self.children.front and (self.ability.delayed or (self.ability.effect ~= 'Stone Card' and not self.config.center.replace_base_card)) then
                self.children.front:draw_shader('played', nil, self.ARGS.send_to_shader)
            end
        end
    end,
    conditions = { vortex = false, facing = 'front' },
}

SMODS.DrawStep {
    key = 'back',
    order = 0,
    func = function(self)
        local overlay = G.C.WHITE
        if self.area and self.area.config.type == 'deck' and self.rank > 3 then
            self.back_overlay = self.back_overlay or {}
            self.back_overlay[1] = 0.5 + ((#self.area.cards - self.rank)%7)/50
            self.back_overlay[2] = 0.5 + ((#self.area.cards - self.rank)%7)/50
            self.back_overlay[3] = 0.5 + ((#self.area.cards - self.rank)%7)/50
            self.back_overlay[4] = 1
            overlay = self.back_overlay
        end

        if self.area and self.area.config.type == 'deck' then
            self.children.back:draw(overlay)
        else
            self.children.back:draw_shader('dissolve')
        end
    end,
    conditions = { vortex = false, facing = 'back' },
} 

SMODS.DrawStep {
    key = 'back_sticker',
    order = 10,
    func = function(self)
        if self.sticker and G.shared_stickers[self.sticker] then
            G.shared_stickers[self.sticker].role.draw_major = self
            local sticker_offset = self.sticker_offset or {}
            G.shared_stickers[self.sticker]:draw_shader('dissolve', nil, nil, true, self.children.center, nil, self.sticker_rotation, sticker_offset.x, sticker_offset.y)
            local stake = G.P_STAKES['stake_'..string.lower(self.sticker)] or {}
            if stake.shiny then G.shared_stickers[self.sticker]:draw_shader('voucher', nil, self.ARGS.send_to_shader, true, self.children.center, nil, self.sticker_rotation, sticker_offset.x, sticker_offset.y) end
        end
    end,
    conditions = { vortex = false, facing = 'back' },
}

-- All keys in this table will not be automatically drawn with a default `draw()` call in the "others" DrawStep.
SMODS.draw_ignore_keys = {
    focused_ui = true, front = true, back = true, soul_parts = true, center = true, floating_sprite = true, shadow = true, use_button = true, buy_button = true, buy_and_use_button = true, debuff = true, price = true, particles = true, h_popup = true
}
SMODS.DrawStep {
    key = 'others',
    order = 90,
    func = function(self)
        for k, v in pairs(self.children) do
            if not v.custom_draw and not SMODS.draw_ignore_keys[k] then v:draw() end
        end
    end,
}

SMODS.DrawStep {
    key = 'focused_ui_2',
    order = 100,
    func = function(self)
        if self.area == G.hand then 
            if self.children.focused_ui then self.children.focused_ui:draw() end
        end
    end,
}

SMODS.DrawStep {
    key = 'drawhash_boundingrect',
    order = 1000,
    func = function(self)
        add_to_drawhash(self)
        self:draw_boundingrect()
    end,
}

function Card:draw(layer)
    layer = layer or 'both'
    self.hover_tilt = 1
    if not self.states.visible then return end
    for _, k in ipairs(SMODS.DrawStep.obj_buffer) do
        if SMODS.DrawSteps[k]:check_conditions(self, layer) then SMODS.DrawSteps[k].func(self, layer) end
    end
end
