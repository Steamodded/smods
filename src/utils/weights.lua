-- TODO: how do soul objects fit into this system?

-- Returns a `key` of the polled object type
---@param args table|{type: string?, attributes: table[string]?, pool: table[string]?, seed: string?, chance: number?, guaranteed: boolean?}
function SMODS.poll_object(args)
    assert(args, "SMODS.poll_object called with no args."..SMODS.log_crash_info(debug.getinfo(2)))
    assert((args.type or (args.types and type(args.types) == 'table') or (args.attributes and type(args.attributes) == 'table') or (args.pool and type(args.pool) == 'table')), "SMODS.poll_object called without a pool source." .. SMODS.log_crash_info(debug.getinfo(2)))

    -- Prepare pool
    local pool = args.pool or {}
    local types = args.attributes or args.types or {args.type}

    -- Populate pool
    local types_used = {}

    if not args.pool then
        pool, types_used = SMODS.create_poll_pool(types, args)
    end
    
    if args.filter then pool = args.filter(pool) end
    
    -- Check pool has valid options
    assert(#pool > 0, "SMODS.poll_object called with an empty pool."..SMODS.log_crash_info(debug.getinfo(2)))
    
    local total_weight = 0
    local weight_pool = {}
    for _, key in ipairs(pool) do
        local weight_table = {}
        
        local w, m_w = SMODS.get_weight_of_object(G[SMODS.game_table_from_type[key.type] or 'P_CENTERS'][key.key or key], key.weight, args)
        weight_table = {key = key.key or key, weight = m_w}
        
        total_weight = total_weight + w
        weight_pool[#weight_pool + 1] = weight_table
        weight_pool[key.key or key] = weight_table
        
        if args.print then print(string.format("Key: %s, Base weight: %s, Final weight: %s", weight_table.key, w, weight_table.weight)) end
    end
    
    -- Allow calculate functions to modify the pool table
    SMODS.calculate_context({modify_weights = true, pool = weight_pool, pool_types = types_used})
    local modded_weight = 0

    -- Prepare final table to poll
    local final_pool = {}
    for _, weight_table in ipairs(weight_pool) do
        modded_weight = modded_weight + weight_pool[weight_table.key].weight
        weight_table.mod_weight = modded_weight
        final_pool[#final_pool + 1] = weight_table
        if args.print then print(string.format("Key: %s, Weight: %s, Position: %s", weight_table.key, weight_table.weight, weight_table.mod_weight)) end
    end
    
    local chance = (args.guaranteed or not (args.chance or SMODS.base_rate_percentage[args.type])) and 1 or ((args.chance or SMODS.base_rate_percentage[args.type] or 1) * (args.mod or 1) * (modded_weight/total_weight))
    -- Adjust chance based on modified weightings
    -- chance = chance * (modded_weight/total_weight)
    local output_key = 'UNAVAILABLE'

    while output_key == 'UNAVAILABLE' do
        local poll_key = pseudorandom(pseudoseed(args.seed or SMODS.get_poll_key(args.type)))
        
        if args.print then print('Total Weight: '..total_weight) end
        if args.print then print('Modded Weight:'..modded_weight) end
        if args.print then print('Base Chance: '..chance) end

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

        if poll_weight > final_pool[1].mod_weight then
            output_key = final_pool[SMODS.select_by_weight(final_pool, poll_weight, 1, #final_pool)].key
        else 
            output_key = final_pool[1].key
        end
    end

    -- Edition specific functionality
    if args.no_negative and output_key == 'e_negative' then return 'e_polychrome' end


    return output_key
end

-- Returns the `weight` and `modified_weight` or a given object
---@param args table|{key: string, no_mod: boolean?} 
function SMODS.get_weight_of_object(obj, opt_weight, args)
    if not obj then return 10, 10 end
    local w = opt_weight or obj.weight or 10
    local m = not opt_weight and obj.get_weight and obj:get_weight(w, args) or w

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

function SMODS.create_blind_pool(blind_type, skip_cull)
    assert(type(blind_type) == 'string', "SMODS.create_blind_pool called with a non-string type argument."..SMODS.log_crash_info(debug.getinfo(2)))
    local eligible_bosses = {}
    for k, v in pairs(G.P_BLINDS) do
        local res, options = SMODS.add_to_pool(v)
        options = options or {}
        if not v[blind_type] then
        elseif options.ignore_showdown_check then
            eligible_bosses[k] = res and true or nil
        elseif blind_type == 'boss' then
            if
                ((SMODS.is_showdown_ante()) == (v.boss.showdown or false)) and ((v[blind_type].min or G.GAME.round_resets.ante) <= math.max(1, G.GAME.round_resets.ante)) and ((v[blind_type].max or G.GAME.round_resets.ante) >= G.GAME.round_resets.ante)
            then
                eligible_bosses[k] = res and true or nil
            end
        else
            if (v[blind_type].min or G.GAME.round_resets.ante) <= math.max(1, G.GAME.round_resets.ante) and (v[blind_type].max or G.GAME.round_resets.ante) >= G.GAME.round_resets.ante then
                eligible_bosses[k] = res and true or nil
            end
        end
    end
    for k, v in pairs(G.GAME.banned_keys) do
        if eligible_bosses[k] then eligible_bosses[k] = nil end
    end

    if skip_cull then 
        local final_pool = {}
        for k, _ in pairs(eligible_bosses) do
            final_pool[#final_pool + 1] = k
        end
        return final_pool
    end

    local min_use = 100
    for k, v in pairs(G.GAME.bosses_used) do
        if eligible_bosses[k] then
            eligible_bosses[k] = v
            if eligible_bosses[k] <= min_use then 
                min_use = eligible_bosses[k]
            end
        end
    end
    local final_pool = {}
    for k, v in pairs(eligible_bosses) do
        if eligible_bosses[k] then
            if eligible_bosses[k] > min_use then 
                eligible_bosses[k] = nil
            else
                final_pool[#final_pool + 1] = k
            end
        end
    end

    local output = {}
    for k, _ in pairs(eligible_bosses) do
        output[#output + 1] = k
    end
    
    return output
end

local function SMODS_WEIGHTS_poll_rarity(pool, args)
    local rarity_poll = pseudorandom(pseudoseed((args.seed or 'smods_cull_rarity')..'_cull' )) -- Generate the poll value
    local available_rarities = copy_table(SMODS.ObjectTypes[args.type or 'Joker'].rarities) -- Table containing a list of rarities and their rates
    local vanilla_rarities = {["Common"] = 1, ["Uncommon"] = 2, ["Rare"] = 3, ["Legendary"] = 4}
    local final_rarities = {}
    
	-- Check to see if any rarities are empty and should be disabled
    for _, v in ipairs(available_rarities) do
        local missing = true
        local i = 1
        while missing and i <= #pool do
            if G.P_CENTERS[pool[i]] and G.P_CENTERS[pool[i]].rarity == (vanilla_rarities[v.key] or v.key) then
                missing = false
            end
            i = i+1
        end
        if not missing then
            final_rarities[#final_rarities + 1] = v
        end
    end

    -- Calculate total rates of rarities
    local total_weight = 0
    for _, v in ipairs(final_rarities) do
        v.mod = G.GAME[tostring(v.key):lower().."_mod"] or 1
        -- Should this fully override the v.weight calcs?
        if SMODS.Rarities[v.key] and SMODS.Rarities[v.key].get_weight and type(SMODS.Rarities[v.key].get_weight) == "function" then
            v.weight = SMODS.Rarities[v.key]:get_weight(v.weight, SMODS.ObjectTypes[args.type or 'Joker'])
        end
        v.weight = v.weight*v.mod
        total_weight = total_weight + v.weight
    end
    -- recalculate rarities to account for v.mod
    for _, v in ipairs(final_rarities) do
        v.weight = v.weight / total_weight
    end

    -- Calculate selected rarity
    local weight_i = 0
    for _, v in ipairs(final_rarities) do
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

-- Create a table of {key = string, type = label} items to be polled
function SMODS.create_poll_pool(labels, args)
    local labels_used = {}
    local pool = {}
    local final_pool = {}
    local it = 0
    
    local function join_lists(args)
        local l1 = args[1] or {}
        local l2 = args[2] or {}
        for _, v in ipairs(l2) do
            l1[#l1 + 1] = v
        end
        return l1
    end

    local function pool_exists(pool)
        for _, v in ipairs(pool) do
            if v ~= 'UNAVAILABLE' then return true end
        end
        return false
    end
    
    for _, label in ipairs(labels) do
        labels_used[label] = true
        local temp_pool = {}
        local join_func = (args.attributes and not args.union) and SMODS.intersect_lists or join_lists
        for i=1, #(args.rarities or {true}) do
            local _p = label == 'Blind' and SMODS.create_blind_pool(args.blind_type or 'boss') or SMODS.Attributes[label] and SMODS.get_attribute_pool(label) or get_current_pool(label, args.rarities and args.rarities[i], nil, args.append)
            if SMODS.Attributes[label] then
                _p = SMODS.cull_pool(_p, args)
            end
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
            temp_pool = join_lists({temp_pool, _p})
        end
        for _, v in ipairs(temp_pool) do
            pool[v] = {key = v, type = label}
        end
        local temp = pool_exists(final_pool) and final_pool and join_func({final_pool, temp_pool}) or temp_pool
        final_pool = (args.closest_match and not pool_exists(temp)) and final_pool or temp
    end
    
    if args.attributes and not args.rarity and args.rarity ~= false then
        args.rarity = SMODS_WEIGHTS_poll_rarity(final_pool, args)
        final_pool = SMODS.cull_pool(final_pool, args)
    end

    local ret_pool = {}
    local pool_exists = false
    for i, k in ipairs(final_pool) do
        if not pool_exists and k ~= 'UNAVAILABLE' then pool_exists = true end
        table.insert(ret_pool, pool[k])
    end

    if not pool_exists then ret_pool = {{key = 'j_joker', type = 'Joker'}} end

    return ret_pool, labels_used
end

function SMODS.is_showdown_ante()
    return G.GAME.round_resets.ante%G.GAME.win_ante == 0 and G.GAME.round_resets.ante > 0
end

-- New create_card_for_shop structure
function SMODS.create_shop_card(area)
    -- Tutorial Override
    if area == G.shop_jokers and G.SETTINGS.tutorial_progress and G.SETTINGS.tutorial_progress.forced_shop and G.SETTINGS.tutorial_progress.forced_shop[#G.SETTINGS.tutorial_progress.forced_shop] then
        local t = G.SETTINGS.tutorial_progress.forced_shop
        local _center = G.P_CENTERS[t[#t]] or G.P_CENTERS.c_empress
        local card = Card(area.T.x + area.T.w/2, area.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, _center, {bypass_discovery_center = true, bypass_discovery_ui = true})
        t[#t] = nil
        if not t[1] then G.SETTINGS.tutorial_progress.forced_shop = nil end
        
        create_shop_card_ui(card)
        return card
    end
    -- Tags that affect shop override
    local forced_tag = nil
    for k, v in ipairs(G.GAME.tags) do
        if not forced_tag then
            forced_tag = v:apply_to_run({type = 'store_joker_create', area = area})
            if forced_tag then
                for kk, vv in ipairs(G.GAME.tags) do
                    if vv:apply_to_run({type = 'store_joker_modify', card = forced_tag}) then break end
                end
            return forced_tag
            end
        end
    end

    -- Poll a type for the shop
    local card_args = {
        type = SMODS.poll_object_type({seed = 'cdt'..G.GAME.round_resets.ante}),
        area = area
    }
    card_args.key = SMODS.poll_object({type = card_args.type, append = 'sho'})

    local flags = SMODS.calculate_context({create_shop_card = true, set = card_args.type, key = card_args.key})

    local card = SMODS.create_card(SMODS.merge_defaults(flags.shop_create_flags or {}, card_args))

    SMODS.calculate_context({modify_shop_card = true, card = card})

    create_shop_card_ui(card)

    -- Tag modifier check
    G.E_MANAGER:add_event(Event({
        func = (function()
            for k, v in ipairs(G.GAME.tags) do
                if v:apply_to_run({type = 'store_joker_modify', card = card}) then break end
            end
            return true
        end)
    }))

    if (card.ability.set == 'Default' or card.ability.set == 'Enhanced') and G.GAME.used_vouchers["v_illusion"] and pseudorandom(pseudoseed('illusion')) > 0.8 then 
        card:set_edition(poll_edition('illusion', nil, true, true))
    end

    return card
end

function SMODS.poll_object_type(args)
    args = args or {}
    
    -- If no types are given to select between, populate the list with all valid types
    if not args.types then
        args.types = {
            'Joker', 'playing_card',
        }
        for _,v in ipairs(SMODS.ConsumableType.obj_buffer) do
            args.types[#args.types + 1] = v
        end
    else
        -- Ensure types are in correct format
        assert(type(args.types) == 'table',  "SMODS.poll_object_type called with invalid types table."..SMODS.log_crash_info(debug.getinfo(2)))
    end

    local total_rate = 0
    local weighted_table = {}
    -- Populate `weighted_table` by finding the rates in G.GAME
    for _, type in ipairs(args.types) do
        total_rate = total_rate + G.GAME[type:lower()..'_rate']
        weighted_table[#weighted_table + 1] = {type = type, rate = G.GAME[type:lower()..'_rate'], mod_weight = total_rate}

        -- Playing Card modify type between Base and Enhanced
        if type == 'playing_card' then weighted_table[#weighted_table].type = (G.GAME.used_vouchers["v_illusion"] and pseudorandom(pseudoseed('illusion')) > 0.6) and 'Enhanced' or 'Base' end

        if args.print then print(string.format("Type: %s, Weight: %s, Position: %s", type, G.GAME[type:lower()..'_rate'], total_rate)) end
    end

    -- Adjust the pseudorandom number by the total_rate to obtain a number to check against the `mod_weight` values
    local poll_weight = pseudorandom(args.seed or 'smods_poll_object_type') * total_rate

    if args.print then print('Looking for item: '..poll_weight) end

    local ind = 1
    -- If first element is not target, find correct index
    if poll_weight > weighted_table[1].mod_weight then ind = SMODS.select_by_weight(weighted_table, poll_weight, 1, #weighted_table) end
    if SMODS.debug_prints then print(weighted_table[ind].type) end
    return weighted_table[ind].type
end

function SMODS.cull_pool(pool, args)
    local final_pool = {}
    
    local _rarity = args.rarity and args.rarity ~= true and args.rarity

    for _, key in ipairs(pool) do
        local add = nil
        local v = G.P_CENTERS[key]
        if v then
            local in_pool, pool_opts = SMODS.add_to_pool(v, { source = args.append })
            pool_opts = pool_opts or {}
            if not (G.GAME.used_jokers[v.key] and not pool_opts.allow_duplicates and not SMODS.showman(v.key) and not args.allow_duplicates) and (v.unlocked ~= false or (v.rarity == 4 and args.allow_legendaries)) and (not _rarity or _rarity == v.rarity) then
                if v.enhancement_gate then
                    add = nil
                    for kk, vv in pairs(G.playing_cards) do
                        if SMODS.has_enhancement(vv, v.enhancement_gate) then
                            add = true
                        end
                    end
                else
                    add = true
                end
            end

            if v.no_pool_flag and G.GAME.pool_flags[v.no_pool_flag] then add = nil end
            if v.yes_pool_flag and not G.GAME.pool_flags[v.yes_pool_flag] then add = nil end
            
            add = in_pool and (add or ((not _rarity or _rarity == v.rarity) and pool_opts.override_base_checks))
            
            if add and not G.GAME.banned_keys[v.key] then 
                final_pool[#final_pool + 1] = v.key
            else
                final_pool[#final_pool + 1] = 'UNAVAILABLE'
            end
        end
    end

        
    return final_pool
end

local smods_get_voucher_key = get_next_voucher_key
function get_next_voucher_key(_from_tag)
    if SMODS.optional_features.object_weights then return SMODS.poll_object({type = 'Voucher'}) end
    return smods_get_voucher_key(_from_tag)
end
