---@meta

---@class SMODS.Colour: SMODS.GameObject
---@field colour? table<number, number> The colour, defined as {R, G, B, A}. 
---@field get_colour_table? fun(self: SMODS.Colour|table): table Returns the global table that the colour will be stored at. 
---@field __call? fun(self: SMODS.Colour|table, o: SMODS.Colour|table): nil|table|SMODS.Colour
---@field extend? fun(self: SMODS.Colour|table, o: SMODS.Colour|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Colour|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Colour|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Colour|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Colour|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Colour|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Colour|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Colour|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Colour|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Colour|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Colour|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Colour|table, key: string, obj: SMODS.Colour|table, silent?: boolean): nil|table|SMODS.Colour Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Colour|table, key: string): SMODS.Colour|table? Returns an object if one matches the `key`.
---@overload fun(self: SMODS.Colour): SMODS.Colour
SMODS.Colour = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type number? Red component of the current colour
SMODS.Colour[1] = 0
---@type number? Green component of the current colour
SMODS.Colour[2] = 0
---@type number? Blue component of the current colour
SMODS.Colour[3] = 0
---@type number? Opacity component of the current colour
SMODS.Colour[4] = 1

---@type table<string, SMODS.Colour|SMODS.Gradient|table>
SMODS.Colours = {}