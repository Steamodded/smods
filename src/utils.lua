--- STEAMODDED CORE
--- UTILITY FUNCTIONS
function inspect(table)
	if type(table) ~= 'table' then
		return "Not a table"
	end

	local str = ""
	for k, v in pairs(table) do
		local valueStr = type(v) == "table" and "table" or tostring(v)
		str = str .. tostring(k) .. ": " .. valueStr .. "\n"
	end

	return str
end

function inspectDepth(table, indent, depth)
	if depth and depth > 5 then  -- Limit the depth to avoid deep nesting
		return "Depth limit reached"
	end

	if type(table) ~= 'table' then  -- Ensure the object is a table
		return "Not a table"
	end

	local str = ""
	if not indent then indent = 0 end

	for k, v in pairs(table) do
		local formatting = string.rep("  ", indent) .. tostring(k) .. ": "
		if type(v) == "table" then
			str = str .. formatting .. "\n"
			str = str .. inspectDepth(v, indent + 1, (depth or 0) + 1)
		elseif type(v) == 'function' then
			str = str .. formatting .. "function\n"
		elseif type(v) == 'boolean' then
			str = str .. formatting .. tostring(v) .. "\n"
		else
			str = str .. formatting .. tostring(v) .. "\n"
		end
	end

	return str
end

function inspectFunction(func)
    if type(func) ~= 'function' then
        return "Not a function"
    end

    local info = debug.getinfo(func)
    local result = "Function Details:\n"

    if info.what == "Lua" then
        result = result .. "Defined in Lua\n"
    else
        result = result .. "Defined in C or precompiled\n"
    end

    result = result .. "Name: " .. (info.name or "anonymous") .. "\n"
    result = result .. "Source: " .. info.source .. "\n"
    result = result .. "Line Defined: " .. info.linedefined .. "\n"
    result = result .. "Last Line Defined: " .. info.lastlinedefined .. "\n"
    result = result .. "Number of Upvalues: " .. info.nups .. "\n"

    return result
end

function SMODS._save_d_u(o)
    assert(not o._discovered_unlocked_overwritten)
    o._d, o._u = o.discovered, o.unlocked
    o._saved_d_u = true
end

