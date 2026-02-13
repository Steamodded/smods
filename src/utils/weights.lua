-- TODO: labels are union or interset
-- TODO: filter function accepted

-- Returns a `key` of the polled object type
---@param args table|{type: string?, labels: table[string]?, pool: table[string]?, seed: string?, chance: number?, guaranteed: boolean?}
function SMODS.poll_object(args)
    assert(args, "SMODS.poll_object called with no args."..SMODS.log_crash_info(debug.getinfo(2)))
    assert((args.type or (args.labels and type(args.labels) == 'table') or (args.pool and type(args.pool) == 'table')), "SMODS.poll_object called without a pool source." .. SMODS.log_crash_info(debug.getinfo(2)))

    -- Prepare pool
    local pool = args.pool or {}
    local types = args.labels or {args.type}
    local total_weight = 0
    local modded_weight = 0
    local chance = (args.guaranteed and 1 or args.chance or SMODS.base_rate_percentage[args.type] or 1) * (args.mod or 1)
    local poll_key = pseudorandom(pseudoseed(args.seed or SMODS.get_poll_key(args.type)))
    if not args.pool then
        for _, label in ipairs(types) do
            local temp_pool = {}
            for i=1, #(args.rarities or {true}) do
                local _p = label == 'Blind' and get_new_boss(true) or get_current_pool(label, args.rarities and args.rarities[i])
                if label == 'Edition' then
                    local _options = {}
                    for _, edition in ipairs(_p) do
                        if G.P_CENTERS[edition] and G.P_CENTERS[edition].vanilla then
                            table.insert(_options, 1, edition)
                        elseif G.P_CENTERS[edition] then
                            table.insert(_options, edition)
                        end
                    end
                    _p = _options
                end
                temp_pool = SMODS.merge_lists({temp_pool, _p})
            end
            for _, v in ipairs(temp_pool) do
                if G[SMODS.game_table_from_type[label] or 'P_CENTERS'][v] then table.insert(pool, {key = v, type = label}) end
            end
        end
    end
    
    if args.filter then pool = args.filter(pool) end
    
    -- Check pool has valid options
    assert(#pool > 0, "SMODS.poll_object called with an empty pool."..SMODS.log_crash_info(debug.getinfo(2)))
    
    local final_pool = {}
    for _, key in ipairs(pool) do
        local weight_table = {}
        
        local w, m_w = SMODS.get_weight_of_object(G[SMODS.game_table_from_type[key.type] or 'P_CENTERS'][key.key or key], key.weight)
        modded_weight = modded_weight + m_w
        weight_table = {key = key.key or key, weight = w, mod_weight = modded_weight}
        
        total_weight = total_weight + weight_table.weight
        table.insert(final_pool, weight_table)
        if args.print then print(string.format("Key: %s, Weight: %s, Modded Weight: %s", weight_table.key, weight_table.weight, weight_table.mod_weight)) end
    end

    
    if args.print then print('Total Weight: '..total_weight) end
    if args.print then print('Modded Weight:'..modded_weight) end
    if args.print then print('Base Chance: '..chance) end

    -- Adjust chance based on modified weightings
    chance = chance * (modded_weight/total_weight)
    if args.print then print('Mod Chance: '..chance) end
    if args.print then print('Poll Key:'..poll_key) end

    if poll_key < (1 - chance) then
        if args.print then print('Poll failed') end
        return
    end

    if not SMODS.no_repoll[args.type] then
        poll_key = pseudorandom(pseudoseed(args.type_key or SMODS.get_poll_key(args.type, args.append or 'type')))
        if args.print then print('Poll key string:', args.type_key or SMODS.get_poll_key(args.type, args.append or 'type')) end
        chance = 1
    end
    if args.print then print('Poll key: '..poll_key) end

    -- Find weight
    local poll_weight = modded_weight - (poll_key - (1 - chance))/chance * modded_weight
    if args.print then print('Looking for item: '..poll_weight) end
    local low = 1
    local high = #final_pool
    local ind = 1
    if poll_weight > final_pool[1].mod_weight then ind = SMODS.select_by_weight(final_pool, poll_weight, low, high) end
    -- print('Index: '..ind)
    -- print(final_pool[ind].key)

    if args.no_negative and final_pool[ind].key == 'e_negative' then return 'e_polychrome' end

    return final_pool[ind].key
end

-- Returns the `weight` and `modified_weight` or a given object
---@param args table|{key: string, no_mod: boolean?} 
function SMODS.get_weight_of_object(obj, opt_weight)
    if not obj then return 10, 10 end
    local w = opt_weight or obj.weight or 10
    local m = not opt_weight and obj.get_weight and obj:get_weight(w) or w

    return w, m
end

function SMODS.select_by_weight(pool, poll, low, high, depth)
    if high - low <= 1 then return high end
    local check = math.floor((low + high)/2)
    if poll < pool[check].mod_weight then
        high = check
    else
        low = check
    end
    return SMODS.select_by_weight(pool, poll, low, high, (depth or 0) + 1)
end

SMODS.base_rate_percentage = {
    Enhanced = 0.40,
    Seal = 0.02,
    Edition = 0.04
}

SMODS.no_repoll = {
    Edition = true,
}

SMODS.game_table_from_type = {
    Seal = 'P_SEALS',
    Tag = 'P_TAGS',
    Blind = 'P_BLINDS',
    Card = 'P_CARDS',
    Stake = 'P_STAKES'
}

SMODS.poll_keys = {
    Edition = {str = 'edition_generic', block_infill = true},
    Seal = {str = 'stdseal', ante = true},
    Enhanced = {str = 'Enhanced', ante = true}
}

function SMODS.get_poll_key(type, infill)
    local t = SMODS.poll_keys[type] or {str = 'std_smods_poll', ante = true}
    return t.str .. (t.block_infill and "" or infill or "") .. (t.ante and G.GAME.round_resets.ante or "")
end

function SMODS.create_blind_pool(type, skip_cull)
    local eligible_bosses = {}
    for k, v in pairs(G.P_BLINDS) do
        local res, options = SMODS.add_to_pool(v)
        options = options or {}
        if not v[type] then
        elseif options.ignore_showdown_check then
            eligible_bosses[k] = res and true or nil
        elseif type == 'boss' then
            if
                ((SMODS.is_showdown_ante()) == (v.boss.showdown or false)) and ((v[type].min or G.GAME.round_resets.ante) <= math.max(1, G.GAME.round_resets.ante)) and ((v[type].max or G.GAME.round_resets.ante) >= G.GAME.round_resets.ante)
            then
                eligible_bosses[k] = res and true or nil
            end
        else
            if (v[type].min or G.GAME.round_resets.ante) <= math.max(1, G.GAME.round_resets.ante) and (v[type].max or G.GAME.round_resets.ante) >= G.GAME.round_resets.ante then
                eligible_bosses[k] = res and true or nil
            end
        end
    end
    for k, v in pairs(G.GAME.banned_keys) do
        if eligible_bosses[k] then eligible_bosses[k] = nil end
    end

    if skip_cull then return eligible_bosses end

    local min_use = 100
    for k, v in pairs(G.GAME.bosses_used) do
        if eligible_bosses[k] then
            eligible_bosses[k] = v
            if eligible_bosses[k] <= min_use then 
                min_use = eligible_bosses[k]
            end
        end
    end
    for k, v in pairs(eligible_bosses) do
        if eligible_bosses[k] then
            if eligible_bosses[k] > min_use then 
                eligible_bosses[k] = nil
            end
        end
    end
    
    return eligible_bosses
end

function SMODS.is_showdown_ante()
    return G.GAME.round_resets.ante%G.GAME.win_ante == 0 and G.GAME.round_resets.ante > 0
end