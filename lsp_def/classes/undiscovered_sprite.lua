---@meta

---@class SMODS.UndiscoveredSprite: SMODS.GameObject
---@field super? SMODS.GameObject|table Parent class. 
---@field key? string Key to the ObjectType this UndiscoveredSprite is made for. 
---@field atlas? string Key to the undiscovered sprite's atlas. 
---@field pos? table Position of the undiscovered sprite. 
---@field lc_atlas? string Low constrast atlas. Used when `G.SETTINGS.colourblind_option` is `false`. 
---@field hc_atlas? string High contrast atlas. Used when `G.SETTINGS.colourblind_option` is `true`.
---@field no_overlay? boolean Sets whether the floating "?" is drawn or not. 
---@field __call? fun(self: SMODS.UndiscoveredSprite|table, o: SMODS.UndiscoveredSprite|table): nil|SMODS.UndiscoveredSprite
---@field extend? fun(self: SMODS.UndiscoveredSprite|table, o: SMODS.UndiscoveredSprite|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.UndiscoveredSprite|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.UndiscoveredSprite|table): boolean? Ensures objects with duplicate keys will not register. Checked on __call but not take_ownerhsip. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.UndiscoveredSprite|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.UndiscoveredSprite|table): boolean? Returns true if there's no failed dependencies, else false
---@field process_loc_text? fun(self: SMODS.UndiscoveredSprite|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.UndiscoveredSprite|table, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.UndiscoveredSprite|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.UndiscoveredSprite|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.UndiscoveredSprite|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.UndiscoveredSprite|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.UndiscoveredSprite|table, key: string, obj: table, silent?: boolean): nil|SMODS.UndiscoveredSprite Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.UndiscoveredSprite|table, key: string): table? Returns an object if one matches the `key`. 
---@overload fun(self: SMODS.UndiscoveredSprite): SMODS.UndiscoveredSprite
SMODS.UndiscoveredSprite = setmetatable({}, {
    __call = function(self)
        return self
    end
})