---@meta

---@class SMODS.Atlas: SMODS.GameObject
---@field super? SMODS.GameObject|table Parent class. 
---@field px? string|number Width of individual sprites using this atlas. 
---@field py? string|number Height of individual sprite using this atlas. 
---@field path? string Name of the image file, including extension. 
---@field atlas_table? string Type of atlas. `ASSET_ATLAS`: non-animated sprites, `ANIMATION_ATLAS`: animated sprites, `ASSET_IMAGES`: anything else. 
---@field frames? number Number of frames in the animation. 
---@field raw_key? boolean Sets whether the mod prefix is added to atlas key. Used for overriding vanilla sprites. 
---@field language? string Key to a language. Restricts the atlas to only when this language is enabled. 
---@field disable_mipmap? boolean Sets if the sprite is affected by the mipmap. 
---@field __call? fun(self: SMODS.Atlas|table, o: SMODS.Atlas|table): nil|SMODS.Atlas
---@field extend? fun(self: SMODS.Atlas|table, o: SMODS.Atlas|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Atlas|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Atlas|table): boolean? Ensures objects with duplicate keys will not register. Checked on __call but not take_ownerhsip. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Atlas|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Atlas|table): boolean? Returns true if there's no failed dependencies, else false
---@field process_loc_text? fun(self: SMODS.Atlas|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Atlas|table, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Atlas|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Atlas|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Atlas|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Atlas|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Atlas|table, key: string, obj: table, silent?: boolean): nil|SMODS.Atlas Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Atlas|table, key: string): table? Returns an object if one matches the `key`. 
---@overload fun(self: SMODS.Atlas): SMODS.Atlas
SMODS.Atlas = setmetatable({}, {
    __call = function(self)
        return self
    end
})