function SMODS.SAVE_UNLOCKS()
    boot_print_stage("Saving Unlocks")
	G:save_progress()
    -------------------------------------
    local TESTHELPER_unlocks = false and not _RELEASE_MODE
    -------------------------------------
    if not love.filesystem.getInfo(G.SETTINGS.profile .. '') then
        love.filesystem.createDirectory(G.SETTINGS.profile ..
            '')
    end
    if not love.filesystem.getInfo(G.SETTINGS.profile .. '/' .. 'meta.jkr') then
        love.filesystem.append(
            G.SETTINGS.profile .. '/' .. 'meta.jkr', 'return {}')
    end

    convert_save_to_meta()

    local meta = STR_UNPACK(get_compressed(G.SETTINGS.profile .. '/' .. 'meta.jkr') or 'return {}')
    meta.unlocked = meta.unlocked or {}
    meta.discovered = meta.discovered or {}
    meta.alerted = meta.alerted or {}

    G.P_LOCKED = {}
    for k, v in pairs(G.P_CENTERS) do
        if not v.wip and not v.demo then
            if TESTHELPER_unlocks then
                v.unlocked = true; v.discovered = true; v.alerted = true
            end --REMOVE THIS
            if not v.unlocked and meta.unlocked[k] then
                v.unlocked = true
            end
            if not v.unlocked then
                G.P_LOCKED[#G.P_LOCKED + 1] = v
            end
            if not v.discovered and meta.discovered[k] then
                v.discovered = true
            end
            if v.discovered and meta.alerted[k] or v.set == 'Back' or v.start_alerted then
                v.alerted = true
            elseif v.discovered then
                v.alerted = false
            end
        end
    end

	table.sort(G.P_LOCKED, function (a, b) return a.order and b.order and a.order < b.order end)

	for k, v in pairs(G.P_BLINDS) do
        v.key = k
        if not v.wip and not v.demo then 
            if TESTHELPER_unlocks then v.discovered = true; v.alerted = true  end --REMOVE THIS
            if not v.discovered and meta.discovered[k] then 
                v.discovered = true
            end
            if v.discovered and meta.alerted[k] then 
                v.alerted = true
            elseif v.discovered then
                v.alerted = false
            end
        end
    end
	for k, v in pairs(G.P_TAGS) do
        v.key = k
        if not v.wip and not v.demo then 
            if TESTHELPER_unlocks then v.discovered = true; v.alerted = true  end --REMOVE THIS
            if not v.discovered and meta.discovered[k] then 
                v.discovered = true
            end
            if v.discovered and meta.alerted[k] then 
                v.alerted = true
            elseif v.discovered then
                v.alerted = false
            end
        end
    end
    for k, v in pairs(G.P_SEALS) do
        v.key = k
        if not v.wip and not v.demo then
            if TESTHELPER_unlocks then
                v.discovered = true; v.alerted = true
            end                                                                   --REMOVE THIS
            if not v.discovered and meta.discovered[k] then
                v.discovered = true
            end
            if v.discovered and meta.alerted[k] then
                v.alerted = true
            elseif v.discovered then
                v.alerted = false
            end
        end
    end
    for _, t in ipairs{
        G.P_CENTERS,
        G.P_BLINDS,
        G.P_TAGS,
        G.P_SEALS,
    } do
        for k, v in pairs(t) do
            v._discovered_unlocked_overwritten = true
        end
    end
end

function SMODS.process_loc_text(ref_table, ref_value, loc_txt, key)
    local target = (type(loc_txt) == 'table') and
    ((G.SETTINGS.real_language and loc_txt[G.SETTINGS.real_language]) or loc_txt[G.SETTINGS.language] or loc_txt['default'] or loc_txt['en-us']) or loc_txt
    if key and (type(target) == 'table') then target = target[key] end
    if not (type(target) == 'string' or target and next(target)) then return end
    ref_table[ref_value] = target
end

local function parse_loc_file(file_name, force, mod_id)
    local loc_table = nil
    if file_name:lower():match("%.json$") then
        loc_table = assert(JSON.decode(NFS.read(file_name)))
    else
        loc_table = assert(loadstring(NFS.read(file_name), ('=[SMODS %s "%s"]'):format(mod_id, string.match(file_name, '[^/]+/[^/]+$'))))()
    end
    local function recurse(target, ref_table)
        if type(target) ~= 'table' then return end --this shouldn't happen unless there's a bad return value
        for k, v in pairs(target) do
            -- If the value doesn't exist *or*
            -- force mode is on and the value is not a table,
            -- change/add the thing
            -- brings back compatibility with language patching mods
            if (not ref_table[k] and type(k) ~= 'number') or (force and ((type(v) ~= 'table') or type(v[1]) == 'string')) then
                ref_table[k] = v
            else
                recurse(v, ref_table[k])
            end
        end
    end
	recurse(loc_table, G.localization)
end

local function handle_loc_file(dir, language, force, mod_id)
    for k, v in ipairs({ dir .. language .. '.lua', dir .. language .. '.json' }) do
        if NFS.getInfo(v) then
            parse_loc_file(v, force, mod_id)
            break
        end
    end
end

function SMODS.handle_loc_file(path, mod_id)
    local dir = path .. 'localization/'
    handle_loc_file(dir, 'en-us', true, mod_id)
    handle_loc_file(dir, 'default', true, mod_id)
    handle_loc_file(dir, G.SETTINGS.language, true, mod_id)
    if G.SETTINGS.real_language then handle_loc_file(dir, G.SETTINGS.real_language, true, mod_id) end
end

function SMODS.insert_pool(pool, center, replace)
	if replace == nil then replace = center.taken_ownership end
	if replace then
		for k, v in ipairs(pool) do
            if v.key == center.key then
                pool[k] = center
                return
            end
		end
    end
    local prev_order = (pool[#pool] and pool[#pool].order) or 0
    if prev_order ~= nil then 
        center.order = prev_order + 1
    end
    table.insert(pool, center)
end

function SMODS.remove_pool(pool, key)
    local j
    for i, v in ipairs(pool) do
        if v.key == key then j = i end
    end
    if j then return table.remove(pool, j) end
end

function SMODS.juice_up_blind()
    local ui_elem = G.HUD_blind:get_UIE_by_ID('HUD_blind_debuff')
    for _, v in ipairs(ui_elem.children) do
        v.children[1]:juice_up(0.3, 0)
    end
    G.GAME.blind:juice_up()
end

---@deprecated
function SMODS.eval_this(_card, effects)
    sendWarnMessage('SMODS.eval_this is deprecated. All calculation stages now support returning effects directly. Effects evaluated using this function are out of order and may not use the correct sound pitch.', 'Util')
    if effects then
        local extras = { mult = false, hand_chips = false }
        if effects.mult_mod then
            mult = mod_mult(mult + effects.mult_mod); extras.mult = true
        end
        if effects.chip_mod then
            hand_chips = mod_chips(hand_chips + effects.chip_mod); extras.hand_chips = true
        end
        if effects.Xmult_mod then
            mult = mod_mult(mult * effects.Xmult_mod); extras.mult = true
        end
        update_hand_text({ delay = 0 }, { chips = extras.hand_chips and hand_chips, mult = extras.mult and mult })
        if effects.message then
            card_eval_status_text(_card, 'jokers', nil, percent, nil, effects)
        end
        percent = (percent or 0) + (percent_delta or 0.08)
    end
end

-- Change a card's suit, rank, or both.
-- Accepts keys for both objects instead of needing to build a card key yourself.
function SMODS.change_base(card, suit, rank)
    if not card then return false end
    local _suit = SMODS.Suits[suit or card.base.suit]
    local _rank = SMODS.Ranks[rank or card.base.value]
    if not _suit or not _rank then
        sendWarnMessage(('Tried to call SMODS.change_base with invalid arguments: suit="%s", rank="%s"'):format(suit, rank), 'Util')
        return false
    end
    card:set_base(G.P_CARDS[('%s_%s'):format(_suit.card_key, _rank.card_key)])
    return card
end

-- Return an array of all (non-debuffed) jokers or consumables with key `key`.
-- Debuffed jokers count if `count_debuffed` is true.
-- This function replaces find_joker(); please use SMODS.find_card() instead
-- to avoid name conflicts with other mods.
function SMODS.find_card(key, count_debuffed)
    local results = {}
    if not G.jokers or not G.jokers.cards then return {} end
    for _, area in ipairs(SMODS.get_card_areas('jokers')) do
        for _, v in pairs(area.cards) do
            if v and type(v) == 'table' and v.config.center.key == key and (count_debuffed or not v.debuff) then
                table.insert(results, v)
            end
        end
    end
    return results
end

function SMODS.create_card(t)
    if not t.area and t.key and G.P_CENTERS[t.key] then
        t.area = G.P_CENTERS[t.key].consumeable and G.consumeables or G.P_CENTERS[t.key].set == 'Joker' and G.jokers
    end
    if not t.area and not t.key and t.set and SMODS.ConsumableTypes[t.set] then
        t.area = G.consumeables
    end
    SMODS.bypass_create_card_edition = t.no_edition
    local _card = create_card(t.set, t.area, t.legendary, t.rarity, t.skip_materialize, t.soulable, t.key, t.key_append)
    SMODS.bypass_create_card_edition = nil

    -- Should this be restricted to only cards able to handle these
    -- or should that be left to the person calling SMODS.create_card to use it correctly? 
    if t.edition then _card:set_edition(t.edition) end
    if t.enhancement then _card:set_ability(G.P_CENTERS[t.enhancement]) end
    if t.seal then _card:set_seal(t.seal) end
    if t.stickers then 
        for i, v in ipairs(t.stickers) do
            local s = SMODS.Stickers[v]
            if not s or type(s.should_apply) ~= 'function' or s:should_apply(_card, t.area, true) then
                SMODS.Stickers[v]:apply(_card, true)
            end
        end
    end

    return _card
end

function SMODS.add_card(t)
    local card = SMODS.create_card(t)
    card:add_to_deck()
    local area = t.area or G.jokers
    area:emplace(card)
    return card
end

function SMODS.debuff_card(card, debuff, source)
    debuff = debuff or nil
    source = source and tostring(source) or nil
    if debuff == 'reset' then card.ability.debuff_sources = {}; return end
    card.ability.debuff_sources = card.ability.debuff_sources or {}
    card.ability.debuff_sources[source] = debuff
    card:set_debuff()
end

-- Recalculate whether a card should be debuffed
function SMODS.recalc_debuff(card)
    G.GAME.blind:debuff_card(card)
end

function SMODS.restart_game()
    if ((G or {}).SOUND_MANAGER or {}).channel then
        G.SOUND_MANAGER.channel:push({
            type = "kill",
        })
    end
    if ((G or {}).SAVE_MANAGER or {}).channel then
        G.SAVE_MANAGER.channel:push({
            type = "kill",
        })
    end
    if ((G or {}).HTTP_MANAGER or {}).channel then
        G.HTTP_MANAGER.channel:push({
            type = "kill",
        })
    end
    if love.system.getOS() ~= 'OS X' then
        love.thread.newThread("os.execute(...)\n"):start('"' .. arg[-2] .. '" ' .. table.concat(arg, " "))
    else
        os.execute('sh "/Users/$USER/Library/Application Support/Steam/steamapps/common/Balatro/run_lovely.sh" &')
    end

    love.event.quit()
end

function SMODS.create_mod_badges(obj, badges)
    if not SMODS.config.no_mod_badges and obj and obj.mod and obj.mod.display_name and not obj.no_mod_badges then
        local mods = {}
        badges.mod_set = badges.mod_set or {}
        if not badges.mod_set[obj.mod.id] and not obj.no_main_mod_badge then table.insert(mods, obj.mod) end
        badges.mod_set[obj.mod.id] = true
        if obj.dependencies then
            for _, v in ipairs(obj.dependencies) do
                local m = assert(SMODS.find_mod(v)[1])
                if not badges.mod_set[m.id] then
                    table.insert(mods, m)
                    badges.mod_set[m.id] = true
                end
            end
        end
        for i, mod in ipairs(mods) do
            local mod_name = string.sub(mod.display_name, 1, 20)
            local size = 0.9
            local font = G.LANG.font
            local max_text_width = 2 - 2*0.05 - 4*0.03*size - 2*0.03
            local calced_text_width = 0
            -- Math reproduced from DynaText:update_text
            for _, c in utf8.chars(mod_name) do
                local tx = font.FONT:getWidth(c)*(0.33*size)*G.TILESCALE*font.FONTSCALE + 2.7*1*G.TILESCALE*font.FONTSCALE
                calced_text_width = calced_text_width + tx/(G.TILESIZE*G.TILESCALE)
            end
            local scale_fac =
                calced_text_width > max_text_width and max_text_width/calced_text_width
                or 1
            badges[#badges + 1] = {n=G.UIT.R, config={align = "cm"}, nodes={
                {n=G.UIT.R, config={align = "cm", colour = mod.badge_colour or G.C.GREEN, r = 0.1, minw = 2, minh = 0.36, emboss = 0.05, padding = 0.03*size}, nodes={
                  {n=G.UIT.B, config={h=0.1,w=0.03}},
                  {n=G.UIT.O, config={object = DynaText({string = mod_name or 'ERROR', colours = {mod.badge_text_colour or G.C.WHITE},float = true, shadow = true, offset_y = -0.05, silent = true, spacing = 1*scale_fac, scale = 0.33*size*scale_fac})}},
                  {n=G.UIT.B, config={h=0.1,w=0.03}},
                }}
              }}
        end
    end
end

function SMODS.create_loc_dump()
    local _old, _new = SMODS.dump_loc.pre_inject, G.localization
    local _dump = {}
    local function recurse(old, new, dump)
        for k, _ in pairs(new) do
            if type(new[k]) == 'table' then
                dump[k] = {}
                if not old[k] then
                    dump[k] = new[k]
                else
                    recurse(old[k], new[k], dump[k])
                end
            elseif old[k] ~= new[k] then
                dump[k] = new[k]
            end
        end
    end
    recurse(_old, _new, _dump)
    local function cleanup(dump)
        for k, v in pairs(dump) do
            if type(v) == 'table' then
                cleanup(v)
                if not next(v) then dump[k] = nil end
            end
        end
    end
    cleanup(_dump)
    local str = 'return ' .. serialize(_dump)
	NFS.createDirectory(SMODS.dump_loc.path..'localization/')
	NFS.write(SMODS.dump_loc.path..'localization/dump.lua', str)
end

-- Serializes an input table in valid Lua syntax
-- Keys must be of type number or string
-- Values must be of type number, boolean, string or table
function serialize(t, indent)
    indent = indent or ''
    local str = '{\n'
	for k, v in ipairs(t) do
        str = str .. indent .. '\t'
		if type(v) == 'number' then
            str = str .. v
        elseif type(v) == 'boolean' then
            str = str .. (v and 'true' or 'false')
        elseif type(v) == 'string' then
            str = str .. serialize_string(v)
        elseif type(v) == 'table' then
            str = str .. serialize(v, indent .. '\t')
        else
            -- not serializable
            str = str .. 'nil'
        end
		str = str .. ',\n'
	end
    for k, v in pairs(t) do
		if type(k) == 'string' then
        	str = str .. indent .. '\t' .. '[' .. serialize_string(k) .. '] = '
            
			if type(v) == 'number' then
				str = str .. v
            elseif type(v) == 'boolean' then
                str = str .. (v and 'true' or 'false')
			elseif type(v) == 'string' then
				str = str .. serialize_string(v)
			elseif type(v) == 'table' then
				str = str .. serialize(v, indent .. '\t')
			else
				-- not serializable
                str = str .. 'nil'
			end
			str = str .. ',\n'
		end
    end
    str = str .. indent .. '}'
	return str
end

function serialize_string(s)
	return string.format("%q", s)
end

-- Starting with `t`, insert any key-value pairs from `defaults` that don't already
-- exist in `t` into `t`. Modifies `t`.
-- Returns `t`, the result of the merge.
--
-- `nil` inputs count as {}; `false` inputs count as a table where
-- every possible key maps to `false`. Therefore,
-- * `t == nil` is weak and falls back to `defaults`
-- * `t == false` explicitly ignores `defaults`
-- (This function might not return a table, due to the above)
function SMODS.merge_defaults(t, defaults)
    if t == false then return false end
    if defaults == false then return false end

    -- Add in the keys from `defaults`, returning a table
    if defaults == nil then return t end
    if t == nil then t = {} end
    for k, v in pairs(defaults) do
        if t[k] == nil then
            t[k] = v
        end
    end
    return t
end
V_MT = {
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
            sendWarnMessage('Trailing dot found in version "' .. str .. '".')
            major, minor, patch = -1, 0, 0
        end
        local t = {
            major = tonumber(major),
            minor = minorWildcard and -2 or tonumber(minor) or 0,
            patch = patchWildcard and -2 or tonumber(patch) or 0,
            rev = rev or '',
            beta = rev and rev:sub(1,1) == '~' and -1 or 0
        }
        return setmetatable(t, V_MT)
    end
}
V = setmetatable({}, V_MT)
V_MT.__index = V
function V.is_valid(v, allow_wildcard)
    if getmetatable(v) ~= V_MT then return false end
    return(pcall(function() return V() <= v and (allow_wildcard or (v.minor ~= -2 and v.patch ~= -2 and v.rev ~= '~')) end))
end

-- Flatten the given arrays of arrays into one, then
-- add elements of each table to a new table in order,
-- skipping any duplicates.
function SMODS.merge_lists(...)
    local t = {}
    for _, v in ipairs({...}) do
        for _, vv in ipairs(v) do
            table.insert(t, vv)
        end
    end
    local ret = {}
    local seen = {}
    for _, li in ipairs(t) do
        assert(type(li) == 'table')
        for _, v in ipairs(li) do
            if not seen[v] then
                ret[#ret+1] = v
                seen[v] = true
            end
        end
    end
    return ret
end

--#region Number formatting

function round_number(num, precision)
	precision = 10^(precision or 0)
	
	return math.floor(num * precision + 0.4999999999999994) / precision
end

-- Formatting util for UI elements (look number_formatting.toml)
function format_ui_value(value)
    if type(value) ~= "number" then
        return tostring(value)
    end

    return number_format(value, 1000000)
end

--#endregion


function SMODS.poll_seal(args)
    args = args or {}
    local key = args.key or 'stdseal'
    local mod = args.mod or 1
    local guaranteed = args.guaranteed or false
    local options = args.options or get_current_pool("Seal")
    local type_key = args.type_key or key.."type"..G.GAME.round_resets.ante
    key = key..G.GAME.round_resets.ante

    local available_seals = {}
    local total_weight = 0
    for _, v in ipairs(options) do
        if v ~= "UNAVAILABLE" then
            local seal_option = {}
            if type(v) == 'string' then
                assert(G.P_SEALS[v])
                seal_option = { key = v, weight = G.P_SEALS[v].weight or 5 } -- default weight set to 5 to replicate base game weighting
            elseif type(v) == 'table' then
                assert(G.P_SEALS[v.key])
                seal_option = { key = v.key, weight = v.weight }
            end
            if seal_option.weight > 0 then
                table.insert(available_seals, seal_option)
                total_weight = total_weight + seal_option.weight
            end
        end
	end
    total_weight = total_weight + (total_weight / 2 * 98) -- set base rate to 2%

    local type_weight = 0 -- modified weight total
    for _,v in ipairs(available_seals) do
        v.weight = G.P_SEALS[v.key].get_weight and G.P_SEALS[v.key]:get_weight() or v.weight
        type_weight = type_weight + v.weight
    end
    
    local seal_poll = pseudorandom(pseudoseed(key or 'stdseal'..G.GAME.round_resets.ante))
    if seal_poll > 1 - (type_weight*mod / total_weight) or guaranteed then -- is a seal generated
        local seal_type_poll = pseudorandom(pseudoseed(type_key)) -- which seal is generated
        local weight_i = 0
        for k, v in ipairs(available_seals) do
            weight_i = weight_i + v.weight
            if seal_type_poll > 1 - (weight_i / type_weight) then
                return v.key
            end
        end
    end
end

function SMODS.get_blind_amount(ante)
    local scale = G.GAME.modifiers.scaling
    local amounts = {
        300,
        700 + 100*scale,
        1400 + 600*scale,
        2100 + 2900*scale,
        15000 + 5000*scale*math.log(scale),
        12000 + 8000*(scale+1)*(0.4*scale),
        10000 + 25000*(scale+1)*((scale/4)^2),
        50000 * (scale+1)^2 * (scale/7)^2
    }
    
    if ante < 1 then return 100 end
    if ante <= 8 then return amounts[ante] - amounts[ante]%(10^math.floor(math.log10(amounts[ante])-1)) end
    local a, b, c, d = amounts[8], amounts[8]/amounts[7], ante-8, 1 + 0.2*(ante-8)
    local amount = math.floor(a*(b + (b*0.75*c)^d)^c)
    amount = amount - amount%(10^math.floor(math.log10(amount)-1))
    return amount
end

function SMODS.stake_from_index(index)
    local stake = G.P_CENTER_POOLS.Stake[index] or nil
    if not stake then return "error" end
    return stake.key
end

function convert_save_data()
    for k, v in pairs(G.PROFILES[G.SETTINGS.profile].deck_usage) do
        local first_pass = not v.wins_by_key and not v.losses_by_key
        v.wins_by_key = v.wins_by_key or {}
        for index, number in pairs(v.wins or {}) do
            if index > 8 and not first_pass then break end
            v.wins_by_key[SMODS.stake_from_index(index)] = number
        end
        v.losses_by_key = v.losses_by_key or {}
        for index, number in pairs(v.losses or {}) do
            if index > 8 and not first_pass then break end
            v.losses_by_key[SMODS.stake_from_index(index)] = number
        end
    end
    for k, v in pairs(G.PROFILES[G.SETTINGS.profile].joker_usage) do
        local first_pass = not v.wins_by_key and not v.losses_by_key
        v.wins_by_key = v.wins_by_key or {}
        for index, number in pairs(v.wins or {}) do
            if index > 8 and not first_pass then break end
            v.wins_by_key[SMODS.stake_from_index(index)] = number
        end
        v.losses_by_key = v.losses_by_key or {}
        for index, number in pairs(v.losses or {}) do
            if index > 8 and not first_pass then break end
            v.losses_by_key[SMODS.stake_from_index(index)] = number
        end
    end
    G:save_settings()
end


function SMODS.poll_rarity(_pool_key, _rand_key)
	local rarity_poll = pseudorandom(pseudoseed(_rand_key or ('rarity'..G.GAME.round_resets.ante))) -- Generate the poll value
	local available_rarities = copy_table(SMODS.ObjectTypes[_pool_key].rarities) -- Table containing a list of rarities and their rates
    local vanilla_rarities = {["Common"] = 1, ["Uncommon"] = 2, ["Rare"] = 3, ["Legendary"] = 4}
    
    -- Calculate total rates of rarities
    local total_weight = 0
    for _, v in ipairs(available_rarities) do
        v.mod = G.GAME[tostring(v.key):lower().."_mod"] or 1
        -- Should this fully override the v.weight calcs? 
        if SMODS.Rarities[v.key] and SMODS.Rarities[v.key].get_weight and type(SMODS.Rarities[v.key].get_weight) == "function" then
            v.weight = SMODS.Rarities[v.key]:get_weight(v.weight, SMODS.ObjectTypes[_pool_key])
        end
        v.weight = v.weight*v.mod
        total_weight = total_weight + v.weight
    end
    -- recalculate rarities to account for v.mod
    for _, v in ipairs(available_rarities) do
        v.weight = v.weight / total_weight
    end

	-- Calculate selected rarity
	local weight_i = 0
	for _, v in ipairs(available_rarities) do
		weight_i = weight_i + v.weight
		if rarity_poll < weight_i then
            if vanilla_rarities[v.key] then 
                return vanilla_rarities[v.key]
            else
			    return v.key
            end
		end
	end
	return nil
end

function SMODS.poll_enhancement(args)
    args = args or {}
    local key = args.key or 'std_enhance'
    local mod = args.mod or 1
    local guaranteed = args.guaranteed or false
    local options = args.options or get_current_pool("Enhanced")
    if args.no_replace then
        for i, k in pairs(options) do
            if G.P_CENTERS[k] and G.P_CENTERS[k].replace_base_card then
                options[i] = 'UNAVAILABLE'
            end
        end
    end
    local type_key = args.type_key or key.."type"..G.GAME.round_resets.ante
    key = key..G.GAME.round_resets.ante

    local available_enhancements = {}
    local total_weight = 0
    for _, v in ipairs(options) do
        if v ~= "UNAVAILABLE" then
            local enhance_option = {}
            if type(v) == 'string' then
                assert(G.P_CENTERS[v])
                enhance_option = { key = v, weight = G.P_CENTERS[v].weight or 5 } -- default weight set to 5 to replicate base game weighting
            elseif type(v) == 'table' then
                assert(G.P_CENTERS[v.key])
                enhance_option = { key = v.key, weight = v.weight }
            end
            if enhance_option.weight > 0 then
                table.insert(available_enhancements, enhance_option)
                total_weight = total_weight + enhance_option.weight
            end
        end
	  end
    total_weight = total_weight + (total_weight / 40 * 60) -- set base rate to 40%

    local type_weight = 0 -- modified weight total
    for _,v in ipairs(available_enhancements) do
        v.weight = G.P_CENTERS[v.key].get_weight and G.P_CENTERS[v.key]:get_weight() or v.weight
        type_weight = type_weight + v.weight
    end
    
    local enhance_poll = pseudorandom(pseudoseed(key))
    if enhance_poll > 1 - (type_weight*mod / total_weight) or guaranteed then -- is an enhancement selected
        local seal_type_poll = pseudorandom(pseudoseed(type_key)) -- which enhancement is selected
        local weight_i = 0
        for k, v in ipairs(available_enhancements) do
            weight_i = weight_i + v.weight
            if seal_type_poll > 1 - (weight_i / type_weight) then
                return v.key
            end
        end
    end
end

function time(func, ...)
    local start_time = love.timer.getTime()
    func(...)
    local end_time = love.timer.getTime()
    return 1000*(end_time-start_time)
end

function Card:add_sticker(sticker, bypass_check)
    local sticker = SMODS.Stickers[sticker]
    if bypass_check or (sticker and sticker.should_apply and type(sticker.should_apply) == 'function' and sticker:should_apply(self, self.config.center, self.area, true)) then
        sticker:apply(self, true)
    end
end

function Card:remove_sticker(sticker)
    if self.ability[sticker] then
        SMODS.Stickers[sticker]:apply(self, false)
    end
end


function Card:calculate_sticker(context, key)
    local sticker = SMODS.Stickers[key]
    if self.ability[key] and type(sticker.calculate) == 'function' then
        local o = sticker:calculate(self, context)
        if o then
            if not o.card then o.card = self end
            return o
        end
    end
end

function Card:calculate_enhancement(context)
    if self.debuff or self.ability.set ~= 'Enhanced' then return nil end
    local center = self.config.center
    if center.calculate and type(center.calculate) == 'function' then
        local o = center:calculate(self, context)
        if o then
            if not o.card then o.card = self end
            return o
        end
    end
end

function SMODS.get_enhancements(card, extra_only)
    if not SMODS.optional_features.quantum_enhancements or not G.hand then
        return not extra_only and card.ability.set == 'Enhanced' and { [card.config.center.key] = true } or {}
    end
    if card.extra_enhancements and next(card.extra_enhancements) then
        if extra_only then
            local extras = copy_table(card.extra_enhancements)
            extras[card.config.center.key] = nil
            return extras
        end
        return card.extra_enhancements
    end
    local enhancements = {}
    if card.config.center.key ~= "c_base" and not extra_only then
        enhancements[card.config.center.key] = true
    end
    local calc_return = {}
    SMODS.calculate_context({other_card = card, check_enhancement = true, no_blueprint = true}, calc_return)
    for _, eval in pairs(calc_return) do
        for key, eval2 in pairs(eval) do
            if type(eval2) == 'table' then
                for key2, _ in pairs(eval2) do
                    if G.P_CENTERS[key2] then enhancements[key2] = true end
                end
            else
                if G.P_CENTERS[key] then enhancements[key] = true end
            end
        end
    end

    if extra_only and enhancements[card.config.center.key] then
        enhancements[card.config.center.key] = nil
    end
    if next(enhancements) then card.extra_enhancements = enhancements end
    return enhancements
end

function SMODS.has_enhancement(card, key)
    if card.config.center.key == key then return true end
    card.extra_enhancements = nil
    local enhancements = SMODS.get_enhancements(card)
    if enhancements[key] then return true end
    return false
end

function SMODS.shatters(card)
    card.extra_enhancements = nil
    local enhancements = SMODS.get_enhancements(card)
    for key, _ in pairs(enhancements) do
        if G.P_CENTERS[key].shatters or key == 'm_glass' then return true end
    end
end

function SMODS.calculate_quantum_enhancements(card, effects, context)
    if not SMODS.optional_features.quantum_enhancements then return end
    context.extra_enhancement = true
    local extra_enhancements = SMODS.get_enhancements(card, true)
    local old_ability = copy_table(card.ability)
    local old_center = card.config.center
    local old_center_key = card.config.center_key
    for k, _ in pairs(extra_enhancements) do
        if G.P_CENTERS[k] then
            card:set_ability(G.P_CENTERS[k])
            card.ability.extra_enhancement = k
            local eval = eval_card(card, context)
            table.insert(effects, 1, eval)
        end
    end
    card.ability = old_ability
    card.config.center = old_center
    card.config.center_key = old_center_key
    card:set_sprites(old_center)
    context.extra_enhancement = nil
end

function SMODS.has_no_suit(card)
    local is_stone = false
    local is_wild = false
    card.extra_enhancements = nil
    for k, _ in pairs(SMODS.get_enhancements(card)) do
        if k == 'm_stone' or G.P_CENTERS[k].no_suit then is_stone = true end
        if k == 'm_wild' or G.P_CENTERS[k].any_suit then is_wild = true end
    end
    return is_stone and not is_wild
end
function SMODS.has_any_suit(card)
    card.extra_enhancements = nil
    for k, _ in pairs(SMODS.get_enhancements(card)) do
        if k == 'm_wild' or G.P_CENTERS[k].any_suit then return true end
    end
end
function SMODS.has_no_rank(card)
    card.extra_enhancements = nil
    for k, _ in pairs(SMODS.get_enhancements(card)) do
        if k == 'm_stone' or G.P_CENTERS[k].no_rank then return true end
    end
end
function SMODS.always_scores(card)
    card.extra_enhancements = nil
    for k, _ in pairs(SMODS.get_enhancements(card)) do
        if k == 'm_stone' or G.P_CENTERS[k].always_scores then return true end
    end
    if (G.P_CENTERS[(card.edition or {}).key] or {}).always_scores then return true end
    if (G.P_SEALS[card.seal or {}] or {}).always_scores then return true end
    for k, v in pairs(SMODS.Stickers) do
        if v.always_scores and card.ability[k] then return true end
    end
end
function SMODS.never_scores(card)
    card.extra_enhancements = nil
    for k, _ in pairs(SMODS.get_enhancements(card)) do
        if G.P_CENTERS[k].never_scores then return true end
    end
    if (G.P_CENTERS[(card.edition or {}).key] or {}).never_scores then return true end
    if (G.P_SEALS[card.seal or {}] or {}).never_scores then return true end
    for k, v in pairs(SMODS.Stickers) do
        if v.never_scores and card.ability[k] then return true end
    end
end

SMODS.collection_pool = function(_base_pool)
    local pool = {}
    if type(_base_pool) ~= 'table' then return pool end
    local is_array = _base_pool[1]
    local ipairs = is_array and ipairs or pairs
    for _, v in ipairs(_base_pool) do
        if (not G.ACTIVE_MOD_UI or v.mod == G.ACTIVE_MOD_UI) and not v.no_collection then
            pool[#pool+1] = v
        end
    end
    if not is_array then table.sort(pool, function(a,b) return a.order < b.order end) end
    return pool
end

SMODS.find_mod = function(id)
    local ret = {}
    local mod = SMODS.Mods[id] or {}
    if mod.can_load then ret[#ret+1] = mod end
    for _,v in ipairs(SMODS.provided_mods[id] or {}) do
        if v.mod.can_load then ret[#ret+1] = v.mod end
    end
    return ret
end

local function bufferCardLimitForSmallDS(cards, scaleFactor)
    local cardCount = #cards
    if type(scaleFactor) ~= "number" or scaleFactor <= 0 then
        sendWarnMessage("scaleFactor must be a positive number")
        return cardCount
    end
    -- Ensure card_limit is always at least the number of cards
    G.cdds_cards.config.card_limit = math.max(G.cdds_cards.config.card_limit, cardCount)
    -- Calculate the buffer size dynamically based on the scale factor
    local buffer = 0
    if cardCount < G.cdds_cards.rankCount then
        -- Buffer decreases as cardCount approaches G.cdds_cards.rankCount, modulated by scaleFactor
        buffer = math.ceil(((G.cdds_cards.rankCount - cardCount) / scaleFactor))
    end
    G.cdds_cards.config.card_limit = math.max(cardCount, cardCount + buffer)

    return G.cdds_cards.config.card_limit
end

G.FUNCS.update_collab_cards = function(key, suit, silent)
    if type(key) == "number" then
        key = G.COLLABS.options[suit][key]
    end
    if not G.cdds_cards then return end
    local cards = {}
    local cards_order = {}
    local deckskin = SMODS.DeckSkins[key]
    local palette = deckskin.palette_map and deckskin.palette_map[G.SETTINGS.colour_palettes[suit] or ''] or (deckskin.palettes or {})[1]
    local suit_data = SMODS.Suits[suit]
    local d_ranks = (palette and (palette.display_ranks or palette.ranks)) or deckskin.display_ranks or deckskin.ranks
    if deckskin.outdated then
        local reversed = {}
        for i = #d_ranks, 1, -1 do
           table.insert(reversed, d_ranks[i])
        end
        d_ranks = reversed
    end

    local diff_order
    if #G.cdds_cards.cards ~= #d_ranks then
        diff_order = true
    else
        for i,v in ipairs(G.cdds_cards.cards) do
            if v.config.card_key ~= suit_data.card_key..'_'..SMODS.Ranks[d_ranks[i]].card_key then
                diff_order = true
                break
            end
        end
    end

    if diff_order then
        for i = #G.cdds_cards.cards, 1, -1 do
            G.cdds_cards:remove_card(G.cdds_cards.cards[i]):remove()
        end
        for i, r in ipairs(d_ranks) do
            local rank = SMODS.Ranks[r]
            local card_code = suit_data.card_key .. '_' .. rank.card_key
            cards_order[#cards_order+1] = card_code
            local card = Card(G.cdds_cards.T.x+G.cdds_cards.T.w/2, G.cdds_cards.T.y+G.cdds_cards.T.h/2, G.CARD_W*1.2, G.CARD_H*1.2, G.P_CARDS[card_code], G.P_CENTERS.c_base)
            -- Instead of no ui it would be nice to pass info queue to this so that artist credits can be done?
            card.no_ui = true
    
            G.cdds_cards:emplace(card)
        end
    end
    G.cdds_cards.config.card_limit = bufferCardLimitForSmallDS(cards, 2.5)
end

G.FUNCS.update_suit_colours = function(suit, skin, palette_num)
    skin = skin and SMODS.DeckSkins[skin] or nil
    local new_colour_proto = G.C.SO_1[suit]
    if G.SETTINGS.colour_palettes[suit] == 'lc' or G.SETTINGS.colour_palettes[suit] == 'hc' then
        new_colour_proto = G.C["SO_"..((G.SETTINGS.colour_palettes[suit] == 'hc' and 2) or (G.SETTINGS.colour_palettes[suit] == 'lc' and 1))][suit]
    end
    if skin and not skin.outdated then
        local palette = (palette_num and skin.palettes[palette_num]) or skin.palette_map and skin.palette_map[G.SETTINGS.colour_palettes[suit] or '']
        new_colour_proto = palette and palette.colour or new_colour_proto
    end
    G.C.SUITS[suit] = new_colour_proto
end

-- This function handles the calculation of each effect returned to evaluate play.
-- Can easily be hooked to add more calculation effects ala Talisman
SMODS.calculate_individual_effect = function(effect, scored_card, key, amount, from_edition)
    if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
    if (key == 'chips' or key == 'h_chips' or key == 'chip_mod') and amount then 
        hand_chips = mod_chips(hand_chips + amount)
        update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
        if not effect.remove_default_message then
            if from_edition then
                card_eval_status_text(scored_card, 'jokers', nil, percent, nil, {message = localize{type = 'variable', key = amount > 0 and 'a_chips' or 'a_chips_minus', vars = {amount}}, chip_mod = amount, colour = G.C.EDITION, edition = true})
            else
                if key ~= 'chip_mod' then
                    if effect.chip_message then
                        card_eval_status_text(scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, effect.chip_message)
                    else
                        card_eval_status_text(scored_card or effect.card or effect.focus, 'chips', amount, percent)
                    end
                end
            end
        end
        return true
    end

    if (key == 'mult' or key == 'h_mult' or key == 'mult_mod') and amount then 
        mult = mod_mult(mult + amount)
        update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
        if not effect.remove_default_message then
            if from_edition then
                card_eval_status_text(scored_card, 'jokers', nil, percent, nil, {message = localize{type = 'variable', key = amount > 0 and 'a_mult' or 'a_mult_minus', vars = {amount}}, mult_mod = amount, colour = G.C.DARK_EDITION, edition = true})
            else
                if key ~= 'mult_mod' then 
                    if effect.mult_message then
                        card_eval_status_text(scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, effect.mult_message)
                    else
                        card_eval_status_text(scored_card or effect.card or effect.focus, 'mult', amount, percent)
                    end
                end
            end
        end
        return true
    end
    
    if (key == 'p_dollars' or key == 'dollars' or key == 'h_dollars') and amount then 
        ease_dollars(amount)
        if not effect.remove_default_message then
            if effect.dollar_message then
                card_eval_status_text(scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, effect.dollar_message)
            else
                card_eval_status_text(scored_card or effect.card or effect.focus, 'dollars', amount, percent)
            end
        end
        return true
    end

    if (key == 'x_chips' or key == 'xchips' or key == 'Xchip_mod') and amount ~= 1 then 
        hand_chips = mod_chips(hand_chips * amount)
        update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
        if not effect.remove_default_message then
            if from_edition then
                card_eval_status_text(scored_card, 'jokers', nil, percent, nil, {message = localize{type='variable',key= amount > 0 and 'a_xchips' or 'a_xchips_minus',vars={amount}}, Xchips_mod =  amount, colour =  G.C.EDITION, edition = true})
            else
                if key ~= 'Xchip_mod' then
                    if effect.xchip_message then
                        card_eval_status_text(scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, effect.xchip_message)
                    else
                        card_eval_status_text(scored_card or effect.card or effect.focus, 'x_chips', amount, percent)
                    end
                end
            end
        end
        return true
    end
    
    if (key == 'x_mult' or key == 'xmult' or key == 'Xmult' or key == 'x_mult_mod' or key == 'Xmult_mod') and amount ~= 1 then 
        mult = mod_mult(mult * amount)
        update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
        if not effect.remove_default_message then
            if from_edition then
                card_eval_status_text(scored_card, 'jokers', nil, percent, nil, {message = localize{type='variable',key= amount > 0 and 'a_xmult' or 'a_xmult_minus',vars={amount}}, Xmult_mod =  amount, colour =  G.C.EDITION, edition = true})
            else
                if key ~= 'Xmult_mod' then
                    if effect.xmult_message then
                        card_eval_status_text(scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, effect.xmult_message)
                    else
                        card_eval_status_text(scored_card or effect.card or effect.focus, 'x_mult', amount, percent)
                    end
                end
            end
        end
        return true
    end

    if key == 'message' then
        card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, effect)
        return true
    end

    if key == 'func' then
        effect.func()
        return true
    end

    if key == 'swap' then 
        local old_mult = mult
        mult = mod_mult(hand_chips)
        hand_chips = mod_chips(old_mult)
        update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
        return true
    end

    if key == 'level_up' then
        local old_text = {}
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                old_text = copy_table(G.GAME.current_round.current_hand)
                update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = old_text.mult, chips = old_text.chips, handname = old_text.handname, level = old_text.handname ~= "" and G.GAME.hands[G.GAME.last_hand_played].level or ''})
                return true
            end
        }))
        local hand_type = effect.level_up_hand or G.GAME.last_hand_played
        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(hand_type, 'poker_hands'),chips = G.GAME.hands[hand_type].chips, mult = G.GAME.hands[hand_type].mult, level=G.GAME.hands[hand_type].level})
        level_up_hand(scored_card, hand_type, effect.instant, type(amount) == 'number' and amount or 1)
        return true
    end

    if key == 'extra' then
        return SMODS.calculate_effect(amount, scored_card)
    end

    if key == 'saved' then
        SMODS.saved = amount
        return true
    end
