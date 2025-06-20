---@meta

---@class SMODS.Challenge: SMODS.GameObject
---@field obj_table? table<string, SMODS.Challenge|table> Table of objects registered to this class.
---@field loc_txt? table|{name: string} Contains strings used for displaying text related to this object.
---@field super? SMODS.GameObject|table Parent class.
---@field rules? table|{custom?: table[]|{id: string, value?: any}[], modifiers?: table[]|{id: string, value?: any}} List of tables setting custom rules and modifiers. Each rule/modifier has an `id`, with optional `value` param (defaults to `true`). See [SMODS.Challenge](https://github.com/Steamodded/smods/wiki/SMODS.Challenge) Documentation for default rules/modifiers.
---@field jokers? table[]|{id: string, edition?: string, eternal?: boolean, pinned?: boolean}[] List of tables setting jokers to start with.
---@field consumeables? table[]|{id: string, edition?: string, eternal?: boolean}[] List of tables setting consumables to start with.
---@field vouchers? table[]|{id: string}[] List of tables setting vouchers to start with.
---@field restrictions? table|{banned_cards?: table[]|{id: string}[], banned_tags?: table[]|{id: string}[], banned_other?: table[]|{id: string, type: "blind"}[]} Contains IDs to objects to ban from the challenge.
---@field deck? table|{type?: string|"Challenge Deck", cards?: table[], yes_ranks?: table<string, true>, yes_suits?: table<string, true>, no_ranks?: table<string, true>, no_suits?: table<string, true>, enhancement?: string, edition?: string, seal?: string} Defines the Challenge's deck. See [SMODS.Challenge](https://github.com/Steamodded/smods/wiki/SMODS.Challenge) Documentation for details.
---@field __call? fun(self: SMODS.Challenge|table, o: SMODS.Challenge|table): nil|table|SMODS.Challenge
---@field extend? fun(self: SMODS.Challenge|table, o: SMODS.Challenge|table): table Primary method of creating a class.
---@field check_duplicate_register? fun(self: SMODS.Challenge|table): boolean? Ensures objects already registered will not register.
---@field check_duplicate_key? fun(self: SMODS.Challenge|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist.
---@field register? fun(self: SMODS.Challenge|table) Registers the object.
---@field check_dependencies? fun(self: SMODS.Challenge|table): boolean? Returns `true` if there's no failed dependencies.
---@field process_loc_text? fun(self: SMODS.Challenge|table) Called during `inject_class`. Handles injecting loc_text.
---@field send_to_subclasses? fun(self: SMODS.Challenge|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments.
---@field pre_inject_class? fun(self: SMODS.Challenge|table) Called before `inject_class`. Injects and manages class information before object injection.
---@field post_inject_class? fun(self: SMODS.Challenge|table) Called after `inject_class`. Injects and manages class information after object injection.
---@field inject_class? fun(self: SMODS.Challenge|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`.
---@field inject? fun(self: SMODS.Challenge|table, i?: number) Called during `inject_class`. Injects the object into the game.
---@field take_ownership? fun(self: SMODS.Challenge|table, key: string, obj: SMODS.Challenge|table, silent?: boolean): nil|table|SMODS.Challenge Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Challenge|table, key: string): SMODS.Challenge|table? Returns an object if one matches the `key`.
---@field unlocked? fun(self: SMODS.Challenge|table): boolean
---@field button_colour? table HEX color of the button on the challenge list
---@overload fun(self: SMODS.Challenge): SMODS.Challenge
SMODS.Challenge = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.Challenge|table>
SMODS.Challenges = {}
