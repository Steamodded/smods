StateSprite = AnimatedSprite:extend()



-- See https://docs.smods.dev/Guides/Animated-Sprites for an Animated/StateSprite guide!



-- Form of sprite_args param [states] is; 
--[[
{ 
    [state_name] = { 
        start_pos = { x/y = [0..n-1 for n columns/rows in sprite atlas] }, 
        (frames = [amount of frames] |OR| end_pos = { [same as start_pos] }),
        frame_order = "linear" |OR| "random" |OR| {1: x, 2: y, .. n: m} |OR| function(sprite), returning frame
        (optional) flipped_h/flipped_v = true,
        (optional) exit_to = [state] |OR [function(state_table, sprite), returning a state],
        (optional) frame_durations = {1: 2, 2:...},     (in Frames according to G.ANIMATION_FPS)
        (optional) frame_duration = 1,                  (in Frames according to G.ANIMATION_FPS)
        (optional) fps = 2,                             (in Frames per second according to G.ANIMATION_FPS, alternative to frame_duration)
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
        frames = 4,                 (end_pos is set to start_pos with .x + frames (wraps correctly))
        frame_duration = 3,         (all frames last 3 times longer (0.3 seconds with default G.ANIMATION_FPS == 10))
        exit_to = "lookey",         (after one iteration, sets state to this value)
    },
    lookey = {
        (start_pos is set to {x = 0, y = 0}, end_pos is set to start_pos => this state is a single frame "animation" at x = 0, y = 0)
        flipped_h = true, (flipped_h/v makes the sprite be drawn flipped (by calling love.graphics.draw() with a width/height multiplied by -1), it does not affect state/frame order.)
        flipped_v = true,
        frame_durations = {[1] = 3} (the first frame lasts three times longer) (ignore that this example has only one frame) (frame indices start at 1 like Lua!!)
    }
}
]]
-- To change state, call StateSprite:set_state(state_name) / Card:set_sprite_state()
function StateSprite:init(X, Y, W, H, new_sprite_atlas, _pos, args)
    AnimatedSprite.init(self, X, Y, W, H, new_sprite_atlas, _pos, args)

    if getmetatable(self) == StateSprite then
        table.insert(G.I.SPRITE, self)
    end
end

function StateSprite:load_sprite_args(args)
	self.sprite_args = args or {}
	if self.atlas.sprite_args then 
		for arg_key, v in pairs(self.atlas.sprite_args) do
			if self.sprite_args[arg_key] == nil then self.sprite_args[arg_key] = v end
		end
	end
    if not self.sprite_args.states or not next(self.sprite_args.states) then
        sendWarnMessage(string.format("StateSprite initialized without states, atlas = '%s'", self.atlas.name), "utils")
    else
        self.states_offset = self.sprite_args.states_offset and {x = self.sprite_args.states_offset.x or 0, y = self.sprite_args.states_offset.y or 0} or {x = 0, y = 0}
        self.default_state = self.sprite_args.default_state or next(self.sprite_args.states)
        self:load_states(self.sprite_args.states)
        self:set_state(self.default_state)
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
        state.start_pos = state.start_pos or {}
        state.start_pos.x = state.start_pos.x or self.sprite_args.start_pos and self.sprite_args.start_pos.x or self.sprite_pos.x or 0
        state.start_pos.y = state.start_pos.y or self.sprite_args.start_pos and self.sprite_args.start_pos.y or self.sprite_pos.y or 0
        state.end_pos = state.end_pos or {}
        self.sprite_args.end_pos = self.sprite_args.end_pos or {}
        state.end_pos.x = state.end_pos.x or self.sprite_args.end_pos.x
        state.end_pos.y = state.end_pos.y or self.sprite_args.end_pos.y
        state.frames = state.frames or (state.end_pos.x and state.end_pos.y) and (state.end_pos.x - state.start_pos.x + (state.end_pos.y - state.start_pos.y) * self.atlas.columns + 1) or self.sprite_args.frames or self.atlas.frames or 1
        state.fps = state.fps or self.sprite_args.fps or self.atlas.fps or G.ANIMATION_FPS
        state.frame_duration = state.frame_duration or self.sprite_args.frame_duration or 1
        state.frame_durations = state.frame_durations or self.sprite_args.frame_durations
        state.key = key
        if self.sprite_args.flipped_h ~= nil and state.flipped_h == nil then
            state.flipped_h = self.sprite_args.flipped_h
        end
        if self.sprite_args.flipped_v ~= nil and state.flipped_v == nil then
            state.flipped_v = self.sprite_args.flipped_v
        end
        state.frame_order = state.frame_order or self.sprite_args.frame_order
        if type(state.frame_order) == "string" then
            local keymap = {
                linear=true,
                random=true
            }
            if not keymap[state.frame_order:lower()] then
                sendWarnMessage(("StateSprite:load_states() state '%s' had an incorrect frame_order argument '%s'."):format(key, state.frame_order))
                state.frame_order = "linear"
            end
        elseif type(state.frame_order) == "table" then
            if not state.frame_order[1] then
                sendWarnMessage(("StateSprite:load_states() state '%s' had an incorrect frame_order argument '%s'."):format(key, state.frame_order))
                state.frame_order = "linear"
            end
        elseif type(state.frame_order) ~= "function" then
            state.frame_order = "linear"
        end
        self.a_states[key] = state
    end
