---@meta

---@class SMODS.DeckSkin: SMODS.GameObject
---@field __call? fun(self: table|SMODS.DeckSkin, o: table|SMODS.DeckSkin): nil|SMODS.DeckSkin
---@field extend? fun(self: table|SMODS.DeckSkin, o: table|SMODS.DeckSkin): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: table|SMODS.DeckSkin): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: table|SMODS.DeckSkin): boolean? Ensures objects with duplicate keys will not register. Checked on __call but not take_ownerhsip. For take_ownership, the key must exist. 
---@field register? fun(self: table|SMODS.DeckSkin) Registers the object. 
---@field check_dependencies? fun(self: table|SMODS.DeckSkin): boolean? Returns true if there's no failed dependencies, else false
---@field process_loc_text? fun(self: table|SMODS.DeckSkin) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: table|SMODS.DeckSkin, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: table|SMODS.DeckSkin) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: table|SMODS.DeckSkin) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: table|SMODS.DeckSkin) Inject all direct instances of `o` of the class by calling `o:inject`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: table|SMODS.DeckSkin, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: table|SMODS.DeckSkin, key: string, obj: table, silent?: boolean): nil|SMODS.DeckSkin Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: table|SMODS.DeckSkin, key: string): table? Returns an object if one matches the `key`. 
---@overload fun(self: SMODS.DeckSkin): SMODS.DeckSkin
SMODS.DeckSkin = setmetatable({}, {
    __call = function(self)
        return self
    end
})