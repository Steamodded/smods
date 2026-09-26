---@meta

---@class SMODS.MatcherCondition: SMODS.GameObject
---@field obj_buffer? string[] Array of keys to all objects registered to this class. 
---@field obj_table? table<Ranks|string, SMODS.MatcherCondition|table> Table of objects registered to this class. 
---@field super? SMODS.GameObject|table Parent class. 
---@field __call? fun(self: SMODS.MatcherCondition|table, o: SMODS.MatcherCondition|table): nil|table|SMODS.MatcherCondition
---@field extend? fun(self: SMODS.MatcherCondition|table, o: SMODS.MatcherCondition|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.MatcherCondition|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.MatcherCondition|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.MatcherCondition|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.MatcherCondition|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.MatcherCondition|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.MatcherCondition|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.MatcherCondition|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.MatcherCondition|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.MatcherCondition|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.MatcherCondition|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.MatcherCondition|table, key: string, obj: SMODS.MatcherCondition|table, silent?: boolean): nil|table|SMODS.MatcherCondition Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.MatcherCondition|table, key: string): SMODS.MatcherCondition|table? Returns an object if one matches the `key`. 
---@field loc_vars? fun(self: SMODS.MatcherCondition|table, info_queue: table, card: Card|table) Allows adding tooltips onto cards with this suit. Return values not respected. 
---@field in_pool? fun(self: SMODS.MatcherCondition|table, args: table): boolean? Allows configuring if cards with this suit should spawn. 
---@field delete? fun(self: SMODS.MatcherCondition|table) Deletes this suit. 
---@overload fun(self: SMODS.MatcherCondition): SMODS.MatcherCondition---@overload fun(self: SMODS.ConsumableType): SMODS.ConsumableType
SMODS.MatcherCondition = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.MatcherCondition|table>
SMODS.MatcherConditions = {}


--- Conditions: (format {[condition] = {flags}, [condition 2] = ...})
--- Shared flags (most conditions support these):
---     "any" = {...}           -> map of keys, matcher matches if the card is/has any of them (quantum ranks/seals/editions are currently not supported)
---     "all" = {...}           -> ^ same but only matches if the card is all of them (quantum ranks/seals/editions are currently not supported)
---     "none" = {...}          -> ^ same but only matches if the card is none of them
---     "count" = {...}         -> "count" has the following subflags;
---             "exact" = integer       -> The exact number of cards that must share a card's property, e.g. its enhancement, for the matcher to match a card.
---             "at_least" = integer    -> The minimum number of cards ...^
---             "at_most" = integer     -> The maximum number of cards ...^
---             "func" = function       -> A function, which is called with the total number of cards that share a card's property (^), expecting a boolean return value to determine whether it matches or not. -> e.g. is_even() check or similar
---             "overlap" = {...}       -> "overlap" allows for linking conditions and has the following subflags;
---                     "any" = {...}       -> A map of conditions; A card which shares the base condition (e.g. enhancement) with another card must also share any of the conditions in this map.
---                     "all" = {...}       -> Same as the above, but a card must share all conditions.
---                     "none" = {...}      -> Same but only matches if the card shares none of them.
---                             [condition] = true, or {...};   -> These per-condition flags allow overlapping cards based on how many of the [condition] overlap;
---                                     "any" = boolean         -> any [condition]s overlap
---                                     "all" = boolean         -> all [condition]s of the primary card checked overlap with the card checked against
---                                     "all_either" = boolean  -> all [condition]s of the card with fewer [condition]s overlap with the other card 
---                                     "none" = boolean        -> none of the [condition]s overlap
---                                     "exact" = integer       -> [exact] number of cards overlap
---                                     "at_least" = integer    -> [at_least] number of cards overlap
---                                     "at_most" = integer     -> [at_most] number of cards overlap
---                                     "func" = functions      -> see above count.func
---     "invert" = boolean      -> If true, inverts the final result of a condition.
--- Unique flags:
--- "check_function" condition:
---     flags = [function]      -> matcher.check_function(pcard, matcher) is called for every card, expecting a boolean return value for whether it matched or not
---@param conditions table<"rank"|"enhancement"|"seal"|"edition"|"suit"|"check_function", table<string, table>|function>
---@return table<string, table> matcher A matcher is a table with conditions as keys and flags as values, e.g. '{enhancement = {any = {m_stone = true, m_lucky = true}}}' would be a matcher to match a card that is either stone or lucky. 
function SMODS.create_card_matcher(conditions) end

--- Internal function for creating a card matcher, hooking this and SMODS.matcher_partial_evaluate() allows adding new conditions.
---@param matcher table<string, table> See SMODS.create_card_matcher()
---@param condition string See SMODS.create_card_matcher()
---@param flags table See SMODS.create_card_matcher()
function SMODS.insert_card_matcher_condition(matcher, condition, flags) end

--- Internal function for checking if a matcher matches a card, hooking this and SMODS.insert_card_matcher_condition() allows adding new conditions.
---@param matcher table<string, table> The matcher to evaluate, see SMODS.create_card_matcher()
---@param pcard Card The card to evaluate
---@param condition string See SMODS.create_card_matcher()
function SMODS.matcher_partial_evaluate(matcher, pcard, condition) end

---@param matcher table<string, table> See SMODS.create_card_matcher()
---@param pcard Card The card to evaluate
---@return boolean is_match
function SMODS.matcher_evaluate_card(matcher, pcard) end

---@param cards table<integer, Card> The cards to match
---@param matchers table<integer, table<string, table>> The matchers to match against, see SMODS.create_card_matcher()
---@return table<table<string, table>, table<Card, boolean>> matchers_met_cards A map of matchers, with all the cards it matched as its value as a map too.
---@return table<Card, table<table<string, table>, boolean>> cards_met_matchers The inverse of the above.
function SMODS.match_cards(cards, matchers) end

---@param matchers_met_cards table<table<string, table>, table<Card, boolean>> A map of matchers indexing the cards each matched with.
---@param cards_met_matchers table<Card, table<table<string, table>, boolean>> The inverse of the above.
---@param args table<"deduplicate_matches"|"all_matched_cards_score"|"matcher_max_cards", boolean> Args;
---     "deduplicate_matches": Whether to make sure that each matcher matches a unique card. 
---     "all_matched_cards_score": In addition; As long as every matcher has at least one unique card, all cards that matched any matcher should score. (-> Akin to how Straight Flushes with Four Fingers work.)
---     "matcher_max_cards": A table<matcher, integer> allowing a matcher to count for more than one card, without needing to calculate it twice.
---@return table<integer, table> hand The list of valid hands (though only one is ever returned). 
function SMODS.get_hand_from_matching(matchers_met_cards, cards_met_matchers, args) end