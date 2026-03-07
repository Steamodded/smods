---@meta

---@class SMODS.DynaTextEffect: SMODS.GameObject
---@field obj_table? table<string, SMODS.DynaTextEffect|table> Table of objects registered to this class. 
---@field super? SMODS.GameObject|table Parent class. 
---@field extend? fun(self: SMODS.DynaTextEffect|table, o: SMODS.DynaTextEffect|table): table Primary method of creating a class. 
---@field __call? fun(self: SMODS.DynaTextEffect|table, o: SMODS.DynaTextEffect|table): nil|table|SMODS.DynaTextEffect
---@field check_duplicate_register? fun(self: SMODS.DynaTextEffect|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.DynaTextEffect|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.DynaTextEffect|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.DynaTextEffect|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.DynaTextEffect|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.DynaTextEffect|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.DynaTextEffect|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.DynaTextEffect|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.DynaTextEffect|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.DynaTextEffect|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.DynaTextEffect|table, key: string, obj: SMODS.DynaTextEffect|table, silent?: boolean): nil|table|SMODS.DynaTextEffect Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.DynaTextEffect|table, key: string): SMODS.DynaTextEffect|table? Returns an object if one matches the `key`.  
---@field func? fun(dynatext: DynaText, index: number, letter: DynaTextLetter|table) function to modify each letter. DynaText being the main object itself. Index is the index of current letter in the dynatext
---@field draw_letter? fun(dynatext: DynaText, index: number, letter: DynaTextLetter|table) function to draw each letter. DynaText being the main object itself. Index is the index of current letter in the dynatext
---@field draw_shadow? fun(dynatext: DynaText, index: number, letter: DynaTextLetter|table) function to draw each letter's shadow. DynaText being the main object itself. Index is the index of current letter in the dynatext
---@field draw_override? fun(dynatext: DynaText) wholly overrides the draw function for the dynatext. you will have to align everything yourselves (advanced)
---@overload fun(self: SMODS.DynaTextEffect): SMODS.DynaTextEffect
SMODS.DynaTextEffect = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.DynaTextEffect|table>
SMODS.DynaTextEffects = {}

---@class DynaTextLetter
---@field pop_in number Determines how the letter gradually pops in
---@field r number Rotation of the letter in radians, defaults to 0
---@field scale number Scale of the letter with the normal size being 1
---@field dims table|{x: integer, y: integer} a hashtable with x and y as letter's dimension. in this case it does NOT modify the size that it is drawn. it instead modifies how far apart each letter are
---@field offset table|{x: integer, y: integer} a hashtable with x and y to specify the letter's offset from the main dynatext alignment
---@field letter love.graphics.Text a replaceable text object that will get drawn

---@class love.graphics.Text