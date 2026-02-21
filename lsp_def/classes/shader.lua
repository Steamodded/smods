---@meta

---@class SMODS.Shader: SMODS.GameObject
---@field obj_table? table<string, SMODS.Shader|table> Table of objects registered to this class. 
---@field super? SMODS.GameObject|table Parent class. 
---@field key string Unique string to reference this object. This, `path`, and shader name in the GLSL must be the same.
---@field path string Name of the shader file. This, `key`, and shader name in the GLSL must be the same. 
---@field __call? fun(self: SMODS.Shader|table, o: SMODS.Shader|table): nil|table|SMODS.Shader
---@field extend? fun(self: SMODS.Shader|table, o: SMODS.Shader|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Shader|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Shader|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Shader|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Shader|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Shader|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Shader|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Shader|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Shader|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Shader|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Shader|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Shader|table, key: string, obj: SMODS.Shader|table, silent?: boolean): nil|table|SMODS.Shader Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Shader|table, key: string): SMODS.Shader|table? Returns an object if one matches the `key`. 
---@field send_vars? fun(self: SMODS.Shader|table, sprite: Sprite, card: nil|Card): table? Used to send extra args to the shader via `Shader:send(key, value)`. 
---@overload fun(self: SMODS.Shader): SMODS.Shader
SMODS.Shader = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.Shader|table>
SMODS.Shaders = {}