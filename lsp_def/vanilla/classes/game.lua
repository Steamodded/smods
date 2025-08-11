---@meta

---@class Game: Object
---@overload fun(): Game
Game = {}
Game.__index = Game
Game.super = Object

G = Game()

---@type string
--- Balatro version
G.VERSION = ""

---@type boolean
--- Include the main menu "Quit" button
G.F_QUIT_BUTTON = true

---@type boolean
--- Completely skup the tutorial on fresh save
G.F_SKIP_TUTORIAL = false

---@type boolean
--- Completely skip the tutorial on fresh save
G.F_BASIC_CREDITS = false

---@type boolean
--- Remove all references to any external links (mainly for console)
G.F_EXTERNAL_LINKS = true

---@type boolean
--- Disable debugging tool for performance of each frame
G.F_ENABLE_PERF_OVERLAY = false

---@type boolean
--- Disables all 'run' saving
G.F_NO_SAVING = false

---@type boolean 
--- Force mute all sounds
G.F_MUTE = false

---@type boolean 
--- Have sound in a separate thread entirely - if not sounds will run on main thread
G.F_SOUND_THREAD = true

---@type boolean 
--- Let the player change their video settings
G.F_VIDEO_SETTINGS = true

---@type boolean
--- Call to Action video for the Demo - keep this as false
G.F_CTA = false

---@type boolean 
--- Extra debug information on screen and in the console
G.F_VERBOSE = true

---@type boolean
--- Include HTTP scores to fetch/set high scores
G.F_HTTP_SCORES = false

---@type number
--- Add rumble to the primary controller - adjust this for amount of rumble
G.F_RUMBLE = nil

---@type boolean
--- Send Crash reports over the internet
G.F_CRASH_REPORTS = false

---@type boolean
--- Hard crash without error message screen
G.F_NO_ERROR_HAND = false

---@type boolean
--- Swapping button pips for A and B buttons (mainly for switch)
G.F_SWAP_AB_PIPS = false

---@type boolean
--- Swapping button function for A and B buttons (mainly for switch)
G.F_SWAP_AB_BUTTONS = false

---@type boolean
--- Swapping button function for X and Y buttons (mainly for switch)
G.F_SWAP_XY_BUTTONS = false

---@type boolean
--- Disables Achievements
G.F_NO_ACHIEVEMENTS = false

---@type string
--- If a username is required to be displayed in the main menu, set this value to that name
G.F_DISP_USERNAME = ""

---@type boolean
--- Disables language selection - only in english
G.F_ENGLISH_ONLY = false

---@type boolean
--- Replaces back/select with a "guide" button
G.F_GUIDE = false

---@type boolean 
--- Call to action for Jan demo
G.F_JAN_CTA = false

---@type boolean 
--- Hide the game objects when paused
G.F_HIDE_BG = false

---@type boolean
--- Use "trophy" terminology instead of "achievement"
G.F_TROPHIES = false

---@type boolean
--- Use PS4 glyphs instead of PS5 glyphs for PS controllers
G.F_PS4_PLAYSTATION_GLYPHS = false

---@type boolean
--- Uses `G.CLIPBOARD` for copy/paste rather than `love.system`
G.F_LOCAL_CLIPBOARD = false

---@type number
--- Timer between saves
G.F_SAVE_TIMER = 30

---@type boolean 
--- Enables mobile UI
G.F_MOBILE_UI = false

---@type boolean
--- Hides beta languages
G.F_HIDE_BETA_LANGS = false

---@type number
--- Number used for generating seeds, starts as `os.time()`
G.SEED = 0

---@type number
--- Tile size
G.TILESIZE = 20

---@type number
--- Tile scale
G.TILESCALE = 3.65

---@type number
--- Tile width
G.TILE_W = 20

---@type number
--- Tile height
G.TILE_H = 11.5

---@type number
--- Draw hash buffer
G.DRAW_HASH_BUFF = 2

---@type number
--- Default card width
G.CARD_W = 2.4*35/41

---@type number 
--- Default card height
G.CARD_H = 2.4*47/41

---@type number
--- Highlight height
G.HIGHLIGHT_H = 0.2*G.CARD_H

---@type number
--- Collision buffer
G.COLLISION_BUFFER = 0.05

---@type number
--- Pitch modifier
G.PITCH_MOD = 1

---@type table
--- Table of timers
G.TIMERS = {}

---@type table
--- Table of fame counters
G.FRAMES = {}

---@type table
--- Table of factors used for moving objects
G.exp_times = {}

---@type table
--- Table of game settings
G.SETTINGS = {}

---@type table
--- Table with information about collabs
G.COLLABS = {}

---@type table
--- Unused in vanilla. Table of metrics, saved as 
G.METRICS = {}

---@type table[]
--- Array of tables corresponding to profiles.
G.PROFILES = {}

---@type table<string, number>
--- Table of game states
G.STATES = {}

---@type table<string, number>
--- Table of game stages
G.STAGES = {}

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
