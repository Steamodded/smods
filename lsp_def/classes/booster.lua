---@meta

---@class SMODS.Booster: SMODS.Center
---@field super? SMODS.Center|table Parent class. 
---@field loc_txt? table|{name: string|string[], text: string[]|string[][], group_name: string} Contains strings used to display text relating to this object. 
---@field group_key? string Key to the group name. Grabs from `G.localization.misc.dictionary[group_key]`. 
---@field draw_hand? boolean Sets if playing cards are drawn when booster pack is opened. 
---@field kind? string Groups pack types together. For example, this can be used in `get_pack()` to generate a booster pack of a specific type. 
---@field weight? number Weight of the booster pack. 
---@field select_card? string|{[string]: string} Key to the CardArea (e.x. `G[SMODS.Booster.select_card]`). Consumables inside this booster pack will be "selected" and emplaced into a CardArea instead of used. As a table, each key-value pair is a card set as key and CardArea string as values.  
---@field select_exclusions? string[] List of card sets to exclude from being "Selected". 
---@field __call? fun(self: SMODS.Booster|table, o: SMODS.Booster|table): nil|table|SMODS.Booster
---@field extend? fun(self: SMODS.Booster|table, o: SMODS.Booster|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Booster|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Booster|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Booster|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Booster|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Booster|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Booster|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Booster|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Booster|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Booster|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Booster|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Booster|table, key: string, obj: SMODS.Booster|table, silent?: boolean): nil|table|SMODS.Booster Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Booster|table, key: string): SMODS.Booster|table? Returns an object if one matches the `key`. 
---@field create_card? fun(self: SMODS.Booster|table, card: Card|table, i: number): Card|table Creates the cards inside the booster pack. Returning a table will create a Card through `SMODS.create_card`. 
---@field update_pack? fun(self: SMODS.Booster|table, dt: number) Handles booster pack UI when opened. 
---@field ease_background_colour? fun(self: SMODS.Booster|table) Changes background colour when booster pack is opened. 
---@field particles? fun(self: SMODS.Booster|table) Handles ambient particle effects when booster pack is opened. 
---@field create_UIBox? fun(self: SMODS.Booster|table): table Returns booster pack UIBox. 
---@field take_ownership_by_kind? fun(self: SMODS.Booster|table, kind: string, obj: table, silent?: boolean) Finds all booster packs with matching `kind` and applies `SMODS.Booster:take_ownership()` to each one with `obj` and `silent` args passed through. 
---@overload fun(self: SMODS.Booster): SMODS.Booster
SMODS.Booster = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type Card|table|nil
---Last opened Booster Pack. 
SMODS.OPENED_BOOSTER = nil