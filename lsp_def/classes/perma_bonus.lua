---@meta

---@class SMODS.Perma_Bonus: SMODS.GameObject
---@field obj_buffer? string[] Array of keys to all objects registered to this class. 
---@field obj_table? table<string, SMODS.Perma_Bonus|table> Table of objects registered to this class. 
---@field super? SMODS.GameObject|table Parent class. 
---@field __call? fun(self: SMODS.Perma_Bonus|table, o: SMODS.Perma_Bonus|table): nil|table|SMODS.Perma_Bonus
---@field extend? fun(self: SMODS.Perma_Bonus|table, o: SMODS.Perma_Bonus|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Perma_Bonus|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Perma_Bonus|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Perma_Bonus|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Perma_Bonus|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Perma_Bonus|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Perma_Bonus|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Perma_Bonus|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Perma_Bonus|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Perma_Bonus|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Perma_Bonus|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Perma_Bonus|table, key: string, obj: SMODS.Perma_Bonus|table, silent?: boolean): nil|table|SMODS.Perma_Bonus Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Perma_Bonus|table, key: string): SMODS.Perma_Bonus|table? Returns an object if one matches the `key`. 
---@field should_apply? fun(self: SMODS.Perma_Bonus|table, card: Card|table, calculation: string): boolean? Returns true if the Bonus applies to the given `calculation`.
---@field key string Used to reference the Perma_Bonus, also used in the card.ability table.
---@field apply_to string A string representing what calculation this bonus applies to; see the perma bonuses page for provided calculations.
---@field get_ui_value? fun(self: SMODS.Perma_Bonus|table, card: Card|table): number|nil Returns the number to be used for the display in the ui box, returns `nil` if the bonus is 0.
---@field upgrade? fun(self: SMODS.Perma_Bonus|table, card: Card|table, amount: number?, from?: Card|table?) Called through SMODS.upgrade_perma_bonus, allows for control over how the perma bonus is upgraded.
---@field loc_key? string The key of the object in G.localization.descriptions.Other, defaults to the object's key.
---@field vars_key? string How the value of the bonus is stored in the specific_vars table for playing card ui, defaults to the object's key.
---@field signed_value? boolean If this is `true`, the value in the ui box will be signed with `SMODS.signed`.
---@field signed_dollars? boolean Same as signed_value except the value is signed using `SMODS.signed_dollars`, has priority over signed_value by deafult.
---@field localize? fun(self: SMODS.Perma_Bonus|table, value: number, desc_nodes: table) Defines what to show in the playing card description, not recommended to change unless you know what you're doing.
---@overload fun(self: SMODS.Perma_Bonus): SMODS.Perma_Bonus
SMODS.Perma_Bonus = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.Perma_Bonus|table>
SMODS.Perma_Bonuses = {}