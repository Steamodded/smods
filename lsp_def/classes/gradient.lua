---@meta

---@class SMODS.Gradient: SMODS.GameObject
---@field interpolation? 'trig'|'linear'|string Interpolation type of the gradient. Currently supported: `'trig'`, `'linear'`.
---@field colours? table<number, table<number, number>> List of colours to interpolate between.
---@field cycle? number Amount of time (in seconds) for the gradient to cycle through all colours.
---@field __call? fun(self: SMODS.Gradient|table, o: SMODS.Gradient|table): nil|table|SMODS.Gradient
---@field extend? fun(self: SMODS.Gradient|table, o: SMODS.Gradient|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Gradient|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Gradient|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Gradient|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Gradient|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Gradient|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Gradient|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Gradient|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Gradient|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Gradient|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Gradient|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Gradient|table, key: string, obj: SMODS.Gradient|table, silent?: boolean): nil|table|SMODS.Gradient Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Gradient|table, key: string): SMODS.Gradient|table? Returns an object if one matches the `key`.
---@field update? fun(self: SMODS.Gradient|table, dt: number) Allows finer per-frame control over the implementation.
---@overload fun(self: SMODS.Gradient): SMODS.Gradient
SMODS.Gradient = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type number? Red component of the current colour
SMODS.Gradient[1] = 0
---@type number? Green component of the current colour
SMODS.Gradient[2] = 0
---@type number? Blue component of the current colour
SMODS.Gradient[3] = 0
---@type number? Opacity component of the current colour
SMODS.Gradient[4] = 1

---@type table<string, SMODS.Gradient|table>
SMODS.Gradients = {}