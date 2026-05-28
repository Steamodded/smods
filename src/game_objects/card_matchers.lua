SMODS.MatcherConditions = {}
SMODS.MatcherCondition = SMODS.GameObject:extend{
    obj_table = SMODS.MatcherConditions,
    obj_buffer = {},
    required_params = {
        'key',
    },
    inject = function(self) end,
    getter = function (card) return {} end
}

SMODS.MatcherCondition {
    key = "rank",
    getter = function (card)
        return {[SMODS.has_no_rank(card) and SMODS.card_matcher_nil_sentinel or card.base.value] = true}
    end
}
SMODS.MatcherCondition {
    key = "suit",
    getter = function (card)
        local keys
        if not SMODS.has_no_suit(card) then
            keys = card:get_suits()
        else
            keys = {[SMODS.card_matcher_nil_sentinel] = true}
        end
        return keys
    end
}
SMODS.MatcherCondition {
    key = "enhancement",
    getter = function (card)
        local keys = SMODS.get_enhancements(card)
        if not next(keys) then keys = {[SMODS.card_matcher_nil_sentinel] = true} end
        return keys
    end
}
SMODS.MatcherCondition {
    key = "edition",
    getter = function (card)
        return {[card.edition and card.edition.key or SMODS.card_matcher_nil_sentinel] = true}
    end
}
SMODS.MatcherCondition {
    key = "seal",
    getter = function (card)
        return {[card.seal or SMODS.card_matcher_nil_sentinel] = true}
    end
}
SMODS.MatcherCondition {
    key = "check_function",
}

-- Creates and returns (sanitized) matcher table
function SMODS.create_card_matcher(conditions)
    local matcher = {}
    for condition, flags in pairs(conditions) do
        SMODS.insert_card_matcher_condition(matcher, condition, flags)
    end
    return matcher
end

local _warn_invalid_condition = function (at, condition)
    sendWarnMessage(("%s called with invalid condition '%s'"):format(at, condition), "Utils")
end

local _general_insert_all_any_or_none = function(_table, condition, flags)
    local whitelist = { 
        all = true, 
        any = true, 
        none = true
    }
    if not whitelist[condition] then _warn_invalid_condition("SMODS.insert_card_matcher_condition", condition); return false end
    _table[condition] = {}
    for obj_key, v in pairs(flags[condition]) do
        if v then
            _table[condition][obj_key] = v
        end
    end
end
local _overlap_insert_flags = function (flags)
    local whitelist = {
        all = true,
        all_either = true,
        any = true,
        none = true,
        exact = true,
        at_least = true,
        at_most = true
    }
    local _flags = {}
    for flag, v in pairs(flags) do
        if whitelist[flag] then
            _flags[flag] = v
        else _warn_invalid_condition("SMODS.insert_card_matcher_condition -> insert overlap -> insert flags", flag) end
    end
    return _flags
end
local _overlap_insert_all_any_or_none = function(_table, condition, flags)
    local whitelist = { 
        all = true, 
        any = true, 
        none = true
    }
    if not whitelist[condition] then _warn_invalid_condition("SMODS.insert_card_matcher_condition -> insert overlap", condition); return false end
    _table[condition] = {}
    for obj_key, v in pairs(flags[condition]) do
        if v then
            if type(v) ~= "table" then v = {any = true} end
            _table[condition][obj_key] = _overlap_insert_flags(v)
        end
    end
end
local _matcher_insert_count = function(matcher, condition, subflags)
    matcher[condition].count = {}
    for flag, v in pairs(subflags) do
        if flag == "exact" then
            matcher[condition].count.exact = v
        elseif flag == "at_least" then
            matcher[condition].count.at_least = v
        elseif flag == "at_most" then
            matcher[condition].count.at_most = v
        elseif flag == "func" then
            matcher[condition].count.func = v
        elseif flag == "overlap" then
            matcher[condition].count.overlap = {}
            if v.all then
                _overlap_insert_all_any_or_none(matcher[condition].count.overlap, "all", v)
            end
            if v.any then
                _overlap_insert_all_any_or_none(matcher[condition].count.overlap, "any", v)
            end
            if v.none then
                _overlap_insert_all_any_or_none(matcher[condition].count.overlap, "none", v)
            end
        end
    end
