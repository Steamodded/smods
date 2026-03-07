---@meta

SMODS.GUI = {}
SMODS.GUI.DynamicUIManager = {}

--- @type table<function>
SMODS.stencil_stack = {}

---@type string|"achievements"|"config"|"credits"|"mod_desc"|"additions"
SMODS.LAST_SELECTED_MOD_TAB = ""

---@type boolean?
SMODS.IN_MODS_TAB = nil

---@enum G.UIT
G.UIT = {
    T=1, -- Text node
    B=2, -- Box node
    C=3, -- Column node (orients children vertically)
    R=4, -- Row node (orients children horizontally)
    O=5, -- Object node 
    ROOT=7, -- Top-level node
    S=8, -- Slider node 
    I=9, -- Input node
    padding = 0, --default padding
}

---@class UINode.config: table
---@field align? string String *MUST* be two or less letters, 1st indicating vertical alignment and 2nd horizontal.
---@field h? number Fixed height.
---@field minh? number Minimum height.
---@field maxh? number Maximum height.
---@field w? number Fixed width.
---@field minw? number Minimum width.
---@field maxw? number Maximum width.
---@field padding? number Extra padding in the edges of the node.
---@field r? number Roundness of the node's corners.
---@field colour? table HEX color fill of the node.
---@field no_fill? boolean Set the node to no fill. Also sets text color for text nodes.
---@field outline? number Thickness of the outline.
---@field outline_colour? table HEX color of the outline.
---@field emboss? number How raised the current node is from its parent node.
---@field hover? boolean Renders the node as hovering above the parent node.
---@field shadow? boolean Renders a shadow below the node.
---@field juice? boolean Applied the `juice_up` animation on the node when loaded.
---@field id? string Sets an ID for the node.
---@field instance_type? "NODE"|"MOVEABLE"|"UIBOX"|"CARDAREA"|"CARD"|"UI_BOX"|"ALERT"|"POPUP" Sets the layer this node is drawn on.
---@field ref_table? table Table containing data relevant to this node.
---@field ref_value? string String corresponding to a key inside of `ref_table`.
---@field func? string Key to the function called when this node is drawn.
---@field button? string Key to the function called when this node is clicked.
---@field tooltip? table|{title: string, text: string[]} Displays a tooltip when this node is hovered.
---@field detailed_tooltip? table Contains the center of an object, turned into a detailed tooltip displayed when this node is hovered.
---@field text? string String to displayed as text.
---@field scale? number Size multiplier for text.
---@field vert? boolean Sets if the text is drawn vertically.
---@field object? Node Object to render.
---@field role? "Major"|"Minor"|"Glued" Sets object's role type.
---@field no_overflow? boolean Renders node as overflow container: constrain it's size, truncate drawing and prevent colliding child nodes which go outside of parent's boundaries

--- Internal class for annotating UIBox/UIElement tables before being turned into objects.
---@class UINode: table
---@field n G.UIT Type of UIBox/UIElement
---@field config UINode.config Config of the UINode.
---@field nodes? UINode[] Child UINodes

--

---@class SMODS.UIScrollBox.input
---@field content Moveable | { definition: UINode, config: table, T?: table } Moveable or UIBox definition to render inside scrollable content (passed to G.UIT.O).
---@field container? { node_config?: UINode.config, config?: table, T?: table } UIBox args for scroll container which will be moved to create scroll effect.
---@field overflow? { node_config?: UINode.config, config?: table, T?: table } UIBox args for main element.
---@field progress? { x?: number, y?: number } Value of scroll content relative offset in directions (0-1). Keeps reference for original table.
---@field offset? { x?: number, y?: number } Value of scroll content absolute offset in directions (in game units). Keeps reference for original table.
---@field sync_mode? "offset" | "progress" | "none" Sync mode. `offset` sync progress to match offset, `progress` sync offset to match progress, `none` disables syncing. Default is `progress`.
---@field scroll_move? fun(self: SMODS.UIScrollBox, dt: number) Function which called every frame before scroll syncing and can be used to perform automatic scrolling.

