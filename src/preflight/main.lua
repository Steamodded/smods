-- This file is used for testing preflight without balatro/lovely
-- Usage: cd into the steamodded directory, then run `love src/preflight`
-- love.event.quit()
PREFLIGHT_DEV = true

print("hi")

local function makePreload(name)
    local mod = require(name)
    return function() return mod end
end

function tprint(tbl, indent)
    if not indent then indent = 0 end
    local toprint = string.rep(" ", indent) .. "{\r\n"
    indent = indent + 2 
    for k, v in pairs(tbl) do
      toprint = toprint .. string.rep(" ", indent)
      if (type(k) == "number") then
        toprint = toprint .. "[" .. k .. "] = "
      elseif (type(k) == "string") then
        toprint = toprint  .. k ..  "= "
      end
      if (type(v) == "number") then
        toprint = toprint .. v .. ",\r\n"
      elseif (type(v) == "string") then
        toprint = toprint .. "\"" .. v .. "\",\r\n"
      elseif (type(v) == "table") then
        if indent>=10 then
        toprint = toprint .. tostring(v) .. ",\r\n"
        else
        toprint = toprint .. tostring(v) .. tprint(v, indent + 1) .. ",\r\n"
        end
      else
        toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
      end
    end
    toprint = toprint .. string.rep(" ", indent-2) .. "}"
    return toprint
end

-- modules
package.preload["SMODS.version"] = makePreload("version")
package.preload["SMODS.release"] = makePreload("release")
package.preload["nativefs"] = makePreload("libs.nativefs.nativefs")
package.preload["json"] = makePreload("libs.json.json")
package.preload["SMODS.preflight.sharedUtil"] = makePreload("src.preflight.sharedUtil")
package.preload["SMODS.preflight.logging"] = function() return require"logging" end
package.preload["SMODS.preflight.loader"] = function() return require"loader" end
package.preload["SMODS.preflight.sharedUI"] = function() return require"sharedUI" end

if not package.preload.lovely then -- This could be run with a real lovely
    local vars = {}
    love.filesystem.createDirectory("preflightStubMods/lovely/logs")
    love.filesystem.write("preflightStubMods/lovely/logs/example.log", "Hello world")
    package.preload["lovely"] = function()
        return {
            version = "0.9.0-preflight-stub",
            get_var = function(name) return vars[name] end,
            set_var = function(name, val) vars[name] = tostring(val) end,
            remove_var = function(name) local key = vars[name] vars[name] = nil return key end,
            reload_patches = function()end,
            mod_dir = love.filesystem.getSaveDirectory() .. "/preflightStubMods",
            log_file = love.filesystem.getSaveDirectory() .. "/preflightStubMods/lovely/logs/example.log",
        }
    end
end

function boot_print_stage(str)
    print("[stage]", str)
end

require"core"
love.event.quit()
