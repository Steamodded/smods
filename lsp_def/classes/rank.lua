---@meta

---@class SMODS.Rank: SMODS.GameObject
---@field super? SMODS.GameObject|table Parent class. 
---@field __call? fun(self: SMODS.Rank|table, o: SMODS.Rank|table): nil|SMODS.Rank
---@field extend? fun(self: SMODS.Rank|table, o: SMODS.Rank|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Rank|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Rank|table): boolean? Ensures objects with duplicate keys will not register. Checked on __call but not take_ownerhsip. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Rank|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Rank|table): boolean? Returns true if there's no failed dependencies, else false
---@field process_loc_text? fun(self: SMODS.Rank|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Rank|table, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Rank|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Rank|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Rank|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Rank|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Rank|table, key: string, obj: table, silent?: boolean): nil|SMODS.Rank Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Rank|table, key: string): table? Returns an object if one matches the `key`. 
---@overload fun(self: SMODS.Rank): SMODS.Rank
SMODS.Rank = setmetatable({}, {
    __call = function(self)
        return self
    end
})