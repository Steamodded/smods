---@meta

---@class SMODS.PokerHand: SMODS.GameObject
---@field obj_table? table<string, SMODS.PokerHand|table> Table of objects registered to this class. 
---@field loc_txt? table|{name: string, description: string[]} Contains strings used for displaying text related to this object. 
---@field super? SMODS.GameObject|table Parent class. 
---@field mult? number Base mult for poker hand. 
---@field chips? number Base chips for poker hand. 
---@field l_mult? number Mult gained per hand level. 
---@field l_chips? number Chips gained per hand level. 
---@field example? table Table of cards used to represent the hand example in the "Run Info" tab. 
---@field visible? boolean|fun(self:SMODS.PokerHand|table): boolean? Sets hand visibility in the poker hands menu. If `false`, poker hand is shown only after being played once.  A function allows more precise control over hand visibility in the poker hands menu.  
---@field above_hand? string Key to a poker hand. Used to order this poker hand above specified poker hand. 
---@field order_offset? number Adds this value to poker hand's mult and chips to offset ordering. 
---@field __call? fun(self: SMODS.PokerHand|table, o: SMODS.PokerHand|table): nil|table|SMODS.PokerHand
---@field extend? fun(self: SMODS.PokerHand|table, o: SMODS.PokerHand|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.PokerHand|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.PokerHand|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.PokerHand|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.PokerHand|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.PokerHand|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.PokerHand|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.PokerHand|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.PokerHand|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.PokerHand|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.PokerHand|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.PokerHand|table, key: string, obj: SMODS.PokerHand|table, silent?: boolean): nil|table|SMODS.PokerHand Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.PokerHand|table, key: string): SMODS.PokerHand|table? Returns an object if one matches the `key`. 
---@field evaluate? fun(parts: table, hand: table): table? Determines if played cards contain this hand, and what cards are a part of it. 
---@field modify_display_text? fun(self: SMODS.PokerHand|table, cards: Card[]|table[], scoring_hand: Card[]|table[]): string? Allows modifying the display text when this poker hand's text is meant to display.
---@overload fun(self: SMODS.PokerHand): SMODS.PokerHand
SMODS.PokerHand = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.PokerHand|table>
SMODS.PokerHands = {}

---@class SMODS.PokerHandPart: SMODS.GameObject
---@field super? SMODS.GameObject|table Parent class. 
---@field __call? fun(self: SMODS.PokerHandPart|table, o: SMODS.PokerHandPart|table): nil|table|SMODS.PokerHandPart
---@field extend? fun(self: SMODS.PokerHandPart|table, o: SMODS.PokerHandPart|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.PokerHandPart|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.PokerHandPart|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.PokerHandPart|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.PokerHandPart|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.PokerHandPart|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.PokerHandPart|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.PokerHandPart|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.PokerHandPart|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.PokerHandPart|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.PokerHandPart|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.PokerHandPart|table, key: string, obj: SMODS.PokerHandPart|table, silent?: boolean): nil|table|SMODS.PokerHandPart Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.PokerHandPart|table, key: string): SMODS.PokerHandPart|table? Returns an object if one matches the `key`. 
---@field func? fun(hand: Card[]|table[]): Card[]|table[] Returns array of cards that are a part of this hand. 
---@overload fun(self: SMODS.PokerHandPart): SMODS.PokerHandPart
SMODS.PokerHandPart = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.PokerHandPart|table>
SMODS.PokerHandParts = {}