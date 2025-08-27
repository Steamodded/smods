---@meta

---@class SMODS.JimboQuip: SMODS.GameObject
---@field type? 'win'|'loss'|string Whether it's a win, loss or another type quip.
---@field loc_txt? string[] Text for the quip.
---@field __call? fun(self: SMODS.JimboQuip|table, o: SMODS.JimboQuip|table): nil|table|SMODS.JimboQuip
---@field extend? fun(self: SMODS.JimboQuip|table, o: SMODS.JimboQuip|table): table Primary method of creating a class.
---@field check_duplicate_register? fun(self: SMODS.JimboQuip|table): boolean? Ensures objects already registered will not register.
---@field check_duplicate_key? fun(self: SMODS.JimboQuip|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist.
---@field register? fun(self: SMODS.JimboQuip|table) Registers the object.
---@field check_dependencies? fun(self: SMODS.JimboQuip|table): boolean? Returns `true` if there's no failed dependencies.
---@field process_loc_text? fun(self: SMODS.JimboQuip|table) Called during `inject_class`. Handles injecting loc_text.
---@field send_to_subclasses? fun(self: SMODS.JimboQuip|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments.
---@field pre_inject_class? fun(self: SMODS.JimboQuip|table) Called before `inject_class`. Injects and manages class information before object injection.
---@field post_inject_class? fun(self: SMODS.JimboQuip|table) Called after `inject_class`. Injects and manages class information after object injection.
---@field inject_class? fun(self: SMODS.JimboQuip|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`.
---@field inject? fun(self: SMODS.JimboQuip|table, i?: number) Called during `inject_class`. Injects the object into the game.
---@field take_ownership? fun(self: SMODS.JimboQuip|table, key: string, obj: SMODS.JimboQuip|table, silent?: boolean): nil|table|SMODS.JimboQuip Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.JimboQuip|table, key: string): SMODS.JimboQuip|table? Returns an object if one matches the `key`.
---@field extra? table|fun():table? Arguments for Card_Character.
---@field filter? fun(self: SMODS.JimboQuip|table, quip_type: string): boolean?, table? Allows configuring if the quip is allowed to appear. 
---@overload fun(self: SMODS.JimboQuip): SMODS.JimboQuip
SMODS.JimboQuip = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.JimboQuip|table>
SMODS.JimboQuips = {}