end

-- Used to calculate a table of effects generated in evaluate_play
SMODS.trigger_effects = function(effects, card)
    for i, effect_table in ipairs(effects) do
        for key, effect in pairs(effect_table) do
            if key ~= 'smods' then
                if type(effect) == 'table' then
                    local calc = SMODS.calculate_effect(effect, card, key == 'edition')
                    if calc then effects.calculated = true end
                end
            end
        end
    end
end

SMODS.calculate_effect = function(effect, scored_card, from_edition, pre_jokers)
    local calculated = false
    for _, key in ipairs(SMODS.calculation_keys) do
        if effect[key] then
            if effect.juice_card then G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function () effect.juice_card:juice_up(0.1); scored_card:juice_up(0.1); return true end})) end
            calculated = SMODS.calculate_individual_effect(effect, scored_card, key, effect[key], from_edition, pre_jokers)
            percent = (percent or 0) + (percent_delta or 0.08)
        end
    end
    if effect.effect then calculated = true end
    if effect.remove then calculated = true end
    return calculated
end

SMODS.calculation_keys = {
    'chips', 'h_chips', 'chip_mod',
    'mult', 'h_mult', 'mult_mod',
    'x_chips', 'xchips', 'Xchip_mod',
    'x_mult', 'Xmult', 'xmult', 'x_mult_mod', 'Xmult_mod',
    'p_dollars', 'dollars', 'h_dollars',
    'swap',
    'message',
    'level_up', 'func', 'extra',
    'saved'
}

