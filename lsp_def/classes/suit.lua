---@meta

---@class SMODS.Suit: SMODS.GameObject
---@field obj_buffer? Suits|string[] Array of keys to all objects registered to this class.
---@field obj_table? table<Suits|string, SMODS.Suit|table> Table of objects registered to this class. 
---@field loc_txt? table|{singular: string, plural: string} Contains strings used for displaying text related to this object. 
---@field super? SMODS.GameObject|table Parent class. 
---@field atlas? string Key to the suit's atlas. 
---@field pos? table|{y: integer} Position of the center's sprite. `x` is handled automatically.
---@field card_key? string Used for creating keys for playing cards. Card keys follow `S_R`, `S` being the suit and `R` being the rank. 
---@field ui_pos? table|{x: integer, y: integer} Sprite position of the miniature suit symbol used in deck view. 
---@field lc_atlas? string Atlas used for low-contrast cards. 
---@field hc_atlas? string Atlas used for high-contrast cards. 
---@field lc_ui_atlas? string Atlas used for low-contrast mini suit symbol in deck view. 
---@field hc_ui_atlas? string Atlas used for high-contrast mini suit symbol in deck view. 
---@field lc_colour? table HEX color of the suit text for low-contrast. 
---@field hc_colour? table HEX color of the suit text for high-contrast. 
---@field __call? fun(self: SMODS.Suit|table, o: SMODS.Suit|table): nil|table|SMODS.Suit
---@field extend? fun(self: SMODS.Suit|table, o: SMODS.Suit|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Suit|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Suit|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Suit|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Suit|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Suit|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Suit|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Suit|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Suit|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Suit|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Suit|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Suit|table, key: string, obj: SMODS.Suit|table, silent?: boolean): nil|table|SMODS.Suit Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Suit|table, key: string): SMODS.Suit|table? Returns an object if one matches the `key`. 
---@field loc_vars? fun(self: SMODS.Suit|table, info_queue: table, card: Card|table) Allows adding tooltips onto cards with this suit. Return values not respected. 
---@field draw? fun(self: SMODS.Suit|table, card: Card|table, layer: string) Allows drawing additional sprites or shaders onto cards with this suit. 
---@field in_pool? fun(self: SMODS.Suit|table, args: table): boolean? Allows configuring if cards with this suit should spawn. 
---@field delete? fun(self: SMODS.Suit|table) Deletes this suit. 
---@overload fun(self: SMODS.Suit): SMODS.Suit
SMODS.Suit = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<Suits|string, SMODS.Suit|table>
SMODS.Suits = {}
