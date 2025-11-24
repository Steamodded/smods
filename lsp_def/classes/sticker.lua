---@meta

---@class SMODS.Sticker: SMODS.GameObject
---@field obj_buffer? Stickers|string[] Array of keys to all objects registered to this class. 
---@field obj_table? table<Stickers|string, SMODS.Sticker|table> Table of objects registered to this class. 
---@field super? SMODS.GameObject|table Parent class. 
---@field atlas? string Key to the center's atlas. 
---@field pos? table|{x: integer, y: integer} Position of the center's sprite. 
---@field order? number Position of the sticker in collections menu. 
---@field rate? number Change of this sticker applying onto an eligible card. 
---@field hide_badge? boolean Sets if the sticker badge shows up on the card. 
---@field badge_colour? table HEX color the sticker badge uses. 
---@field default_compat? boolean Default compatibility with cards. 
---@field compat_exceptions? string[] Array of keys to centers that are exceptions to `default_compat`. 
---@field sets? string[] Array of keys to pools that this sticker is allowed to be applied on. 
---@field needs_enable_flag? boolean Sets whether the sticker requires `G.GAME.modifiers["enable_"..key]` to be `true` before it can be applied. 
---@field sticker_sprite? Sprite|table Sprite object of the sticker. 
---@field __call? fun(self: SMODS.Sticker|table, o: SMODS.Sticker|table): nil|table|SMODS.Sticker
---@field extend? fun(self: SMODS.Sticker|table, o: SMODS.Sticker|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Sticker|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Sticker|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Sticker|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Sticker|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Sticker|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Sticker|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Sticker|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Sticker|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Sticker|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Sticker|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Sticker|table, key: string, obj: SMODS.Sticker|table, silent?: boolean): nil|table|SMODS.Sticker Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Sticker|table, key: string): SMODS.Sticker|table? Returns an object if one matches the `key`. 
---@field loc_vars? fun(self: SMODS.Sticker|table, info_queue: table, card: Card|table): table? Provides control over displaying descriptions and tooltips of the sticker's tooltip. See [SMODS.Sticker `loc_vars` implementation](https://github.com/Steamodded/smods/wiki/SMODS.Sticker#api-methods) documentation for details. 
---@field calculate? fun(self: SMODS.Sticker|table, card: Card|table, context: CalcContext|table): table?, boolean?  Calculates effects based on parameters in `context`. See [SMODS calculation](https://github.com/Steamodded/smods/wiki/calculate_functions) docs for details. 
---@field should_apply? boolean|fun(self: SMODS.Sticker|table, card: Card, center: table, area: CardArea, bypass_reroll?: boolean): boolean Determines if the sticker applies onto the card. If `bypass_reroll` is true, ignore RNG check. 
---@field apply? fun(self: SMODS.Sticker|table, card: Card|table, val: any) Handles applying and removing the sticker. By default, sets `card.ability[self.key] = val`. 
---@field draw? fun(self: SMODS.Sticker|table, card: Card|table, layer: string) Draws the sprite and shader of the sticker. 
---@overload fun(self: SMODS.Sticker): SMODS.Sticker
SMODS.Sticker = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<Stickers|string, SMODS.Sticker|table>
SMODS.Stickers = {}

---@param self Card|table
---@param sticker Stickers|string Key to the sticker to apply. 
---@param bypass_check? boolean Whether the sticker's `should_apply` function is called. 
--- Adds the sticker onto the card. 
function Card:add_sticker(sticker, bypass_check) end

---@param self Card|table
---@param sticker Stickers|string Key to the sticker to remove. 
--- Removes the sticker from the card, if it has the sticker. 
function Card:remove_sticker(sticker) end

---@param self Card|table
---@param key string
---@return table?
--- Calculates Stickers on cards. 
function Card:calculate_sticker(context, key) end
