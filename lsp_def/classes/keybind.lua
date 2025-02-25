---@meta

---@class SMODS.Keybind: SMODS.GameObject
---@field obj_table? table<string, SMODS.Keybind|table> Table of objects registered to this class. 
---@field super? SMODS.GameObject|table Parent class. 
---@field key_pressed? string Required key to press for this keybind to activate. Keycodes are documented [here](https://love2d.org/wiki/KeyConstant). 
---@field event? "pressed"|"released"|"held" Defines when the keybind should trigger. "pressed": on key press, "released": on key release, "held": on key hold for specified amount of time. 
---@field held_duration? number How long the keybind needs to be pressed before activation. Only active if `event = held`. 
---@field held_keys? string[] Array of keycodes additionally required to be pressed for keybind to activate. 
---@field __call? fun(self: SMODS.Keybind|table, o: SMODS.Keybind|table): nil|table|SMODS.Keybind
---@field extend? fun(self: SMODS.Keybind|table, o: SMODS.Keybind|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Keybind|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Keybind|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Keybind|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Keybind|table): boolean? Returns true if there's no failed dependencies, else false
---@field process_loc_text? fun(self: SMODS.Keybind|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Keybind|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Keybind|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Keybind|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Keybind|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Keybind|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Keybind|table, key: string, obj: SMODS.Keybind|table, silent?: boolean): nil|table|SMODS.Keybind Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Keybind|table, key: string): SMODS.Keybind|table? Returns an object if one matches the `key`. 
---@field action? fun(self: SMODS.Keybind|table) Called when the keybind is triggered. 
---@overload fun(self: SMODS.Keybind): SMODS.Keybind
SMODS.Keybind = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.Keybind|table>
SMODS.Keybinds = {}