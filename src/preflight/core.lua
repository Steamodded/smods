-- TODO: Properly handle this
function boot_print_stage(str)
    print("[stage]", str)
end
local st = love.timer.getTime()

SMODS = {}
MODDED_VERSION = require'SMODS.version'
RELEASE_VERSION = require'SMODS.release'
SMODS.id = 'Steamodded'
SMODS.version = MODDED_VERSION:gsub('%-STEAMODDED', '')
SMODS.can_load = true
SMODS.meta_mod = true
SMODS.config_file = 'config.lua'
SMODS.loading = {
    loaded = false,
    percent = 0,
    lines = {},
}

-- Include lovely and nativefs modules
local nativefs = require "SMODS.nativefs"
SMODS.NFS = nativefs
local lovely = require "lovely"
local json = require "json"

local lovely_mod_dir = lovely.mod_dir:gsub("/$", "")
NFS = nativefs -- Global for backwards compatibility
local NFS = nativefs -- local so nothing accidentially overwrites our global
-- make lovely_mod_dir an absolute path.
-- respects symlink/.. combos
NFS.setWorkingDirectory(lovely_mod_dir)
lovely_mod_dir = NFS.getWorkingDirectory()
-- make sure NFS behaves the same as love.filesystem
NFS.setWorkingDirectory(love.filesystem.getSaveDirectory())

JSON = json

local function set_mods_dir()
    local love_dirs = {
        love.filesystem.getSaveDirectory(),
        love.filesystem.getSourceBaseDirectory()
    }
    for _, love_dir in ipairs(love_dirs) do
        if lovely_mod_dir:sub(1, #love_dir) == love_dir then
            -- relative path from love_dir
            SMODS.MODS_DIR = lovely_mod_dir:sub(#love_dir+2)
            NFS.setWorkingDirectory(love_dir)
            return
        end
    end
    SMODS.MODS_DIR = lovely_mod_dir:gsub("\\", "/")
end
set_mods_dir()

local lovely_path = false -- This line is patched, don't edit it

-- TODO: hanlde preflight dev correctly
SMODS.path = assert(lovely_path, "Steamodded could not find itself"):gsub("\\", "/")

require"SMODS.preflight.logging"
require"SMODS.preflight.loader"
initLoader()
sendInfoMessage("Preflight loaded after " .. love.timer.getTime() - st, "Steamodded")

local function tmpBlacklist(folders)
    local path = SMODS.MODS_DIR .. "/lovely/blacklist.txt"
    if NFS.getInfo(path) then
        local content = NFS.read(path)
        NFS.write(path, content .. "\n# SMODS TMP Blacklist\n" .. table.concat(folders, "\n"))
        assert(lovely.reload_patches())
        NFS.write(path, content)
    else
        NFS.write(path, "# SMODS TMP Blacklist\n" .. table.concat(folders, "\n"))
        assert(lovely.reload_patches())
        NFS.remove(path)
    end
end

local function handleConflicts()
    if lovely.remove_var("SMODS_TMP_DISABLED") then return end
    local conflicted = {}
    local has_lovely = false
    for k, mod in pairs(SMODS.Mods) do
        if not (mod.lovely_only or mod.meta or mod.disabled) and not mod.can_load then
            if mod.lovely then has_lovely = true end
            mod.disabled = true
            table.insert(conflicted, mod.blacklist_name)
        end
    end
    if not has_lovely then return end -- SMODS won't load mods that fail to load

    lovely.set_var("SMODS_TMP_DISABLED", "1") -- NOTE: Maybe store the disabled mods
    SMODS.preflight_force_quit = true
    -- Running this here will cause a deadlock due to lovely still "applying" patches for load_now modules
    SMODS.preflight_quit_before = function() tmpBlacklist(conflicted) end
    love.event.quit("restart")
    return true
end

if handleConflicts() then return end

local ui = require "SMODS.preflight.sharedUI"

function SMODS.loading:draw(dt, dirty)
    if not dirty then
        return
    end
    local percent = math.min(assert(self.percent, "Someone forgot to set a percent"), 100)
    local lines = self.lines or {}
    local c = love.graphics.getCanvas()
    local h = c:getHeight()
    local w = c:getWidth()

    local barw = w * .4
    local barh = barw * .1
    local centerx = w / 2
    local centery = h / 2
    local barx = centerx - barw / 2
    local bary = centery - barh / 2
    local lineHeight = barh * .6
    local numLines = #lines

    local main = {love.graphics.getColor()}
    if percent > 0 then
        love.graphics.setColor(0, .5, 1, 1)
        love.graphics.rectangle("fill", barx, bary, barw * percent, barh, barh * .1)
    end
    love.graphics.setColor(unpack(main))
    love.graphics.rectangle("line", barx, bary, barw, barh, barh * .1)
    if numLines > 0 then
        lineHeight = lineHeight * numLines
        ui.textScaleHelper(lines, barx, bary + barh * 1.1, barw, lineHeight)
    end
end

function SMODS.loading:afterRender()

end


local b = ui.Base{
    bg = {1,0.933,0.549,1},
    fg = {0,0,0,1},
    header = {
        draw = function(self, dt, dirty)
            if not dirty then
                return
            end
            love.graphics.clear()
            local version = require "SMODS.version"
            local release = require "SMODS.release"
            local dev = version ~= release
            local subtitle = "v" .. version
            if dev then subtitle = subtitle .. " (Development Build)" end
            if PREFLIGHT_DEV then subtitle = subtitle .. " (Preflight Dev Mode)" end

            local c = love.graphics.getCanvas()
            local h = c:getHeight()
            local w = c:getWidth()
            ui.textScaleHelper({"Steamodded", {subtitle, 0.5}}, 0, 0, w, h, true)
        end,
        full = false,
    },
    body = SMODS.loading,

}

SMODS.loading.base = b

local _, _, flags = love.window.getMode()
local width, height = love.window.getDesktopDimensions(flags.display)
-- local width, height = 1280, 720

love.window.updateMode(width * 0.8, height * 0.8, {
    resizable = true,
})

-- We don't want the first frame's dt to include time taken by love.load.
-- TODO: Properly hook this up
-- if love.timer then love.timer.step() end
-- while true do
--     local res = b:loop()
--     if res then
--         if res ~= 0 then -- Not successful
--             SMODS.preflight_force_quit = true
--             love.event.quit(res)
--         end
--         break
--     end
--     SMODS.loading:afterRender();
-- end
