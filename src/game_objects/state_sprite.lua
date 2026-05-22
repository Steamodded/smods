StateSprite = AnimatedSprite:extend()

-- Form of param [states] is; 
--[[
{ 
    [state_name] = { 
        start_pos = { x/y = [0..n-1 for n columns/rows in sprite atlas] }, 
        (frames = [amount of frames] |OR| end_pos = { [same as start_pos] }),
        frame_order = "linear" |OR| "random" |OR| {1: x, 2: y, .. n: m}
        (optional) flipped_h/flipped_v = true,
        (optional) exit_to = [state],
        (optional) frame_durations = {1: 2, 2:...},     (in Frames according to G.ANIMATION_FPS)
        (optional) default_frame_duration = 1,          (in Frames according to G.ANIMATION_FPS)
    }, 
    ...
}
]]
-- Example;
--[[
{
    sleepy = {
        start_pos = {x = 0, y = 0},
        end_pos = {x = 3}           (y is set to start_pos.y)
    },
    wakey = {
        start_pos = {x = 4},        (y is set to 0)
        frames = 4,                 (end_pos is set to start_pos with .x + frames)
        default_frame_duration = 3,
        exit_to = "lookey",         (after one iteration, sets state to this value)
    },
    lookey = {
        flipped_h = true, (start_pos is set to {x = 0, y = 0}, end_pos is set to start_pos => this state is a single frame "animation" at x = 0, y = 0, and flipped horizontally and vertically)
        flipped_v = true,
        frame_durations = {[1] = 3} (the first frame lasts three times longer)
    }
}
]]
-- To change state, call StateSprite:set_state(state_name)
function StateSprite:init(X, Y, W, H, new_sprite_atlas, _pos, args)
    AnimatedSprite.init(self, X, Y, W, H, new_sprite_atlas, {x=0, y=0})
    args = args or {}

    if not args.states or not next(args.states) then
        sendWarnMessage(string.format("StateSprite initialized without states, atlas = '%s'", new_sprite_atlas.name), "utils")
    else
        self.sprite_args = args
        self.states_offset = args.states_offset and {x = args.states_offset.x or 0, y = args.states_offset.y or 0} or {x = 0, y = 0}
        self:load_states(args.states)
        self:set_state(args.default_state or next(args.states))
    end

    self.flipped_h = false
    self.flipped_v = false

    if getmetatable(self) == StateSprite then
        table.insert(G.I.SPRITE, self)
    end
end

function StateSprite:set_state(state)
    local a_state = self.a_states[state]
    if not a_state then
        sendWarnMessage(string.format("StateSprite:set_state() called with invalid state '%s'", state), "utils")
    elseif self.state ~= a_state then
        self.state = a_state
        self:set_sprite_pos({x = self.state.start_pos.x + self.states_offset.x, y = self.state.start_pos.y + self.states_offset.y})
        self.flipped_h = self.state.flipped_h
        self.flipped_v = self.state.flipped_v
        return true
    end
    return false
end

function StateSprite:load_states(states)
    self.a_states = {}
    for key, state in pairs(states) do
        state.start_pos = state.start_pos and {x = state.start_pos.x or 0, y = state.start_pos.y or 0} or {x = 0, y = 0}
        state.frames = state.frames or ((state.end_pos or state.start_pos).x - state.start_pos.x + ((state.end_pos.y or state.start_pos).y - state.start_pos.y) * self.atlas.columns + 1)
        if type(state.frame_order) == "string" then
            local keymap = {
                linear=true,
                random=true
            }
            if not keymap[state.frame_order:lower()] then
                state.frame_order = "linear"
            end
        elseif type(state.frame_order) == "table" then
            if not state.frame_order[1] then
                state.frame_order = "linear"
            end
        else
            state.frame_order = "linear"
        end
        self.a_states[key] = state
    end
end

function StateSprite:animate()
    if not self.state then return end
    if self.state.exit_to and self.current_animation.elapsed >= self.current_animation.frames then
        self:set_state(self.state.exit_to)
    end
    local frame_finished = (math.floor(G.ANIMATION_FPS*(G.TIMERS.REAL - self.offset_seconds) / (self.current_animation.frame_duration or self.state.default_frame_duration or 1))) > 0
    if frame_finished then
        local new_frame
        if type(self.state.frame_order) == "table" then
            self.current_animation.frame_index = (self.current_animation.frame_index + 1) % self.current_animation.frames
            new_frame = self.state.frame_order[self.current_animation.frame_index] or self.current_animation.current
        elseif self.state.frame_order == "random" then
            new_frame = math.random(0, self.current_animation.frames - 1)
        end
        self.current_animation.current = new_frame or ((self.current_animation.current + 1) % self.current_animation.frames)
        self.current_animation.elapsed = self.current_animation.elapsed + 1
        self.current_animation.frame_duration = (self.state.frame_durations or {})[self.current_animation.current] or self.state.default_frame_duration or 1
        local _x = self.animation.w * ((self.states_offset.x + self.state.start_pos.x + self.current_animation.current) % self.atlas.columns)
        local _y = self.animation.h * (self.states_offset.y + self.state.start_pos.y + math.floor(self.current_animation.current / self.atlas.columns))
        self.sprite:setViewport(
            _x,
            _y,
            self.animation.w,
            self.animation.h
        )
        self.offset_seconds = G.TIMERS.REAL
    end
    if self.float then 
        self.T.r = 0.02*math.sin(2*G.TIMERS.REAL+self.T.x)
        self.offset.y = -(1+0.3*math.sin(0.666*G.TIMERS.REAL+self.T.y))*self.shadow_parrallax.y
        self.offset.x = -(0.7+0.2*math.sin(0.666*G.TIMERS.REAL+self.T.x))*self.shadow_parrallax.x
    end
end

function StateSprite:set_sprite_pos(sprite_pos)
    self.animation = {
        x = sprite_pos and sprite_pos.x or 0,
        y = sprite_pos and sprite_pos.y or 0,
        frames = self.state and self.state.frames or 1, current = 0,
        w = self.scale.x, h = self.scale.y
    }

    self.frame_offset = 0 -- Unused

    self.current_animation = {
        current = 0,
        frames = self.animation.frames,
        w = self.animation.w,
        h = self.animation.h,
        elapsed = 0,
        frame_duration = (self.state.frame_durations or {})[0] or self.state.default_frame_duration or 1
    }

    self.image_dims = self.image_dims or {}
    self.image_dims[1], self.image_dims[2] = self.atlas.image:getDimensions()

    self.sprite = love.graphics.newQuad(
        self.animation.w*self.animation.x,
        self.animation.h*self.animation.y,
        self.animation.w,
        self.animation.h,
        self.image_dims[1], self.image_dims[2]
    )
    self.offset_seconds = G.TIMERS.REAL
end

function StateSprite:draw_self()
    if not self.states.visible then return end

    prep_draw(self, 1)
    love.graphics.scale(1/self.scale_mag)
    love.graphics.setColor(G.C.WHITE)
    love.graphics.draw(
        self.atlas.image,
        self.sprite,
        0 ,0,
        0,
        self.VT.w/(self.T.w) * (self.flipped_h and -1 or 1),
        self.VT.h/(self.T.h) * (self.flipped_v and -1 or 1)
    )
    love.graphics.pop()
end


function Card:set_sprite_state(new_state)
    if self.children.center:is(StateSprite) then
        return self.children.center:set_state(new_state)
    else
        sendWarnMessage("Card:card_set_sprite_state() called on card with no StateSprite", "utils")
    end
end