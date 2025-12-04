---@meta

---@class SMODS.Rarity: SMODS.GameObject
---@field obj_buffer? Rarities|string[] Array of keys to all objects registered to this class. 
---@field obj_table? table<Rarities|string, SMODS.Rarity|table> Table of objects registered to this class. 
---@field loc_txt? table|{name: string} Contains strings used for displaying text related to this object. 
---@field super? SMODS.GameObject|table Parent class. 
---@field pools? table Table with a list of ObjectTypes keys this rarity should be added to.
---@field badge_colour? table HEX color the rarity badge uses. 
---@field default_weight? number Default weight of the rarity. When referenced in ObjectTypes with just the key, this value is used as the default. 
---@field disable_if_empty? boolean Disables polling of the rarity if set to `true` if there are no available objects.
---@field __call? fun(self: SMODS.Rarity|table, o: SMODS.Rarity|table): nil|table|SMODS.Rarity
---@field extend? fun(self: SMODS.Rarity|table, o: SMODS.Rarity|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Rarity|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Rarity|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Rarity|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Rarity|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Rarity|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Rarity|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Rarity|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Rarity|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Rarity|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Rarity|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Rarity|table, key: string, obj: SMODS.Rarity|table, silent?: boolean): nil|table|SMODS.Rarity Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Rarity|table, key: string): SMODS.Rarity|table? Returns an object if one matches the `key`. 
---@field get_weight? fun(self: SMODS.Rarity|table, weight: number, object_type: SMODS.ObjectType): number Used for finer control over this rarity's weight. 
---@field gradient? fun(self: SMODS.Rarity|table, dt: number) Used to make a gradient for this rarity's `badge_colour`. 
---@field get_rarity_badge? fun(self: SMODS.Rarity|table, rarity: string): string Returns localized rarity key. 
---@overload fun(self: SMODS.Rarity): SMODS.Rarity
SMODS.Rarity = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<Rarities|string, SMODS.Rarity|table>
SMODS.Rarities = {}

---@param _pool_key string Key to ObjectType
---@param _rand_key? string Used as polling seed
---@return Rarities|string|number rarity_key
---Polls all rarities tied to provided ObjectType. 
function SMODS.poll_rarity(_pool_key, _rand_key) end

---@param object_type SMODS.ObjectType|table
---@param rarity SMODS.Rarity
---Injects `rarity` into `object_type`. 
function SMODS.inject_rarity(object_type, rarity) end
