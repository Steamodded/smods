local stackfmt = require("SMODS.crash_handler.stack_format")
local errgen = require("SMODS.crash_handler.errorgen")

local has_jit_p, jit_p = pcall(require, "jit.p")
local has_jit_profile, jit_profile = pcall(require, "jit.profile")

--- @class SMODS.CrashHandler.Stack: debuginfo
--- @field locals [string, any][]

--- @class SMODS.CrashHandler
--- @field trace? SMODS.CrashHandler.Stack[]
--- @field traceStr? string
local crashHandler = {
    scrollOffset = 0,
    endHeight = 0,
    pos = 70,
    arrowSize = 20,
    background = {0x37/255, 0x42/255, 0x44/255},
    initialized = false,
    errorStr = '',
    sanitizedStr = '',
}

function crashHandler:doRestart()
    if SMODS and SMODS.restart_game then
        SMODS.restart_game()
    else
        local test, msg = pcall(function()
            require"lovely".reload_patches()
        end)
        if not test then sendErrorMessage("Failed to reload patches... " .. tostring(msg), "StackTrace") end
        love.event.quit("restart")
    end
end

function crashHandler:scrollDown(amt)
    if amt == nil then
        amt = 18
    end
    self.scrollOffset = self.scrollOffset + amt
    if self.scrollOffset > self.endHeight then
        self.scrollOffset = self.endHeight
    end
end

function crashHandler:scrollUp(amt)
    if amt == nil then
        amt = 18
    end
    self.scrollOffset = self.scrollOffset - amt
    if self.scrollOffset < 0 then
        self.scrollOffset = 0
    end
end

function crashHandler:copyToClipboard()
    if not love.system then return end
    love.system.setClipboardText(self.sanitizedStr)
end

function crashHandler:draw()
    if not love.graphics.isActive() then
        return
    end
    love.graphics.clear(self.background)

    love.graphics.printf(self.sanitizedStr, self.pos, self.pos - self.scrollOffset, love.graphics.getWidth() - self.pos * 2)
    if self.scrollOffset ~= self.endHeight then
        love.graphics.polygon("fill", love.graphics.getWidth() - (self.pos / 2),
            love.graphics.getHeight() - self.arrowSize, love.graphics.getWidth() - (self.pos / 2) + self.arrowSize,
            love.graphics.getHeight() - (self.arrowSize * 2), love.graphics.getWidth() - (self.pos / 2) - self.arrowSize,
            love.graphics.getHeight() - (self.arrowSize * 2))
    end
    if self.scrollOffset ~= 0 then
        love.graphics.polygon("fill", love.graphics.getWidth() - (self.pos / 2), self.arrowSize,
            love.graphics.getWidth() - (self.pos / 2) + self.arrowSize, self.arrowSize * 2,
            love.graphics.getWidth() - (self.pos / 2) - self.arrowSize, self.arrowSize * 2)
    end
    love.graphics.present()
end

function crashHandler:loop()
    if not self.initialized then
        self:postInit()
        self.initialized = true
    end

    love.event.pump()

    for e, a, b, c in love.event.poll() do
        if e == "quit" then
            return a or 0
        elseif e == "keypressed" and a == "escape" then
            return 1
        elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
            self:copyToClipboard()
        elseif e == "keypressed" and a == "r" then
            self:doRestart()
        elseif e == "keypressed" and a == "down" then
            self:scrollDown()
        elseif e == "keypressed" and a == "up" then
            self:scrollUp()
        elseif e == "keypressed" and a == "pagedown" then
            self:scrollDown(love.graphics.getHeight())
        elseif e == "keypressed" and a == "pageup" then
            self:scrollUp(love.graphics.getHeight())
        elseif e == "keypressed" and a == "home" then
            self.scrollOffset = 0
        elseif e == "keypressed" and a == "end" then
            self.scrollOffset = self.endHeight
        elseif e == "wheelmoved" then
            self:scrollUp(b * 20)
        elseif e == "gamepadpressed" and b == "dpdown" then
            self:scrollDown()
        elseif e == "gamepadpressed" and b == "dpup" then
            self:scrollUp()
        elseif e == "gamepadpressed" and b == "a" then
            self:doRestart()
        elseif e == "gamepadpressed" and b == "x" then
            self:copyToClipboard()
        elseif e == "gamepadpressed" and (b == "b" or b == "back" or b == "start") then
            return 1
        elseif e == "touchpressed" then
            local name = love.window.getTitle()
            if #name == 0 or name == "Untitled" then
                name = "Game"
            end
            local buttons = {"OK", "Cancel", "Restart"}
            if love.system then
                buttons[4] = "Copy to clipboard"
            end
            local pressed = love.window.showMessageBox("Quit " .. name .. "?", "", buttons)
            if pressed == 1 then
                return 1
            elseif pressed == 3 then
                self:doRestart()
            elseif pressed == 4 then
                self:copyToClipboard()
            end
        end
    end

    self:draw()

    if love.timer then
        love.timer.sleep(0.03)
    end
end

