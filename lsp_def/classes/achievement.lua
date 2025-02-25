---@meta

---@class SMODS.Achievement: SMODS.GameObject
---@field obj_table? table<string, SMODS.Achievement|table> Table of objects registered to this class. 
---@field super? SMODS.GameObject|table Parent class. 
---@field atlas? string Key to the achievement's atlas. 
---@field pos? table|{x: integer, y: integer} Position of the achievement's sprite. 
---@field earned? boolean Sets whether the achievemnt is considered "earned" on profile load. To reset, set `reset_on_startup` to `true`. 
---@field reset_on_startup? boolean Sets whether the achievement is unearned on profile load. 
---@field bypass_all_unlocked? boolean Sets whether the achievement can be earned on profiles that pressed the "Unlock All" button. 
---@field hidden_name? boolean Sets if the name of the achievement is hidden when not earned. 
---@field hidden_text? boolean Sets if the description of the achievement is hidden when not earned. 
---@field __call? fun(self: SMODS.Achievement|table, o: SMODS.Achievement|table): nil|table|SMODS.Achievement
---@field extend? fun(self: SMODS.Achievement|table, o: SMODS.Achievement|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Achievement|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Achievement|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Achievement|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Achievement|table): boolean? Returns true if there's no failed dependencies, else false
---@field process_loc_text? fun(self: SMODS.Achievement|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Achievement|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Achievement|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Achievement|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Achievement|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Achievement|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Achievement|table, key: string, obj: SMODS.Achievement|table, silent?: boolean): nil|table|SMODS.Achievement Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Achievement|table, key: string): SMODS.Achievement|table? Returns an object if one matches the `key`. 
---@field unlock_condition? fun(self: SMODS.Achievement|table, args: table): boolean? Controls when the achievement is unlocked. 
---@overload fun(self: SMODS.Achievement): SMODS.Achievement
SMODS.Achievement = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.Achievement|table>
SMODS.Achievements = {}