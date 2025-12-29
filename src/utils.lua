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
    assert(not o._discovered_unlocked_overwritten, ("Internal: discovery/unlocked of object \"%s\" should not be overwritten at this stage."):format(o and o.key or "UNKNOWN"))
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
    assert(pool, ("Attempted to insert object \"%s\" into an empty pool."):format(center.key or "UNKNOWN"))
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
    assert(pool, ("Attempted to remove object \"%s\" from an empty pool."):format(key or "UNKNOWN"))
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
function SMODS.change_base(card, suit, rank, manual_sprites)
    if not card then return nil, "SMODS.change_base called with no card" end
    local _suit = SMODS.Suits[suit or card.base.suit]
    local _rank = SMODS.Ranks[rank or card.base.value]
    if not _suit or not _rank then
        return nil, ('Tried to call SMODS.change_base with invalid arguments: suit="%s", rank="%s"'):format(suit, rank)
    end
    card:set_base(G.P_CARDS[('%s_%s'):format(_suit.card_key, _rank.card_key)], nil, manual_sprites)
    return card
end

-- Modify a card's rank by the specified amount.
-- Increase rank if amount is positive, decrease rank if negative.
function SMODS.modify_rank(card, amount, manual_sprites)
    local rank_key = card.base.value
    local rank_data = SMODS.Ranks[card.base.value]
    if amount > 0 then
        for _ = 1, amount do
            local behavior = rank_data.strength_effect or { fixed = 1, ignore = false, random = false }
            if behavior.ignore or not next(rank_data.next) then
                break
            elseif behavior.random then
                rank_key = pseudorandom_element(
                    rank_data.next,
                    pseudoseed('strength'),
                    { in_pool = function(key) return SMODS.add_to_pool(SMODS.Ranks[key], { suit = card.base.suit }) end }
                )
            else
                local i = (behavior.fixed and rank_data.next[behavior.fixed]) and behavior.fixed or 1
                rank_key = rank_data.next[i]
            end
            rank_data = SMODS.Ranks[rank_key]
        end
    else
        for _ = 1, -amount do
            local behavior = rank_data.prev_behavior or { fixed = 1, ignore = false, random = false }
            if not next(rank_data.prev) or behavior.ignore then
                break
            elseif behavior.random then
                rank_key = pseudorandom_element(
                    rank_data.prev,
                    pseudoseed('weakness'),
                    { in_pool = function(key) return SMODS.add_to_pool(SMODS.Ranks[key], { suit = card.base.suit }) end }
                )
            else
                local i = (behavior.fixed and rank_data.prev[behavior.fixed]) and behavior.fixed or 1
                rank_key = rank_data.prev[i]
            end
            rank_data = SMODS.Ranks[rank_key]
        end
    end
    
    return SMODS.change_base(card, nil, rank_key, manual_sprites)
end

-- Return an array of all (non-debuffed) jokers or consumables with key `key`.
-- Debuffed jokers count if `count_debuffed` is true.
-- This function replaces find_joker(); please use SMODS.find_card() instead
-- to avoid name conflicts with other mods.
function SMODS.find_card(key, count_debuffed)
    local results = {}
    if not G.jokers or not G.jokers.cards then return {} end
    for _, area in ipairs(SMODS.get_card_areas('jokers')) do
        if area.cards then
            for _, v in pairs(area.cards) do
                if v and type(v) == 'table' and v.config.center.key == key and (count_debuffed or not v.debuff) then
                    table.insert(results, v)
                end
            end
        end
    end
    return results
end

function SMODS.create_card(t)
    if not t.area and t.key and G.P_CENTERS[t.key] then
        t.area = G.P_CENTERS[t.key].consumeable and G.consumeables or G.P_CENTERS[t.key].set == 'Joker' and G.jokers
    end
    if not t.area and not t.key and t.set and SMODS.ConsumableTypes[t.set] or t.set == 'Consumeables' then
        t.area = G.consumeables
    end
    if not t.key and t.set == 'Playing Card' or t.set == 'Base' or t.set == 'Enhanced' or (not t.set and (t.front or t.rank or t.suit)) then
        t.set = t.set == 'Playing Card' and (t.enhancement and 'Base' or (pseudorandom('front' .. (t.key_append or '') .. G.GAME.round_resets.ante) > (t.enhanced_poll or 0.6) and 'Enhanced' or 'Base')) or t.set or 'Base'
        t.area = t.area or G.hand
        if not t.front and (t.suit or t.rank) then
            t.suit = t.suit and (SMODS.Suits["".. t.suit] or {}).card_key or t.suit or
            pseudorandom_element(SMODS.Suits, pseudoseed('front' .. (t.key_append or '') .. G.GAME.round_resets.ante)).card_key
            t.rank = t.rank and (SMODS.Ranks["".. t.rank] or {}).card_key or t.rank or
            pseudorandom_element(SMODS.Ranks, pseudoseed('front' .. (t.key_append or '') .. G.GAME.round_resets.ante)).card_key
        end
        t.front = t.front or (t.suit and t.rank and (t.suit .. "_" .. t.rank)) or nil
    end
    SMODS.bypass_create_card_edition = t.no_edition or t.edition
    SMODS.bypass_create_card_discover = t.discover
    SMODS.bypass_create_card_discovery_center = t.bypass_discovery_center
    SMODS.set_create_card_front = G.P_CARDS[t.front]
    SMODS.create_card_allow_duplicates = t.allow_duplicates
    local _card = create_card(t.set, t.area, t.legendary, t.rarity, t.skip_materialize, t.soulable, t.key, t.key_append)
    SMODS.bypass_create_card_edition = nil
    SMODS.bypass_create_card_discover = nil
    SMODS.bypass_create_card_discovery_center = nil
    SMODS.set_create_card_front = nil
    SMODS.create_card_allow_duplicates = nil

    -- Should this be restricted to only cards able to handle these
    -- or should that be left to the person calling SMODS.create_card to use it correctly?
    if t.edition then _card:set_edition(t.edition) end
    if t.enhancement then _card:set_ability(G.P_CENTERS[t.enhancement]) end
    if t.seal then _card:set_seal(t.seal); _card.ability.delay_seal = false end
    if t.stickers then
        for i, v in ipairs(t.stickers) do
            _card:add_sticker(v, t.force_stickers)
        end
    end

    return _card
end

function SMODS.add_card(t)
    local card = SMODS.create_card(t)
    if t.set == "Base" or t.set == "Enhanced" then
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        card.playing_card = G.playing_card
        table.insert(G.playing_cards, card)
    end
    card:add_to_deck()
    local area = t.area or G.jokers
    area:emplace(card)
    return card
end

