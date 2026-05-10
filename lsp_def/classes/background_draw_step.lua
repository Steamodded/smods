---@meta

---@class SMODS.BackgroundDrawStep: SMODS.GameObject
---@field key string Unique string to reference this object.
---@field order? number Sets the order. `BackgroundDrawStep` objects are evaluated in order from lowest to highest. 
---@field __call? fun(self: SMODS.BackgroundDrawStep|table, o: SMODS.BackgroundDrawStep|table): nil|table|SMODS.BackgroundDrawStep
---@field extend? fun(self: SMODS.BackgroundDrawStep|table, o: SMODS.BackgroundDrawStep|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.BackgroundDrawStep|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.BackgroundDrawStep|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.BackgroundDrawStep|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.BackgroundDrawStep|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.BackgroundDrawStep|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.BackgroundDrawStep|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.BackgroundDrawStep|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.BackgroundDrawStep|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.BackgroundDrawStep|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.BackgroundDrawStep|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.BackgroundDrawStep|table, key: string, obj: SMODS.BackgroundDrawStep|table, silent?: boolean): nil|table|SMODS.BackgroundDrawStep Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.BackgroundDrawStep|table, key: string): SMODS.BackgroundDrawStep|table? Returns an object if one matches the `key`. 
---@field func? fun(card: Card|table, layer?: string) Handles the drawing logic of the `DrawStep`.
---@overload fun(self: SMODS.BackgroundDrawStep): SMODS.BackgroundDrawStep
SMODS.BackgroundDrawStep = setmetatable({}, {
    __call = function(self)
        return self
    end
})