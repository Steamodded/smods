---@meta

---@class Game: Object
---@overload fun(): Game
Game = {}
Game.__index = Game
Game.super = Object

G = Game()
---@type Color[]
--- Table of colors. Contains some generic colors.
G.C = {}

---@type Color[]
--- Colors used for easing the background elements. 
G.C.DYN_UI = {}

---@type Color[]
--- Default suit colors.
G.C.SO_1 = {}

---@type Color[]
--- High contrast suit colors.
G.C.SO_2 = {}

---@type Color[]
--- Suit colors. Set to either `G.C.SO_1` or `G.C.SO_2` based on if "High Contrast Cards" is enabled.
G.C.SUITS = {}

---@type Color[]
--- Main UI colors.
G.C.UI = {}

---@type Color[]
--- Main Card set colors. 
G.C.SET = {}

---@type Color[]
--- Secondary Card set colors.
G.C.SECONDARY_SET = {}

---@type Color[]
--- Rarity colors.
G.C.RARITY = {}

---@type Color[]
--- Blind colors.
G.C.BLIND = {}

---@type Color[]
--- Hand Level colors.
G.C.HAND_LEVELS = {}

---@type Color[]
--- Colors used for the swirl background and particles default.
G.C.BACKGROUND = {}

---@param self Game
---@return Game
function Game:__call() end

---@param self Game
function Game:init() end

---@param self Game
--- Sets Game globals and settings.
function Game:set_globals() end

---@param self Game
--- Called on game startup.
function Game:start_up() end

---@param self Game
--- Initializes item prototypes.
function Game:init_item_prototypes() end

---@param _profile number|string Current profile selected
--- Loads profile data.
function Game:load_profile(_profile) end

---@param self Game
--- Sets the language.
function Game:set_language() end

---@param self Game
--- Sets render settings.
function Game:set_render_settings() end

---@param self Game
--- Initializes game window.
function Game:init_window() end

---@param self Game
--- Deletes current run.
function Game:delete_run() end

---@param self Game
--- Saves game progress.
function Game:save_progress() end

---@param self Game
---@param card Card
--- Save the provided `card` when unlocked.
function Game:save_notify(card) end

---@param self Game
--- Saves game settings.
function Game:save_settings() end

---@param self Game
--- Save game metrics.
function Game:save_metrics() end

---@param self Game
---@param new_stage number
---@param new_state number
---@param new_game_obj? boolean
--- Preps game for the provided stage and state.
function Game:prep_stage(new_stage, new_state, new_game_obj) end

---@param self Game
--- Sets the game into a sandbox. 
function Game:sandbox() end

---@param self Game
--- Sets up the splash screen.
function Game:splash_screen() end

---@param self Game
---@param change_context string|nil
--- Initializes the main menu.
function Game:main_menu(change_context) end

---@param self Game
--- Sets the demo UI.
function Game:demo_cta() end

---@param self Game
--- Initializes all centers and game objects.
function Game:init_game_object() end

---@param self Game
---@param args? table
--- Starts a run up.
function Game:start_run(args) end

---@param self Game
---@param dt number 
--- Updates the game. Called each frame.
function Game:update(dt) end

---@param self Game
--- Handler for drawing objects. 
function Game:draw() end

---@param self Game
---@param _state number
---@return number Red
---@return number Blue
---@return number Green
---@return number Opacity
--- Returns color of provided `_state`.
function Game:state_col(_state) end

---@param self Game
---@param dt number
--- Updates `SELECTING_HAND` state.
function Game:update_selecting_hand(dt) end

---@param self Game
---@param dt number
--- Updates `SHOP` state.
function Game:update_shop(dt) end

---@param self Game
---@param dt number
--- Updates `PLAY_TAROT` state.
function Game:update_play_tarot(dt) end

---@param self Game
---@param dt number
--- Updates `HAND_PLAYED` state.
function Game:update_hand_played(dt) end

---@param self Game
---@param dt number
--- Updates `DRAW_TO_HAND` state.
function Game:update_draw_to_hand(dt) end

---@param self Game
---@param dt number
--- Updates `NEW_ROUND` state
function Game:update_new_round(dt) end

---@param self Game
---@param dt number
--- Updates `BLIND_SELECT` state.
function Game:update_blind_select(dt) end

---@param self Game
---@param dt number
--- Updates `ROUND_EVAL` state.
function Game:update_round_eval(dt) end

---@param self Game
---@param dt number
--- Updates `TAROT_PACK` state.
function Game:update_tarot_pack(dt) end

---@param self Game
---@param dt number
--- Updates `SPECTRAL_PACK` state.
function Game:update_spectral_pack(dt) end

---@param self Game
---@param dt number
--- Updates `STANDARD_PACK` states. 
function Game:update_standard_pack(dt) end

---@param self Game
---@param dt number
--- Updates `BUFFOON_PACK` state.
function Game:update_buffoon_pack(dt) end

---@param self Game
---@param dt number
--- Updates `CELESTIAL_PACK` state.
function Game:update_celestial_pack(dt) end

---@param self Game
---@param dt number
--- Updates `GAME_OVER` state.
function Game:update_game_over(dt) end

---@param self Game
---@param dt number
--- Updates `MENU` state.
--- Note: this function does quite literally nothing by default (there is no code here).
function Game:update_menu(dt) end
