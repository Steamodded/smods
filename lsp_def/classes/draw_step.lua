---@meta

---@class SMODS.DrawStep: SMODS.GameObject
---@field order? number Sets the order. `DrawStep` objects are evaluated in order from lowest to highest. 
---@field layers? table<string, true> Strings corresponding to draw layers. The `DrawStep` object's `func` will only be called when the `layer` arg in `Card:draw()` matches a string in this table. 
---@field __call? fun(self: SMODS.DrawStep|table, o: SMODS.DrawStep|table): nil|table|SMODS.DrawStep
---@field extend? fun(self: SMODS.DrawStep|table, o: SMODS.DrawStep|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.DrawStep|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.DrawStep|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.DrawStep|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.DrawStep|table): boolean? Returns true if there's no failed dependencies, else false
---@field process_loc_text? fun(self: SMODS.DrawStep|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.DrawStep|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.DrawStep|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.DrawStep|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.DrawStep|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.DrawStep|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.DrawStep|table, key: string, obj: SMODS.DrawStep|table, silent?: boolean): nil|table|SMODS.DrawStep Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.DrawStep|table, key: string): SMODS.DrawStep|table? Returns an object if one matches the `key`. 
---@field func? fun(card: Card|table, layer?: string) Handles the drawing logic of the `DrawStep`. 
---@overload fun(self: SMODS.DrawStep): SMODS.DrawStep
SMODS.DrawStep = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.DrawStep|table>
SMODS.DrawSteps = {}