function SMODS.debuff_card(card, debuff, source)
    debuff = debuff or nil
    source = source and tostring(source) or nil
    if debuff == 'reset' then
        sendWarnMessage("SMODS.debuff_card(card, 'reset', source) is deprecated")
        card.ability.debuff_sources = {};
        return
    end
    card.ability.debuff_sources = card.ability.debuff_sources or {}
    card.ability.debuff_sources[source] = debuff
    SMODS.recalc_debuff(card)
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
        os.execute('sh "/Users/$USER/Library/Application Support/Steam/steamapps/common/Balatro/run_lovely_macos.sh" &')
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
                local m = assert(SMODS.find_mod(v)[1], ("Could not find mod \"%s\"."):format(v))
                if not badges.mod_set[m.id] then
                    table.insert(mods, m)
                    badges.mod_set[m.id] = true
                end
            end
        end
        for i, mod in ipairs(mods) do
            local mod_name = mod.display_name
            local size = 0.9
            local font = G.LANG.font
            local max_text_width = 2 - 2*0.05 - 4*0.03*size - 2*0.03
            local calced_text_width = 0
            -- Math reproduced from DynaText:update_text
            for _, c in utf8.chars(mod_name) do
                local tx = font.FONT:getWidth(c)*(0.33*size)*G.TILESCALE*font.FONTSCALE + 2.7*1*G.TILESCALE*font.FONTSCALE
                calced_text_width = calced_text_width + tx/(G.TILESIZE*G.TILESCALE)
            end
            local scale_fac = 1
                -- calced_text_width > max_text_width and max_text_width/calced_text_width
                -- or 1
            badges[#badges + 1] = {n=G.UIT.R, config={align = "cm"}, nodes={
                {n=G.UIT.R, config={align = "cm", colour = mod.badge_colour or G.C.GREEN, r = 0.1, minw = 2, minh = 0.36, emboss = 0.05, padding = 0.03*size}, nodes={
                  {n=G.UIT.B, config={h=0.1,w=0.03}},
                  {n=G.UIT.O, config={object = DynaText({string = mod_name or 'ERROR', colours = {mod.badge_text_colour or G.C.WHITE},float = true, shadow = true, offset_y = -0.05, silent = true, spacing = 1*scale_fac, scale = 0.33*size*scale_fac, marquee = calced_text_width > max_text_width and not mod.no_marquee, maxw = max_text_width})}},
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

function SMODS.shallow_copy(t)
    local copy = {}
    for k, v in next, t, nil do
        copy[k] = v
    end
    setmetatable(copy, getmetatable(t))
    return copy
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
        assert(type(li) == 'table', ("\"%s\" is not a table."):format(tostring(li)))
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

function SMODS.poll_edition(args)
    args = args or {}
    return poll_edition(args.key or 'editiongeneric', args.mod, args.no_negative, args.guaranteed, args.options)
end

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
                assert(G.P_SEALS[v], ("Could not find seal \"%s\"."):format(v))
                seal_option = { key = v, weight = G.P_SEALS[v].weight or 5 } -- default weight set to 5 to replicate base game weighting
            elseif type(v) == 'table' then
                assert(G.P_SEALS[v.key], ("Could not find seal \"%s\"."):format(v.key))
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

	-- Check to see if any rarities are empty and should be disabled
    for _, v in ipairs(available_rarities) do
        local _pool = get_current_pool("Joker", v.key, false, nil)
        if #_pool == 1 and _pool[1] == "empty_rarity" then
            SMODS.remove_pool(available_rarities, v.key)
        end
    end
    G.ARGS.TEMP_POOL = EMPTY(G.ARGS.TEMP_POOL)

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
                assert(G.P_CENTERS[v], ("Could not find enhancement \"%s\"."):format(v))
                enhance_option = { key = v, weight = G.P_CENTERS[v].weight or 5 } -- default weight set to 5 to replicate base game weighting
            elseif type(v) == 'table' then
                assert(G.P_CENTERS[v.key], ("Could not find enhancement \"%s\"."):format(v.key))
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
        SMODS.enh_cache:write(self, nil)
    end
end

function Card:remove_sticker(sticker)
    if self.ability[sticker] then
        SMODS.Stickers[sticker]:apply(self, false)
        SMODS.enh_cache:write(self, nil)
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

function Card:can_calculate(ignore_debuff, ignore_sliced)
    local is_available = (not self.debuff or ignore_debuff) and (not self.getting_sliced or ignore_sliced)
    -- TARGET : Add extra conditions here
    return is_available
end

function Card:calculate_enhancement(context)
    if self.ability.set ~= 'Enhanced' then return nil end
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
    if not SMODS.enh_cache:read(card, extra_only) then

        local enhancements = {}
        if card.config.center.key ~= "c_base" then
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
        SMODS.enh_cache:write(card, enhancements)
    end
    return SMODS.enh_cache:read(card, extra_only)
end

SMODS.enh_cache = {
    write = function(self, key, value)
        self.data[key] = value
    end,
    read = function(self, key, extra_only)
        if not self.data[key] then return end
        local ret = copy_table(self.data[key])
        if extra_only then ret[key.config.center.key] = nil end
        return ret
    end,
    clear = function(self)
        self.data = setmetatable({}, { __mode = 'k' })
    end,
}
SMODS.enh_cache:clear()

function SMODS.has_enhancement(card, key)
    if card.config.center.key == key then return true end
    local enhancements = SMODS.get_enhancements(card)
    if enhancements[key] then return true end
    return false
end

function SMODS.shatters(card)
    local enhancements = SMODS.get_enhancements(card)
    for key, _ in pairs(enhancements) do
        if G.P_CENTERS[key].shatters or key == 'm_glass' then return true end
    end
end

function SMODS.calculate_quantum_enhancements(card, effects, context)
    if not SMODS.optional_features.quantum_enhancements then return end
    if context.extra_enhancement or context.check_enhancement or SMODS.extra_enhancement_calc_in_progress then return end
    context.extra_enhancement = true
    SMODS.extra_enhancement_calc_in_progress = true
    local extra_enhancements = SMODS.get_enhancements(card, true)
    local old_ability = copy_table(card.ability)
    local old_center = card.config.center
    local old_center_key = card.config.center_key
    -- Note: For now, just trigger extra enhancements in order.
    -- Future work: combine enhancements during 
    -- playing card scoring (ex. Mult comes before Glass because +_mult
    -- naturally comes before x_mult)
    local extra_enhancements_list = {}
    for k, _ in pairs(extra_enhancements) do
        if G.P_CENTERS[k] then
            table.insert(extra_enhancements_list, k)
        end
    end
    table.sort(extra_enhancements_list, function(a, b) return G.P_CENTERS[a].order < G.P_CENTERS[b].order end)
    for _, k in ipairs(extra_enhancements_list) do
        card:set_ability(G.P_CENTERS[k], nil, 'quantum')
        card.ability.extra_enhancement = k
        local eval = eval_card(card, context)
        table.insert(effects, eval)
    end
    card.ability = old_ability
    card.config.center = old_center
    card.config.center_key = old_center_key
    context.extra_enhancement = nil
    SMODS.extra_enhancement_calc_in_progress = nil
end

function SMODS.has_no_suit(card)
    local is_stone = false
    local is_wild = false
    for k, _ in pairs(SMODS.get_enhancements(card)) do
        if k == 'm_stone' or G.P_CENTERS[k].no_suit then is_stone = true end
        if k == 'm_wild' or G.P_CENTERS[k].any_suit then is_wild = true end
    end
    return is_stone and not is_wild
end
function SMODS.has_any_suit(card)
    for k, _ in pairs(SMODS.get_enhancements(card)) do
        if k == 'm_wild' or G.P_CENTERS[k].any_suit then return true end
    end
end
function SMODS.has_no_rank(card)
    for k, _ in pairs(SMODS.get_enhancements(card)) do
        if k == 'm_stone' or G.P_CENTERS[k].no_rank then return true end
    end
end
function SMODS.always_scores(card)
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
        sendWarnMessage("scaleFactor must be a positive number", "Utils")
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

            card.no_ui = true

            G.cdds_cards:emplace(card)
        end
    end
    G.cdds_cards.config.card_limit = bufferCardLimitForSmallDS(cards, 2.5)

    for i, _card in ipairs(G.cdds_cards.cards) do
        if deckskin.generate_ds_card_ui and type(deckskin.generate_ds_card_ui) == 'function' and deckskin.has_ds_card_ui and type(deckskin.has_ds_card_ui) == 'function' then
            _card.no_ui = not deckskin.has_ds_card_ui(_card, deckskin, palette)
            if not _card.no_ui then
                _card.generate_ds_card_ui = deckskin.generate_ds_card_ui
                _card.deckskin = deckskin
                _card.palette = palette
            end
        else
            _card.no_ui = true
        end
    end
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

SMODS.smart_level_up_hand = function(card, hand, instant, amount)
    -- Cases:
    -- Level ups in context.before on the played hand
    --     -> direct level_up_hand(), keep displaying
    -- Level ups in context.before on another hand AND any level up during scoring
    --     -> restore the current chips/mult
    -- Level ups outside anything -> always update to empty chips/mult
    level_up_hand(card, hand, instant, (type(amount) == 'number' or type(amount) == 'table') and amount or 1)
end

-- This function handles the calculation of each effect returned to evaluate play.
-- Can easily be hooked to add more calculation effects ala Talisman
SMODS.calculate_individual_effect = function(effect, scored_card, key, amount, from_edition)
    if SMODS.Scoring_Parameter_Calculation[key] then
        return SMODS.Scoring_Parameters[SMODS.Scoring_Parameter_Calculation[key]]:calc_effect(effect, scored_card, key, amount, from_edition)
    end

    if (key == 'p_dollars' or key == 'dollars' or key == 'h_dollars') and amount then
        if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
        SMODS.ease_dollars_calc = true
        ease_dollars(amount)    
        SMODS.ease_dollars_calc = nil
        if not effect.remove_default_message then
            if effect.dollar_message then
                card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, effect.dollar_message)
            else
                card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'dollars', amount, percent)
            end
        end
        SMODS.calculate_context({
            money_altered = true,
            amount = amount,
            from_shop = (G.STATE == G.STATES.SHOP or G.STATE == G.STATES.SMODS_BOOSTER_OPENED or G.STATE == G.STATES.SMODS_REDEEM_VOUCHER) or nil,
            from_consumeable = (G.STATE == G.STATES.PLAY_TAROT) or nil,
            from_scoring = (G.STATE == G.STATES.HAND_PLAYED) or nil,
        })
        return true
    end

    if key == 'message' and not SMODS.no_resolve then
        if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
        if effect.retrigger_juice then juice_card(effect.retrigger_juice) end
        card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, effect)
        return true
    end

    if key == 'func' then
        effect.func()
        return true
    end

    if key == 'swap' then
        if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
        local old_mult = mult
        mult = mod_mult(hand_chips)
        hand_chips = mod_chips(old_mult)
        update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
        juice_card(scored_card)
        return true
    end

    if key == 'balance' then
        if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
        local total = mult + hand_chips
        mult = mod_mult(total/2)
        hand_chips = mod_chips(total/2)
        update_hand_text({delay = 0}, {chips = hand_chips, mult = mult})
        G.E_MANAGER:add_event(Event({
            func = (function()
                -- scored_card:juice_up()
                play_sound('gong', 0.94, 0.3)
                play_sound('gong', 0.94*1.5, 0.2)
                play_sound('tarot1', 1.5)
                ease_colour(G.C.UI_CHIPS, {0.8, 0.45, 0.85, 1})
                ease_colour(G.C.UI_MULT, {0.8, 0.45, 0.85, 1})
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    blockable = false,
                    blocking = false,
                    delay =  0.8,
                    func = (function() 
                            ease_colour(G.C.UI_CHIPS, G.C.BLUE, 0.8)
                            ease_colour(G.C.UI_MULT, G.C.RED, 0.8)
                        return true
                    end)
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    blockable = false,
                    blocking = false,
                    no_delete = true,
                    delay =  1.3,
                    func = (function() 
                        G.C.UI_CHIPS[1], G.C.UI_CHIPS[2], G.C.UI_CHIPS[3], G.C.UI_CHIPS[4] = G.C.BLUE[1], G.C.BLUE[2], G.C.BLUE[3], G.C.BLUE[4]
                        G.C.UI_MULT[1], G.C.UI_MULT[2], G.C.UI_MULT[3], G.C.UI_MULT[4] = G.C.RED[1], G.C.RED[2], G.C.RED[3], G.C.RED[4]
                        return true
                    end)
                }))
                return true
            end)
        }))
        if not effect.remove_default_message then
            if effect.balance_message then
                card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, effect.balance_message)
            else
                card_eval_status_text(effect.message_card or effect.juice_card or scored_card or effect.card or effect.focus, 'extra', nil, percent, nil, {message = localize('k_balanced'), colour =  {0.8, 0.45, 0.85, 1}})
            end
        end
        delay(0.6)

        return true
    end

    if key == 'level_up' then
        if effect.card and effect.card ~= scored_card then juice_card(effect.card) end
        local hand_type = effect.level_up_hand or G.GAME.last_hand_played
        SMODS.smart_level_up_hand(scored_card, hand_type, effect.instant, amount)
        return true
    end

    if key == 'extra' then
        return SMODS.calculate_effect(amount, scored_card)
    end

    if key == 'saved' then
        SMODS.saved = amount
        G.GAME.saved_text = amount
        return key
    end

    if key == 'effect' then
        return true
    end
    
    if key == 'prevent_debuff' or key == 'add_to_hand' or key == 'remove_from_hand' or key == 'stay_flipped' or key == 'prevent_stay_flipped' or key == 'prevent_trigger' then
        return key
    end

    if key == 'remove' or key == 'debuff_text' or key == 'cards_to_draw' or key == 'numerator' or key == 'denominator' or key == 'no_destroy' or
        key == 'replace_scoring_name' or key == 'replace_display_name' or key == 'replace_poker_hands' or key == 'modify' or key == 'shop_create_flags'  then
        return { [key] = amount }
    end
    
    if key == 'debuff' then
        return { [key] = amount, debuff_source = scored_card }
    end

end

-- Used to calculate a table of effects generated in evaluate_play
SMODS.trigger_effects = function(effects, card)
    local ret = {}
    for _, effect_table in ipairs(effects) do
        -- note: these sections happen to be mutually exclusive:
        -- Playing cards in scoring
        for _, key in ipairs({'playing_card', 'enhancement', 'edition', 'seals'}) do
            SMODS.calculate_effect_table_key(effect_table, key, card, ret)
        end
        for _, k in ipairs(SMODS.Sticker.obj_buffer) do
            local v = SMODS.Stickers[k]
            SMODS.calculate_effect_table_key(effect_table, v, card, ret)
        end
        -- Playing cards at end of round
        SMODS.calculate_effect_table_key(effect_table, 'end_of_round', card, ret)
        -- Jokers
        for _, key in ipairs({'jokers', 'retriggers'}) do
            SMODS.calculate_effect_table_key(effect_table, key, card, ret)
        end
        SMODS.calculate_effect_table_key(effect_table, 'individual', card, ret)
        -- todo: might want to move these keys to a customizable list/lists
    end

    if SMODS.post_prob and next(SMODS.post_prob) then
        local prob_tables = SMODS.post_prob
        SMODS.post_prob = {}
        for i, v in ipairs(prob_tables) do
            v.pseudorandom_result = true
            SMODS.calculate_context(v)
        end
    end

    return ret
end

-- Calculate one key of an effect table returned from eval_card.
SMODS.calculate_effect_table_key = function(effect_table, key, card, ret)
    local effect = effect_table[key]
    if key ~= 'smods' and type(effect) == 'table' then
        local calc = SMODS.calculate_effect(effect, effect.scored_card or card, key == 'edition')
        for k, v in pairs(calc) do ret[k] = type(ret[k]) == 'number' and ret[k] + v or v end
    end
end

SMODS.calculate_effect = function(effect, scored_card, from_edition, pre_jokers)
    local ret = {}
    for _, key in ipairs(SMODS.calculation_keys) do
        if effect[key] then
            if effect.juice_card and not SMODS.no_resolve then
                G.E_MANAGER:add_event(Event({trigger = 'immediate', func = function ()
                    effect.juice_card:juice_up(0.1)
                    if (not effect.message_card) or (effect.message_card and effect.message_card ~= scored_card) then
                        scored_card:juice_up(0.1)
                    end
                    return true end}))
            end
            local calc = SMODS.calculate_individual_effect(effect, scored_card, key, effect[key], from_edition)
            if calc == true then ret.calculated = true end
            if type(calc) == 'string' then
                ret[calc] = true
            elseif type(calc) == 'table' then
                for k,v in pairs(calc) do ret[k] = v end
            end
            if not SMODS.silent_calculation[key] then
                percent = (percent or 0) + (percent_delta or 0.08)
            end
        end
    end
    return ret
end

