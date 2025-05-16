---@meta

---@class SMODS.Stake: SMODS.GameObject
---@field obj_table? table<string, SMODS.Stake|table> Table of objects registered to this class. 
---@field loc_txt? table|{name: string, text: string[], sticker: table|{name: string, text: string[]} } Contains strings used for displaying text related to this object. 
---@field super? SMODS.GameObject|table Parent class. 
---@field applied_stakes? string[] Array of keys to stakes that should be applied when this stake is active. 
---@field atlas? string Key to the center's atlas. 
---@field pos? table|{x: integer, y: integer} Position of the center's sprite. 
---@field sticker_atlas? string Atlas for stake's win sticker. 
---@field sticker_pos? table|{x: integer, y: integer} Position of the stake's win sticker sprite. 
---@field above_stake? string Key to the stake that this stake appeard above in the run menu. By default, stakes are added on top of the last injected stake. 
---@field colour? table HEX color of the stake in the stake selection menu. 
---@field unlocked? boolean Sets if the stake is unlocked by default. 
---@field shiny? boolean Draws the shiny shader on State sticker. 
---@field __call? fun(self: SMODS.Stake|table, o: SMODS.Stake|table): nil|table|SMODS.Stake
---@field extend? fun(self: SMODS.Stake|table, o: SMODS.Stake|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Stake|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Stake|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Stake|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Stake|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Stake|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Stake|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Stake|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Stake|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Stake|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Stake|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Stake|table, key: string, obj: SMODS.Stake|table, silent?: boolean): nil|table|SMODS.Stake Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Stake|table, key: string): SMODS.Stake|table? Returns an object if one matches the `key`. 
---@field modifiers? fun() Applies changes to the game state when this stake is applied at the start of a run. 
---@overload fun(self: SMODS.Stake): SMODS.Stake
SMODS.Stake = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.Stake|table>
SMODS.Stakes = {}

---@param stake SMODS.Stake|table
---@param applied? table
---@return table applied
---Builds the stake chain. 
function SMODS.build_stake_chain(stake, applied) end

---@param i number 
---Sets up stakes after deck select, calls `SMODS.Stake.modifier()` on all applied stakes. 
function SMODS.setup_stake(i) end

---@param index number
---@return number|string
---Given an index from the Stake pool, return corresponding key or `"error"` if it doesn't exist
function SMODS.stake_from_index(index) end

---@param i number
---@param stake_desc_rows table 
---@param num_added? { val: number }
--- Creates "Applies X" Stake UI. 
function SMODS.applied_stakes_UI(i, stake_desc_rows, num_added) end
