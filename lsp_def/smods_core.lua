---@meta

--- Core SMODS classes/functions

SMODS = {}

---@type string
--- Current SMODS version
MODDED_VERSION = ""

---@type string
--- Path to SMODS directory
SMODS.path = ""

---@class Mod
---@field id? string Unique ID.
---@field name? string Name of the mod.
---@field display_name? string Display name of the mod.
---@field description? string Mod description.
---@field priority? number Loaded mods are sorted via priority.
---@field badge_colour? table HEX color of the mod badge.
---@field badge_text_colour? table HEX color of the text inside the mod badge.
---@field prefix? string Unique string. All objects created by this mod have this string appended to their key.
---@field version? string Mod version.
---@field dump_loc? true Dumps G.localization table into this mod's directory.
---@field dependencies? string[] All mods in this array must be installed and loaded for this mod to load.
---@field conflicts? table[] No mods in this array can be installed for this mod to load.
---@field provides? table[] If any of the mods in this array are not installed or loaded, this mod will act as a stand in.
---@field main_file? string Path to the main .lua file of this mod.
---@field config_file? string Path to the config file of this mod. Defaults to "config.lua" if not provided.
---@field config? table Config values for this mod.
---@field can_load? boolean `true` if the mod is able to load.
---@field config_tab? fun(): table Creates this mod's config tab UI.
---@field extra_tabs? fun(): table[] Creates additional tabs within this mod's menu.
---@field custom_collection_tabs? fun(): table[] Creates additional buttons displayed inside the "Other" tab in collections.
---@field description_loc_vars? fun(self: Mod|table): table Allows dynamic display of this mod's description.
---@field custom_ui? fun(mod_nodes: table) Allows manipulating this mod's description tab.
---@field ui_config? fun(mod_nodes: table) Allows specifying custom values for this mod's menu UI elements.
---@field set_ability_reset_keys? fun(): string[] When a card's `ability` table is changed, values with a key matching a string inside the returned table .
---@field reset_game_globals? fun(run_start: boolean) Allows resetting global values every new run or round.
---@field set_debuff? fun(card: Card|table): boolean|string? Allows controlling when a card is debuffed or not. Return `"prevent_debuff"` to force a card to be undebuffable.
---@field optional_features? SMODS.optional_features|(fun(): SMODS.optional_features) Table of optional SMODS features to enable inserted into `SMODS.optional_features`. If function, returns table.
---@field save_mod_config? fun(mod: Mod) If defined, this funciton will be called over `SMODS.save_mod_config` when SMODS goes to save this mod's config.
---@field meta_mod? boolean Marked as a "meta mod" by SMODS. Only "Steamodded", "Lovely", and "Balatro" are provided by default.

---@type table<string, Mod|table>
SMODS.Mods = {}

---@type Mod|table?
--- The current mod being loaded.
SMODS.current_mod = {}

SMODS.Mods["Steamodded"] = SMODS
SMODS.Mods["Lovely"] = {
    id = "Lovely",
    can_load = true,
    meta_mod = true
}
SMODS.Mods["Balatro"] = {
    id = "Balatro",
    can_load = true,
    meta_mod = true
}

---@param modsDirectory string
--- Loads mods.
function loadMods(modsDirectory) end

--- Initializes Steamodded.
function initSteamodded() end

--- Injects all classes and items.
function SMODS.injectItems() end

---@param class SMODS.GameObject|table
--- Inject all SMODS Objects that are part of this class or a subclass.
function SMODS.injectObjects(class) end
