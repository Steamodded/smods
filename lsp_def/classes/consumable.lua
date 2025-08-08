---@meta

---@class SMODS.Consumable: SMODS.Center
---@field super? SMODS.Center|table Parent class. 
---@field hidden? boolean Sets if this consumable is considered "legendary" (e.x. behaves like "The Soul"). 
---@field soul_set? string Key to the ConsumableType set this consumable can replace. Requires `hidden` to be true.
---@field soul_rate? number Chance this card replaces a consumable. Requires `hidden` to be true.
---@field type? SMODS.ConsumableType|table ConsumableType this center belongs to. 
---@field legendaries? (SMODS.Consumable|table)[] All injected "legendary" consumables. 
---@field __call? fun(self: SMODS.Consumable|table, o: SMODS.Consumable|table): nil|table|SMODS.Consumable
---@field extend? fun(self: SMODS.Consumable|table, o: SMODS.Consumable|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Consumable|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Consumable|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Consumable|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Consumable|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Consumable|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Consumable|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Consumable|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Consumable|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Consumable|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Consumable|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Consumable|table, key: string, obj: SMODS.Consumable|table, silent?: boolean): nil|table|SMODS.Consumable Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Consumable|table, key: string): SMODS.Consumable|table? Returns an object if one matches the `key`. 
---@field use? fun(self: SMODS.Consumable|table, card: Card|table, area: CardArea|table, copier?: table) Defines behaviour when this consumable is used. 
---@field can_use? fun(self: SMODS.Consumable|table, card: Card|table): boolean? Return `true` if the consumable is allowed to be used. 
---@field keep_on_use? fun(self: SMODS.Consumable|table, card: Card|table): boolean? Return `true` if the consumable should stay after use.
---@field calc_scaling? fun(self: SMODS.Consumable|table, card: Card|table, other_card: Card|table, scaling_value: number, scalar_value: number, args: table): table? Called by `SMODS.scale_card`. Allows detection and modification of cards when scaling values. The return may include a `scaling_value` or `scalar_value` field to modify those values or any standard calculation return.
---@overload fun(self: SMODS.Consumable): SMODS.Consumable
SMODS.Consumable = setmetatable({}, {
    __call = function(self)
        return self
    end
})