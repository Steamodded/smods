---@meta

---@class SMODS.DeckSkin: SMODS.GameObject
---@field obj_table? table<string, SMODS.DeckSkin|table> Table of objects registered to this class. 
---@field super? SMODS.GameObject|table Parent class. 
---@field loc_txt? string|table String displayed as the name of this DeckSkin. 
---@field suit? string Suit this DeckSkin is tied to. 
---@field palettes? table[]|{key: string, ranks: string[], atlas: string, pos_style?: string|{[string]: string}, colour?: table, suit_icon?: {atlas: string, pos: number|{x: number, y: number}, loc_txt?: string}}[] List of tables representing each palette. See [SMODS DeckSkin](https://github.com/Steamodded/smods/wiki/SMODS.DeckSkin) documentation for details. 
---@field __call? fun(self: SMODS.DeckSkin|table, o: SMODS.DeckSkin|table): nil|table|SMODS.DeckSkin
---@field extend? fun(self: SMODS.DeckSkin|table, o: SMODS.DeckSkin|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.DeckSkin|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.DeckSkin|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.DeckSkin|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.DeckSkin|table): boolean? Returns true if there's no failed dependencies, else false
---@field process_loc_text? fun(self: SMODS.DeckSkin|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.DeckSkin|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.DeckSkin|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.DeckSkin|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.DeckSkin|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.DeckSkin|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.DeckSkin|table, key: string, obj: SMODS.DeckSkin|table, silent?: boolean): nil|table|SMODS.DeckSkin Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.DeckSkin|table, key: string): SMODS.DeckSkin|table? Returns an object if one matches the `key`. 
---@field add_palette? fun(self: SMODS.DeckSkin|table, palette: table): boolean, string? Internal function. Adds the palette into the DeckSkin. 
---@field get_palette_loc_options? fun(key: number|string, suit: string): string[] Internal function. Returns palette options for given key and suit. 
---@overload fun(self: SMODS.DeckSkin): SMODS.DeckSkin
SMODS.DeckSkin = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.DeckSkin|table>
SMODS.DeckSkins = {}