end

function SMODS.insert_card_matcher_condition(matcher, condition, flags)
    if not SMODS.MatcherConditions[condition] then _warn_invalid_condition("SMODS.insert_card_matcher_condition", condition); return false end
    if condition == "check_function" then
        matcher.check_function = flags.check_function
        return true
    end
    matcher[condition] = {}
    if flags.all then
        _general_insert_all_any_or_none(matcher[condition], "all", flags)
    end
    if flags.any then
        _general_insert_all_any_or_none(matcher[condition], "any", flags)
    end
    if flags.none then
        _general_insert_all_any_or_none(matcher[condition], "none", flags)
    end
    if flags.count then
        _matcher_insert_count(matcher, condition, flags.count)
    end
    if matcher[condition] and flags.invert then
        matcher[condition].invert = true
    end
    return true
end

SMODS.card_matcher_nil_sentinel = "--NONE--"

local _matcher_evaluate_count_subflags = function(count_flag, total)
    local is_match = true
    local below = false
    if count_flag.exact then
        is_match = is_match and total == count_flag.exact
        if count_flag.exact > total then below = true end
    end
    if count_flag.at_most then
        is_match = is_match and total <= count_flag.at_most
        if total <= count_flag.at_most then below = true end
    end
    if count_flag.at_least then
        is_match = is_match and total >= count_flag.at_least
        below = total < count_flag.at_least
    end
    if count_flag.func then
        is_match = is_match and count_flag.func(total)
    end
    return is_match, below
end
local _matcher_evaluate_card_overlap = function(pcard_values, other_card_values, all)
    for p_value, v in pairs(pcard_values) do
        if v and other_card_values[p_value] then
            if not all then return true end
        elseif all then
            return false
        end
    end
    return not not all
end
local _matcher_evaluate_count_overlap_subflags = function (matcher, condition, other_condition, pcard, all_cards, subflags)
    local pcard_values = SMODS.MatcherConditions[other_condition].getter(pcard)
    local failed_cards = {}
    if subflags.any then
        for other_card, _ in pairs(all_cards) do
            if other_card ~= pcard and not failed_cards[other_card] then
                if other_condition ~= condition then
                    if not _matcher_evaluate_card_overlap(pcard_values, SMODS.MatcherConditions[other_condition].getter(other_card)) then
                        failed_cards[other_card] = true
                    end
                end
            end
        end
    end
    if subflags.all or subflags.all_either then
        local primary_card_values
        local check_card_values
        for other_card, _ in pairs(all_cards) do
            primary_card_values = pcard_values
            if other_card ~= pcard and not failed_cards[other_card] then
                if subflags.all_either then primary_card_values = ((matcher._pre_count[other_condition] or {})[pcard] or 0) <= ((matcher._pre_count[other_condition] or {})[other_card] or 0) and pcard_values or SMODS.MatcherConditions[other_condition].getter(other_card) end
                check_card_values = primary_card_values == pcard_values and SMODS.MatcherConditions[other_condition].getter(other_card) or pcard_values
                if not _matcher_evaluate_card_overlap(primary_card_values, check_card_values, true) then
                    failed_cards[other_card] = true
                end
            end
        end
    end
    if subflags.none then
        for other_card, _ in pairs(all_cards) do
            if other_card ~= pcard and not failed_cards[other_card] then
                if other_condition == condition or _matcher_evaluate_card_overlap(pcard_values, SMODS.MatcherConditions[other_condition].getter(other_card)) then
                    failed_cards[other_card] = true
                end
            end
        end
    end
    local success_number = table_length(all_cards) - table_length(failed_cards)
    local success = _matcher_evaluate_count_subflags(subflags, success_number)
    if not success then return 0 end
    return success_number
