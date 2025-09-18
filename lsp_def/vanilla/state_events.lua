---@meta

--- Wins the run.
function win_game() end

--- Ends the current blind and checks if you lost. 
function end_round() end

--- Starts a new blind.
function new_round() end

---@param e? number Sets how many cards are drawn.
--- Moves the cards from `G.deck` to `G.hand`.
function G.FUNCS.draw_from_deck_to_hand(e) end

---@param e? any Unused in vanilla
---@param hook? boolean `true` if this function is called from The Hook.
--- Discards all cards currently highlighted.
function G.FUNCS.discard_cards_from_highlighted(e, hook) end

---@param e? any Unused in vanilla
--- Plays all the cards currently highlighted.
function G.FUNCS.play_cards_from_highlighted(e) end

---@param _cards Card[]
---@return string text
---@return string loc_disp_text
---@return table<string, (Card[])[]>
---@return Card[] scoring_hand
---@return string disp_text
--- Returns poker hand information about the provided `_cards` table.
function G.FUNCS.get_poker_hand_info(_cards) end

---@param e? any Unused in vanilla
--- The game's main scoring event.
--- Evaluates and scores the played hand.
function G.FUNCS.evaluate_play(e) end

---@param e? any Unused in vanilla
--- Moves the played cards from `G.play` into `G.discard`.
function G.FUNCS.draw_from_play_to_discard(e) end

---@param cards Card[]
--- Unused in vanilla
--- Moves the cards within `cards` from `G.play` to `G.hand`.
function G.FUNCS.draw_from_play_to_hand(cards) end

---@param e? any Unused in vanilla
--- Moves the cards from `G.discard` to `G.deck`.
function G.FUNCS.draw_from_discard_to_deck(e) end

---@param e? any Unused in vanilla
--- Moves the cards from `G.hand` to `G.deck`.
function G.FUNCS.draw_from_hand_to_deck(e) end

---@param e? any Unused in vanilla
--- Moves the cards from `G.hand` to `G.discard`.
function G.FUNCS.draw_from_hand_to_discard(e) end

--- Evaluates the end of a round.
function G.FUNCS.evaluate_round() end

--- Handles the tutorial section of the game.
function G.FUNCS.tutorial_controller() end

---@param _part string
--- Handles individual parts of the tutorial.
function G.FUNCS.tutorial_part(_part) end
