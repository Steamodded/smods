---@meta

---@class SMODS.Voucher: SMODS.Center
---@field super? SMODS.Center|table Parent class. 
---@field requires? string[] Array of keys to other voucher. This voucher will not appear if those are not redeemed.  
---@field __call? fun(self: SMODS.Voucher|table, o: SMODS.Voucher|table): nil|table|SMODS.Voucher
---@field extend? fun(self: SMODS.Voucher|table, o: SMODS.Voucher|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Voucher|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Voucher|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Voucher|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Voucher|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Voucher|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Voucher|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Voucher|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Voucher|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Voucher|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Voucher|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Voucher|table, key: string, obj: SMODS.Voucher|table, silent?: boolean): nil|table|SMODS.Voucher Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Voucher|table, key: string): SMODS.Voucher|table? Returns an object if one matches the `key`. 
---@field redeem? fun(self: SMODS.Voucher|table, voucher?: Card|table) Defines behaviour when this voucher is redeemed.
---@field calc_scaling? fun(self: SMODS.Voucher|table, voucher: Card|table, other_card: Card|table, scaling_value: number, scalar_value: number, args: table): table? Called by `SMODS.scale_card`. Allows detection and modification of cards when scaling values. The return may include a `scaling_value` or `scalar_value` field to modify those values or any standard calculation return.
---@field new? fun(self, name, slug, config, pos, loc_txt, cost, unlocked, discovered, available, requires, atlas): any DEPRECATED. DO NOT USE
---@overload fun(self: SMODS.Voucher): SMODS.Voucher
SMODS.Voucher = setmetatable({}, {
    __call = function(self)
        return self
    end
})