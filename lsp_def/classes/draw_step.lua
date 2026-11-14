---@meta

---@class SMODS.DrawStep: SMODS.GameObject
---@field order? number Sets the order. `DrawStep` objects are evaluated in order from lowest to highest. 
---@field layers? table<string, true> Strings corresponding to draw layers. The `DrawStep` object's `func` will only be called when the `layer` arg in `Card:draw()` matches a string in this table. 
---@field conditions? table<string, any> Table of conditions. This object will not draw if any condition is not `true` when evaluated. 
---@field custom_conditions? table<string, any> Table of conditions except `vortex`, `facing` and `front_hidden`. This object will not draw if any condition is not `true` when evaluated. 
---@field __call? fun(self: SMODS.DrawStep|table, o: SMODS.DrawStep|table): nil|table|SMODS.DrawStep
---@field extend? fun(self: SMODS.DrawStep|table, o: SMODS.DrawStep|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.DrawStep|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.DrawStep|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.DrawStep|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.DrawStep|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.DrawStep|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.DrawStep|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.DrawStep|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.DrawStep|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.DrawStep|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.DrawStep|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.DrawStep|table, key: string, obj: SMODS.DrawStep|table, silent?: boolean): nil|table|SMODS.DrawStep Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.DrawStep|table, key: string): SMODS.DrawStep|table? Returns an object if one matches the `key`. 
---@field func? fun(card: Card|table, layer?: string) Handles the drawing logic of the `DrawStep`. 
---@field check_conditions? fun(self: SMODS.DrawStep|table, card: Card|table, layer: string): boolean? Iterates over the `conditions` table, calling `check_individual_condition` per element`. 
---@field check_individual_condition? fun(self: SMODS.DrawStep|table, card: Card|table, layer: string, k: string, v: any): boolean? Checks individual `SMODS.DrawStep` conditions, with `k` and `v` as key and value of condition. 
---@overload fun(self: SMODS.DrawStep): SMODS.DrawStep
SMODS.DrawStep = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.DrawStep|table>
SMODS.DrawSteps = {}

---@type table<string, true>
-- All keys in this table will not be automatically drawn with a default `draw()` call in the "others" DrawStep.
SMODS.draw_ignore_keys = {
    focused_ui = true, front = true, back = true, soul_parts = true, center = true, floating_sprite = true, shadow = true, use_button = true, buy_button = true, buy_and_use_button = true, debuff = true, price = true, particles = true, h_popup = true
}