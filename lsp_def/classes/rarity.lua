---@meta

---@class SMODS.Rarity: SMODS.GameObject
---@field pools? table Table with a list of ObjectTypes keys this rarity should be added to.
---@field badge_colour? table HEX color the rarity badge uses. 
---@field default_weight? number Default weight of the rarity. When referenced in ObjectTypes with just the key, this value is used as the default. 
---@field __call? fun(self: table|SMODS.Rarity, o: table|SMODS.Rarity): nil|SMODS.Rarity
---@field extend? fun(self: table|SMODS.Rarity, o: table|SMODS.Rarity): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: table|SMODS.Rarity): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: table|SMODS.Rarity): boolean? Ensures objects with duplicate keys will not register. Checked on __call but not take_ownerhsip. For take_ownership, the key must exist. 
---@field register? fun(self: table|SMODS.Rarity) Registers the object. 
---@field check_dependencies? fun(self: table|SMODS.Rarity): boolean? Returns true if there's no failed dependencies, else false
---@field process_loc_text? fun(self: table|SMODS.Rarity) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: table|SMODS.Rarity, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: table|SMODS.Rarity) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: table|SMODS.Rarity) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: table|SMODS.Rarity) Inject all direct instances of `o` of the class by calling `o:inject`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: table|SMODS.Rarity, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: table|SMODS.Rarity, key: string, obj: table, silent?: boolean): nil|SMODS.Rarity Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: table|SMODS.Rarity, key: string): table? Returns an object if one matches the `key`. 
---@field get_weight? fun(self: table|SMODS.Rarity, weight: number, object_type: SMODS.ObjectType): number Used for finer control over this rarity's weight. 
---@field gradient? fun(self: table|SMODS.Rarity, dt: number) Used to make a gradient for this rarity's `badge_colour`. 
---@field get_rarity_badge? fun(self: table|SMODS.Rarity, rarity: string): string Returns loclaized rarity key. 
---@overload fun(self: SMODS.Rarity): SMODS.Rarity
SMODS.Rarity = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@param _pool_key string Key to ObjectType
---@param _rand_key? string Used as polling seed
---@return string rarity_key
---Polls all rarities tied to provided ObjectType. 
function SMODS.poll_rarity(_pool_key, _rand_key) end

---@param object_type SMODS.ObjectType
---@param rarity SMODS.Rarity
---Injects `rarity` into `object_type`. 
function SMODS.inject_rarity(object_type, rarity) end
