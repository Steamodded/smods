---@meta

---@class SMODS.Back: SMODS.Center
---@field super? SMODS.Center|table Parent class. 
---@field __call? fun(self: SMODS.Back|table, o: SMODS.Back|table): nil|table|SMODS.Back
---@field extend? fun(self: SMODS.Back|table, o: SMODS.Back|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Back|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Back|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Back|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Back|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Back|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Back|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Back|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Back|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Back|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Back|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Back|table, key: string, obj: SMODS.Back|table, silent?: boolean): nil|table|SMODS.Back Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Back|table, key: string): SMODS.Back|table? Returns an object if one matches the `key`. 
---@field calculate? fun(self: SMODS.Back|table, back: Back|table, context: CalcContext|table): table?, boolean? Calculates effects based on parameters in `context`. See [SMODS calculation](https://github.com/Steamodded/smods/wiki/calculate_functions) docs for details. 
---@field apply? fun(self: SMODS.Back|table, back: Back|table) Applied modifiers at the start of a run.
---@field quip_filter? fun(quip: SMODS.JimboQuip|table, quip_type: string): boolean?, table? Allows configuring a quip is allowed to appear. 
---@overload fun(self: SMODS.Back): SMODS.Back
SMODS.Back = setmetatable({}, {
    __call = function(self)
        return self
    end
})