SMODS.calculation_keys = {}
SMODS.scoring_parameter_keys = {
    'chips', 'h_chips', 'chip_mod',
    'mult', 'h_mult', 'mult_mod',
    'x_chips', 'xchips', 'Xchip_mod',
    'x_mult', 'Xmult', 'xmult', 'x_mult_mod', 'Xmult_mod',
}
SMODS.other_calculation_keys = {
    'p_dollars', 'dollars', 'h_dollars',
    'swap', 'balance',
    'saved', 'effect', 'remove',
    'debuff', 'prevent_debuff', 'debuff_text',
    'add_to_hand', 'remove_from_hand',
    'stay_flipped', 'prevent_stay_flipped',
    'cards_to_draw',
    'message',
    'level_up', 'func',
    'numerator', 'denominator',
    'modify',
    'no_destroy', 'prevent_trigger',
    'replace_scoring_name', 'replace_display_name', 'replace_poker_hands',
    'shop_create_flags',
    'extra',
}
SMODS.silent_calculation = {
    saved = true, effect = true, remove = true,
    debuff = true, prevent_debuff = true, debuff_text = true,
    add_to_hand = true, remove_from_hand = true,
    stay_flipped = true, prevent_stay_flipped = true,
    cards_to_draw = true,
    func = true, extra = true,
    numerator = true, denominator = true,
    no_destroy = true
}

SMODS.insert_repetitions = function(ret, eval, effect_card, _type)
    repeat
        eval.repetitions = eval.repetitions or 0
        if eval.repetitions <= 0 then
            sendWarnMessage('Found effect table with no assigned repetitions during repetition check')
        end
        local effect = {}
        for k,v in pairs(eval) do
            if k ~= 'extra' then effect[k] = v end
        end
        if _type == 'joker_retrigger' then
            effect.retrigger_card = effect_card
            effect.message_card = effect.message_card or effect_card
            effect.retrigger_flag = true
        elseif _type == 'individual_retrigger' then
            effect.retrigger_card = effect_card.object
            effect.message_card = effect.message_card or effect_card.scored_card
        elseif not _type then
            effect.card = effect.card or effect_card
        end
        effect.message = effect.message or (not effect.remove_default_message and localize('k_again_ex'))
        for h=1, effect.repetitions do
            table.insert(ret, _type == "joker_retrigger" and effect or { retriggers = effect})
        end
        eval = eval.extra
    until not eval
end