end
local _matcher_evaluate_count_overlap = function(matcher, condition, pcard, property_value)
    local overlap_flag = matcher[condition].count.overlap
    local all_cards = matcher._pre_count[condition][property_value]
    if overlap_flag.all then
        for other_condition, subflags in pairs(overlap_flag.all) do
            local success_number = _matcher_evaluate_count_overlap_subflags(matcher, condition, other_condition, pcard, all_cards, subflags)
            if not _matcher_evaluate_count_subflags(matcher[condition].count, success_number) then return false end
        end
    end
    
    local any_succeeded = false
    if overlap_flag.any then
        for other_condition, subflags in pairs(overlap_flag.any) do
            local success_number = _matcher_evaluate_count_overlap_subflags(matcher, condition, other_condition, pcard, all_cards, subflags)
            if _matcher_evaluate_count_subflags(matcher[condition].count, success_number) then
                any_succeeded = true
                break
            end
        end
    end
    if overlap_flag.any and not any_succeeded then return false end
    
    if overlap_flag.none then
        for other_condition, subflags in pairs(overlap_flag.none) do
            local success_number = _matcher_evaluate_count_overlap_subflags(matcher, condition, other_condition, pcard, all_cards, subflags)
            if _matcher_evaluate_count_subflags(matcher[condition].count, success_number) then return false end
        end
    end
    return true
end
local _matcher_evaluate_count = function(matcher, pcard, condition)
    local is_match = true
    local below -- Optimization to not calculate overlap, because overlap can only reduce the count
    local keys = SMODS.MatcherConditions[condition].getter(pcard)
    for key, v in pairs(keys) do
        if v then
            is_match, below = _matcher_evaluate_count_subflags(matcher[condition].count, table_length(matcher._pre_count[condition][key]))
            if not below and matcher[condition].count.overlap then
                is_match = _matcher_evaluate_count_overlap(matcher, condition, pcard, key)
            end
            if is_match then break end
        end
    end
    return is_match
end

function SMODS.matcher_evaluate_card(matcher, pcard)
    for condition, _ in pairs(matcher) do
        if not SMODS.matcher_partial_evaluate(matcher, pcard, condition) then
            return false
        end
    end
    return true
end

function SMODS.matcher_partial_evaluate(matcher, pcard, condition)
    local simplified = {
        rank = true,
        enhancement = true,
        seal = true,
        edition = true,
        suit = true,
    }
    local partial_match = true 
    if simplified[condition] then
        local card_values = SMODS.MatcherConditions[condition].getter(pcard)
        if matcher[condition].all then
            for key, _ in pairs(matcher[condition].all) do
                partial_match = card_values[key]
                if not partial_match then break end
            end
            if not partial_match then goto skip end
        end
        if matcher[condition].any then
            for key, _ in pairs(matcher[condition].any) do
                partial_match = card_values[key]
                if partial_match then break end
            end
            if not partial_match then goto skip end
        end
        if matcher[condition].none then
            for key, _ in pairs(matcher[condition].none) do
                partial_match = not card_values[key]
                if not partial_match then break end
            end
            if not partial_match then goto skip end
        end
    elseif condition == "check_function" then
        partial_match = matcher.check_function(pcard, matcher)
    end
    if matcher[condition].count then
        partial_match = _matcher_evaluate_count(matcher, pcard, condition)
    end
    ::skip::
    if matcher[condition].invert then partial_match = not partial_match end
    return partial_match
end

local _matcher_count_condition = function(matcher, condition, pcard)
    matcher._pre_count[condition][pcard] = 0 -- Number of [condition]s a card has -> used by overlap.all_either to determine the primary card
    for key, _ in pairs(SMODS.MatcherConditions[condition].getter(pcard)) do
        matcher._pre_count[condition][key] = matcher._pre_count[condition][key] or {}
        matcher._pre_count[condition][key][pcard] = true
        matcher._pre_count[condition][pcard] = matcher._pre_count[condition][pcard] + 1
    end
