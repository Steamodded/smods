---@meta

---@class SMODS.Joker: SMODS.Center
---@field super? SMODS.Center|table Parent class. 
---@field __call? fun(self: SMODS.Joker|table, o: SMODS.Joker|table): nil|table|SMODS.Joker
---@field extend? fun(self: SMODS.Joker|table, o: SMODS.Joker|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Joker|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Joker|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Joker|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Joker|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Joker|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Joker|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Joker|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Joker|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Joker|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Joker|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Joker|table, key: string, obj: SMODS.Joker|table, silent?: boolean): nil|table|SMODS.Joker Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Joker|table, key: string): SMODS.Joker|table? Returns an object if one matches the `key`. 
---@field calc_dollar_bonus? fun(self: SMODS.Joker|table, card: Card|table): nil|number Calculates reward money. 
---@field calc_scaling? fun(self: SMODS.Joker|table, card: Card|table, other_card: Card|table, scaling_value: number, scalar_value: number, args: table): table? Called by `SMODS.scale_card`. Allows detection and modification of cards when scaling values. The return may include a `scaling_value` or `scalar_value` field to modify those values or any standard calculation return.
---@field new? fun(self, name, slug, config, spritePos, loc_txt, rarity, cost, unlocked, discovered,blueprint_compat, eternal_compat, effect, atlas, soul_pos): any DEPRECATED. DO NOT USE
---@overload fun(self: SMODS.Joker): SMODS.Joker
SMODS.Joker = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@param self Card|table
---@param context CalcContext|table
---@return table? effect
---@return boolean? # Return `true` if the Joker was calculated but no effect was provided. 
--- Calculates Jokers. 
function Card:calculate_joker(context) end