end

-- Helper function used by AnimatedSprite:animate() and StateSprite:animate()
function SMODS.get_new_frame(animated_sprite, frame_order)
    local cur_anim = animated_sprite.current_animation
    if type(frame_order) == "table" then
        cur_anim.frame_index = ((cur_anim.frame_index + 1) % cur_anim.frames)
        if cur_anim.frame_index == 0 then cur_anim.frame_index = cur_anim.frames end
        return frame_order[cur_anim.frame_index] - 1 or cur_anim.current
    elseif frame_order == "random" then
        return math.random(0, cur_anim.frames-1)
    elseif type(frame_order) == "function" then
        return ((frame_order(animated_sprite)) % cur_anim.frames)
    end
    return ((cur_anim.current + 1) % cur_anim.frames)
end

function StateSprite:animate()
    if not self.state then return end
    local frame_finished = (math.floor((G.TIMERS.REAL - self.offset_seconds) / self.current_animation.frame_duration)) > 0
    if frame_finished then
        self.current_animation.current = SMODS.get_new_frame(self, self.state.frame_order)
        self.current_animation.elapsed = self.current_animation.elapsed + 1
        local frame_duration = (self.state.frame_durations or {})[self.current_animation.current+1] or self.state.frame_duration or 1
        self.current_animation.frame_duration = frame_duration / self.state.fps
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
    if self.state.exit_to and self.current_animation.elapsed >= self.current_animation.frames then
        if type(self.state.exit_to) == "function" then
            self:set_state(self.state:exit_to(self) or self.default_state)
        else
            self:set_state(self.state.exit_to)
        end
    end
    if self.float then 
        self.T.r = 0.02*math.sin(2*G.TIMERS.REAL+self.T.x)
        self.offset.y = -(1+0.3*math.sin(0.666*G.TIMERS.REAL+self.T.y))*self.shadow_parrallax.y
        self.offset.x = -(0.7+0.2*math.sin(0.666*G.TIMERS.REAL+self.T.x))*self.shadow_parrallax.x
    end
end

function StateSprite:set_sprite_pos(sprite_pos)
    if not self.state then return end
    self.animation = {
        x = sprite_pos and sprite_pos.x or 0,
        y = sprite_pos and sprite_pos.y or 0,
        frames = self.state.frames, current = 0,
        w = self.scale.x, h = self.scale.y
    }

    local frame_duration = self.state and ((self.state.frame_durations or {})[1] or self.state.frame_duration)
    self.current_animation = {
        current = 0,
        frames = self.animation.frames,
        w = self.animation.w,
        h = self.animation.h,
        elapsed = 0,
        frame_index = 0,
        frame_duration = frame_duration / self.state.fps
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
    love.graphics.scale(1/(self.scale.x/self.VT.w), 1/(self.scale.y/self.VT.h))
    love.graphics.setColor(G.C.WHITE)
    love.graphics.draw(
        self.atlas.image,
        self.sprite,
        (self.state.flipped_h and self.atlas.px or 0), (self.state.flipped_v and self.atlas.py or 0),
        0,
        self.VT.w/(self.T.w) * (self.state.flipped_h and -1 or 1),
        self.VT.h/(self.T.h) * (self.state.flipped_v and -1 or 1)
    )
    love.graphics.pop()
end

function StateSprite:get_pos_pixel()
    self.RETS.get_pos_pixel = self.RETS.get_pos_pixel or {}
    self.RETS.get_pos_pixel[1] = self.state and ((self.state.start_pos.x + self.current_animation.current) % self.atlas.columns) or 0
    self.RETS.get_pos_pixel[2] = self.state and (self.state.start_pos.y + math.floor(self.current_animation.current / self.atlas.columns)) or 0
    self.RETS.get_pos_pixel[3] = self.animation.w
    self.RETS.get_pos_pixel[4] = self.animation.h
    return self.RETS.get_pos_pixel
end


function Card:set_sprite_state(new_state)
    if self.children.center:is(StateSprite) then
        return self.children.center:set_state(new_state)
    else
        sendWarnMessage("Card:card_set_sprite_state() called on card with no StateSprite as .children.center", "utils")
    end
end
