---@meta

--- Util Classes

--- Internal class referring args passed as `context` in a SMODS object's `calculate` function. 
--- Not all arguments typed here are present in all contexts, see [Calculate Function](https://github.com/Steamodded/smods/wiki/calculate_functions#contexts) for details. 
---@class CalcContext: table 
---@field cardarea? CardArea|"unscored" The CardArea currently being checked. 
---@field full_hand? Card[]|table[] All played or selected cards. 
---@field scoring_hand? Card[]|table[] All scoring cards in played hand. 
---@field scoring_name? string Key to the scoring poker hand. 
---@field poker_hands? table<string, Card[]|table[]> All poker hand parts the played hand can form. 
---@field other_card? Card|table The individual card being checked during scoring. 
---@field other_joker? Card|table The individual Joker being checked during scoring. 
---@field card_effects? table Table of effects that have been calculated. 
---@field destroy_card? Card|table The individual card being checked for destruction. 
---@field destroying_card? Card|table The individual card being checked for destruction. Only present when calculating G.play. 
---@field removed? Card[]|table[] Table of destroyed playing cards. 
---@field game_over? boolean Whether the run is lost or not. 
---@field blind? Blind|table Current blind being selected. 
---@field hook? boolean `true` when "The Hook" discards cards. 
---@field card? Card|table The individual card being checked outside of scoring. 
---@field cards? table[]|Card[] Table of cards representing how many cards were created. 
---@field consumeable? Card|table The Consumable being used. Only a value when `context.using_consumeable` is `true`. 
---@field blueprint_card? Card|table The card currently copying the eval effects. 
---@field no_blueprint? true Effects akin to Blueprint or Brainstorm should not trigger in this context. 
---@field other_context? CalcContext|table The context the last eval happened on. 
---@field other_ret? table The return table from the last eval. 
---@field before? true Check if `true` for effects that happen before hand scoring. 
---@field after? true Check if `true` for effects that happen after hand scoring. 
---@field main_scoring? true Check if `true` for effects that happen during scoring. 
---@field individual? true Check if `true` for effects on individual playing cards during scoring. 
---@field repetition? true Check if `true` for adding repetitions to playing cards. 
---@field edition? true `true` for any Edition-specific context (e.x. context.pre_joker and context.post_joker). 
---@field pre_joker? true Check if `true` for triggering editions on jokers before they score. 
---@field post_joker? true Check if `true` for triggering editions on jokers after they score. 
---@field joker_main? true Check if `true` for triggering normal scoring effects on Jokers. 
---@field final_scoring_step? true Check if `true` for effects after cards are scored and before the score is totalled. 
---@field remove_playing_cards? true Check if `true` for effects on removed cards. 
---@field debuffed_hand? true Check if `true` for effects when playing a hand debuffed by a blind. 
---@field end_of_round? true Check if `true` for effects at the end of the round. 
---@field setting_blind? true Check if `true` for effects when the blind is selected. 
---@field pre_discard? true Check if `true` for effects before cards are discarded. 
---@field discard? true Check if `true` for effects on each individual card discarded. 
---@field open_booster? true Check if `true` for effects when opening a Booster Pack. 
---@field skipping_booster? true Check if `true` for effects after a Booster Pack is skipped. 
---@field buying_card? true Check if `true` for effects after buying a card. 
---@field selling_card? true Check if `true` for effects after selling a card. 
---@field reroll_shop? true Check if `true` for effects after rerolling the shop. 
---@field ending_shop? true Check if `true` for effects after leaving the shop. 
---@field first_hand_drawn? true Check if `true` for effects after drawing the first hand. 
---@field hand_drawn? true Check if `true` for effects after drawing a hand. 
---@field using_consumeable? true Check if `true` for effects after using a Consumable. 
---@field skip_blind? true Check if `true` for effects after skipping a blind. 
---@field playing_card_added? true Check if `true` for effects after a playing card was added into the deck. 
---@field check_enhancement? true Check if `true` for applying quantum enhancements. 
---@field post_trigger? true Check if `true` for effects after another Joker is triggered. 
---@field modify_scoring_hand? true Check if `true` for modifying the scoring hand. 
---@field ending_booster? true Check if `true` for effects after a Booster Pack ends. 
---@field starting_shop? true Check if `true` for effects when the shop is first opened. 
---@field blind_disabled? true Check if `true` for effects when the blind is disabled. 
---@field blind_defeated? true Check if `true` for effects when the blind is disabled. 
---@field press_play? true Check if `true` for effects when the Play button is pressed.
---@field debuff_card? Card|table The card being checked for if it should be debuffed. 
---@field ignore_debuff? true Sets if `self.debuff` checks are ignored. 
---@field debuff_hand? true Check if `true` for calculating if the played hand should be debuffed. 
---@field check? true `true` when the blind is being checked for if it debuffs the played hand. 
---@field stay_flipped? true Check if `true` for effects when a card is being drawn. 
---@field to_area? CardArea|table CardArea the card is being drawn to. 
---@field from_area? CardArea|table CardArea the card is being drawn from. 
---@field modify_hand? true Check if `true` for modifying the chips and mult of the played hand. 
---@field drawing_cards? true `true` when cards are being drawn
---@field amount? integer Amount of cards about to be drawn from deck to hand. Check for modifying amount of cards drawn.
---@field evaluate_poker_hand? integer Check if `true` for modifying the name, display name or contained poker hands when evaluating a hand.
---@field display_name? integer Display name of the scoring poker hand

--- Util Functions

---@param ... table<integer, any>
---@return table
---Flattens given arrays into one, then adds elements from each table to a new one. Skips duplicates. 
function SMODS.merge_lists(...) end

--- A table of SMODS feature that mods can choose to enable. 
---@class SMODS.optional_features: table
---@field quantum_enhancements? boolean Enables "Quantum Enhancement" contexts. Cards can count as having multiple enhancements at once. 
---@field retrigger_joker? boolean Enables "Joker Retrigger" contexts. Jokers can be retriggered by other jokers or effects. 
---@field post_trigger? boolean Enables "Post Trigger" contexts. Allows calculating effects after a Joker has been calculated. 
---@field cardareas? SMODS.optional_features.cardareas Enables additional CardArea calculation. 

---@class SMODS.optional_features.cardareas: table
---@field deck? boolean Enables "Deck Calculation". Decks are included in calculation.
---@field discard? boolean Enables "Discard Calculation". Discarded cards are included in calculation.

---@type SMODS.optional_features
SMODS.optional_features = { cardareas = {} }

--- Inserts all SMODS features enabled by loaded mods into `SMODS.optional_features`. 
function SMODS.get_optional_features() end

---@param context CalcContext|table 
---@param return_table? table 
---@return table? # Will use `return_table` over returning if provided.
--- Used to calculate contexts across `G.jokers`, `scoring_hand` (if present), `G.play` and `G.GAME.selected_back`.
--- Hook this function to add different areas to MOST calculations
function SMODS.calculate_context(context, return_table) end

---@param _type string Type of CardAreas to check
---@param context CalcContext
---@param return_table? table
---@param args? table
---@return table
--- Calculates effects on cards across multiple cardareas based on provided `_type`.
function SMODS.calculate_card_areas(_type, context, return_table, args) end

---@param card Card|table
---@param context CalcContext|table
--- Scores the provided `card`. 
function SMODS.score_card(card, context) end

---@param context CalcContext|table
---@param scoring_hand? Card[]|table[]
--- Handles calculating the scoring hand. Defaults to `context.cardarea.cards` if `scoring_hand` is not provided.
function SMODS.calculate_main_scoring(context, scoring_hand) end

---@param context CalcContext|table
--- Handles calculating end of round effects. 
function SMODS.calculate_end_of_round_effects(context) end

---@param context CalcContext|table
---@param cards_destroyed Card[]|table[]
---@param scoring_hand Card[]|table[]
--- Handles calculating whether to destroy cards. Adds the destroyed cards to `cards_destroyed`.
function SMODS.calculate_destroying_cards(context, cards_destroyed, scoring_hand) end

---@param effect table
---@param scored_card Card|table
---@param key string
---@param amount number|boolean 
---@param from_edition? boolean
---@return boolean|table?
--- This function handles the calculation of each effect returned to evaluate play.
--- Can easily be hooked to add more calculation effects ala Talisman
function SMODS.calculate_individual_effect(effect, scored_card, key, amount, from_edition) end

---@param effect table
---@param scored_card Card|table
---@param from_edition? boolean 
---@return table
--- Handles calculating effects on provided `scored_card`. 
function SMODS.calculate_effect(effect, scored_card, from_edition, pre_jokers) end

---@param effect_table table
---@param key string
---@param card Card|table
---@param ret table
--- Internal helper for SMODS.calculate_effect.
--- Calculate one key of an effect table returned from eval_card.
function SMODS.calculate_effect_table_key(effect_table, key, card, ret) end

---@param effects table
---@param card Card|table
--- Used to calculate a table of effects generated in evaluate_play
function SMODS.trigger_effects(effects, card) end

---@param card Card|table
---@param context CalcContext|table
---@param _ret table
---@return number[]
--- Calculate retriggers on provided `card`. 
function SMODS.calculate_retriggers(card, context, _ret) end

---@param card Card|table
---@param context CalcContext|table
---@param reps table[]
---@return table[] reps
function SMODS.calculate_repetitions(card, context, reps) end

---@param copier Card|table
---@param copied_card? Card|table
---@param context CalcContext|table
---@return table?
--- Helper function to copy the ability of another joker. Useful for implementing Blueprint-like jokers.
function SMODS.blueprint_effect(copier, copied_card, context) end

---@type string?
--- Internal global variable for smart_level_up_hand
--- Holds the currently displayed hand type,
--- if it hasn't had mult/chips added
SMODS.displayed_hand = nil

---@type boolean?
--- Internal global variable for smart_level_up_hand
--- True if scoring is ongoing (chips/mult/etc. are being displayed on the left)
SMODS.displaying_scoring = nil

---@param card? Card
---@param hand string
---@param instant boolean
---@param amount? number
-- Like level_up_hand(), but takes care of calling update_hand_text().
-- Tries to avoid calling update_hand_text() if unnecessary.
function SMODS.smart_level_up_hand(card, hand, instant, amount) end

---@param _type string
---@param _context string
---@return CardArea[]|table[]
--- Returns table of CardAreas. 
function SMODS.get_card_areas(_type, _context) end

---@param card Card|table
---@param extra_only? boolean Return table will not have the card's actual enhancement. 
---@return table<string, true> enhancements
--- Returns table of enhancements the provided `card` has. 
function SMODS.get_enhancements(card, extra_only) end

---@param card Card|table
---@param key string
---@return boolean 
--- Checks if this card a specific enhancement. 
function SMODS.has_enhancement(card, key) end

---@param card Card|table
---@param effects table
---@param context CalcContext|table
--- Calculates quantum Enhancements. Require `SMODS.optional_features.quantum_enhancements` to be `true`. 
function SMODS.calculate_quantum_enhancements(card, effects, context) end

---@param card Card|table
---@return boolean?
--- Check if the card should shatter. 
function SMODS.shatters(card) end

---@param card Card|table
---@return boolean?
--- Checks if the card counts as having no suit. 
function SMODS.has_no_suit(card) end

---@param card Card|table
---@return boolean?
--- Checks if the card counts as having all suits. 
function SMODS.has_any_suit(card) end

---@param card Card|table
---@return boolean?
--- Checks if the card counts as having no rank. 
function SMODS.has_no_rank(card) end

---@param card Card|table
---@return boolean?
--- Checks if the card should score. 
function SMODS.always_scores(card) end

---@param card Card|table
--- Checks if the card should not score. 
function SMODS.never_scores(card) end

---@param card Card|table
---@param scoring_hand Card[]|table[]
---@return true?
--- Returns `true` if provided card is inside the scoring hand. 
function SMODS.in_scoring(card, scoring_hand) end

---@nodiscard
---@param path string Path to the file (excluding `mod.path`)
---@param id? string Key to Mod ID. Default to `SMODS.current_mod` if not provided. 
---@return function|nil 
---@return nil|string err
--- Loads the file from provided path. 
function SMODS.load_file(path, id) end

---@param table table 
---@return string
--- Shallow inspect a table. 
function inspect(table) end

---@param table table
---@param indent? number
---@param depth? number Cap depth of 5
---@return string
--- Deep inspect a table. 
function inspectDepth(table, indent, depth) end

---@param func function
---@return string
--- Inspect a function. 
function inspectFunction(func) end

--- Handles saving discovery and unlocks. 
function SMODS.SAVE_UNLOCKS() end

---@param ref_table table
---@param ref_value string
---@param loc_txt table|string
---@param key? string Key to the value within `loc_txt`. 
--- Injects `loc_txt` into `G.localization`. 
function SMODS.process_loc_text(ref_table, ref_value, loc_txt, key) end

---@param path string
--- Handles injecting localization files. 
function SMODS.handle_loc_file(path) end

---@param pool table[]
---@param center metatable
---@param replace boolean?
--- Injects an object into provided pool. 
function SMODS.insert_pool(pool, center, replace) end

---@param pool table
---@param key string
--- Removes an object from the provided pool. 
function SMODS.remove_pool(pool, key) end

--- Juices up blind. 
function SMODS.juice_up_blind() end

--- Change a card's suit, rank, or both.
--- Accepts keys for both objects instead of needing to build a card key yourself.
--- It is recommended to wrap this function in `assert` to prevent unnoticed errors.
---@nodiscard
---@param card Card|table
---@param suit? string Key to the suit. 
---@param rank? string Key to the rank. 
---@return Card|table? cardOrErr If successful the card. If it failed `nil`.
---@return string? msg If it failed, a message describing what went wrong. 
function SMODS.change_base(card, suit, rank) end

--- Modify a card's rank by the specified amount.
--- Increase rank if amount is positive, decrease rank if negative.
--- It is recommended to wrap this function in `assert` to prevent unnoticed errors.
---@nodiscard
---@param card Card|table
---@param amount number
---@return Card|table? cardOrErr If successful the card. If it failed `nil`.
---@return string? msg If it failed, a message describing what went wrong.  
function SMODS.modify_rank(card, amount) end

---@param key string
---@param count_debuffed? true
---@return Card[]|table[]
--- Returns all cards matching provided `key`. 
function SMODS.find_card(key, count_debuffed) end

---@class CreateCard
---@field set? string Set of the card. 
---@field area? CardArea|table CardArea to emplace this card to. 
---@field legendary? boolean Pools legendary cards, if applicable. 
---@field rarity? number|string Only spawns cards with provided rarity, if applicable. 
---@field skip_materialize? boolean Skips materialization animations. 
---@field soulable? boolean Card could be replace by a legendary version, if applicable. 
---@field key? string Created card is forced to have a center matching this key. 
---@field key_append? string Appends this string to seeds. 
---@field discover? boolean Discovers the card when created.
---@field bypass_discovery_center? boolean Creates the card's proper sprites and UI even if it hasn't been discovered.
---@field no_edition? boolean Ignore natural edition application. 
---@field edition? string Apply this edition. 
---@field enhancement? string Apply this enhancement. 
---@field seal? string Apply this seal. 
---@field stickers? string[] Apply all stickers in this array. 

---@param t CreateCard|table
---@return Card|table
--- Creates a card. 
function SMODS.create_card(t) end

---@param t CreateCard|table
---@return Card|table
--- Adds + creates a card into provided `area`. 
function SMODS.add_card(t) end

---@param card Card|table
---@param debuff boolean|"reset"?
---@param source string?
--- Debuffs provided `card`. 
function SMODS.debuff_card(card, debuff, source) end

---@param card Card|table
--- Recalculate card debuffs. 
function SMODS.recalc_debuff(card) end

--- Restarts the game. 
function SMODS.restart_game() end

---@param obj SMODS.GameObject|table
---@param badges table[]
--- Adds the mod badge into the `badges` of the provided `obj` description UIBox. 
function SMODS.create_mod_badges(obj, badges) end

--- Creates a localization dump. 
function SMODS.create_loc_dump() end

---@param t table
---@param indent? string
---@return string
--- Serializes an input table in valid Lua syntax
--- Keys must be of type number or string
--- Values must be of type number, boolean, string or table
function serialize(t, indent) end

---@param s string
---@return string
--- Serializes provided string. 
function serialize_string(s) end

---@param t table
---@return table
--- Return a shallow copy of table `t`.
function SMODS.shallow_copy(t) end

---@param t? false|table
---@param defaults? false|table
---@return false|table?
--- Starting with `t`, insert any key-value pairs from `defaults` that don't already
--- exist in `t` into `t`. Modifies `t`.
--- Returns `t`, the result of the merge.
---
--- `nil` inputs count as {}; `false` inputs count as a table where
--- every possible key maps to `false`. Therefore,
--- * `t == nil` is weak and falls back to `defaults`
--- * `t == false` explicitly ignores `defaults`
--- (This function might not return a table, due to the above)
function SMODS.merge_defaults(t, defaults) end

---@param num number
---@param precision number
---@return number
--- Rounds provided `num`. 
function round_number(num, precision) end

---@param value number|string
---@return string
--- Format provided `value`
function format_ui_value(value) end

---@param ante number
---@return number
--- Returns the blind amount. 
function SMODS.get_blind_amount(ante) end

--- Converts save data for vanilla objects. 
function convert_save_data() end

---@param id string
---@return Mod[]|table[]
--- Returns table representing mods either matching provided `id` or can provide that mod. 
function SMODS.find_mod(id) end

---@param tbl table
---@param val any
---@param mode? ("index"|"i")|("value"|"v") Sets if the value is compared with the indexes or values of the table. 
---@param immediate? boolean
---@return table
--- Searches for `val` anywhere deep in `tbl`. Return a table of finds, or the first found if args.immediate is provided.
function SMODS.deepfind(tbl, val, mode, immediate) end

--- Enables debugging Joker calculations. 
function SMODS.debug_calculation() end

---@param card Card|table
---@param pack SMODS.Booster|table
---@return boolean
--- Controls if the card should be selectable from a Booster Pack. 
function Card.selectable_from_pack(card, pack) end

---@param pool (string|"UNAVAILABLE")[]
---@return number
--- Returns size of the provided pool (excluding `"UNAVAILABLE"`). 
function SMODS.size_of_pool(pool) end

---@param vouchers {[number]: table, spawn: table<string, true>}?
---@return {[number]: table, spawn: table<string, true>} vouchers
--- Returns the next vouchers to spawn. 
function SMODS.get_next_vouchers(vouchers) end

---@param key string
---@return Card|table voucher
--- Adds a Voucher with matching `key` to the shop. 
function SMODS.add_voucher_to_shop(key) end

---@param mod number
--- Modifies the Voucher shop limit by `mod`. 
function SMODS.change_voucher_limit(mod) end

---@param key string 
---@return Card|table booster
--- Adds a Booster Pack with matching `key` to the shop. 
function SMODS.add_booster_to_shop(key) end

---@param mod number
--- Modifies the Booster Pack shop limit by `mod`. 
function SMODS.change_booster_limit(mod) end

---@param mod number
--- Modifies the current amount of free shop rerolls by `mod`. 
function SMODS.change_free_rerolls(mod) end

---@param mod number
--- Modifies the amount of cards you are allowed to play by `mod`. 
function SMODS.change_play_limit(mod) end

---@param mod number
--- Modifies the amount of cards you are allowed to discard by `mod`. 
function SMODS.change_discard_limit(mod) end

---@param message string
---@param logger? string
--- Prints to the console at "DEBUG" level
function sendDebugMessage(message, logger) end

---@param message string
---@param logger? string
--- Prints to the console at "INFO" level
function sendInfoMessage(message, logger) end

---@param message string
---@param logger? string
--- Prints to the console at "WARN" level
function sendWarnMessage(message, logger) end

---@param message string
---@param logger? string
--- Prints to the console at "ERROR" level
function sendErrorMessage(message, logger) end

---@param message string
---@param logger? string
--- Prints to the console at "FATAL" level
function sendFatalMessage(message, logger) end

---@param level string 
---@param logger string 
---@param message string 
--- Sends the provided `message` to debug console. 
function sendMessageToConsole(level, logger, message) end

---@param val number
---@return string
--- Returns a signed `val` by
--- prefixing with "+" if positive
function SMODS.signed(val) end

---@param val number
---@return string
--- Returns string representing "$"`val`.
--- If `val` is negative, correctly adds "-" before "$".
function SMODS.signed_dollars(val) end

---@param base number
---@param perma number
---@return number
--- Returns result of multiplying `base` and `perma + 1`.
--- Reproduces weird vanilla behavior of using 0 for no/negative x_mult.
function SMODS.multiplicative_stacking(base, perma) end

---@param card Card
---@param suit string
---@return boolean
--- Checks if the suit can be smeared (e.x. Smeared Joker).
function SMODS.smeared_check(card, suit) end

---@param hand Card[]
---@param suit string
---@return boolean
--- Checks if the provided `hand` meets the conditions to trigger Seeing Double.
function SMODS.seeing_double_check(hand, suit) end

---@param lines table
---@param args table
--- Handles localization description boxes.
function SMODS.localize_box(lines, args) end

---@param multi_box table
---@return table multi_boxes
--- Returns all description boxes within `multi_box`.
function SMODS.get_multi_boxes(multi_box) end

---@param cards Card|Card[]
---@param bypass_eternal boolean?
---@param immediate boolean?
--- Destroys the cards passed to the function, handling calculation events that need to happen
function SMODS.destroy_cards(cards, bypass_eternal, immediate) end

---@param hand_space number
--- Used to draw cards to hand outside of the normal card draw
--- Allows context.drawing_cards to function
function SMODS.draw_cards(hand_space) end

---@param ... table<integer, any>
---@return table
---Flattens given calculation returns into one, utilising `extra` tables. 
function SMODS.merge_effects(...) end


---@param trigger_obj Card|table
---@param base_numerator number
---@param base_denominator number
---@param key string|nil optional seed key for associating results in loc_vars with in-game probability rolls
---@param from_roll boolean|nil
---@return number numerator
---@return number denominator
--- Returns a *`numerator` in `denominator`* listed probability opportunely modified by in-game effects
--- starting from a *`base_numerator` in `base_denominator`* probability. 
--- 
--- Can be hooked for more complex probability behaviour. `trigger_obj` is optionally the object that queues the probability.
function SMODS.get_probability_vars(trigger_obj, base_numerator, base_denominator, key, from_roll) end

---@param trigger_obj Card|table
---@param seed string|number
---@param base_numerator number
---@param base_denominator number
---@param key string
---@return boolean
--- Sets the seed to `seed` and runs a *`base_numerator` in `base_denominator`* listed probability check. 
--- Returns `true` if the probability succeeds. You do not need to multiply `base_numerator` by `G.GAME.probabilities.normal`. 
--- 
--- Can be hooked to run code when a listed probability succeeds and/or fails. `trigger_obj` is optionally the object that queues the probability.
function SMODS.pseudorandom_probability(trigger_obj, seed, base_numerator, base_denominator, key) end

---@param handname string
---@return boolean
---Checks if handname is visible in the poker hands menu.
function SMODS.is_poker_hand_visible(handname) end

---@param card Card|table
---@param trigger? Card|table
---@return boolean
--- Checks whether the card is eternal.
--- `trigger` is the card or effect that runs the check
function SMODS.is_eternal(card, trigger) end
