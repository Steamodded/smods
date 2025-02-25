---@meta

---@class SMODS.Tag: SMODS.GameObject
---@field obj_table? table<string, SMODS.Tag|table> Table of objects registered to this class. 
---@field super? SMODS.GameObject|table Parent class. 
---@field atlas? string Key to the center's atlas. 
---@field pos? table|{x: integer, y: integer} Position of the center's sprite. 
---@field min_ante? number Minimum ante needed for this tag to appear. For more complex restrictions, use `SMODS.Tag:in_pool()`. 
---@field discovered? boolean Sets the discovery state of the tag. 
---@field __call? fun(self: SMODS.Tag|table, o: SMODS.Tag|table): nil|table|SMODS.Tag
---@field extend? fun(self: SMODS.Tag|table, o: SMODS.Tag|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Tag|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Tag|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Tag|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Tag|table): boolean? Returns true if there's no failed dependencies, else false
---@field process_loc_text? fun(self: SMODS.Tag|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Tag|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Tag|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Tag|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Tag|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Tag|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Tag|table, key: string, obj: SMODS.Tag|table, silent?: boolean): nil|table|SMODS.Tag Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Tag|table, key: string): SMODS.Tag|table? Returns an object if one matches the `key`. 
---@field apply? fun(self: SMODS.Tag|table, tag: Tag|table, context: table): any? Defines behaviour when a tag triggers. To trigger, call `Tag:yep()`. See [SMODS.Tag](https://github.com/Steamodded/smods/wiki/SMODS.Tag#api-methods) wiki for details. 
---@field set_ability? fun(self: SMODS.Tag|table, tag: Tag|table) Sets up initial ability for the tag. Values should be stored in `tag.ability`. 
---@field generate_ui? fun(self: SMODS.Tag|table, info_queue: table, tag: Tag|table, desc_nodes: table, specific_vars: table, full_UI_table: table) Provides complex control over the UI display of the tag. See [`generate_ui` function](https://github.com/Steamodded/smods/wiki/Localization#generate_ui-advanced) documentation for details. 
---@field loc_vars? fun(self: SMODS.Tag|table, info_queue: table, tag: Tag|table): table? Provides simple control over displaying descriptions and tooltips of the tag. See [`loc_vars` function](https://github.com/Steamodded/smods/wiki/Localization#loc_vars) documentation for details. 
---@field in_pool? fun(self: SMODS.Tag|table, args: table): nil|boolean, table? Allows configuring if the tag is allowed to spawn. 
---@overload fun(self: SMODS.Tag): SMODS.Tag
SMODS.Tag = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.Tag|table>
SMODS.Tags = {}