--- Element for displaying scrollable content
---@class SMODS.UIScrollBox: UIBox
---@field content Moveable Displayed content.
---@field content_container UIBox Container which positions `content` according to scroll offset.
---@field scroll_args SMODS.UIScrollBox.input Input args
---@field scroll_progress { x: number, y: number } Relative offset of scroll content in directions (0-1). Keeps reference for original table.
---@field scroll_offset { x: number, y: number } Absolute offset of scroll content in directions (in game units). Keeps reference for original table.
---@field scroll_sync_mode "offset" | "progress" | "none" Sync mode. `offset` sync progress to match offset, `progress` sync offset to match progress, `none` disables syncing. Default is `progress`.
---@overload fun(args: SMODS.UIScrollBox.input): SMODS.UIScrollBox
SMODS.UIScrollBox = {}
SMODS.UIScrollBox.__index = SMODS.UIScrollBox
SMODS.UIScrollBox.super = UIBox

---@return number, number
--- Distance of content overflow in both directions
function SMODS.UIScrollBox:get_scroll_distance() end

--- Update offset to match progress. Called every frame if `scroll_sync_mode = "progress"`
function SMODS.UIScrollBox:sync_scroll_offset() end

--- Update progress to match offset. Called every frame if `scroll_sync_mode = "offset"`
function SMODS.UIScrollBox:sync_scroll_progress() end

---@param t? { x?: number, y?: number }
--- Set new table for offset (keeps reference), and sync progress to match new offset
function SMODS.UIScrollBox:set_scroll_offset(t) end

---@param t? { x?: number, y?: number }
--- Set new table for progress (keeps reference), and sync offset to match new progress
function SMODS.UIScrollBox:set_scroll_progress(t) end

---@param dt number
---@param init? boolean Is sync called during initialization
--- Perform syncing according to `scroll_sync_mode`, and position elements to match result offset
function SMODS.UIScrollBox:sync_scroll(dt, init) end

-- UI Functions

---@param stencil_fn fun(exit?: boolean)
--- Add new stencil to stencil stack; result stencil is sum of all stencils in stack
function SMODS.push_to_stencil_stack(stencil_fn) end

--- Discard last applied stencil in stack
function SMODS.pop_from_stencil_stack() end

--- Cleanup stencil stack
function SMODS.reset_stencil_stack() end

--- Reload stencil stack by cleaning up current stencil and redrawing all stencils from stack
function SMODS.reload_stencil_stack() end

---@param str string
---@return any
--- Unpacks provided string. 
function STR_UNPACK(str) end

---@param args table
---@return UINode
--- Creates UIBox for individual mod tabs. 
function create_UIBox_mods(args) end

---@param mod Mod
---@return UINode
--- Creates UIBox for Mod's Description tab. 
function buildModDescTab(mod) end

---@param mod Mod
---@return UINode
--- Creates UIBox for Mod's "Additions" tab. 
function buildAdditionsTab(mod) end

---@param e? table
--- Button function for "Other" collections menu
G.FUNCS.your_collection_other_gameobjects = function(e) end

---@return UINode?
--- Creates UIBox for "Other" collections menu
function create_UIBox_Other_GameObjects() end

---@param e? table
--- Button function for "Consumables" collections menu UIBox
G.FUNCS.your_collection_consumables = function(e) end

---@return UINode
--- Creates UIBox for "Consumables" collections menu
function create_UIBox_your_collection_consumables() end

---@param args? table
--- Pages button function for "Consumables" collection menu
G.FUNCS.your_collection_consumables_page = function(args) end

---@param page? number
---@return UINode
--- Creates UIBox for "Consumables" collection menu pages. 
G.UIDEF.consumable_collection_page = function(page) end

---@param mod Mod
---@param current_page? number
---@return UINode
--- Creates UIBox for Mod's "Achievements" tab. 
function buildAchievementsTab(mod, current_page) end

---@param args? table
--- Pages button function for "Achievements" tab
G.FUNCS.achievments_tab_page = function(args) end

---@param pool table[]
---@param set? string Only objects with matching set will be tallied. 
---@return {tally: 0|number, of: 0|number} 
--- Tallies all objects within `pool` that are discovered. 
function modsCollectionTally(pool, set) end

---@param mod Mod
---@return UINode
--- Creates Mod tag UI for Mods list menu. 
function buildModtag(mod) end

---@param options? table
--- Opens "Mods" directory. 
function G.FUNCS.openModsDirectory(options) end

---@param mod Mod
---@return table
--- Loads mod config. 
function SMODS.load_mod_config(mod) end

---@param mod Mod
---@return boolean
--- Saves mod config
function SMODS.save_mod_config(mod) end

--- Saves all mod configs. 
function SMODS.save_all_config() end

---@param e? table
--- Exits mods tab. 
function G.FUNCS.exit_mods(e) end

