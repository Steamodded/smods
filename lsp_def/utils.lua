---@meta

--- Util Classes

--- Internal class referring args passed as `context` in a SMODS object's `calculate` function. 
--- Not all arguments typed here are present in all contexts, see [Calculate Function](https://github.com/Steamodded/smods/wiki/calculate_functions#contexts) for details. 
---@class CalcContext: table 
---@field cardarea? CardArea The CardArea currently being checked. 
---@field full_hand? Card[]|table[] All play or selected cards. 
---@field scoring_hand? Card[]|table[] All scoring cards in played hand. 
---@field scoring_name? string Key to the scoring poker hand. 
---@field poker_hands? table<string, Card[]|table[]> All poker hand parts the played hand can form. 
---@field other_card? Card|table The individual card being checked during scoring. 
---@field other_joker? Card|table The individual Joker being checked during scoring. 
---@field card_effects? table Table of effects that have been calculated. 
---@field destory_card? Card|table The individual card being checked for destruction. 
---@field destorying_card? Card|table The individual card being checked for destruction. Only present when calculating G.play. 
---@field removed? Card[]|table[] Table of destroyed playing cards. 
---@field game_over? boolean Whether the run is lost or not. 
---@field blind? Blind|table Current blind being selected. 
---@field hook? boolean `true` when "The Hook" discards cards. 
---@field card? Card|table The individual card being checked outside of scoring. 
---@field cards? boolean[] Table of booleans representing how many cards are created. Only a value when `context.playing_card_added` is `true`. 
---@field consumable? Card|table The Consumable being used. Only a value when `context.using_consumeable` is `true`. 
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
---@field remove_playing_card? true Check if `true` for effects on removed cards. 
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

--- Util Functions

---@param ... table<integer, any>
---@return table
---Flattens given arrays into one, then adds elements from each table to a new one. Skips duplicates. 
function SMODS.merge_lists(...) end

---@param hex string
---@return table
---Returns HEX color attributed to the string. 
function HEX(hex) end

---@param context CalcContext|table 
---@param return_table table 
--- Used to calculate contexts across `G.jokers`, `scoring_hand` (if present), `G.play` and `G.GAME.selected_back`.
--- Hook this function to add different areas to MOST calculations
function SMODS.calculate_context(context, return_table) end

---@param card Card|table
---@param context CalcContext|table
--- Scores the provided `card`. 
function SMODS.score_card(card, context) end

---@param context CalcContext|table
---@param scoring_hand Card[]|table[]?
--- Handles calculating the scoring hand. Defaults to `context.cardarea.cards` if `scoring_hand` is not provided.
function SMODS.calculate_main_scoring(context, scoring_hand) end

---@param context CalcContext|table
--- Handles calculating end of round effects. 
function SMODS.calculate_end_of_round_effects(context) end

---@param context CalcContext|table
---@param cards_destroyed Card[]|table[]
---@param scoring_hand Card[]|table[]
--- Handles calculating destroyed cards. 
function SMODS.calculate_destroying_cards(context, cards_destroyed, scoring_hand) end

---@param effect table
---@param scored_card Card|table
---@param key string
---@param amount number|boolean 
---@param from_edition boolean
---@return boolean?
--- This function handles the calculation of each effect returned to evaluate play.
--- Can easily be hooked to add more calculation effects ala Talisman
function SMODS.calculate_individual_effect(effect, scored_card, key, amount, from_edition) end

---@param effect table
---@param scored_card Card|table
---@param from_edition boolean 
---@return table
--- Handles calculating effects on provided `scored_card`. 
function SMODS.calculate_effect(effect, scored_card, from_edition, pre_jokers) end

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
function SMODS.calculate_repetitions(card, context, reps) end

---@param _type string
---@param _context string
---@return CardArea[]|table[]
--- Returns table of CardAreas. 
function SMODS.get_card_areas(_type, _context) end

---@param card Card|table
---@param extra_only boolean? Return table will not have the card's actual enhancement. 
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
--- Check if the card shoud shatter. 
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

---@param path string Path to the file (excluding `mod.path`)
---@param id string? Key to Mod ID. Default to `SMODS.current_mod` if not provided. 
---@return function|nil 
---@return nil|string err
--- Loads the file from provided path. 
function SMODS.load_file(path, id) end

---@param obj SMODS.GameObject|table
---@param prefix string
---@param condition boolean?
---@param key string?
--- Modifies the object's key. 
function SMODS.modify_key(obj, prefix, condition, key) end