end

function SMODS.match_cards(cards, matchers)
    local matchers_met_cards = {} -- {matcher 1 = {map of cards that met it}, matcher 2 = ...}
    local cards_met_matchers = {} -- Inverse of the above
    -- Precalculate conditions like .count, so that all conditions can be correctly partially matched at once.
    for i, matcher in ipairs(matchers) do
        for condition, flags in pairs(matcher) do
            if flags.count then
                matcher._pre_count = matcher._pre_count or {} -- Counterintuitively, this is of form table<condition (e.g. "seal"), table<value (e.g. "Red"), table<Card, boolean>>>, so to get the actual count table_length() has to be called on the innermost table.
                matcher._pre_count[condition] = {}
                for _, pcard in ipairs(cards) do
                    _matcher_count_condition(matcher, condition, pcard)
                end
            end
        end
    end
    for i, matcher in ipairs(matchers) do
        matchers_met_cards[matcher] = {}
        for _, pcard in ipairs(cards) do
            if i == 1 then
                cards_met_matchers[pcard] = {}
            end
            if SMODS.matcher_evaluate_card(matcher, pcard) then
                matchers_met_cards[matcher][pcard] = true
                cards_met_matchers[pcard][matcher] = true
            end
        end
        matcher._pre_count = nil
    end
    return matchers_met_cards, cards_met_matchers
end

function SMODS.get_hand_from_matching(matchers_to_cards, cards_to_matchers, args)
    args = args or {}
    args.deduplicate_matches = args.deduplicate_matches == nil or args.deduplicate_matches -- Defaults to true
    if args.matcher_max_cards then -- This duplicates matchers so that they may take up more than one card in the final hand.
        for matcher, max in pairs(args.matcher_max_cards) do
            while max > 1 do
                max = max - 1
                local dummy = {} -- None of the actual matcher fields are needed anymore
                matchers_to_cards[dummy] = matchers_to_cards[matcher]
                for pcard, _ in pairs(matchers_to_cards[matcher]) do
                    cards_to_matchers[pcard][dummy] = true
                end
            end
        end
    end
    local matcher_n = table_length(matchers_to_cards)
    local card_n = table_length(cards_to_matchers)
    if args.deduplicate_matches and matcher_n > card_n then
        return {} 
    end
    for matcher, pcards in pairs(matchers_to_cards) do
        if not next(pcards) then
            return {}
        end
    end
    if not args.deduplicate_matches then -- Yay this is simple
        local hand = {}
        for pcard, matchers in pairs(cards_to_matchers) do
            if next(matchers) then 
                hand[#hand+1] = pcard
            end
        end
        return {hand}
    end

    -- Recursive bipartite matching function
    local bpm
    bpm = function(matcher, c_to_m, used_c)
        for pcard, _ in pairs(matchers_to_cards[matcher]) do
            if not used_c[pcard] then
                used_c[pcard] = true
                if not c_to_m[pcard] or bpm(c_to_m[pcard], c_to_m, used_c) then
                    c_to_m[pcard] = matcher
                    return true
                end
            end
        end
    end

    local used_cards = {}
    local card_to_matcher = {}
    local count = 0
    for matcher, _ in pairs(matchers_to_cards) do
        used_cards = {}
        if bpm(matcher, card_to_matcher, used_cards) then
            count = count + 1
        end
    end
    if count == matcher_n then
        local hand = {}
        if args.all_matched_cards_score then -- Every matcher has a unique card, but all cards that matched any matcher should still score
            for pcard, matchers in pairs(cards_to_matchers) do
                if next(matchers) then 
                    hand[#hand+1] = pcard
                end
            end
        else
            for pcard, _ in pairs(card_to_matcher) do
                hand[#hand+1] = pcard
            end
        end
        return {hand}
    end
    return {}
end