---@return UINode
--- Creates UIBox for SMODS Menu. 
function create_UIBox_mods_button() end

---@param e? table
--- Updates achievements settings. 
function G.FUNCS.update_achievement_settings(e) end

---@param e? table
--- Button function for Steamodded Github link. 
function G.FUNCS.steamodded_github(e) end

---@param e? table
--- Updates UI to display SMODS menu. 
function G.FUNCS.mods_button(e) end

---@param args table
--- Updates mod list. 
function G.FUNCS.update_mod_list(args) end

---@param args table
---@return UINode
--- Same as Balatro base game code, but accepts a value to match against (rather than the index in the option list)
--- e.g. create_option_cycle({ current_option = 1 })  vs. SMODS.GUI.createOptionSelector({ current_option = "Page 1/2" })
function SMODS.GUI.createOptionSelector(args) end

---@param args table
---@return UINode
-- Initialize a tab with sections that can be updated dynamically (e.g. modifying text labels, showing additional UI elements after toggling buttons, etc.)
function SMODS.GUI.DynamicUIManager.initTab(args) end

---@param uiDefinitions table<string, UIBox|table>
--- Updates all provided dynamic UIBoxes. 
function SMODS.GUI.DynamicUIManager.updateDynamicAreas(uiDefinitions) end

---@return UINode
--- Define the content in the pane that does not need to update
--- Should include OBJECT nodes that indicate where the dynamic content sections will be populated
--- EX: in this pane the 'modsList' node will contain the dynamic content which is defined in the function below
function SMODS.GUI.staticModListContent() end

---@param page? number
---@return UINode
--- Creates mod list. 
function SMODS.GUI.dynamicModListContent(page) end

---@param args table
--- Updates mipmap. 
function G.FUNCS.SMODS_change_mipmap(args) end

---@class CardCollection
---@field w_mod? number CardArea width modifier. 
---@field h_mod? number CardArea height modifier. 
---@field card_scale? number Card scale modifier. 
---@field collapse_single_page? boolean Removes a row if there's only one page. 
---@field area_type? string CardArea type. 
---@field center? string Key to a center. All created cards will have this as their center. 
---@field no_materialize? boolean Sets if the card play materialize animations when created. 
---@field back_func? string Back function of the collections UI. 
---@field hide_single_page? boolean Hides the page portion of the UI if there's only one page. 
---@field infotip? string Text displayed above the collections menu (e.x. Edition/Seal/Enhancement). 
---@field snap_back? boolean Some controller related. TODO define more specific term
---@field modify_card? fun(card: Card|table, center: SMODS.GameObject|table, i: number, j: number) Modifies all created cards for this collection. 

---@param _pool table
---@param rows number[]
---@param args CardCollection
---@return UINode
--- Creates a default collections UIBox
function SMODS.card_collection_UIBox(_pool, rows, args) end

---@return UINode
--- Creates UIBox for "Jokers" collection menu
function create_UIBox_your_collection_jokers() end

---@return UINode
--- Creates UIBox for "Boosters" collection menu
function create_UIBox_your_collection_boosters() end

---@return UINode
--- Creates UIBox for "Vouchers" collection menu
function create_UIBox_your_collection_vouchers() end

---@return UINode
--- Creates UIBox for "Enhancements" collection menu
function create_UIBox_your_collection_enhancements() end

---@return UINode
--- Creates UIBox for "Editions" collection menu
function create_UIBox_your_collection_editions() end

---@return UINode
--- Creates UIBox for "Seals" collection menu
function create_UIBox_your_collection_seals() end

---@param e? table
--- Button function for "Stickers" collection menu
G.FUNCS.your_collection_stickers = function(e) end

---@return UINode
--- Creates UIBox for "Stickers" collection menu
function create_UIBox_your_collection_stickers() end

---@class ScoreContainerArgs
---@field scale? number Set scale of text
---@field colour? table HEX colour of the container
---@field type string Type of scoring component, ex. 'mult'. Can take the key of a Scoring_Parameter
---@field align? string Must be two letters, first indicates vertical alignment, second indicates horizontal alignment
---@field func? string Reference to function in `G.FUNCS` that controls changing the text - defaults to `'hand_'..type..'_UI_set'`
---@field text? string Key of value in `G.GAME.current_round.current_hand` - defaults to `type..'_text'`
---@field w? number Minimum width
---@field h? number Minimum height

---@return UINode
---@param args ScoreContainerArgs
function SMODS.GUI.score_container(args) end