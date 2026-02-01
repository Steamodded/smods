-- Listen you better be real careful about the code in this file so the crash handler doesn't crash

local balatro_ver
local M = {}

function M.getBalatroVersion()
    if balatro_ver then return balatro_ver end
    local versionFile = love.filesystem.read("version.jkr")
    if versionFile then
        balatro_ver = versionFile:match("[^\n]*")
        return balatro_ver
    end
end

function M.hex(hex)
  if #hex <= 6 then hex = hex.."FF" end
  local _,_,r,g,b,a = hex:find('(%x%x)(%x%x)(%x%x)(%x%x)')
  local color = {tonumber(r,16)/255,tonumber(g,16)/255,tonumber(b,16)/255,tonumber(a,16)/255 or 255}
  return color
end

local v_mt
v_mt = {
    __eq = function(a, b)
        local minorWildcard = a.minor == -2 or b.minor == -2
        local patchWildcard = a.patch == -2 or b.patch == -2
        local betaWildcard = a.rev == '~' or b.rev == '~'
        return a.major == b.major and
        (a.minor == b.minor or minorWildcard) and
        (a.patch == b.patch or minorWildcard or patchWildcard) and
        (a.rev == b.rev or minorWildcard or patchWildcard or betaWildcard) and
        (betaWildcard or a.beta == b.beta)
    end,
    __le = function(a, b)
        local b = {
            major = b.major + (b.minor == -2 and 1 or 0),
            minor = b.minor == -2 and 0 or (b.minor + (b.patch == -2 and 1 or 0)),
            patch = b.patch == -2 and 0 or b.patch,
            beta = b.beta,
            rev = b.rev,
        }
        -- yes, i'm leaving the comparison of two wildcards as undefined behavior
        a = {
            major = a.major + (a.minor == -2 and 1 or 0),
            minor = a.minor == -2 and 0 or (a.minor + (a.patch == -2 and 1 or 0)),
            patch = a.patch == -2 and 0 or a.patch,
            beta = a.beta,
            rev = a.rev,
        }
        if a.major ~= b.major then return a.major < b.major end
        if a.minor ~= b.minor then return a.minor < b.minor end
        if a.patch ~= b.patch then return a.patch < b.patch end
        if a.beta ~= b.beta then return a.beta < b.beta end
        return a.rev <= b.rev
    end,
    __lt = function(a, b)
        return a <= b and not (a == b)
    end,
    __call = function(_, str)
        str = str or '0.0.0'
        local _, _, major, minorFull, minor, patchFull, patch, rev = string.find(str, '^(%d+)(%.?([%d%*]*))(%.?([%d%*]*))(.*)$')
        local minorWildcard = string.match(minor, '%*')
        local patchWildcard = string.match(patch, '%*')
        if (minorFull ~= "" and minor == "") or (patchFull ~= "" and patch == "") then
            sendWarnMessage('Trailing dot found in version "' .. str .. '".', "Utils")
            major, minor, patch = -1, 0, 0
        end
        local t = {
            major = tonumber(major),
            minor = minorWildcard and -2 or tonumber(minor) or 0,
            patch = patchWildcard and -2 or tonumber(patch) or 0,
            rev = rev or '',
            beta = rev and rev:sub(1,1) == '~' and -1 or 0
        }
        return setmetatable(t, v_mt)
    end
}

local V = setmetatable({}, v_mt)
M.V = V
v_mt.__index = V
function V.is_valid(v, allow_wildcard)
    if getmetatable(v) ~= v_mt then return false end
    return(pcall(function() return V() <= v and (allow_wildcard or (v.minor ~= -2 and v.patch ~= -2 and v.rev ~= '~')) end))
end

return M
