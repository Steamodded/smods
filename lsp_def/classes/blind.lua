---@meta

---@class SMODS.Blind: SMODS.GameObject
---@field obj_table? table<string, SMODS.Blind|table> Table of objects registered to this class. 
---@field super? SMODS.GameObject|table Parent class. 
---@field atlas? string Key to the blind's atlas. 
---@field pos? table|{x: integer, y: integer} Position of the blind's sprite. 
---@field discovered? boolean Sets the discovery state of the blind. 
---@field dollars? number Amount of money earned when defeated. 
---@field mult? number Required score multiplier relative to the Ante's Base score. 
---@field boss? table|{min: integer, max: integer, showdown: boolean} Marks this Blind as a Boss Blind. `min` indicates minimum Ante for this Blind to appear. `showdown` indicates this Blind is a Final Boss Blind. For complex conditions, use `in_pool`. 
---@field boss_colour? table HEX color for the background when playing this Blind. 
---@field debuff? table Configures vanilla blind effects related to debuffing, see [SMODS.Blind](https://github.com/Steamodded/smods/wiki/SMODS.Blind#api-documentation-smodsblind) Documentation. Ignored if Blind defines `debuff_hand` or `debuff_card`. 
---@field ignore_showdown_check? boolean Sets if `in_pool` should be respected regardless of whether a showdown Boss Blind was requested or not. 
---@field vars? table Variables for this Blind's description in the collection. 
---@field __call? fun(self: SMODS.Blind|table, o: SMODS.Blind|table): nil|table|SMODS.Blind
---@field extend? fun(self: SMODS.Blind|table, o: SMODS.Blind|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Blind|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Blind|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Blind|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Blind|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Blind|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Blind|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Blind|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Blind|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Blind|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Blind|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Blind|table, key: string, obj: SMODS.Blind|table, silent?: boolean): nil|table|SMODS.Blind Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Blind|table, key: string): SMODS.Blind|table? Returns an object if one matches the `key`. 
---@field new? fun(self, name, slug, loc_txt, dollars, mult, vars, debuff, pos, boss, boss_colour, defeated, atlas): any DEPRECATED. DO NOT USE
---@field set_blind? fun(self: SMODS.Blind|table) Handles effects when this Blind is selected. 
---@field disable? fun(self: SMODS.Blind|table) Handles effect reverting when this Blind is disabled. 
---@field defeat? fun(self: SMODS.Blind|table) Handles effect reverting when this Blind is defeated. 
---@field drawn_to_hand? fun(self: SMODS.Blind|table) Handles effects when cards are drawn to hand. 
---@field press_play? fun(self: SMODS.Blind|table) Handles effects when a hand is played. 
---@field recalc_debuff? fun(self: SMODS.Blind|table, card: Card|table, from_blind: boolean): boolean? Determines if a card should be debuffed by this blind. 
---@field debuff_hand? fun(self: SMODS.Blind|table, cards: table, hand: table, handname: PokerHands|string, check: nil|boolean): boolean? Determines if the hand is debuffed. 
---@field stay_flipped? fun(self: SMODS.Blind|table, area: CardArea|table, card: Card|table): boolean? Determines if a card is drawn face down. 
---@field modify_hand? fun(self: SMODS.Blind|table, cards: table, poker_hands: table, text: PokerHands|string, mult: number, hand_chips: number): number?, number?, boolean? Handles modifications of the base score for played poker hand. 
---@field get_loc_debuff_text? fun(self: SMODS.Blind|table): string? Handles text displayed for debuff warnings or invalid hands. 
---@field loc_vars? fun(self: SMODS.Blind|table): table? Provides control over displaying the Blind descriptions. See [SMODS.Blind `loc_vars` implementation](https://github.com/Steamodded/smods/wiki/SMODS.Blind#api-methods) documentation for return value details. 
---@field collection_loc_vars? fun(self: SMODS.Blind|table): table? Provides control over displaying the Blind description in the collections menu. 
---@field in_pool? fun(self: SMODS.Blind|table): boolean Allows configuring if the Blind is allowed to appear. 
---@field calculate? fun(self: SMODS.Blind|table, blind: Blind|table, context: CalcContext|table): table?, boolean? Calculates effects based on parameters in `context`. See [SMODS calculation](https://github.com/Steamodded/smods/wiki/calculate_functions) docs for details. 
---@overload fun(self: SMODS.Blind): SMODS.Blind
SMODS.Blind = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.Blind|table>
SMODS.Blinds = {}