---@meta

---@class SMODS.Background: SMODS.GameObject
---@field obj_table? table<string, SMODS.Background|table> Table of objects registered to this class.
---@field super? SMODS.GameObject|table Parent class.  
---@field key string Unique string to reference this object.
---@field shader? string Key of the shader to apply to the background, shader must already exist to use this.
---@field path? string Name of the shader file to use if `shader` is not provided.
---@field atlas? string Key to the atlas used for the background sprite.
---@field pos? table|{x: integer, y: integer} Position of the background's sprite. 
---@field fade_time? number Time it takes for this background to fade in.
---@field fade_ease? string Easing curve used when this background fades in. Must be in SMODS.ease_types
---@field extend? fun(self: SMODS.Background|table, o: SMODS.Background|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Background|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Background|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Background|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Background|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Background|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Background|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Background|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Background|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Background|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Background|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Background|table, key: string, obj: SMODS.Background|table, silent?: boolean): nil|table|SMODS.Background Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Background|table, key: string): SMODS.Background|table? Returns an object if one matches the `key`. 
---@field select_background? fun(self: SMODS.Background|table): nil|number|boolean Called each frame. Determines what background to use. Background with the highest number is used.
---@field set_sprites? fun(self: SMODS.Background|table, bg: SMODS.BackgroundCanvas|table) Used for setting and manipulating sprites of the background when created or loaded.
---@field update? fun(self: SMODS.Center|table, bg: SMODS.BackgroundCanvas|table) Allows logic for this card to be run per-frame. 
---@field send_vars? fun(self: SMODS.Background|table): table? Used to send extra args to the shader via `Shader:send(key, value)`. 
---@field get_current_background? fun(self: SMODS.Background|table): nil|string Polls `SMODS.Background:select_background` and returns the key to the background to use.
---@overload fun(self: SMODS.Background): SMODS.Background
SMODS.Background = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.Background|table>
SMODS.Backgrounds = {}