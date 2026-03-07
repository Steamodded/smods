--- @class SMODS.CrashHandler.AdditionalContext
--- @field lines string[]
local additionalContext = {
    lines = {}
}

--- @protected
--- @param str string
function additionalContext:put(str)
    table.insert(self.lines, str)
end

--- @protected
--- @param fmt string
function additionalContext:putf(fmt, ...)
    table.insert(self.lines, fmt:format(...))
end

--- @protected
function additionalContext:getSmodsVersion()
	if MODDED_VERSION then return tostring(MODDED_VERSION) end
	local moddedSuccess, reqVersion = pcall(require, "SMODS.version")
	if moddedSuccess then return tostring(reqVersion) end
	return "???"
end

--- @protected
function additionalContext:getBalatroVersion()
	if VERSION then return tostring(VERSION) end
    local versionFile = love.filesystem.read("version.jkr")
	if versionFile then return versionFile:match("[^\n]*") .. " *" end
    return "???"
end

--- @protected
function additionalContext:addVersionInfo()
    self:putf('Balatro: %s', self:getBalatroVersion())
    self:putf('Steamodded: %s', self:getSmodsVersion())
    self:putf('Lovely: %s', require"lovely".version)
    self:putf('Platform: %s (%s) %s', jit.os, love.system.getOS(), jit.arch)
    --[[
    self:put (_VERSION)
    self:put (jit.version)
    self:putf('LÖVE Version: %s.%s.%s', love.getVersion())
    ]]
end

--- @protected
--- @param mod Mod
function additionalContext:addError(mod)
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
function additionalContext:addErrorList(errors)
    self:put('Failed loads:')
    for i,mod in ipairs(errors) do self:addError(mod) end
	self:put("")
end

--- @protected
--- @param mod Mod
function additionalContext:addLovely(mod)
	self:putf(' - %s', mod.name)
end

--- @protected
--- @param list Mod[]
function additionalContext:addLovelyList(list)
    self:put('Lovely mods:')
    for i,mod in ipairs(list) do self:addLovely(mod) end
	self:put("")
end

--- @protected
--- @param mod Mod
--- @param fmt string
function additionalContext:addSmods(mod, fmt)
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
function additionalContext:addSmodsList(list)
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
function additionalContext:addMods()
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

--- @param stack? string[]
function additionalContext:generateAdditionalContext(stack)
    self.lines = stack or {}
    self:addVersionInfo()
    self:put("")
    self:addMods()
    return self.lines
end

return additionalContext
