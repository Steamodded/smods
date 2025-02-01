---@meta

---@class SMODS.GameObject: Object 
---@field log_interval? number
---@field loc_txt? table Contains data used for displaying text related to this object. See SMODS documentation for each class on the format. 
---@field mod? table Mod this object is created by. 
---@field registered? boolean
---@field obj_table? table Table of objects registered to this class. 
---@field obj_buffer? string[] Array of keys to all objects registered to this class. 
---@field dependencies? string[] Array of mod IDs. Object will fail to register if any specified mods cannot load. 
---@field subclasses? table[] Array of child classes. 
---@field super? table Parent class. 
---@field key? string Unique string to reference this object. 
---@field class_prefix? boolean|string All objects created with this class will have their key prefixed with this string. 
---@field prefix_config? boolean|table Controls how prefixes are applied. By default, class_prefix and mod_prefix are applied to all registered objects. 
---@field required_params? string[] Array of parameters required for objects created by this class. 
---@field set? string Important for objects wanting to follow vanilla logic that depends on `set`. For classes, this is used for logging purposes. 
---@field no_collection? boolean Sets whether the object shows up in collections.
---@field config? table Cards/Objects representing your center will copy default values from `config` into it's `ability` table. Custom values can be stored within `extra`. 
---@field __call? fun(self: SMODS.GameObject|table, o: SMODS.GameObject|table): nil|SMODS.GameObject
---@field extend? fun(self: SMODS.GameObject|table, o: SMODS.GameObject|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.GameObject|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.GameObject|table): boolean? Ensures objects with duplicate keys will not register. Checked on __call but not take_ownerhsip. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.GameObject|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.GameObject|table): boolean? Returns true if there's no failed dependencies, else false
---@field process_loc_text? fun(self: SMODS.GameObject|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.GameObject|table, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.GameObject|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.GameObject|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.GameObject|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.GameObject|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.GameObject|table, key: string, obj: table, silent?: boolean): nil|SMODS.GameObject Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.GameObject|table, key: string): table? Returns an object if one matches the `key`. 
---@field obj_list? fun(self: SMODS.GameObject|table, reversed: boolean): table Returns an object if one matches the `key`. 
---@overload fun(o: SMODS.GameObject): SMODS.GameObject
SMODS.GameObject = setmetatable({
    __call = function(self)
        return self
    end
})