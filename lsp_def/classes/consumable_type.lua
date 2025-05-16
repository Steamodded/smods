---@meta

---@class SMODS.ConsumableType: SMODS.ObjectType
---@field obj_table? table<string, SMODS.ConsumableType|table> Table of objects registered to this class. 
---@field loc_txt? table|{name: string, collection: string, undiscovered: table|{name: string, text: string[]} } Contains strings used for displaying text related to this object. 
---@field super? SMODS.ObjectType|table Parent class. 
---@field primary_colour? table HEX color used as the primary color. Set as `G.C.SET[self.key]`. 
---@field secondary_colour? table HEX color used as the seconary color. Set as `G.C.SECONDARY_COLOUR[self.key]`. 
---@field collection_rows? number[] Array of numbers indicating how many rows and how many cards per row this ConsumableType's collection has. 
---@field shop_rate? nil|number Defining this value allows cards part of this ConsumableType to appear in the shop. Defined as `G.GAME[key:lower()..'_rate']`.  
---@field ctype_buffer? string[] Array of keys to all objects registered to the ConsumableType class. 
---@field visible_buffer? string[] Array of keys to all ConsumableType objects allowed to appear in collections menu.
---@field __call? fun(self: SMODS.ConsumableType|table, o: SMODS.ConsumableType|table): nil|table|SMODS.ConsumableType
---@field extend? fun(self: SMODS.ConsumableType|table, o: SMODS.ConsumableType|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.ConsumableType|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.ConsumableType|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.ConsumableType|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.ConsumableType|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.ConsumableType|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.ConsumableType|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.ConsumableType|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.ConsumableType|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.ConsumableType|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.ConsumableType|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.ConsumableType|table, key: string, obj: SMODS.ConsumableType|table, silent?: boolean): nil|table|SMODS.ConsumableType Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.ConsumableType|table, key: string): SMODS.ConsumableType|table? Returns an object if one matches the `key`. 
---@field create_UIBox_your_collection? fun(self: SMODS.ConsumableType|table): table Creates the UIBox of the ConsumableType's collections menu. 
---@overload fun(self: SMODS.ConsumableType): SMODS.ConsumableType
SMODS.ConsumableType = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.ConsumableType|table>
SMODS.ConsumableTypes = {}