SMODS.calculate_repetitions = function(card, context, reps)
    -- From the card
    context.repetition_only = true
    local eval = eval_card(card, context)
    for key, value in pairs(eval) do
        if value.repetitions then
            for h=1, value.repetitions do
                value.card = value.card or card
                value.message = value.message or (not value.remove_default_message and localize('k_again_ex'))
                reps[#reps+1] = {key = value}
            end
        end
    end
    context.repetition_only = false
    --From jokers
    for _, area in ipairs(SMODS.get_card_areas('jokers')) do
        for _, _card in ipairs(area.cards) do
        --calculate the joker effects
            local eval, post = eval_card(_card, context)
            if next(post) then SMODS.trigger_effects({post}, card) end
            local rt = eval and eval.retriggers and #eval.retriggers or 0
            for key, value in pairs(eval) do
                if value.repetitions and key ~= 'retriggers' then

                    for h=1, value.repetitions do
                        value.card = value.card or _card
                        value.message = value.message or (not value.remove_default_message and localize('k_again_ex'))
                        reps[#reps+1] = {key = value}
                        for i=1, rt do
                            local rt_eval, rt_post = eval_card(_card, context)
                            rt_eval.card = rt_eval.card or _card
                            reps[#reps+1] = {key = value}
                            if next(rt_post) then SMODS.trigger_effects({rt_post}, card) end
                        end
                    end
                end
            end
        end
    end
    local effect = G.GAME.selected_back:trigger_effect(context)
    if effect and effect.repetitions then
        for h=1, effect.repetitions do
            effect.card = effect.card or G.deck.cards[1] or G.deck
            reps[#reps+1] = {key = effect}
        end
    end
    return reps
end

SMODS.calculate_retriggers = function(card, context, _ret)
    local retriggers = {}
    if not SMODS.optional_features.retrigger_joker then return retriggers end
    for _, area in ipairs(SMODS.get_card_areas('jokers')) do
        for _, _card in ipairs(area.cards) do
            local eval, post = eval_card(_card, {retrigger_joker_check = true, other_card = card, other_context = context, other_ret = _ret})
            if next(post) then SMODS.trigger_effects({post}, _card) end
            for key, value in pairs(eval) do
                if value.repetitions then
                    for h=1, value.repetitions do
                        value.retrigger_card = _card
                        value.message = value.message or (not value.remove_default_message and localize('k_again_ex'))
                        retriggers[#retriggers + 1] = value
                    end
                end
            end
        end
    end
    return retriggers
end

function Card:calculate_edition(context)
    if self.debuff then return end
    if self.edition then
        local edition = G.P_CENTERS[self.edition.key]
        if edition.calculate and type(edition.calculate) == 'function' then
            local o = edition:calculate(self, context)
            if o then
                if not o.card then o.card = self end    
                return o
            end
        end
    end
end

-- Used to calculate contexts across G.jokers, scoring_hand (if present), G.play and G.GAME.selected_back
-- Hook this function to add different areas to MOST calculations
function SMODS.calculate_context(context, return_table)
    context.cardarea = G.jokers
    context.main_eval = true
    for _, area in ipairs(SMODS.get_card_areas('jokers')) do
        for _, _card in ipairs(area.cards) do
            --calculate the joker effects
            local eval, post = eval_card(_card, context)
            local effects = {eval}
            for _,v in ipairs(post) do effects[#effects+1] = v end

            if context.other_joker then
                for k, v in pairs(effects[1]) do
                    v.other_card = _card
                end
            end
            if effects[1].retriggers then
                context.retrigger_joker = true
                for rt = 1, #effects[1].retriggers do
                    context.retrigger_joker = effects[1].retriggers[rt].retrigger_card
                    local rt_eval, rt_post = eval_card(_card, context)
                    table.insert(effects, {effects[1].retriggers[rt]})
                    table.insert(effects, rt_eval)
                    for _,v in ipairs(rt_post) do effects[#effects+1] = v end
                end
                context.retrigger_joker = false
            end
            if return_table then
                for _,v in ipairs(effects) do 
                    if v.jokers and not v.jokers.card then v.jokers.card = _card end
                    return_table[#return_table+1] = v
                end
            else
                SMODS.trigger_effects(effects, _card)
            end
        end
    end
    context.main_eval = nil
    if context.scoring_hand then
        context.cardarea = G.play
        for i=1, #context.scoring_hand do
            --calculate the played card effects
            if return_table then 
                return_table[#return_table+1] = eval_card(context.scoring_hand[i], context)
                SMODS.calculate_quantum_enhancements(context.scoring_hand[i], return_table, context)
            else
                local effects = {eval_card(context.scoring_hand[i], context)}
                SMODS.calculate_quantum_enhancements(context.scoring_hand[i], effects, context)
                SMODS.trigger_effects(effects, context.scoring_hand[i])
            end
        end
        if SMODS.optional_features.cardareas.unscored then
            context.cardarea = 'unscored'
            local unscored_cards = {}
            for _, played_card in pairs(G.play.cards) do
                if not SMODS.in_scoring(played_card, context.scoring_hand) then unscored_cards[#unscored_cards + 1] = played_card end
            end
            for i=1, #unscored_cards do
                --calculate the played card effects
                if return_table then 
                    return_table[#return_table+1] = eval_card(unscored_cards[i], context)
                    SMODS.calculate_quantum_enhancements(unscored_cards[i], return_table, context)
                else
                    local effects = {eval_card(unscored_cards[i], context)}
                    SMODS.calculate_quantum_enhancements(unscored_cards[i], effects, context)
                    SMODS.trigger_effects(effects, unscored_cards[i])
                end
            end
        end
    end
    context.cardarea = G.hand
    for i=1, #G.hand.cards do
        --calculate the held card effects
        if return_table then 
            return_table[#return_table+1] = eval_card(G.hand.cards[i], context)    
        else
            local effects = {eval_card(G.hand.cards[i], context)}
            SMODS.calculate_quantum_enhancements(G.hand.cards[i], effects, context)
            SMODS.trigger_effects(effects, G.hand.cards[i])
        end
    end
    if SMODS.optional_features.cardareas.deck then
        context.cardarea = G.deck
        for i=1, #G.deck.cards do
            --calculate the held card effects
            if return_table then 
                return_table[#return_table+1] = eval_card(G.deck.cards[i], context)    
            else
                local effects = {eval_card(G.deck.cards[i], context)}
                SMODS.calculate_quantum_enhancements(G.deck.cards[i], effects, context)
                SMODS.trigger_effects(effects, G.deck.cards[i])
            end
        end
    end
    if SMODS.optional_features.cardareas.discard then
        context.cardarea = G.discard
        for i=1, #G.discard.cards do
            --calculate the held card effects
            if return_table then 
                return_table[#return_table+1] = eval_card(G.discard.cards[i], context)    
            else
                local effects = {eval_card(G.discard.cards[i], context)}
                SMODS.calculate_quantum_enhancements(G.discard.cards[i], effects, context)
                SMODS.trigger_effects(effects, G.discard.cards[i])
            end
        end
    end
    local effect = G.GAME.selected_back:trigger_effect(context)
    if effect then SMODS.calculate_effect(effect, G.deck.cards[1] or G.deck) end
end

function SMODS.in_scoring(card, scoring_hand)
    for _, _card in pairs(scoring_hand) do
        if card == _card then return true end
    end
end

function SMODS.score_card(card, context)
    local reps = { 1 }
    local j = 1
    while j <= #reps do
        if reps[j] ~= 1 then
            local _, eff = next(reps[j])
            SMODS.calculate_effect(eff, eff.card)
            percent = percent + percent_delta
        end

        context.main_scoring = true
        local effects = { eval_card(card, context) }
        SMODS.calculate_quantum_enhancements(card, effects, context)
        context.main_scoring = nil
        context.individual = true
        context.other_card = card

        if next(effects) then
            for _, area in ipairs(SMODS.get_card_areas('jokers')) do
                for _, _card in ipairs(area.cards) do
                    --calculate the joker individual card effects
                    local eval, post = eval_card(_card, context)
                    if next(eval) then
                        if eval.jokers then eval.jokers.juice_card = eval.jokers.juice_card or eval.jokers.card or _card end
                        table.insert(effects, eval)
                        for _, v in ipairs(post) do effects[#effects+1] = v end
                        if eval.retriggers then
                            context.retrigger_joker = true
                            for rt = 1, #eval.retriggers do
                                local rt_eval, rt_post = eval_card(_card, context)
                                table.insert(effects, { eval.retriggers[rt] })
                                table.insert(effects, rt_eval)
                                for _, v in ipairs(rt_post) do effects[#effects+1] = v end
                            end
                            context.retrigger_joker = nil
                        end
                    end
                end
            end
        end

        SMODS.trigger_effects(effects, card)
        local deck_effect = G.GAME.selected_back:trigger_effect(context)
        if deck_effect then SMODS.calculate_effect(deck_effect, G.deck.cards[1] or G.deck) end

        context.individual = nil
        if reps[j] == 1 and effects.calculated then
            context.repetition = true
            context.card_effects = effects
            SMODS.calculate_repetitions(card, context, reps)
            context.repetition = nil
            context.card_effects = nil
        end
        j = j + (effects.calculated and 1 or #reps)
        context.other_card = nil
        card.lucky_trigger = nil
    end
    card.extra_enhancements = nil
end

function SMODS.calculate_main_scoring(context, scoring_hand)
    for _, card in ipairs(scoring_hand or context.cardarea.cards) do
        --add cards played to list
        if scoring_hand and not SMODS.has_no_rank(card) then
            G.GAME.cards_played[card.base.value].total = G.GAME.cards_played[card.base.value].total + 1
            if not SMODS.has_no_suit(card) then
                G.GAME.cards_played[card.base.value].suits[card.base.suit] = true
            end
        end
        --if card is debuffed
        if scoring_hand and card.debuff then
            G.GAME.blind.triggered = true
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = (function() SMODS.juice_up_blind();return true end)
            }))
            card_eval_status_text(card, 'debuff')
        else
            SMODS.score_card(card, context)
        end
    end
end

function SMODS.calculate_end_of_round_effects(context)
    for i, card in ipairs(context.cardarea.cards) do
        local reps = {1}
        local j = 1
        while j <= #reps do
            percent = (i-0.999)/(#context.cardarea.cards-0.998) + (j-1)*0.1
            if reps[j] ~= 1 then
                local _, eff = next(reps[j])
                SMODS.calculate_effect(eff, eff.card)
                percent = percent + 0.08
            end

            context.playing_card_end_of_round = true
            --calculate the hand effects
            local effects = {eval_card(card, context)}
            local extra_enhancements = SMODS.get_enhancements(card, true)
            local old_ability = copy_table(card.ability)
            local old_center = card.config.center
            local old_center_key = card.config.center_key
            for k, _ in pairs(extra_enhancements) do
                if G.P_CENTERS[k] then
                    card:set_ability(G.P_CENTERS[k])
                    card.ability.extra_enhancement = k
                    effects[#effects+1] = eval_card(card, context)
                end
            end
            card.ability = old_ability
            card.config.center = old_center
            card.config.center_key = old_center_key
            card:set_sprites(old_center) 

            context.playing_card_end_of_round = nil
            context.individual = true
            context.other_card = card
            -- context.end_of_round individual calculations
            for _, area in ipairs(SMODS.get_card_areas('jokers')) do
                for _, _card in ipairs(area.cards) do
                    
                    local eval, post = eval_card(_card, context)
                    eval.juice_card = eval.card
                    if next(eval) then 
                        table.insert(effects, eval)
                    end
                    for _, v in ipairs(post) do effects[#effects+1] = v end
                end
            end

            local deck_effect = G.GAME.selected_back:trigger_effect(context)
            if deck_effect then SMODS.calculate_effect(deck_effect, G.deck.cards[1] or G.deck) end
            SMODS.trigger_effects(effects, card)

            context.individual = nil
            context.repetition = true
            context.card_effects = effects
            if reps[j] == 1 then 
                SMODS.calculate_repetitions(card, context, reps)
            end
            
            context.repetition = nil
            context.card_effects = nil
            j = j + (effects.calculated and 1 or #reps)
            
            -- TARGET: effects after end of round evaluation
        end
    end
end

function SMODS.calculate_destroying_cards(context, cards_destroyed, scoring_hand)
    for i,card in ipairs(scoring_hand or context.cardarea.cards) do
        local destroyed = nil
        --un-highlight all cards
        if scoring_hand then highlight_card(card,(i-0.999)/(#scoring_hand-0.998),'down') end

        -- context.destroying_card calculations
        context.destroy_card = card
        context.destroying_card = scoring_hand and card
        for _, area in ipairs(SMODS.get_card_areas('jokers')) do
            local should_break
            for _, _card in ipairs(area.cards) do
                local eval, post = eval_card(_card, context)
                local self_destroy = false
                for key, effect in pairs(eval) do
                    if type(effect) == 'table' then
                        self_destroy = SMODS.calculate_effect(effect, card)
                    else
                        self_destroy = effect
                    end
                end
                SMODS.trigger_effects({post}, card)
                if self_destroy then 
                    destroyed = true
                    should_break = true
                    break
                end
            end
            if should_break then break end
        end
        
        if scoring_hand and SMODS.has_enhancement(card, 'm_glass') and not card.debuff and pseudorandom('glass') < G.GAME.probabilities.normal/(card.ability.name == 'Glass Card' and card.ability.extra or G.P_CENTERS.m_glass.config.extra) then
            destroyed = true
        end
        
        local eval, post = eval_card(card, context)
        local self_destroy = false
        for key, effect in pairs(eval) do
            self_destroy = SMODS.calculate_effect(effect, card)
        end
        SMODS.trigger_effects({post}, card)
        if self_destroy then destroyed = true end
        
        local deck_effect = G.GAME.selected_back:trigger_effect(context)
        if deck_effect then
            self_destroy = SMODS.calculate_effect(deck_effect, G.deck.cards[1] or G.deck)
            if self_destroy then destroyed = true end
        end

        -- TARGET: card destroyed

        if destroyed then 
            if SMODS.shatters(card) then
                card.shattered = true
            else 
                card.destroyed = true
            end 
            cards_destroyed[#cards_destroyed+1] = card
        end
    end
end

function SMODS.get_card_areas(_type, _context)
    if _type == 'playing_cards' then
        local t = {}
        if _context ~= 'end_of_round' then t[#t+1] = G.play end
        if _context ~= 'end_of_round' and SMODS.optional_features.cardareas.unscored then t[#t+1] = 'unscored' end
        t[#t+1] = G.hand
        if SMODS.optional_features.cardareas.deck then t[#t+1] = G.deck end
        if SMODS.optional_features.cardareas.discard then t[#t+1] = G.discard end
        -- TARGET: add your own CardAreas for playing card evaluation
        return t
    end
    if _type == 'jokers' then
        local t = {G.jokers, G.consumeables, G.vouchers}
        -- TARGET: add your own CardAreas for joker evaluation
        return t
    end
    return {}
end

local flat_copy_table = function(tbl)
    local new = {}
    for i, v in pairs(tbl) do
        new[i] = v
    end
    return new
end

---Seatch for val anywhere deep in tbl. Return a table of finds, or the first found if args.immediate is provided.
SMODS.deepfind = function(tbl, val, mode, immediate)
    --backwards compat (remove later probably)
    if mode == true then
        mode = "v"
        immediate = true
    end
    if mode == "index" then
        mode = "i"
    elseif mode == "value" then
        mode = "v"
    elseif mode ~= "v" and mode ~= "i" then
        mode = "v"
    end
    local seen = {[tbl] = true}
    local collector = {}
    local stack = { {tbl = tbl, path = {}, objpath = {}} }

    --while there are any elements to traverse
    while #stack > 0 do
        --pull the top off of the stack and start traversing it (by default this will be the last element of the last traversed table found in pairs)
        local current = table.remove(stack)
        --the current table we wish to traverse
        local currentTbl = current.tbl
        --the current path
        local currentPath = current.path
        --the current object path
        local currentObjPath = current.objpath

        --for every table that we have
        for i, v in pairs(currentTbl) do
            --if the value matches
            if (mode == "v" and v == val) or (mode == "i") and i == val then
                --copy our values and store it in the collector
                local newPath = flat_copy_table(currentPath)
                local newObjPath = flat_copy_table(currentObjPath)
                table.insert(newPath, i)
                table.insert(newObjPath, v)
                table.insert(collector, {table = currentTbl, index = i, tree = newPath, objtree = newObjPath})
                if immediate then
                    return collector
                end
                --otherwise, if its a traversable table we havent seen yet
            elseif type(v) == "table" and not seen[v] then
                --make sure we dont see it again
                seen[v] = true
                --and then place it on the top of the stack
                local newPath = flat_copy_table(currentPath)
                local newObjPath = flat_copy_table(currentObjPath)
                table.insert(newPath, i)
                table.insert(newObjPath, v)
                table.insert(stack, {tbl = v, path = newPath, objpath = newObjPath})
            end
        end
    end

    return collector
end

---@deprecated
---backwards compat (remove later probably)
SMODS.deepfindbyindex = function(tbl, val, immediate)
    return SMODS.deepfind(tbl, val, "i", immediate)
end

-- this is for debugging
SMODS.debug_calculation = function()
    G.contexts = {}
    local cj = Card.calculate_joker
    function Card:calculate_joker(context)
        for k,v in pairs(context) do G.contexts[k] = (G.contexts[k] or 0) + 1 end
        return cj(self, context)
    end
end

local function insert(t, res)
    for k,v in pairs(res) do
        if type(v) == 'table' and type(t[k]) == 'table' then
            insert(t[k], v)
        else
            t[k] = v
        end
    end
end
SMODS.optional_features = {
    cardareas = {},
}
SMODS.get_optional_features = function()
    for _,mod in ipairs(SMODS.mod_list) do
        if mod.can_load and mod.optional_features then
            local opt_features = type(mod.optional_features) == 'function' and mod.optional_features() or mod.optional_features
            if type(opt_features) == 'table' then
                insert(SMODS.optional_features, opt_features)
            end
        end
    end
end

G.FUNCS.can_select_from_booster = function(e)
    local area = booster_obj and e.config.ref_table:selectable_from_pack(booster_obj)
    if area and #G[area].cards < G[area].config.card_limit then 
        e.config.colour = G.C.GREEN
        e.config.button = 'use_card'
    else
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
    end
  end

function Card.selectable_from_pack(card, pack)
    if pack.select_exclusions then
        for _, key in ipairs(pack.select_exclusions) do
            if key == card.config.center_key then return false end
        end
    end
    if pack.select_card then
        if type(pack.select_card) == 'table' then
            if pack.select_card[card.ability.set] then return pack.select_card[card.ability.set] else return false end
        end
        return pack.select_card
    end
end

-- Shop functionality
function SMODS.size_of_pool(pool)
    local size = 0
    for _, v in pairs(pool) do
        if v ~= 'UNAVAILABLE' then size = size + 1 end
    end
    return size
end

function SMODS.get_next_vouchers(vouchers)
    vouchers = vouchers or {spawn = {}}
    local _pool, _pool_key = get_current_pool('Voucher')
    for i=#vouchers+1, math.min(SMODS.size_of_pool(_pool), G.GAME.starting_params.vouchers_in_shop + (G.GAME.modifiers.extra_vouchers or 0)) do
        local center = pseudorandom_element(_pool, pseudoseed(_pool_key))
        local it = 1
        while center == 'UNAVAILABLE' or vouchers.spawn[center] do
            it = it + 1
            center = pseudorandom_element(_pool, pseudoseed(_pool_key..'_resample'..it))
        end

        vouchers[#vouchers+1] = center
        vouchers.spawn[center] = true
    end
    return vouchers
end

function SMODS.add_voucher_to_shop(key)
    if key then assert(G.P_CENTERS[key], "Invalid voucher key: "..key) else 
        key = get_next_voucher_key() 
        G.GAME.current_round.voucher.spawn[key] = true
        G.GAME.current_round.voucher[#G.GAME.current_round.voucher + 1] = key
    end
    local card = Card(G.shop_vouchers.T.x + G.shop_vouchers.T.w/2,
        G.shop_vouchers.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS[key],{bypass_discovery_center = true, bypass_discovery_ui = true})
        card.shop_voucher = true
        create_shop_card_ui(card, 'Voucher', G.shop_vouchers)
        card:start_materialize()
        G.shop_vouchers:emplace(card)
        G.shop_vouchers.config.card_limit = #G.shop_vouchers.cards
        return card
end

function SMODS.change_voucher_limit(mod)
    G.GAME.modifiers.extra_vouchers = (G.GAME.modifiers.extra_vouchers or 0) + mod
    if mod > 0 and G.STATE == G.STATES.SHOP then
        for i=1, mod do
            SMODS.add_voucher_to_shop()
        end
    end
end

function SMODS.add_booster_to_shop(key)
    if key then assert(G.P_CENTERS[key], "Invalid booster key: "..key) else key = get_pack('shop_pack').key end
    local card = Card(G.shop_booster.T.x + G.shop_booster.T.w/2,
    G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[key], {bypass_discovery_center = true, bypass_discovery_ui = true})
    create_shop_card_ui(card, 'Booster', G.shop_booster)
    card.ability.booster_pos = #G.shop_booster.cards + 1
    card:start_materialize()
    G.shop_booster:emplace(card)
    return card
end

function SMODS.change_booster_limit(mod)
    G.GAME.modifiers.extra_boosters = (G.GAME.modifiers.extra_boosters or 0) + mod
    if mod > 0 and G.STATE == G.STATES.SHOP then
        for i = 1, mod do
            SMODS.add_booster_to_shop()
        end
    end
end

function SMODS.change_free_rerolls(mod)
    G.GAME.round_resets.free_rerolls = G.GAME.round_resets.free_rerolls + mod
    G.GAME.current_round.free_rerolls = math.max(G.GAME.current_round.free_rerolls + mod, 0)
    calculate_reroll_cost(true)
end
