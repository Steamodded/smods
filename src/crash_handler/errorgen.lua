local additionalContext = require("SMODS.crash_handler.additional_context")

--- @class SMODS.CrashHandler.Errgen
--- @field stack? SMODS.CrashHandler.Stack[]
--- @field stackStr? string
--- @field lines string[]
local errorGen = {
    errorStr = '',
    lines = {},
}

--- @protected
function errorGen:put(line)
    table.insert(self.lines, line)
end

--- @protected
--- @param fmt string
function errorGen:putf(fmt, ...)
    table.insert(self.lines, fmt:format(...))
end

--- @protected
function errorGen:getKnownError()
    if false and smods_dupe then
        return '[!] Duplicate installation of Steamodded detected! [!]'
            ..'\n\nPlease remove the duplicate steamodded/smods folder/zip in your mods folder.'
            ..'\n\nPossible location: ' .. smods_dupe
    end
    if self.errorStr:find("Syntax error: game.lua:4: '=' expected near 'Game'") then
        return '[!] Duplicate installation of Steamodded detected! '
            .. 'Please clean your installation: Steam Library > Balatro > Properties > Installed Files > Verify integrity of game files.'
    end
    if self.errorStr:find("Syntax error: game.lua:%d+: duplicate label 'continue'") then
        return '[!] Duplicate installation of Steamodded detected! '
            .. 'Please remove the duplicate steamodded/smods folder in your mods folder.'
    end
end

local pref = 'Syntax error: '

--- @protected
function errorGen:injectPatchAnalysis()
    local text = self.errorStr
    if text:sub(1, #pref) == pref then text = text:sub(#pref+1) end

    local filename, linestr = text:match('^([%w/_.]+):(%d+):') -- get file & the error line
    local startlinestr = text:match("%(to close '%w+' at line (%d+)%)") -- get the starting line
    if not filename then return end

    local filepath = string.format('%s/lovely/dump/%s.json', require"lovely".mod_dir, filename)
    local content = require"nativefs".read(filepath)
    if not content then return end

    local line = tonumber(linestr) or 0
    local startline = tonumber(startlinestr)
    local pad = 2

    local first = true
    local data = require"json".decode(content)
    for i, patchEntry in ipairs(data.entries) do
        for j, patchRegion in ipairs(patchEntry.regions) do
            local match = false
            if startline then
                match = startline-pad <= patchRegion.start_line and patchRegion.end_line <= line+pad
            else
                match = patchRegion.start_line-pad <= line and line <= patchRegion.end_line+pad
            end
            if match then
                if first then
                    self:put""
                    self:put('Related patches:')
                    first = false
                end
                self:putf(' - %d-%d: %s', patchRegion.start_line, patchRegion.end_line, patchEntry.patch_source.file)
                break
            end
        end
    end
end

--- @protected
function errorGen:injectAdditionalError()
    if V and SMODS and SMODS.save_game and V(SMODS.save_game or '0.0.0') ~= V(SMODS.version or '0.0.0') then
        self:put('\n[!] This crash may be caused by continuing a run that was started on a previous version of Steamodded. Try creating a new run.\n')
    end
    if V and V(MODDED_VERSION or '0.0.0') ~= V(RELEASE_VERSION or '0.0.0') then
        self:put('\n[!] Development version of Steamodded detected! If you are not actively developing a mod, please try using the latest release instead.\n')
    end
    if not V then
        self:put('\n[!] A mod you have installed has caused a syntax error through patching. Please share this crash with the mod developer.\n')
    end
end

--- @protected
function errorGen:injectKeybinds()
        self:put("Press ESC to exit")
        self:put("Press R to restart the game")
    if love.system then
        self:put("Press Ctrl+C or tap to copy this error")
    end
        self:put("")
end

--- @protected
function errorGen:injectAdditionalContext()
    self:put("Additional context:")
    additionalContext:generateAdditionalContext(self.lines)
    self:put("")
end

--- @protected
function errorGen:injectTraceback()
    self:put("Traceback:")
    self:put(self.traceStr)
    self:put("")
end

--- @param err string
--- @param tracestr string
--- @param lines? string[]
--- @return string
function errorGen:generateErrorMessage(err, tracestr, lines)
    self.errorStr = err
    self.traceStr = tracestr
    self.lines = lines or {}

    local knownErr = self:getKnownError()
    if knownErr then
        return knownErr
    end

    self:put('Oops! The game crashed:')
    self:put(self.errorStr)

    self:injectPatchAnalysis()
    self:injectAdditionalError()
    self:injectKeybinds()
    self:injectAdditionalContext()
    self:injectTraceback()

    local errorStr = table.concat(self.lines, "\n")
    errorStr = errorStr:gsub("\t", "")
    errorStr = errorStr:gsub("%[string \"(.-)\"%]", "%1")
    return errorStr
end

return errorGen