SMODS.calculate_repetitions = function(card, context, reps)
    -- From the card
    context.repetition_only = true
    local eval = eval_card(card, context)
    for _, value in pairs(eval) do
        SMODS.insert_repetitions(reps, value, card)
    end
    -- Quantum enhancement support :cat_owl:
    local quantum_eval = {}
    SMODS.calculate_quantum_enhancements(card, quantum_eval, context)
    for _, eval in ipairs(quantum_eval) do
        for _, value in pairs(eval) do
            SMODS.insert_repetitions(reps, value, card)
        end
    end
    context.repetition_only = nil
    --From jokers
    for _, area in ipairs(SMODS.get_card_areas('jokers')) do
        for _, _card in ipairs(area.cards) do
            --calculate the joker effects
            local eval, post = eval_card(_card, context)
            local first = true
            for key, value in pairs(eval) do
                if key ~= 'retriggers' then
                    local curr_size = #reps
                    SMODS.insert_repetitions(reps, value, _card)
                    -- After each inserted repetition we insert the post effects
                    local new_size = #reps
                    for i = curr_size + 1, new_size do
                        if not first then 
                            post = {}
                            if not context.post_trigger and SMODS.optional_features.post_trigger then
                                SMODS.calculate_context({blueprint_card = context.blueprint_card, post_trigger = true, other_card = _card, other_context = context, other_ret = eval}, post)
                            end
                        end
                        first = nil
                        if next(post) then 
                            reps[#reps - new_size + i].retriggers.retrigger_flag = true
                        else break end
                        -- index from behind since that doesn't change
                        for idx, eff in ipairs(post) do
                            if next(eff) then
                                select(2, next(eff)).retrigger_flag = true          
                                table.insert(reps, #reps + 1 - new_size + i, eff)
                            end
                        end
                        select(2, next(reps[#reps - new_size + i])).retrigger_flag = false
                    end
                end
            end
            if eval.retriggers then
                context.retrigger_joker = true
                for rt = 1, #eval.retriggers do
                    context.retrigger_joker = eval.retriggers[rt].retrigger_card
                    local rt_eval, rt_post = eval_card(_card, context)
                    if next(rt_eval) then
                        SMODS.insert_repetitions(reps, eval.retriggers[rt], eval.retriggers[rt].message_card or _card)
                        if next(rt_post) then SMODS.trigger_effects({rt_post}, card) end
                        for key, value in pairs(rt_eval) do
                            if key ~= 'retriggers' then
                                SMODS.insert_repetitions(reps, value, _card)
                            end
                        end
                    end
                end
                context.retrigger_joker = nil
            end
        end
    end
    for _, area in ipairs(SMODS.get_card_areas('individual')) do
        local eval, post = SMODS.eval_individual(area, context)
        if next(post) then SMODS.trigger_effects({post}, card) end
        for key, value in pairs(eval) do
            if key ~= 'retriggers' then
                SMODS.insert_repetitions(reps, value, area.scored_card)
            end
        end
        if eval.retriggers then
            context.retrigger_joker = true
            for rt = 1, #eval.retriggers do
                context.retrigger_joker = eval.retriggers[rt].retrigger_card
                local rt_eval, rt_post = SMODS.eval_individual(area, context)
                if next(rt_eval) then
                    if next(rt_post) then SMODS.trigger_effects({rt_post}, card) end
                    for key, value in pairs(rt_eval) do
                        if key ~= 'retriggers' then
                            SMODS.insert_repetitions(reps, value, area.scored_card)
                        end
                    end
                end
            end
            context.retrigger_joker = nil
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
            if next(eval) then
                if next(post) then SMODS.trigger_effects({post}, _card) end
                for key, value in pairs(eval) do
                    if not value.no_retrigger_juice then
                        value.retrigger_juice = card
                    end
                    SMODS.insert_repetitions(retriggers, value, _card, 'joker_retrigger')
                end
            end
        end
    end

    for _, area in ipairs(SMODS.get_card_areas('individual')) do
        local eval, post = SMODS.eval_individual(area, {retrigger_joker_check = true, other_card = card, other_context = context, other_ret = _ret})
        if next(eval) then
            if next(post) then SMODS.trigger_effects({post}, _card) end
            for key, value in pairs(eval) do
                if value.repetitions then
                    SMODS.insert_repetitions(retriggers, value, area, 'individual_retrigger')
                end
            end
        end
    end

    return retriggers
end

function Card:calculate_edition(context)
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

function SMODS.calculate_card_areas(_type, context, return_table, args)
    local flags = {}
    if _type == 'jokers' then
        for _, area in ipairs(SMODS.get_card_areas('jokers')) do
            if args and args.joker_area and not args.has_area then context.cardarea = area end
            for _, _card in ipairs(area.cards) do
                --calculate the joker effects
                if SMODS.check_looping_context(_card) then
                    goto skip
                end
                SMODS.current_evaluated_object = _card
                local eval, post = eval_card(_card, context)
                if args and args.main_scoring and eval.jokers then
                    eval.jokers.juice_card = eval.jokers.juice_card or eval.jokers.card or _card
                    eval.jokers.message_card = eval.jokers.message_card or context.other_card
                end

                local effects = {eval}
                for _,v in ipairs(post) do effects[#effects+1] = v end
    
                if context.other_joker then
                    for k, v in pairs(effects[1]) do
                        v.other_card = _card
                    end
                end

                if eval.retriggers then
                    context.retrigger_joker = true
                    for rt = 1, #eval.retriggers do
                        context.retrigger_joker = eval.retriggers[rt].retrigger_card
                        local rt_eval, rt_post = eval_card(_card, context)
                        if args and args.main_scoring and rt_eval.jokers then
                            rt_eval.jokers.juice_card = rt_eval.jokers.juice_card or rt_eval.jokers.card or _card
                            rt_eval.jokers.message_card = rt_eval.jokers.message_card or context.other_card
                        end
                        if next(rt_eval) then
                            if next(rt_eval) then
                                table.insert(effects, {retriggers = eval.retriggers[rt]})
                                table.insert(effects, rt_eval)
                                for _,v in ipairs(rt_post) do effects[#effects+1] = v end
                            end
                        end
                    end
                    context.retrigger_joker = nil
                end
                if return_table then
                    for _,v in ipairs(effects) do
                        if v.jokers and not v.jokers.card then v.jokers.card = _card end
                        return_table[#return_table+1] = v
                    end
                else
                    local f = SMODS.trigger_effects(effects, _card)
                    for k,v in pairs(f) do flags[k] = v end
                    SMODS.update_context_flags(context, flags)
                end
                ::skip::
            end
        end
    end

    if _type == 'playing_cards' then
        local scoring_map = {}
        if context.scoring_hand then
            for _,v in ipairs(context.scoring_hand) do scoring_map[v] = true end
        end
        for _, area in ipairs(SMODS.get_card_areas('playing_cards')) do
            if area == G.play and not context.scoring_hand then
                -- If context is for probability, eval_card() anyway
                -- This allows Seals, etc. to affect Joker probabilities during individual scoring:
                -- For example; A seal can double the probability of Blood Stone hitting for the playing card it is applied to.
                if context.mod_probability or context.fix_probability then
                    for _, card in ipairs(area.cards) do
                        if SMODS.check_looping_context(card) then
                            goto skip
                        end
                        SMODS.current_evaluated_object = card
                        local effects = {eval_card(card, context)}
                        local f = SMODS.trigger_effects(effects, card)
                        for k,v in pairs(f) do flags[k] = v end

                        SMODS.update_context_flags(context, flags)
                        ::skip::
                    end
                end
                goto continue
            end
            if not args or not args.has_area then context.cardarea = area end
            for _, card in ipairs(area.cards) do
                if SMODS.check_looping_context(card) then
                    goto skip
                end
                if not args or not args.has_area then
                    if area == G.play then
                        context.cardarea = SMODS.in_scoring(card, context.scoring_hand) and G.play or 'unscored'
                    elseif scoring_map[card] then
                        context.cardarea = G.play
                    else
                        context.cardarea = area
                    end
                end
                --calculate the played card effects
                if return_table then
                    SMODS.current_evaluated_object = card
                    return_table[#return_table+1] = eval_card(card, context)
                    SMODS.calculate_quantum_enhancements(card, return_table, context)
                else
                    SMODS.current_evaluated_object = card
                    local effects = {eval_card(card, context)}
                    SMODS.calculate_quantum_enhancements(card, effects, context)
                    local f = SMODS.trigger_effects(effects, card)
                    for k,v in pairs(f) do flags[k] = v end
                    SMODS.update_context_flags(context, flags)
                end
                ::skip::
            end
            ::continue::
        end
    end

    if _type == 'individual' then
        for _, area in ipairs(SMODS.get_card_areas('individual')) do
            if SMODS.check_looping_context(area.object) then
                goto skip
            end
            SMODS.current_evaluated_object = area.object
            local eval, post = SMODS.eval_individual(area, context)
            if args and args.main_scoring and eval.individual then
                eval.individual.juice_card = eval.individual.juice_card or eval.individual.card or area.scored_card
                eval.individual.message_card = eval.individual.message_card or eval.individual.card or context.other_card
            end
            local effects = {eval}
            for _,v in ipairs(post) do effects[#effects+1] = v end
            if effects[1].retriggers then
                context.retrigger_joker = true
                for rt = 1, #effects[1].retriggers do
                    context.retrigger_joker = effects[1].retriggers[rt].retrigger_card
                    local rt_eval, rt_post = SMODS.eval_individual(area, context)
                    if next(rt_eval) then
                        if next(rt_eval) then
                            table.insert(effects, {retriggers = effects[1].retriggers[rt]})
                            table.insert(effects, rt_eval)
                            for _,v in ipairs(rt_post) do effects[#effects+1] = v end
                        end
                    end
                end
                context.retrigger_joker = nil
            end
            if return_table then
                return_table[#return_table+1] = effects[1]
            else
                local f = SMODS.trigger_effects(effects, area.scored_card)
                for k,v in pairs(f) do flags[k] = v end
                SMODS.update_context_flags(context, flags)
            end
            ::skip::
        end
    end
    SMODS.current_evaluated_object = nil
    return flags
end


-- Updates a [context] with all compatible [flags]
function SMODS.update_context_flags(context, flags)
    if flags.numerator then context.numerator = flags.numerator end
    if flags.denominator then context.denominator = flags.denominator end
    if flags.cards_to_draw then context.amount = flags.cards_to_draw end
    if flags.saved then context.game_over = false end
    if flags.modify then
        -- insert general modified value updating here
        if context.modify_ante then context.modify_ante = flags.modify end
        if context.drawing_cards then context.amount = flags.modify end
    end
end

SMODS.current_evaluated_object = nil

-- Used to avoid looping getter context calls. Example;
-- Joker A: Doubles lucky card probabilities
-- Joker B: 1 in 3 chance that a card counts as a lucky card
-- Joker A calls SMODS.has_enhancement() during a probability context to check whether it should double the numerator
-- Joker B calls SMODS.pseudorandom_probability() to check whether it should trigger
-- A loop is caused (ignore the fact that Joker B would be the trigger_obj and not a playing card) (I'd write a Quantum Ranks example, If I had any!!)
-- To avoid this; Check before evaluating any object, whether the current getter context type (if it's a getter context) has previously caused said object to create a getter context,
-- if yes, don't evaluate the object. 
function SMODS.is_getter_context(context)
    if context.mod_probability or context.fix_probability then return "probability" end
    if context.check_enhancement then return "enhancement" end
    return false
end


function SMODS.check_looping_context(eval_object)
    if #SMODS.context_stack < 2 then return false end
    local getter_type = SMODS.is_getter_context(SMODS.context_stack[#SMODS.context_stack].context)
    if not getter_type then return end
    for i, t in ipairs(SMODS.context_stack) do
        local other_type = SMODS.is_getter_context(t.context)
        local next_context = SMODS.context_stack[i+1]
        -- If the current kind of getter context has caused the eval_object to incite a getter context before, dont evaluate the object again
        if other_type == getter_type and next_context and SMODS.is_getter_context(next_context.context) and next_context.caller == eval_object then
            return true
        end
    end
    return false
end

-- The context stack list, structured like so;
-- SMODS.context_stack = {1: {context = [unique context 1], count = [number of times it was added consecutively], caller = [the SMODS.current_evaluated_object when the context was added]}, ...}
-- (Contexts may repeat non-consecutively, though I don't think they ever should..)
-- Allows some advanced effects, like:
-- Individual playing cards modifying probabilities checked during individual scoring, only when they're the context.other_card 
-- (-> By checking the context in the stack PRIOR to the mod_probability context for the .individual / .other_card flags)
SMODS.context_stack = {}

function SMODS.push_to_context_stack(context, func)
    if not context or type(context) ~= "table" then
        sendWarnMessage(('Called SMODS.push_to_context_stack with invalid context \'%s\', in function \'%s\''):format(context, func), 'Util')
    end
    local len = #SMODS.context_stack
    if len <= 0 or SMODS.context_stack[len].context ~= context then
        SMODS.context_stack[len+1] = {context = context, count = 1, caller = SMODS.current_evaluated_object}
    else
        SMODS.context_stack[len].count = SMODS.context_stack[len].count + 1
    end
end

function SMODS.pop_from_context_stack(context, func)
    local len = #SMODS.context_stack
    if len <= 0 or SMODS.context_stack[len].context ~= context then
        sendWarnMessage(('Called SMODS.pop_from_context_stack with invalid context \'%s\', in function \'%s\''):format(context, func), 'Util')
    else
        SMODS.context_stack[len].count = SMODS.context_stack[len].count - 1
        if SMODS.context_stack[len].count <= 0 then
            table.remove(SMODS.context_stack, len)
        end
    end
end

function SMODS.get_previous_context()
    return (SMODS.context_stack[#SMODS.context_stack-1] or {}).context
end

-- Used to calculate contexts across G.jokers, scoring_hand (if present), G.play and G.GAME.selected_back
-- Hook this function to add different areas to MOST calculations
function SMODS.calculate_context(context, return_table, no_resolve)
    if G.STAGE ~= G.STAGES.RUN then return end

    SMODS.push_to_context_stack(context, "utils.lua : SMODS.calculate_context")

    local has_area = context.cardarea and true or nil
    if no_resolve then SMODS.no_resolve = true end
    local flags = {}
    context.main_eval = true
    flags[#flags+1] = SMODS.calculate_card_areas('jokers', context, return_table, { joker_area = true, has_area = has_area })
    context.main_eval = nil
    
    flags[#flags+1] = SMODS.calculate_card_areas('playing_cards', context, return_table, { has_area = has_area })
    context.main_eval = true
    flags[#flags+1] = SMODS.calculate_card_areas('individual', context, return_table)
    context.main_eval = nil
    
    if SMODS.no_resolve then SMODS.no_resolve = nil end
    
    SMODS.pop_from_context_stack(context, "utils.lua : SMODS.calculate_context")
    
    if not return_table then
        local ret = {}
        for i,f in ipairs(flags) do
            for k,v in pairs(f) do ret[k] = v end
        end
        return ret
    end
end

function SMODS.in_scoring(card, scoring_hand)
    -- if SMODS.always_scores(card) then return true end
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
            while eff.retrigger_flag do 
                SMODS.calculate_effect(eff, eff.card); j = j+1; _, eff = next(reps[j]) 
            end
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
            SMODS.calculate_card_areas('jokers', context, effects, { main_scoring = true })
            SMODS.calculate_card_areas('individual', context, effects, { main_scoring = true })
        end

        local flags = SMODS.trigger_effects(effects, card)

        context.individual = nil
        if reps[j] == 1 and flags.calculated then
            context.repetition = true
            context.card_effects = effects
            SMODS.calculate_repetitions(card, context, reps)
            context.repetition = nil
            context.card_effects = nil
        end
        j = j + (flags.calculated and 1 or #reps)
        context.other_card = nil
        card.lucky_trigger = nil
    end
end

function SMODS.calculate_main_scoring(context, scoring_hand)
    for _, card in ipairs(context.cardarea.cards) do
        local in_scoring = scoring_hand and SMODS.in_scoring(card, context.scoring_hand)
        --add cards played to list
        if scoring_hand and not SMODS.has_no_rank(card) and in_scoring then
            G.GAME.cards_played[card.base.value].total = G.GAME.cards_played[card.base.value].total + 1
            if not SMODS.has_no_suit(card) then
                G.GAME.cards_played[card.base.value].suits[card.base.suit] = true
            end
        end
        --if card is debuffed
        if scoring_hand and card.debuff then
            if in_scoring then 
                G.GAME.blind.triggered = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = (function() SMODS.juice_up_blind();return true end)
                }))
                card_eval_status_text(card, 'debuff')
            end
        else
            if scoring_hand then
                if in_scoring then context.cardarea = G.play else context.cardarea = 'unscored' end
            end
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
            SMODS.calculate_quantum_enhancements(card, effects, context)

            context.playing_card_end_of_round = nil
            context.individual = true
            context.other_card = card
            -- context.end_of_round individual calculations

            SMODS.calculate_card_areas('jokers', context, effects, { main_scoring = true })
            SMODS.calculate_card_areas('individual', context, effects, { main_scoring = true })

            local flags = SMODS.trigger_effects(effects, card)

            context.individual = nil
            context.repetition = true
            context.card_effects = effects
            if reps[j] == 1 then
                SMODS.calculate_repetitions(card, context, reps)
            end

            context.repetition = nil
            context.card_effects = nil
            context.other_card = nil
            j = j + (flags.calculated and 1 or #reps)

            -- TARGET: effects after end of round evaluation
        end
    end
end

function SMODS.calculate_destroying_cards(context, cards_destroyed, scoring_hand)
    for i,card in ipairs(context.cardarea.cards) do
        local destroyed = nil
        --un-highlight all cards
        local in_scoring = scoring_hand and SMODS.in_scoring(card, context.scoring_hand)
        if scoring_hand and in_scoring and not card.destroyed then 
            -- Use index of card in scoring hand to determine pitch
            local m = 1
            for j, _card in pairs(scoring_hand) do
                if card == _card then m = j break end
            end
            highlight_card(card,(m-0.999)/(#scoring_hand-0.998),'down')
        end

        -- context.destroying_card calculations
        context.destroy_card = card
        context.destroying_card = nil
        if scoring_hand then
            if in_scoring then
                context.cardarea = G.play
                context.destroying_card = card
            else
                context.cardarea = 'unscored'
            end
        end
        local flags = SMODS.calculate_context(context)
        if flags.remove then destroyed = true end

        -- TARGET: card destroyed

        if destroyed then
            card.getting_sliced = true
            if SMODS.shatters(card) then
                card.shattered = true
            else
                card.destroyed = true
            end
            cards_destroyed[#cards_destroyed+1] = card
        end
    end
end

function SMODS.blueprint_effect(copier, copied_card, context)
    if not copied_card or copied_card == copier or copied_card.debuff or context.no_blueprint or not copied_card.config.center.blueprint_compat then return end
    if (context.blueprint or 0) > #G.jokers.cards then return end

    local old_context_blueprint = context.blueprint
    context.blueprint = (context.blueprint and (context.blueprint + 1)) or 1
    
    local old_context_blueprint_card = context.blueprint_card
    context.blueprint_card = context.blueprint_card or copier

    context.blueprint_copiers_stack = context.blueprint_copiers_stack or {}
    context.blueprint_copiers_stack[#context.blueprint_copiers_stack + 1] = copier
    context.blueprint_copier = context.blueprint_copiers_stack[#context.blueprint_copiers_stack]

    local eff_card = context.blueprint_card
    local other_joker_ret = copied_card:calculate_joker(context)

    context.blueprint = old_context_blueprint
    context.blueprint_card = old_context_blueprint_card
    table.remove(context.blueprint_copiers_stack, #context.blueprint_copiers_stack)
    context.blueprint_copier = context.blueprint_copiers_stack[#context.blueprint_copiers_stack]

    if other_joker_ret then
        other_joker_ret.card = eff_card
        return other_joker_ret
    end
end

function SMODS.get_mods_scoring_targets()
    local ret = {}
    for _, mod in ipairs(SMODS.mod_list) do
        if mod.can_load and mod.calculate and type(mod.calculate) == "function" then
            table.insert(ret, mod)
        end
    end
    return ret
end

function SMODS.get_stake_scoring_targets()
    local ret = {}
    for _, stake in ipairs(G.GAME.applied_stakes or {}) do
        if G.P_CENTER_POOLS.Stake[stake].calculate and type(G.P_CENTER_POOLS.Stake[stake].calculate) == "function" then
            table.insert(ret, G.P_CENTER_POOLS.Stake[stake])
        end
    end
    return ret
end

function SMODS.get_card_areas(_type, _context)
    if _type == 'playing_cards' then
        local t = {}
        if _context ~= 'end_of_round' then t[#t+1] = G.play end
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
    if _type == 'individual' then
        local t = {
            { object = G.GAME.selected_back, scored_card = G.deck.cards[1] or G.deck },
        }

        if G.GAME.blind and G.GAME.blind.children and G.GAME.blind.children.animatedSprite then 
            t[#t + 1] = { object = G.GAME.blind, scored_card = G.GAME.blind.children.animatedSprite } 
        end
        if G.GAME.challenge then t[#t + 1] = { object = SMODS.Challenges[G.GAME.challenge], scored_card = G.deck.cards[1] or G.deck } end 
        for _, stake in ipairs(SMODS.get_stake_scoring_targets()) do
            t[#t + 1] = { object = stake, scored_card = G.deck.cards[1] or G.deck }
        end
        for _, mod in ipairs(SMODS.get_mods_scoring_targets()) do
            t[#t + 1] = { object = mod, scored_card = G.deck.cards[1] or G.deck }
        end
        -- TARGET: add your own individual scoring targets
        return t
    end
    return {}
end

function Back:calculate(context)
    return self:trigger_effect(context)
end
function Blind:calculate(context)
    local obj = self.config.blind
    if type(obj.calculate) == 'function' then
        return obj:calculate(self, context)
    end
end

function SMODS.eval_individual(individual, context)
    SMODS.push_to_context_stack(context, "utils.lua : SMODS.eval_individual")
    local ret = {}
    local post_trig = {}

    local eff, triggered = individual.object:calculate(context)
    if eff == true then eff = { remove = true } end
    if type(eff) ~= 'table' then eff = nil end

    if (eff and not eff.no_retrigger) or triggered then
        --if type(eff) == 'table' then eff.juice_card = eff.juice_card or individual.scored_card end
        ret.individual = eff
        if not (context.retrigger_joker_check or context.retrigger_joker) then
            local retriggers = SMODS.calculate_retriggers(individual.object, context, ret)
            if next(retriggers) then
                ret.retriggers = retriggers
            end
        end
        if not context.post_trigger and not context.retrigger_joker_check and SMODS.optional_features.post_trigger then
            SMODS.calculate_context({blueprint_card = context.blueprint_card, post_trigger = true, other_card = individual.object, other_context = context, other_ret = ret}, post_trig)
        end
    end
    SMODS.pop_from_context_stack(context, "utils.lua : SMODS.eval_individual")
    return ret, post_trig
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
            t[k] = true
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
    local card = e.config.ref_table
    local area = booster_obj and card:selectable_from_pack(booster_obj)
    local edition_card_limit = card.ability.card_limit
    if area and #G[area].cards < G[area].config.card_limit + edition_card_limit then
        e.config.colour = G.C.GREEN
        e.config.button = 'use_card'
    else
      e.config.colour = G.C.UI.BACKGROUND_INACTIVE
      e.config.button = nil
    end
  end

function Card.selectable_from_pack(card, pack)
    if card.config.center.select_card then return card.config.center.select_card end
    if pack and pack.select_exclusions then
        for _, key in ipairs(pack.select_exclusions) do
            if key == card.config.center_key then return false end
        end
    end
    local select_area = SMODS.card_select_area(card, pack)
    if select_area then
        if type(select_area) == 'table' then
            if select_area[card.ability.set] then return select_area[card.ability.set] else return false end
        end
        return select_area
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

function SMODS.add_voucher_to_shop(key, dont_save)
    if key then assert(G.P_CENTERS[key], "Invalid voucher key: "..key) else
        key = get_next_voucher_key()
        if not dont_save then
            G.GAME.current_round.voucher.spawn[key] = true
            G.GAME.current_round.voucher[#G.GAME.current_round.voucher + 1] = key
        end
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
    if mod > 0 and G.shop then
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
    if mod > 0 and G.shop then
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

function SMODS.signed(val)
    return val and (val > 0 and '+'..val or ''..val) or '0'
end

function SMODS.signed_dollars(val)
    return val and (val > 0 and '$'..val or '-$'..-val) or '0'
end

function SMODS.multiplicative_stacking(base, perma)
    base = (base ~= 0 and base or 1)
    local ret = base * (perma + 1)
    return (ret == 1 and 0) or (ret > 0 and ret) or 0
end

function SMODS.smeared_check(card, suit)
    if not next(find_joker('Smeared Joker')) then
        return false
    end

    if ((card.base.suit == 'Hearts' or card.base.suit == 'Diamonds') and (suit == 'Hearts' or suit == 'Diamonds')) then
        return true
    elseif (card.base.suit == 'Spades' or card.base.suit == 'Clubs') and (suit == 'Spades' or suit == 'Clubs') then
        return true
    end
    return false
end

local function has_any_other_suit(count, suit)
    for k, v in pairs(count) do
        if k ~= suit then
            if v > 0 then
                return true
            end
        end
    end
    return false
end

local function saw_double(count, suit)
    if count[suit] > 0 and has_any_other_suit(count, suit) then return true else return false end
end

function SMODS.seeing_double_check(hand, suit)
    local suit_tally = {}
    for i = #SMODS.Suit.obj_buffer, 1, -1 do
        suit_tally[SMODS.Suit.obj_buffer[i]] = 0
    end
    for i = 1, #hand do
        if not SMODS.has_any_suit(hand[i]) then
            for k, v in pairs(suit_tally) do
                if hand[i]:is_suit(k) then suit_tally[k] = suit_tally[k] + 1 end
            end
        end
    end
    for i = 1, #hand do
        if SMODS.has_any_suit(hand[i]) then
            if hand[i]:is_suit(suit) and suit_tally[suit] == 0 then suit_tally[suit] = suit_tally[suit] + 1 end
            for k, v in pairs(suit_tally) do
                if hand[i]:is_suit(k) and suit_tally[k] == 0  then suit_tally[k] = suit_tally[k] + 1 end
            end
        end
    end
    if saw_double(suit_tally, suit) then return true else return false end
end

function SMODS.localize_box(lines, args)
    local final_line = {}
    for _, part in ipairs(lines) do
        local assembled_string = ''
        for _, subpart in ipairs(part.strings) do
            assembled_string = assembled_string..(type(subpart) == 'string' and subpart or format_ui_value(args.vars[tonumber(subpart[1])]) or 'ERROR')
        end
        local desc_scale = (SMODS.Fonts[part.control.f] or G.FONTS[tonumber(part.control.f)] or G.LANG.font).DESCSCALE
        if G.F_MOBILE_UI then desc_scale = desc_scale*1.5 end
        if part.control.E then
            local _float, _silent, _pop_in, _bump, _spacing = nil, true, nil, nil, nil
            local text_effects
            if part.control.E == '1' then
                _float = true; _silent = true; _pop_in = 0
            elseif part.control.E == '2' then
                _bump = true; _spacing = 1
            elseif SMODS.DynaTextEffects[part.control.E] then
                text_effects = part.control.E
            end
            final_line[#final_line+1] = {n=G.UIT.C, config={align = "m", colour = part.control.B and args.vars.colours[tonumber(part.control.B)] or part.control.X and loc_colour(part.control.X) or nil, r = 0.05, padding = 0.03, res = 0.15}, nodes={}}
            final_line[#final_line].nodes[1] = {n=G.UIT.O, config={
                underline = part.control.u and loc_colour(part.control.u),
                object = DynaText({string = {assembled_string}, colours = {part.control.V and args.vars.colours[tonumber(part.control.V)] or loc_colour(part.control.C or nil)},
                    float = _float,
                    silent = _silent,
                    pop_in = _pop_in,
                    bump = _bump,
                    text_effect = text_effects,
                    spacing = _spacing,
                    font = SMODS.Fonts[part.control.f] or (tonumber(part.control.f) and G.FONTS[tonumber(part.control.f)]),
                    scale = 0.32*(part.control.s and tonumber(part.control.s) or args.scale  or 1)*desc_scale})
                }
            }
        elseif part.control.X or part.control.B then
            final_line[#final_line+1] = {n=G.UIT.C, config={align = "m", colour = part.control.B and args.vars.colours[tonumber(part.control.B)] or loc_colour(part.control.X), r = 0.05, padding = 0.03, res = 0.15}, nodes={
                {n=G.UIT.T, config={
                text = assembled_string,
                colour = part.control.V and args.vars.colours[tonumber(part.control.V)] or loc_colour(part.control.C or nil),
                font = SMODS.Fonts[part.control.f] or (tonumber(part.control.f) and G.FONTS[tonumber(part.control.f)]),
                underline = part.control.u and loc_colour(part.control.u),
                scale = 0.32*(part.control.s and tonumber(part.control.s) or args.scale  or 1)*desc_scale}},
            }}
        else
            final_line[#final_line+1] = {n=G.UIT.T, config={
            detailed_tooltip = part.control.T and (G.P_CENTERS[part.control.T] or G.P_TAGS[part.control.T]) or nil,
            text = assembled_string,
            shadow = args.shadow,
            colour = part.control.V and args.vars.colours[tonumber(part.control.V)] or not part.control.C and args.text_colour or loc_colour(part.control.C or nil, args.default_col),
            font = SMODS.Fonts[part.control.f] or (tonumber(part.control.f) and G.FONTS[tonumber(part.control.f)]),
            underline = part.control.u and loc_colour(part.control.u),
            scale = 0.32*(part.control.s and tonumber(part.control.s) or args.scale  or 1)*desc_scale},}
        end
    end
    return final_line
end

function SMODS.get_multi_boxes(multi_box)
    local multi_boxes = {}
    if multi_box then
        for i, box in ipairs(multi_box) do
            if i > 1 then multi_boxes[#multi_boxes+1] = {n=G.UIT.R, config={minh = 0.07}} end
            local _box = desc_from_rows(box)
            multi_boxes[#multi_boxes+1] = _box
        end
    end
    return multi_boxes
end

function SMODS.info_queue_desc_from_rows(desc_nodes, empty, maxw)
  local t = {}
  for k, v in ipairs(desc_nodes) do
    t[#t+1] = {n=G.UIT.R, config={align = "cm", maxw = maxw}, nodes=v}
  end
  return {n=G.UIT.R, config={align = "cm", colour = desc_nodes.background_colour or empty and G.C.CLEAR or G.C.UI.BACKGROUND_WHITE, r = 0.1, emboss = not empty and 0.05 or nil, filler = true, main_box_flag = desc_nodes.main_box_flag and true or nil}, nodes={
    {n=G.UIT.R, config={align = "cm"}, nodes=t}
  }}
end

function SMODS.destroy_cards(cards, bypass_eternal, immediate, skip_anim)
    if not cards[1] then
        if Object.is(cards, Card) then
            cards = {cards}
        else
            return
        end
    end
    local glass_shattered = {}
    local playing_cards = {}
    for _, card in ipairs(cards) do
        if bypass_eternal or not SMODS.is_eternal(card, {destroy_cards = true}) then
            card.getting_sliced = true
            if SMODS.shatters(card) then
                card.shattered = true
                glass_shattered[#glass_shattered + 1] = card
            else
                card.destroyed = true
            end
            if card.base.name then
                playing_cards[#playing_cards + 1] = card
            end
            card.skip_destroy_animation = skip_anim
        end
    end
    
    check_for_unlock{type = 'shatter', shattered = glass_shattered}
    
    if next(playing_cards) then SMODS.calculate_context({scoring_hand = cards, remove_playing_cards = true, removed = playing_cards}) end

    for i = 1, #cards do
        if immediate or skip_anim then
            if cards[i].shattered then
                cards[i]:shatter()
            elseif cards[i].destroyed then
                cards[i]:start_dissolve()
            end
        else
            G.E_MANAGER:add_event(Event({
                func = function()
                    if cards[i].shattered then
                        cards[i]:shatter()
                    elseif cards[i].destroyed then
                        cards[i]:start_dissolve(nil, i == #cards)
                    end
                    return true
                end
            }))
        end
    end
end

-- Hand Limit API
SMODS.hand_limit_strings = {play = '', discard = ''}
function SMODS.change_play_limit(mod)
    G.GAME.starting_params.play_limit = G.GAME.starting_params.play_limit + mod
    if G.GAME.starting_params.play_limit < 1 then
        sendErrorMessage('Play limit is less than 1', 'HandLimitAPI')
    end
    G.hand.config.highlighted_limit = math.max(G.GAME.starting_params.discard_limit, G.GAME.starting_params.play_limit, 5)
    SMODS.update_hand_limit_text(true)
end

function SMODS.change_discard_limit(mod)
    G.GAME.starting_params.discard_limit = G.GAME.starting_params.discard_limit + mod
    if G.GAME.starting_params.discard_limit < 0 then
        sendErrorMessage('Discard limit is less than 0', 'HandLimitAPI')
    end
    G.hand.config.highlighted_limit = math.max(G.GAME.starting_params.discard_limit, G.GAME.starting_params.play_limit, 5)
    SMODS.update_hand_limit_text(nil, true)
end

function SMODS.update_hand_limit_text(play, discard)
    if play then SMODS.hand_limit_strings.play = G.GAME.starting_params.play_limit ~= 5 and localize('b_limit') .. math.max(1, G.GAME.starting_params.play_limit) or '' end
    if discard then SMODS.hand_limit_strings.discard = G.GAME.starting_params.discard_limit ~= 5 and localize('b_limit') .. math.max(0, G.GAME.starting_params.discard_limit) or '' end
end

function SMODS.draw_cards(hand_space)
    if not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and
        G.hand.config.card_limit <= 0 and #G.hand.cards == 0 then 
        G.STATE = G.STATES.GAME_OVER; G.STATE_COMPLETE = false 
        return true
    end

    local flags = SMODS.calculate_context({drawing_cards = true, amount = hand_space})
    hand_space = math.min(#G.deck.cards, flags.cards_to_draw or flags.modify or hand_space)
    delay(0.3)
    SMODS.drawn_cards = {}
    for i=1, hand_space do --draw cards from deckL
        if G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK then 
            draw_card(G.deck,G.hand, i*100/hand_space,'up', true)
        else
            draw_card(G.deck,G.hand, i*100/hand_space,'up', true)
        end
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'before',
        delay = 0.4,
        func = function()
            if #SMODS.drawn_cards > 0 then
                SMODS.calculate_context({first_hand_drawn = not G.GAME.current_round.any_hand_drawn and G.GAME.facing_blind,
                                        hand_drawn = G.GAME.facing_blind and SMODS.drawn_cards,
                                        other_drawn = not G.GAME.facing_blind and SMODS.drawn_cards})
                SMODS.drawn_cards = {}
                if G.GAME.facing_blind then G.GAME.current_round.any_hand_drawn = true end
            end
            return true
        end
    }))
end

function SMODS.showman(card_key)
    if SMODS.create_card_allow_duplicates or next(SMODS.find_card('j_ring_master')) then
        return true
    end
    return false
end

function SMODS.four_fingers(hand_type)
    if next(SMODS.find_card('j_four_fingers')) then
        return 4
    end
    return 5
end

function SMODS.shortcut()
    if next(SMODS.find_card('j_shortcut')) then
        return true
    end
    return false
end

function SMODS.wrap_around_straight()
    return false
end

function SMODS.merge_effects(...)
    local t = {}
    for _, v in ipairs({...}) do
        for _, vv in ipairs(v) do
            if vv == true or (type(vv) == "table" and next(vv)) then 
                table.insert(t, vv)
            end
        end
    end
    local ret = table.remove(t, 1)
    ret = ret == true and { remove = true } or ret
    local current = ret
    for _, eff in ipairs(t) do
        assert(eff == true or type(eff) == 'table', ("\"%s\" is not a valid calculate return."):format(tostring(eff)))
        while current.extra ~= nil do
            if current.extra == true then
                current.extra = { remove = true }
            end
            assert(type(current.extra) == 'table', ("\"%s\" is not a valid calculate return."):format(tostring(current.extra)))
            current = current.extra
        end
        current.extra = eff == true and { remove = true } or eff
    end
    return ret
end

function SMODS.get_probability_vars(trigger_obj, base_numerator, base_denominator, identifier, from_roll, no_mod)
    if not G.jokers then return base_numerator, base_denominator end
    if no_mod then return base_numerator, base_denominator end
    local additive = SMODS.calculate_context({mod_probability = true, from_roll = from_roll, trigger_obj = trigger_obj, identifier = identifier, numerator = base_numerator, denominator = base_denominator}, nil, not from_roll)
    additive.numerator = (additive.numerator or base_numerator) * ((G.GAME and G.GAME.probabilities.normal or 1) / (2 ^ #SMODS.find_card('j_oops')))
    local fixed = SMODS.calculate_context({fix_probability = true, from_roll = from_roll, trigger_obj = trigger_obj, identifier = identifier, numerator = additive.numerator or base_numerator, denominator = additive.denominator or base_denominator}, nil, not from_roll)
    return fixed.numerator or additive.numerator or base_numerator, fixed.denominator or additive.denominator or base_denominator
end

function SMODS.pseudorandom_probability(trigger_obj, seed, base_numerator, base_denominator, identifier, no_mod)
    local numerator, denominator = SMODS.get_probability_vars(trigger_obj, base_numerator, base_denominator, identifier or seed, true, no_mod)
    local result = pseudorandom(seed) < numerator / denominator
    SMODS.post_prob = SMODS.post_prob or {}
    SMODS.post_prob[#SMODS.post_prob+1] = {pseudorandom_result = true, result = result, trigger_obj = trigger_obj, numerator = numerator, denominator = denominator, identifier = identifier or seed}
    return result
end

function SMODS.is_poker_hand_visible(handname)
    if SMODS.PokerHands[handname] and SMODS.PokerHands[handname].visible and type(SMODS.PokerHands[handname].visible) == "function" then
        return not not SMODS.PokerHands[handname]:visible()
    end
	assert(G.GAME.hands[handname], "handname '" .. handname .. "' not found!")
    return not not SMODS.PokerHands[handname] and G.GAME.hands[handname].visible
end

G.FUNCS.update_blind_debuff_text = function(e)
    if not e.config.object then return end
    local new_str = SMODS.debuff_text or G.GAME.blind:get_loc_debuff_text()
    if new_str ~= e.config.object.string then
        e.config.object.config.string = {new_str}
        e.config.object:update_text(true)
        e.UIBox:recalculate()
    end
end

function Card:should_hide_front()
  return self.ability.effect == 'Stone Card' or self.config.center.replace_base_card
end

function SMODS.is_eternal(card, trigger)
    local calc_return = {}
    local ovr_compat = false
    local ret = false
    if not trigger then trigger = {} end
    SMODS.calculate_context({check_eternal = true, other_card = card, trigger = trigger, no_blueprint = true,}, calc_return)
    for _,eff in pairs(calc_return) do
        for _,tab in pairs(eff) do
            if tab.no_destroy then --Reuses key from context.joker_type_destroyed
                ret = true
                if type(tab.no_destroy) == 'table' then
                    if tab.no_destroy.override_compat then ovr_compat = true end
                end
            end
        end
    end
    if card.ability.eternal then ret = true end
    if card.config.center.eternal_compat == false and not ovr_compat then ret = false end
    return ret
end

-- Scoring Calculation API
function SMODS.set_scoring_calculation(key)
    G.GAME.current_scoring_calculation = SMODS.Scoring_Calculations[key]:new()
    G.FUNCS.SMODS_scoring_calculation_function(G.HUD:get_UIE_by_ID('hand_text_area'))
    G.HUD:get_UIE_by_ID('hand_operator_container').UIBox:recalculate()
    SMODS.refresh_score_UI_list()
end

local game_start_run = Game.start_run
function Game:start_run(args)
    game_start_run(self, args)
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()                
            SMODS.refresh_score_UI_list()
            return true
        end
    }))
end

G.FUNCS.SMODS_scoring_calculation_function = function(e)
    local first = false
    if not (e.config.current_scoring_calculation and e.config.current_scoring_calculation == G.GAME.current_scoring_calculation.key) then
        first = true
        local scale = 0.4
        e.children[1].children[2]:remove()
        e.children[1].children[2] = nil
        if G.GAME.current_scoring_calculation.replace_ui then
            e.children[1].UIBox:add_child(G.GAME.current_scoring_calculation:replace_ui(), e.children[1])
        else
            e.children[1].UIBox:add_child(SMODS.GUI.hand_chips_container(scale), e.children[1])
        end
        e.config.current_scoring_calculation = G.GAME.current_scoring_calculation.key 
    end

    local container = e.children[1].children[2]
    local chip_display = container.UIBox:get_UIE_by_ID('hand_chips_container')
    local operator = container.UIBox:get_UIE_by_ID('hand_operator_container')
    local mult_display = container.UIBox:get_UIE_by_ID('hand_mult_container')
    
    if G.GAME.current_scoring_calculation.update_ui then
        G.GAME.current_scoring_calculation:update_ui(container, chip_display, mult_display, operator)
    else
        if G.GAME.current_scoring_calculation.text and operator then
            operator.children[1].config.text = type(G.GAME.current_scoring_calculation.text) == 'function' and G.GAME.current_scoring_calculation:text() or G.GAME.current_scoring_calculation.text
        end
        if G.GAME.current_scoring_calculation.colour and operator then
            operator.children[1].config.colour = type(G.GAME.current_scoring_calculation.colour) == 'function' and G.GAME.current_scoring_calculation:colour() or G.GAME.current_scoring_calculation.colour
        end
        if operator and (type(G.GAME.current_scoring_calculation.colour) == 'function' or type(G.GAME.current_scoring_calculation.text) == 'function') then operator.UIBox:recalculate() end
    end
end

SMODS.calculate_round_score = function(flames)
    if not G.GAME.current_scoring_calculation then return 0 end
    return G.GAME.current_scoring_calculation:func(SMODS.get_scoring_parameter('chips', flames), SMODS.get_scoring_parameter('mult', flames), flames)
end

function SMODS.get_scoring_parameter(key, flames)
    if flames then return G.GAME.current_round.current_hand[key] end
    return SMODS.Scoring_Parameters[key].current or SMODS.Scoring_Parameters[key].default_value
end

function SMODS.refresh_score_UI_list()
    for name, _ in pairs(SMODS.Scoring_Parameters) do
        G.hand_text_area[name] = G.HUD:get_UIE_by_ID('hand_'..name)
    end
end

-- Adds tag_triggered context
local tag_apply = Tag.apply_to_run
function Tag:apply_to_run(_context)
    local res = tag_apply(self, _context)
    if self.triggered and not self.triggered_calc then
        SMODS.calculate_context({tag_triggered = self})
        self.triggered_calc = true
    end
    return res
end

function SMODS.scale_card(card, args)
    if not G.deck then return end
    if not args.operation then args.operation = "+" end
    args.block_overrides = args.block_overrides or {}
    args.ref_table = args.ref_table or card.ability.extra
    args.scalar_table = args.scalar_table or args.ref_table
    local initial = args.ref_table[args.ref_value]
    local scalar_value = args.scalar_table[args.scalar_value]
    if args.operation == '-' and scalar_value < 0 then scalar_value = scalar_value * -1 end
    local scaling_message = args.scaling_message
    local scaling_responses = {}
    for _, area in ipairs(SMODS.get_card_areas('jokers')) do
        for _, _card in ipairs(area.cards) do
            local obj = _card.config.center
            if obj.calc_scaling and type(obj.calc_scaling) == "function" then
                local ret = obj:calc_scaling(_card, card, initial, scalar_value, args)
                if ret then
                    if ret.override_value and not args.block_overrides.value then initial = ret.override_value.value; SMODS.calculate_effect(ret.override_value, _card) end
                    if ret.override_scalar_value and not args.block_overrides.scalar then scalar_value = ret.override_scalar_value.value; SMODS.calculate_effect(ret.override_scalar_value, _card) end
                    if ret.override_message and not args.block_overrides.message then scaling_message = SMODS.merge_defaults(ret.override_message, scaling_message) end
                    if ret.post then ret.post.source = _card; scaling_responses[#scaling_responses + 1] = ret.post end
                    SMODS.calculate_effect(ret, _card)
                end
            end
        end
    end
    
    if type(args.operation) == 'function' then
        args.operation(args.ref_table, args.ref_value, initial, scalar_value)
    elseif args.operation == 'X' then
        SMODS.multiplicative_scaling(args.ref_table, args.ref_value, initial, scalar_value)
    elseif args.operation == '-' then
        SMODS.additive_scaling(args.ref_table, args.ref_value, initial, -1 * scalar_value)
    else
        SMODS.additive_scaling(args.ref_table, args.ref_value, initial, scalar_value)
    end
    
    scaling_message = scaling_message or {
        message = localize(args.message_key and {type='variable',key=args.message_key,vars={args.message_key =='a_xmult' and args.ref_table[args.ref_value] or scalar_value}} or 'k_upgrade_ex'),
        colour = args.message_colour or G.C.FILTER,
        delay = args.message_delay,
    }
    if next(scaling_message) and not args.no_message then
        SMODS.calculate_effect(scaling_message, card)
    end
    for _, ret in ipairs(scaling_responses) do
        SMODS.calculate_effect(ret, ret.source)
    end
end

function SMODS.additive_scaling(ref_table, ref_value, initial, modifier)
    ref_table[ref_value] = initial + modifier
end

function SMODS.multiplicative_scaling(ref_table, ref_value, initial, modifier)
    ref_table[ref_value] = initial * modifier
end

function SMODS.quip(quip_type)
    if not quip_type then return nil end
    local pool = {}
    local total_weight = 0
    for k, v in pairs(SMODS.JimboQuips) do
        local add = true
        local in_pool, pool_opts, deck_pool_opts, mod_pool_opts
        if v.filter and type(v.filter) == 'function' then
            in_pool, pool_opts = v:filter(quip_type)
        end
        local deck = G.P_CENTERS[G.GAME.selected_back.effect.center.key] or SMODS.Centers[G.GAME.selected_back.effect.center.key]
        if deck and deck.quip_filter and type(deck.quip_filter) == 'function' then
            add, deck_pool_opts = deck.quip_filter(v, quip_type)
        end
        for _, mod in ipairs(SMODS.mod_list) do
            if mod.can_load and mod.quip_filter and type(mod.quip_filter) == "function" then
                local mod_add
                mod_add, mod_pool_opts = mod.quip_filter(v, quip_type)
                add = add and mod_add
            end
        end
        if v.filter and type(v.filter) == 'function' then
            add = in_pool and (add or (mod_pool_opts and mod_pool_opts.override_base_checks) or (deck_pool_opts and deck_pool_opts.override_base_checks) or (pool_opts and pool_opts.override_base_checks))
        end
        if v.type and v.type ~= quip_type then
            add = false
        end
        if add then
            local weight = (mod_pool_opts and mod_pool_opts.weight and math.max(1, math.floor(mod_pool_opts.weight))) or (deck_pool_opts and deck_pool_opts.weight and math.max(1, math.floor(deck_pool_opts.weight))) or (pool_opts and pool_opts.weight and math.max(1, math.floor(pool_opts.weight))) or 1
            pool[#pool+1] = {quip = v, weight = weight}
            total_weight = total_weight + weight
        end
    end
    local quip_poll = pseudorandom(quip_type)
    local it = 0
    for _, v in ipairs(pool) do
        it = it + v.weight
        if it/total_weight >= quip_poll then
            local args = {}
            if v.quip.extra then
                if type(v.quip.extra) == 'function' then
                    args = v.quip.extra()
                else
                    args = v.quip.extra
                end
            end
            return v.quip.key, args
        end
    end
end


local ref_challenge_desc = G.UIDEF.challenge_description_tab
function G.UIDEF.challenge_description_tab(args)
	args = args or {}

	if args._tab == 'Restrictions' then
		local challenge = G.CHALLENGES[args._id]
		if challenge.restrictions then
            if challenge.restrictions.banned_cards and type(challenge.restrictions.banned_cards) == 'function' then
                challenge.restrictions.banned_cards = challenge.restrictions.banned_cards()
            end

            if challenge.restrictions.banned_tags and type(challenge.restrictions.banned_tags) == 'function' then
                challenge.restrictions.banned_tags = challenge.restrictions.banned_tags()
            end

            if challenge.restrictions.banned_other and type(challenge.restrictions.banned_other) == 'function' then
                challenge.restrictions.banned_other = challenge.restrictions.banned_other()
            end
        end
	end

	return ref_challenge_desc(args)
end

function SMODS.challenge_is_unlocked(challenge, k)
    local challenge_unlocked
    if type(challenge.unlocked) == 'function' then
        challenge_unlocked = challenge:unlocked()
    elseif type(challenge.unlocked) == 'boolean' then
        challenge_unlocked = challenge.unlocked
    else
        -- vanilla condition, only for non-smods challenges
        challenge_unlocked = G.PROFILES[G.SETTINGS.profile].challenges_unlocked and (G.PROFILES[G.SETTINGS.profile].challenges_unlocked >= (k or 0))
    end
    challenge_unlocked = challenge_unlocked or G.PROFILES[G.SETTINGS.profile].all_unlocked
    return challenge_unlocked
end

function SMODS.localize_perma_bonuses(specific_vars, desc_nodes)
    if specific_vars and specific_vars.bonus_x_chips then
        localize{type = 'other', key = 'card_x_chips', nodes = desc_nodes, vars = {specific_vars.bonus_x_chips}}
    end
    if specific_vars and specific_vars.bonus_mult then
        localize{type = 'other', key = 'card_extra_mult', nodes = desc_nodes, vars = {SMODS.signed(specific_vars.bonus_mult)}}
    end
    if specific_vars and specific_vars.bonus_x_mult then
        localize{type = 'other', key = 'card_x_mult', nodes = desc_nodes, vars = {specific_vars.bonus_x_mult}}
    end
    if specific_vars and specific_vars.bonus_h_chips then
        localize{type = 'other', key = 'card_extra_h_chips', nodes = desc_nodes, vars = {SMODS.signed(specific_vars.bonus_h_chips)}}
    end
    if specific_vars and specific_vars.bonus_h_x_chips then
        localize{type = 'other', key = 'card_h_x_chips', nodes = desc_nodes, vars = {specific_vars.bonus_h_x_chips}}
    end
    if specific_vars and specific_vars.bonus_h_mult then
        localize{type = 'other', key = 'card_extra_h_mult', nodes = desc_nodes, vars = {SMODS.signed(specific_vars.bonus_h_mult)}}
    end
    if specific_vars and specific_vars.bonus_h_x_mult then
        localize{type = 'other', key = 'card_h_x_mult', nodes = desc_nodes, vars = {specific_vars.bonus_h_x_mult}}
    end
    if specific_vars and specific_vars.bonus_p_dollars then
        localize{type = 'other', key = 'card_extra_p_dollars', nodes = desc_nodes, vars = {SMODS.signed_dollars(specific_vars.bonus_p_dollars)}}
    end
    if specific_vars and specific_vars.bonus_h_dollars then
        localize{type = 'other', key = 'card_extra_h_dollars', nodes = desc_nodes, vars = {SMODS.signed_dollars(specific_vars.bonus_h_dollars)}}
    end
    if specific_vars and specific_vars.bonus_repetitions then
        localize{type = 'other', key = 'card_extra_repetitions', nodes = desc_nodes, vars = {specific_vars.bonus_repetitions, localize(specific_vars.bonus_repetitions > 1 and 'b_retrigger_plural' or 'b_retrigger_single')}}
    end
end

local ease_dollar_ref = ease_dollars
function ease_dollars(mod, instant)
    ease_dollar_ref(mod, instant)
    if SMODS.ease_dollars_calc then return end
    SMODS.calculate_context({
        money_altered = true,
        amount = mod,
        from_shop = (G.STATE == G.STATES.SHOP or G.STATE == G.STATES.SMODS_BOOSTER_OPENED or G.STATE == G.STATES.SMODS_REDEEM_VOUCHER) or nil,
        from_consumeable = (G.STATE == G.STATES.PLAY_TAROT) or nil,
        from_scoring = (G.STATE == G.STATES.HAND_PLAYED) or nil,
    })
end
function SMODS.add_to_pool(prototype_obj, args)
    if type(prototype_obj.in_pool) == "function" then
        return prototype_obj:in_pool(args)
    end
    return true
end


function Card:is_rarity(rarity)
    if self.ability.set ~= "Joker" then return false end
    local rarities = {"Common", "Uncommon", "Rare", "Legendary"}
    rarity = rarities[rarity] or rarity
    local own_rarity = rarities[self.config.center.rarity] or self.config.center.rarity
    return own_rarity == rarity or SMODS.Rarities[own_rarity] == rarity
end


function UIElement:draw_pixellated_under(_type, _parallax, _emboss, _progress)
    if not self.pixellated_rect or
        #self.pixellated_rect[_type].vertices < 1 or
        _parallax ~= self.pixellated_rect.parallax or
        self.pixellated_rect.w ~= self.VT.w or
        self.pixellated_rect.h ~= self.VT.h or
        self.pixellated_rect.sw ~= self.shadow_parrallax.x or
        self.pixellated_rect.sh ~= self.shadow_parrallax.y or
        self.pixellated_rect.progress ~= (_progress or 1)
    then 
        self.pixellated_rect = {
            w = self.VT.w,
            h = self.VT.h,
            sw = self.shadow_parrallax.x,
            sh = self.shadow_parrallax.y,
            progress = (_progress or 1),
            fill = {vertices = {}},
            shadow = {vertices = {}},
            line = {vertices = {}},
            emboss = {vertices = {}},
            line_emboss = {vertices = {}},
            parallax = _parallax
        }
        local ext_up = self.config.ext_up and self.config.ext_up*G.TILESIZE or 0
        local totw, toth = self.VT.w*G.TILESIZE, (self.VT.h + math.abs(ext_up)/G.TILESIZE)*G.TILESIZE

        local vertices = {
            totw,toth+ext_up,
            0, toth+ext_up,
            0, toth+ext_up+0.5,
            totw,toth+ext_up+0.5
        }
        for k, v in ipairs(vertices) do
            if k%2 == 1 and v > totw*self.pixellated_rect.progress then v = totw*self.pixellated_rect.progress end
            self.pixellated_rect.fill.vertices[k] = v
            if k > 4 then
                self.pixellated_rect.line.vertices[k-4] = v
                if _emboss then
                    self.pixellated_rect.line_emboss.vertices[k-4] = v + (k%2 == 0 and -_emboss*self.shadow_parrallax.y or -0.7*_emboss*self.shadow_parrallax.x)
                end
            end
            if k%2 == 0 then
                self.pixellated_rect.shadow.vertices[k] = v -self.shadow_parrallax.y*_parallax
                if _emboss then
                    self.pixellated_rect.emboss.vertices[k] = v + _emboss*G.TILESIZE
                end
            else
                self.pixellated_rect.shadow.vertices[k] = v -self.shadow_parrallax.x*_parallax
                if _emboss then
                    self.pixellated_rect.emboss.vertices[k] = v
                end
            end
        end
    end
    love.graphics.polygon("fill", self.pixellated_rect.fill.vertices)
end

function SMODS.card_select_area(card, pack)
    local select_area
    if card.config.center.select_card then
        if type(card.config.center.select_card) == "function" then -- Card's value takes first priority
            select_area = card.config.center:select_card(card, pack)
        else
            select_area = card.config.center.select_card
        end
    elseif SMODS.ConsumableTypes[card.ability.set] and SMODS.ConsumableTypes[card.ability.set].select_card then -- ConsumableType is second priority
        if type(SMODS.ConsumableTypes[card.ability.set].select_card) == "function" then
            select_area = SMODS.ConsumableTypes[card.ability.set]:select_card(card, pack)
        else
            select_area = SMODS.ConsumableTypes[card.ability.set].select_card
        end
    elseif pack.select_card then -- Pack is third priority
        if type(pack.select_card) == "function" then
            select_area = pack:select_card(card, pack)
        else
            select_area = pack.select_card
        end
    end
    return select_area
end

function SMODS.get_select_text(card, pack)
    local select_text
    if card.config.center.select_button_text then -- Card's value takes first priority
        if type(card.config.center.select_button_text) == "function" then
            select_text = card.config.center:select_button_text(card, pack)
        else
            select_text = localize(card.config.center.select_button_text)
        end
    elseif SMODS.ConsumableTypes[card.ability.set] and SMODS.ConsumableTypes[card.ability.set].select_button_text then -- ConsumableType is second priority
        if type(SMODS.ConsumableTypes[card.ability.set].select_button_text) == "function" then
            select_text = SMODS.ConsumableTypes[card.ability.set]:select_button_text(card, pack)
        else
            select_text = localize(SMODS.ConsumableTypes[card.ability.set].select_button_text)
        end
    elseif pack.select_button_text then -- Pack is third priority
        if type(pack.select_button_text) == "function" then
            select_text = pack:select_button_text(card, pack)
        else
            select_text = localize(pack.select_button_text)
        end
    end
    return select_text
end

function CardArea:count_property(property)
    local value = 0
    for _, card in ipairs(self.cards) do
        value = value + card.ability[property]
    end
    return value
end

function SMODS.should_handle_limit(area)
    if (area.config.type == 'joker' or area.config.type == 'hand') and not area.config.fixed_limit then
        return true
    end
end

function CardArea:handle_card_limit()
    if SMODS.should_handle_limit(self) then
        if not G.TAROT_INTERRUPT then
            self.config.card_limits.extra_slots = self:count_property('card_limit')
            self.config.card_limits.total_slots = self.config.card_limits.extra_slots + (self.config.card_limits.base or 0) + (self.config.card_limits.mod or 0)
            self.config.card_limits.extra_slots_used = self:count_property('extra_slots_used')
        end
        self.config.card_count = #self.cards + self.config.card_limits.extra_slots_used
        
        if G.hand and self == G.hand and (self.config.card_count or 0) + (SMODS.cards_to_draw or 0) < (self.config.card_limits.total_slots or 0) then
            if G.STATE == G.STATES.DRAW_TO_HAND and not SMODS.blind_modifies_draw(G.GAME.blind.config.blind.key) and not SMODS.draw_queued then
                SMODS.draw_queued = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        SMODS.draw_queued = nil
                        G.E_MANAGER:add_event(Event({
                            trigger = 'immediate',
                            func = function()
                                if (self.config.card_limits.total_slots - self.config.card_count - (SMODS.cards_to_draw or 0)) > 0 and #G.deck.cards > (SMODS.cards_to_draw or 0) then
                                    G.FUNCS.draw_from_deck_to_hand(self.config.card_limits.total_slots - self.config.card_count - (SMODS.cards_to_draw or 0))                
                                end
                                return true
                            end
                        }))
                        return true
                    end
                }))
            elseif G.STATE == G.STATES.SELECTING_HAND and #G.deck.cards > 0 and self.config.card_limits.old_slots < self.config.card_limits.total_slots then
                if (self.config.card_limits.total_slots - self.config.card_limits.old_slots) > 0 then
                    G.FUNCS.draw_from_deck_to_hand((self.config.card_limits.total_slots - self.config.card_limits.old_slots))
                end
            end
            if self == G.hand and G.STATE == G.STATES.SELECTING_HAND or G.STATE == G.STATES.DRAW_TO_HAND then 
                self.config.card_limits.old_slots = self.config.card_limits.total_slots or 0
            end
            return
        end
    else
        self.config.card_count = #self.cards
        self.config.card_limits.total_slots = (self.config.card_limits.base or 0) + (self.config.card_limits.mod or 0)
    end
end


function SMODS.get_atlas(atlas_key)
    return G.ASSET_ATLAS[atlas_key] or G.ANIMATION_ATLAS[atlas_key]
end

function SMODS.get_atlas_sprite_class(atlas_key)
    local atlas = SMODS.get_atlas(atlas_key) or {atlas_table = "ASSET_ATLAS"}
    local class_map = {
        ASSET_ATLAS = Sprite,
        ANIMATION_ATLAS = AnimatedSprite,
    }
    return class_map[atlas.atlas_table] or Sprite
end

function SMODS.create_sprite(X, Y, W, H, atlas, pos)
    local atlas_key = (type(atlas) == "string" and atlas) or (type(atlas) == "table" and (atlas.key or atlas.name))
    atlas = SMODS.get_atlas(atlas_key)
    assert(atlas, "SMODS.create_sprite called with invalid atlas key: "..atlas_key)
    return SMODS.get_atlas_sprite_class(atlas_key)(X, Y, W, H, atlas, pos)
end

local animate = AnimatedSprite.animate
function AnimatedSprite:animate()
    if not self.current_animation.frames then return end
    animate(self)
end

function SMODS.is_active_blind(key, ignore_disabled)
    return G.GAME and G.GAME.blind and G.GAME.facing_blind and (G.GAME.blind.name == key or G.GAME.blind.config.key == key) and (not G.GAME.blind.disabled or ignore_disabled)
end

-- Function used to determine whether the current blind modifies the number of cards drawn
function SMODS.blind_modifies_draw(key)
    if SMODS.Blinds.modifies_draw[key] then return true end
end

function SMODS.upgrade_poker_hands(args)
    -- args.hands
    -- args.parameters
    -- args.func
    -- args.level_up
    -- args.instant
    -- args.from

    local function get_keys(t)
        local keys = {}
        for k, _ in pairs(t) do
            table.insert(keys, k)
        end
        return keys
    end

    args.hands = args.hands or get_keys(G.GAME.hands)
    if type(args.hands) == 'string' then args.hands = {args.hands} end
    args.parameters = args.parameters or get_keys(SMODS.Scoring_Parameters)
    local instant = args.instant

    if not args.func then
        for _, hand in ipairs(args.hands) do
            level_up_hand(args.from, hand, instant, args.level_up or 1)
        end
        return
    end
    
    assert(type(args.func) == 'function', "Invalid func provided to SMODS.upgrade_hands")

    local vals_after_level
    if SMODS.displaying_scoring then
        vals_after_level = copy_table(G.GAME.current_round.current_hand)
        local text,disp_text,_,_,_ = G.FUNCS.get_poker_hand_info(G.play.cards)
        vals_after_level.handname = disp_text or ''
        vals_after_level.level = (G.GAME.hands[text] or {}).level or ''
        for name, p in pairs(SMODS.Scoring_Parameters) do
            vals_after_level[name] = p.current
        end
    end
        
    local displayed = false
    for _, hand in ipairs(args.hands) do
        displayed = hand == SMODS.displayed_hand
        if not instant then
            update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(hand, 'poker_hands'), level=G.GAME.hands[hand].level})
            for name, p in pairs(SMODS.Scoring_Parameters) do
                p.current = G.GAME.hands[hand][name] or p.default_value
                update_hand_text({nopulse = nil, delay = 0}, {[name] = p.current})
            end
        end
        for i, parameter in ipairs(args.parameters) do
            if G.GAME.hands[hand][parameter] then
                G.GAME.hands[hand][parameter] = args.func(G.GAME.hands[hand][parameter], hand, parameter)
                if not instant then
                    G.E_MANAGER:add_event(Event({trigger = 'after', delay = i == 1 and 0.2 or 0.9, func = function()
                        play_sound('tarot1')
                        if args.from then args.from:juice_up(0.8, 0.5) end
                        G.TAROT_INTERRUPT_PULSE = true
                        return true end }))
                    update_hand_text({delay = 0}, {[parameter] = G.GAME.hands[hand][parameter], StatusText = true})
                end
            end
        end
        if args.level_up then
            G.GAME.hands[hand].level = G.GAME.hands[hand].level + (type(args.level_up) == 'number' and args.level_up or 1)
            if not instant then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
                    play_sound('tarot1')
                    if args.from then args.from:juice_up(0.8, 0.5) end
                    G.TAROT_INTERRUPT_PULSE = nil
                    return true end }))
                update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {level=G.GAME.hands[hand].level})
            end
        end
        if not instant then delay(1.3) end
    end

    if not instant and not displayed then
        update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, vals_after_level or {mult = 0, chips = 0, handname = '', level = ''})
    end
end

SMODS.ease_types = {
    lerp = function(percent_done) return percent_done end,
    linear = function(percent_done) return percent_done end,
    insine = function(percent_done) return 1 - math.cos((percent_done * math.pi) / 2) end,
    outsine = function(percent_done) return math.cos((percent_done * math.pi) / 2) end,
    inoutsine = function(percent_done) return -math.cos(percent_done * math.pi) - 1 / 2 end,
    quad = function(percent_done) return percent_done * percent_done end,
    inquad = function(percent_done) return percent_done * percent_done end,
    outquad = function(percent_done) return 1 - (1 - percent_done) * (1 - percent_done) end,
    inoutquad = function(percent_done) return (percent_done < 0.5 and 2 * percent_done * percent_done or 1 - math.pow(-2 * percent_done + 2, 2) / 2) end,
    inexpo = function(percent_done) return math.pow(2, 10 * percent_done - 10) end,
    outexpo = function(percent_done) return 1 - math.pow(2, -10 * percent_done) end,
    inoutexpo = function(percent_done) return (percent_done < 0.5 and math.pow(2, 20 * percent_done - 10) / 2 or 2 - math.pow(2, -20 * percent_done + 10) / 2) end,
    incirc = function(percent_done) return 1 - math.sqrt(1 - math.pow(percent_done, 2)) end,
    outcirc = function(percent_done) return math.sqrt(1 - math.pow(percent_done - 1, 2)) end,
    inoutcirc = function(percent_done) return (percent_done < 0.5 and (1 - math.sqrt(1 - math.pow(2 * percent_done, 2))) / 2 or (math.sqrt(1 - math.pow(-2 * percent_done + 2, 2)) + 1) / 2) end,
    elastic = function(percent_done) return -math.pow(2, 10 * percent_done - 10) * math.sin((percent_done * 10 - 10.75) * 2*math.pi/3); end,
    inelastic = function(percent_done) return -math.pow(2, 10 * percent_done - 10) * math.sin((percent_done * 10 - 10.75) * 2*math.pi/3); end,
    outelastic = function(percent_done) return math.pow(2, -10 * percent_done) * math.sin((percent_done * 10 - 0.75) * (2 * math.pi) / 3) + 1 end,
    inoutelastic = function(percent_done) return (percent_done < 0.5 and -(math.pow(2, 20 * percent_done - 10) * math.sin((20 * percent_done - 11.125) * (2 * math.pi) / 4.5)) / 2 or (math.pow(2, -20 * percent_done - 10) * math.sin((20 * percent_done - 11.125) * (2 * math.pi) / 4.5)) / 2 + 1) end,
    inback = function(percent_done, c1, c2, c3) return c3 * percent_done * percent_done * percent_done - c1 * percent_done * percent_done end,
    outback = function(percent_done, c1, c2, c3) return 1 + c3 * math.pow(percent_done - 1, 3) + c1 * math.pow(percent_done - 1, 2) end,
    inoutback = function(percent_done, c1, c2, c3) return (percent_done < 0.5 and (math.pow(2 * percent_done, 2) * ((c2 + 1) * 2 * percent_done - c2)) / 2 or (math.pow(2 * percent_done - 2, 2) * ((c2 + 1) * (percent_done * 2 - 2) + c2) + 2) / 2) end,
}

-- Internal function used to provide more helpful crash messages when using assert
function SMODS.log_crash_info(info, defined)
    if not info then return end
    local str = info.source:sub(3, -2)
    local props = {}
    local line = defined and info.linedefined or info.currentline
    local line_message = defined and ' in function defined' or ''
    -- Split by space
    for v in string.gmatch(str, "[^%s]+") do
        table.insert(props, v)
    end
    local source = table.remove(props, 1)
    if source == "love" then
        return string.format("\n\nError exists in LÖVE file in '%s'%s at line %d\r\n", table.concat(props, " "):sub(2, -2), line_message, line)
    elseif source == "SMODS" then
        local modID = table.remove(props, 1)
        local fileName = table.concat(props, " ")
        if modID == '_' then
            return string.format("\n\nError exists in Steamodded in file '%s'%s at line %d\r\n", fileName:sub(2, -2), line_message, line)
        else
            return string.format("\n\nError exists in %s in file '%s'%s at line %d", SMODS.Mods[modID].name, fileName:sub(2, -2), line_message, line)
        end
    elseif source == "lovely" then
        local module = table.remove(props, 1)
        local fileName = table.concat(props, " ")
        return string.format("\n\nError exists in file '%s' at line %d (from lovely module %s)\r\n",
            fileName:sub(2, -2), line, module)
    else
        return string.format("\n\nError exists in %s at line %d\r\n", info.source, line)
    end
end