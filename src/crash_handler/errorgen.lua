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
function errorGen:getSmodsVersion()
	if MODDED_VERSION then return tostring(MODDED_VERSION) end
	local moddedSuccess, reqVersion = pcall(require, "SMODS.version")
	if moddedSuccess then return tostring(reqVersion) end
	return "???"
end

--- @protected
function errorGen:getBalatroVersion()
	if VERSION then return tostring(VERSION) end
    local versionFile = love.filesystem.read("version.jkr")
	if versionFile then return versionFile:match("[^\n]*") .. " *" end
    return "???"
end

--- @protected
function errorGen:addVersionInfo()
    self:putf('Balatro: %s', self:getBalatroVersion())
    self:putf('Steamodded: %s', self:getSmodsVersion())
    self:putf('Lovely: %s', require"lovely".version)
    self:putf('Platform: %s (%s) %s', jit.os, love.system.getOS(), jit.arch)
    --[[
    self:put (_VERSION)
    self:put (jit.version)
    self:putf('LÖVE Version: %s.%s.%s', love.getVersion())
    ]]
    self:put("")
end

--- @protected
--- @param mod Mod
function errorGen:addError(mod)
	self:putf(' - %s (%s)', mod.name, mod.version)

	if #mod.load_issues.dependencies > 0 then
		self:put('   [!] Missing dependencies:')
		for k, v in ipairs(mod.load_issues.dependencies) do
			self:putf('    - %s', v)
		end
	end
	if #mod.load_issues.conflicts > 0 then
		self:put('   [!] Conflicts:')
		for k, v in ipairs(mod.load_issues.conflicts) do
			self:putf('    - %s', v)
		end
	end
	if mod.load_issues.outdated then
		self:put('   [!] Outdated')
	end
	if mod.load_issues.main_file_not_found then
		self:putf('   [!] Main file not found (%s)', mod.main_file)
	end
	if mod.load_issues.version_mismatch then
		self:putf('   [!] Steamodded version mismatch (%s)', mod.load_issues.version_mismatch)
	end
	if mod.load_issues.prefix_conflict then
		self:putf('   [!] Prefix conflict (%s)', mod.load_issues.prefix_conflict)
	end
end

--- @protected
--- @param errors Mod[]
function errorGen:addErrorList(errors)
    self:put('Failed loads:')
    for i,mod in ipairs(errors) do self:addError(mod) end
	self:put("")
end

--- @protected
--- @param mod Mod
function errorGen:addLovely(mod)
	self:putf(' - %s', mod.name)
end

--- @protected
--- @param list Mod[]
function errorGen:addLovelyList(list)
    self:put('Lovely mods:')
    for i,mod in ipairs(list) do self:addLovely(mod) end
	self:put("")
end

--- @protected
--- @param mod Mod
--- @param fmt string
function errorGen:addSmods(mod, fmt)
	local state = mod.load_state == 'loaded' and 'L'
		or mod.load_state == 'loading' and 'X'
		or 'U'

	self:putf(fmt, state, mod.name, mod.version, mod.path)

	local debugInfo = mod.debug_info
	if type(debugInfo) == "string" then
		if #debugInfo ~= 0 then
			self:put("   "..debugInfo)
		end
	elseif type(debugInfo) == "table" then
		for k, v in pairs(debugInfo) do
			v = tostring(v)
			if #v ~= 0 then
				self:putf("   %s: %s", k, v)
			end
		end
	end
end

--- @protected
--- @param list Mod[]
function errorGen:addSmodsList(list)
    local nw, vw = 0, 0
    for i,v in ipairs(list) do
        if v.name and v.name:len() > nw then nw = v.name:len() end
        if v.version and v.version:len() > vw then vw = v.version:len() end
    end
    local fmt = string.format(" - [%%s] %%-%ds %%-%ds (%%s)", nw, vw)

    self:put('Steamodded mods: (L: loaded, U: unloaded, X: loading)')
    for i,mod in ipairs(list) do self:addSmods(mod, fmt) end
	self:put("")
end

--- @protected
function errorGen:addMods()
	if not SMODS or not SMODS.Mods then return {} end

	local sortedMods = {}
	for _, v in pairs(SMODS.Mods) do table.insert(sortedMods, v) end
	table.sort(sortedMods, function (a, b) return a.id:lower() < b.id:lower() end)

	local errors = {}
	local lovelyMods = {}
	local smodsMods = {}

	for _, mods in ipairs(sortedMods) do
		if not mods.disabled and (not mods.meta_mod or mods.lovely_only) then
			table.insert(not mods.can_load and errors or mods.lovely_only and lovelyMods or smodsMods, mods)
		end
    end

	if #errors ~= 0 then self:addErrorList(errors) end
	if #smodsMods ~= 0 then self:addSmodsList(smodsMods) end
	if #lovelyMods ~= 0 then self:addLovelyList(lovelyMods) end
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
                    self:put('Related patches:')
                    first = false
                end
                self:putf(' - %d-%d: %s', patchRegion.start_line, patchRegion.end_line, patchEntry.patch_source.file)
                break
            end
        end
    end
    if not first then
        self:put("")
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
    self:addVersionInfo()
    self:injectPatchAnalysis()
    self:addMods()
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