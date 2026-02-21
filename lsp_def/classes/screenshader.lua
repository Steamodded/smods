---@meta

---@class SMODS.ScreenShader: SMODS.GameObject
---@field obj_table? table<string, SMODS.ScreenShader|table> Table of objects registered to this class. 
---@field super? SMODS.GameObject|table Parent class. 
---@field key string Unique string to reference this object.
---@field shader? string Key of the shader to apply to the screen, shader must already exist to use this. Either this or `path` must be used
---@field order? number Sets the order. `ScreenShader` objects are rendered in order from lowest to highest. Defaults to 0 if not provided. 
---@field path? string Name of the shader file to use if `shader` is not provided.
---@field __call? fun(self: SMODS.ScreenShader|table, o: SMODS.ScreenShader|table): nil|table|SMODS.ScreenShader
---@field extend? fun(self: SMODS.ScreenShader|table, o: SMODS.ScreenShader|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.ScreenShader|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.ScreenShader|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.ScreenShader|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.ScreenShader|table): boolean? Returns `true` if there's no failed dependencies. 
---@field send_to_subclasses? fun(self: SMODS.ScreenShader|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.ScreenShader|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.ScreenShader|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.ScreenShader|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.ScreenShader|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.ScreenShader|table, key: string, obj: SMODS.ScreenShader|table, silent?: boolean): nil|table|SMODS.ScreenShader Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.ScreenShader|table, key: string): SMODS.ScreenShader|table? Returns an object if one matches the `key`. 
---@field send_vars? fun(self: SMODS.ScreenShader|table): table? Used to send extra args to the shader via `Shader:send(key, value)`. 
---@field should_apply? fun(self: SMODS.ScreenShader|table): boolean? Used to control if the ScreenShader should apply on the screen per-frame
---@overload fun(self: SMODS.ScreenShader): SMODS.ScreenShader
SMODS.ScreenShader = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.ScreenShader|table>
SMODS.ScreenShaders = {}