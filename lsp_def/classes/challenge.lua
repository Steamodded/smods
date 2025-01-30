---@meta

---@class SMODS.Challenge: SMODS.GameObject
---@field __call? fun(self: table|SMODS.Challenge, o: table|SMODS.Challenge): nil|SMODS.Challenge
---@field extend? fun(self: table|SMODS.Challenge, o: table|SMODS.Challenge): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: table|SMODS.Challenge): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: table|SMODS.Challenge): boolean? Ensures objects with duplicate keys will not register. Checked on __call but not take_ownerhsip. For take_ownership, the key must exist. 
---@field register? fun(self: table|SMODS.Challenge) Registers the object. 
---@field check_dependencies? fun(self: table|SMODS.Challenge): boolean? Returns true if there's no failed dependencies, else false
---@field process_loc_text? fun(self: table|SMODS.Challenge) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: table|SMODS.Challenge, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: table|SMODS.Challenge) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: table|SMODS.Challenge) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: table|SMODS.Challenge) Inject all direct instances of `o` of the class by calling `o:inject`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: table|SMODS.Challenge, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: table|SMODS.Challenge, key: string, obj: table, silent?: boolean): nil|SMODS.Challenge Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: table|SMODS.Challenge, key: string): table? Returns an object if one matches the `key`. 
---@overload fun(self: SMODS.Challenge): SMODS.Challenge
SMODS.Challenge = setmetatable({}, {
    __call = function(self)
        return self
    end
})