function crashHandler:getSanitizedMessage()
    local text = love.graphics.newText(love.graphics.getFont())
    local parts = {}

    local i i = 1
    while i do
        local ni = self.errorStr:find('\n', i, true)
        local sub = self.errorStr:sub(i, ni)
        local ok = pcall(text.set, text, sub)
        table.insert(parts, ok and sub or '[invalid line]\n')

        i = ni and ni+1
    end

    text:release()
    return table.concat(parts)
end

function crashHandler:calcEndHeight()
    local font = love.graphics.getFont()
    local rw, lines = font:getWrap(self.sanitizedStr, love.graphics.getWidth() - self.pos * 2)
    local lineHeight = font:getHeight()
    local atBottom = self.scrollOffset == self.endHeight and self.scrollOffset ~= 0
    self.endHeight = #lines * lineHeight - love.graphics.getHeight() + self.pos * 2
    if (self.endHeight < 0) then
        self.endHeight = 0
    end
    if self.scrollOffset > self.endHeight or atBottom then
        self.scrollOffset = self.endHeight
    end
end

function crashHandler:updateText()
    self.sanitizedStr = self:getSanitizedMessage()
    self:calcEndHeight()
end

function crashHandler:postInit()
    debug.sethook()
    if has_jit_p then jit_p.stop() end
    if has_jit_profile then jit_profile.stop() end
    collectgarbage("restart")

    if self.trace then self.traceStr = stackfmt:format(self.trace) end
    self.traceStr = self.traceStr or ''

    self.errorStr = tostring(self.errorStr)
    self.errorStr = errgen:generateErrorMessage(self.errorStr, self.traceStr)
    self:updateText()

    self:initLog()
    self:initResetStates()
    self:initKillThreads()
end

function crashHandler:initLog()
    sendErrorMessage = sendErrorMessage or print
    sendInfoMessage = sendInfoMessage or print
    sendErrorMessage(self.errorStr, 'StackTrace')
end

function crashHandler:initKillThreads()
    if not G then return end

    -- Kill threads (makes restarting possible)
    if G.SOUND_MANAGER and G.SOUND_MANAGER.channel then
        G.SOUND_MANAGER.channel:push({
            type = 'kill'
        })
    end
    if G.SAVE_MANAGER and G.SAVE_MANAGER.channel then
        G.SAVE_MANAGER.channel:push({
            type = 'kill'
        })
    end
    if G.HTTP_MANAGER and G.HTTP_MANAGER.channel then
        G.HTTP_MANAGER.channel:push({
            type = 'kill'
        })
    end
end

function crashHandler:initResetStates()
    if not love.window or not love.graphics or not love.event then return end

    if not love.graphics.isCreated() or not love.window.isOpen() then --- @diagnostic disable-line
        local success, status = pcall(love.window.setMode, 800, 600)
        if not success or not status then return end
    end

    -- Reset state.
    if love.mouse then
        love.mouse.setVisible(true)
        love.mouse.setGrabbed(false)
        love.mouse.setRelativeMode(false)
        if love.mouse.isCursorSupported() then
            love.mouse.setCursor()
        end
    end
    if love.joystick then
        -- Stop all joystick vibrations.
        for i, v in ipairs(love.joystick.getJoysticks()) do
            v:setVibration()
        end
    end
    if love.audio then
        love.audio.stop()
    end

    if G and G.C and G.C.BLACK then self.background = G.C.BLACK end

    for i=1, love.graphics.getStackDepth() do love.graphics.pop() end
    love.graphics.reset()
    love.graphics.clear(self.background)
    love.graphics.origin()

    love.graphics.setNewFont("resources/fonts/m6x11plus.ttf", 20)
end

--#region stack capturing

-- avoid locals as much as possible so that incase if stack overflow happens theres still room for tracer to capture the stack

local s = {}
--- @protected
function crashHandler.lcapture()
    --- @type SMODS.CrashHandler.Stack[]
    s.stacks = {}

    s.depth = 5
    while true do
        --- @type any
        s.stack = s.thread
            and debug.getinfo(s.thread, s.depth, "nSlf")
            or debug.getinfo(s.depth, "nSlf")
        if not s.stack then break end

        s.stack.locals = {}
        s.localindex = 1
        while true do
            if s.thread then
                s.lk, s.lv = debug.getlocal(s.thread, s.depth, s.localindex)
            else
                s.lk, s.lv = debug.getlocal(s.depth, s.localindex)
            end
            if not s.lk then break end

            s.stack.locals[s.localindex] = { s.lk, s.lv }
            s.localindex = s.localindex + 1
        end

        s.stacks[#s.stacks+1] = s.stack
        s.depth = s.depth + 1
    end

    return s.stacks
end

function crashHandler.capture()
    return crashHandler.lcapture()
end

--#endregion

function crashHandler:loopWrap()
    return crashHandler:loop()
end

local advok
function crashHandler.handler(err)
    crashHandler.errorStr = err

    -- stop all profiles & hooks
    debug.sethook()
    if has_jit_p then jit_p.stop() end
    if has_jit_profile then jit_profile.stop() end

    -- capture trace
    advok, crashHandler.trace = pcall(crashHandler.capture)
    if not advok then
        crashHandler.trace = nil
        crashHandler.traceStr = debug.traceback()
    end

    return crashHandler.loopWrap
end

love.errorhandler = crashHandler.handler

function injectStackTrace() end
function loadStackTracePlus() end

return crashHandler