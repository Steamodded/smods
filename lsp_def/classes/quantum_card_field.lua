---@meta

---@class SMODS.QuantumCardField: SMODS.GameObject
---@field obj_buffer? QuantumCardFields|string[] Array of keys to all objects registered to this class. 
---@field obj_table? table<QuantumCardFields|string, SMODS.QuantumCardField|table> Table of objects registered to this class. 
---@field loc_txt? table|{name: string} Contains strings used for displaying text related to this object. 
---@field super? SMODS.GameObject|table Parent class. 
---@field __call? fun(self: SMODS.QuantumCardField|table, o: SMODS.QuantumCardField|table): nil|table|SMODS.QuantumCardField
---@field extend? fun(self: SMODS.QuantumCardField|table, o: SMODS.QuantumCardField|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.QuantumCardField|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.QuantumCardField|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.QuantumCardField|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.QuantumCardField|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.QuantumCardField|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.QuantumCardField|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.QuantumCardField|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.QuantumCardField|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.QuantumCardField|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.QuantumCardField|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.QuantumCardField|table, key: string, obj: SMODS.QuantumCardField|table, silent?: boolean): nil|table|SMODS.QuantumCardField Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.QuantumCardField|table, key: string): SMODS.QuantumCardField|table? Returns an object if one matches the `key`. 
---@field loc_vars? fun(self: SMODS.QuantumCardField|table, info_queue: table, card: Card|table) Allows adding tooltips onto cards with this suit. Return values not respected. 
---@field delete? fun(self: SMODS.QuantumCardField|table) Deletes this suit. 
---@field default_enabled? boolean Whether this QField is enabled by default.
---@field g_obj_table? table The map to this QField's objects, e.g. SMODS.Ranks.
---@field get_context_flag? string The flag to use in the getter context, e.g. "get_ranks" or "check_enhancement".
---@field has_context_flag? string The flag to use un the card_has_check context, e.g. "has_rank" or "has_enhancement".
---@field return_flag? string The flag used in calculate returns, e.g "ranks" or "enhancements" = [table map of values]
---@field calc_key? string The key this QField injects its calculation returns into the return_table, e.g. 'edition' -> `ret.edition` (see vanilla eval_card()) 
---@field cache_ability? boolean Whether this QField should cache obj.ability; This allows e.g. Quantum Enhancements to add to Card:get_chip_mult() etc. 
---@field base_value_ref? string A table subfield path string to get the base value, e.g. "base.value" for Rank, "config.center.key" for Enhancement.
---@field get_base_value? fun(self: SMODS.QuantumCardField|table, card: Card): string Returns the value according to the above ^
---@field base_getter? fun(self: SMODS.QuantumCardField|table, card: Card, args: table|nil): table<string, "BASE"> Returns a map of the base QField values for a Card before has_no/has_any or any quantum effects.
---@overload fun(self: SMODS.QuantumCardField): SMODS.QuantumCardField
SMODS.QuantumCardField = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<QuantumCardFields|string, SMODS.QuantumCardField|table>
SMODS.QuantumCardFields = {}

---@param card Card Gets and sets SMODS.qfield_cache[card], which has the subfields .get, .has and (maybe) .abilities; 
-- .get[qfield.return_flag] = [table map of values] 
-- .has[qfield.key] = {any = [boolean?], no = [boolean?]} 
-- (if cached) .abilities = [list of structs:] {{t = [ability table], key = [obj.key that cached the ability], qfield_key = [qfield the obj belongs to]}, ...}
---@return table cache The cached values, {has = ..., get = ...} ^ see above.
function SMODS.set_quantum_cache(card) end

-------------------------------
----- Rank
-------------------------------

--- ! Injected by QuantumCardField.inject
---@param args table|nil Args table, used flags: [as_objs: Whether to return objs or obj keys.] 
---@return table<string|table, boolean> get SMODS.qfield_cache[card].get[qfield.return_flag]
function Card:get_ranks(args) end

--- ! Injected by QuantumCardField.inject
---@param card Card The card to check.
---@param ... ... Passed to getter func.
---@return boolean any SMODS.qfield_cache[card].has[qfield.key].any
function SMODS.has_any_rank(card, ...) end

--- ! Injected by QuantumCardField.inject
---@param card Card The card to check.
---@param ... ... Passed to getter func.
---@return boolean no SMODS.qfield_cache[card].has[qfield.key].no and not SMODS.qfield_cache[card].has[qfield.key].any
function SMODS.has_no_rank(card, ...) end

--- ! Injected by QuantumCardField.inject
--- Calls plural_is func (see below)
---@param value string The obj.key to check, e.g. "Ace" or "2"
---@param args table|nil Passed to plural_is func and getter func.
---@param ... ... Passed to getter func.
---@return boolean is
function Card:is_rank(value, args, ...) end

--- ! Injected by QuantumCardField.inject
---@param value_map string A map of `obj.key`s to check against.
---@param args table|nil Passed to getter func and uses flags: [bypass_debuff: Whether to ignore card.debuff, all: Whether all values of the value_map must match (or just any)]
---@param ... ... Passed to getter func.
---@return boolean is
function Card:is_ranks(value_map, args, ...) end

--- ! Injected by QuantumCardField.inject
---@param cards table<integer, Card> A list of cards.
---@param ... ... Passed to getter func.
---@return table<string|table, integer> tally A table map mapping a QField value to its tally, e.g. `{m_stone = 2}`. 
---@return table<string|table, table<Card, true>> value_to_cards A table map mapping a QField value to a table map of cards.
function SMODS.get_rank_tally(cards, ...) end

--- ! Injected by QuantumCardField.inject
---@param context CalcContext The context.
---@param ... ... Passed to getter func.
---@return table ret Effects table.
function Card:calculate_rank(context, ...) end

-------------------------------
----- Enhancement
-------------------------------

--- ! Injected by QuantumCardField.inject
---@param args table|nil Args table, used flags: [as_objs: Whether to return objs or obj keys.] 
---@return table<string|table, boolean> get SMODS.qfield_cache[card].get[qfield.return_flag]
function Card:get_enhancements(args) end

--- ! Injected by QuantumCardField.inject
--- Both Card and SMODS are inject targets via `target_objects = {getter = {Card, SMODS}, is_funcs = {Card, SMODS}}` in obj definition.
---@param card Card The card to get the values for.
---@param args table|nil Args table, used flags: [as_objs: Whether to return objs or obj keys.] 
---@return table<string|table, boolean> get SMODS.qfield_cache[card].get[qfield.return_flag]
function SMODS.get_enhancements(card, args) end

--- ! Injected by QuantumCardField.inject
---@param card Card The card to check.
---@param ... ... Passed to getter func.
---@return boolean any SMODS.qfield_cache[card].has[qfield.key].any
function SMODS.has_any_enhancement(card, ...) end

--- ! Injected by QuantumCardField.inject
---@param card Card The card to check.
---@param ... ... Passed to getter func.
---@return boolean no SMODS.qfield_cache[card].has[qfield.key].no and not SMODS.qfield_cache[card].has[qfield.key].any
function SMODS.has_no_enhancement(card, ...) end

--- ! Injected by QuantumCardField.inject
--- `**has**_enhancement` instead of `**is**_enhancement` via `inject_args = {is_func_prefix = "has"}` in obj definition.
--- Calls plural_is func (see below)
---@param value string The obj.key to check, e.g. "m_stone"
---@param args table|nil Passed to plural_is func and getter func.
---@param ... ... Passed to getter func.
---@return boolean is
function Card:has_enhancement(value, args, ...) end

--- ! Injected by QuantumCardField.inject
--- Both Card and SMODS are inject targets via `target_objects = {getter = {Card, SMODS}, is_funcs = {Card, SMODS}}` in obj definition.
--- `**has**_enhancement` instead of `**is**_enhancement` via `inject_args = {is_func_prefix = "has"}` in obj definition.
--- Calls plural_is func (see below)
---@param card Card The card to check.
---@param value string The obj.key to check, e.g. "m_stone"
---@param args table|nil Passed to plural_is func and getter func.
---@param ... ... Passed to getter func.
---@return boolean is
function SMODS.has_enhancement(card, value, args, ...) end

--- ! Injected by QuantumCardField.inject
---@param value_map string A map of `obj.key`s to check against.
---@param args table|nil Passed to getter func and uses flags: [bypass_debuff: Whether to ignore card.debuff, all: Whether all values of the value_map must match (or just any)]
---@param ... ... Passed to getter func.
---@return boolean is
function Card:has_enhancements(value_map, args, ...) end

--- ! Injected by QuantumCardField.inject
--- Both Card and SMODS are inject targets via `target_objects = {getter = {Card, SMODS}, is_funcs = {Card, SMODS}}` in obj definition.
--- `**has**_enhancement` instead of `**is**_enhancement` via `inject_args = {is_func_prefix = "has"}` in obj definition.
---@param card Card The card to check.
---@param value_map string A map of `obj.key`s to check against.
---@param args table|nil Passed to getter func and uses flags: [bypass_debuff: Whether to ignore card.debuff, all: Whether all values of the value_map must match (or just any)]
---@param ... ... Passed to getter func.
---@return boolean is
function SMODS.has_enhancements(card, value_map, args, ...) end

--- ! Injected by QuantumCardField.inject
---@param cards table<integer, Card> A list of cards.
---@param ... ... Passed to getter func.
---@return table<string|table, integer> tally A table map mapping a QField value to its tally, e.g. `{m_stone = 2}`. 
---@return table<string|table, table<Card, true>> value_to_cards A table map mapping a QField value to a table map of cards.
function SMODS.get_enhancement_tally(cards, ...) end

--- ! Injected by QuantumCardField.inject
---@param context CalcContext The context.
---@param ... ... Passed to getter func.
---@return table ret Effects table.
function Card:calculate_enhancement(context, ...) end

-------------------------------
----- Seal
-------------------------------

--- ! Injected by QuantumCardField.inject
---@param args table|nil Args table, used flags: [as_objs: Whether to return objs or obj keys.] 
---@return table<string|table, boolean> get SMODS.qfield_cache[card].get[qfield.return_flag]
function Card:get_seals(args) end

--- ! Injected by QuantumCardField.inject
---@param card Card The card to check.
---@param ... ... Passed to getter func.
---@return boolean any SMODS.qfield_cache[card].has[qfield.key].any
function SMODS.has_any_seal(card, ...) end

--- ! Injected by QuantumCardField.inject
---@param card Card The card to check.
---@param ... ... Passed to getter func.
---@return boolean no SMODS.qfield_cache[card].has[qfield.key].no and not SMODS.qfield_cache[card].has[qfield.key].any
function SMODS.has_no_seal(card, ...) end

--- ! Injected by QuantumCardField.inject
--- `**has**_seal` instead of `**is**_seal` via `inject_args = {is_func_prefix = "has"}` in obj definition.
--- Calls plural_is func (see below)
---@param value string The obj.key to check, e.g. "Red"
---@param args table|nil Passed to plural_is func and getter func.
---@param ... ... Passed to getter func.
---@return boolean is
function Card:has_seal(value, args, ...) end

--- ! Injected by QuantumCardField.inject
--- `**has**_seal` instead of `**is**_seal` via `inject_args = {is_func_prefix = "has"}` in obj definition.
---@param value_map string A map of `obj.key`s to check against.
---@param args table|nil Passed to getter func and uses flags: [bypass_debuff: Whether to ignore card.debuff, all: Whether all values of the value_map must match (or just any)]
---@param ... ... Passed to getter func.
---@return boolean is
function Card:has_seals(value_map, args, ...) end

--- ! Injected by QuantumCardField.inject
---@param cards table<integer, Card> A list of cards.
---@param ... ... Passed to getter func.
---@return table<string|table, integer> tally A table map mapping a QField value to its tally, e.g. `{m_stone = 2}`. 
---@return table<string|table, table<Card, true>> value_to_cards A table map mapping a QField value to a table map of cards.
function SMODS.get_seal_tally(cards, ...) end

--- ! Injected by QuantumCardField.inject
---@param context CalcContext The context.
---@param ... ... Passed to getter func.
---@return table ret Effects table.
function Card:calculate_seal(context, ...) end

-------------------------------
----- Edition
-------------------------------

--- ! Injected by QuantumCardField.inject
---@param args table|nil Args table, used flags: [as_objs: Whether to return objs or obj keys.] 
---@return table<string|table, boolean> get SMODS.qfield_cache[card].get[qfield.return_flag]
function Card:get_editions(args) end

--- ! Injected by QuantumCardField.inject
---@param card Card The card to check.
---@param ... ... Passed to getter func.
---@return boolean any SMODS.qfield_cache[card].has[qfield.key].any
function SMODS.has_any_edition(card, ...) end

--- ! Injected by QuantumCardField.inject
---@param card Card The card to check.
---@param ... ... Passed to getter func.
---@return boolean no SMODS.qfield_cache[card].has[qfield.key].no and not SMODS.qfield_cache[card].has[qfield.key].any
function SMODS.has_no_edition(card, ...) end

--- ! Injected by QuantumCardField.inject
--- Calls plural_is func (see below)
---@param value string The obj.key to check, e.g. "e_holo"
---@param args table|nil Passed to plural_is func and getter func.
---@param ... ... Passed to getter func.
---@return boolean is
function Card:is_edition(value, args, ...) end

--- ! Injected by QuantumCardField.inject
---@param value_map string A map of `obj.key`s to check against.
---@param args table|nil Passed to getter func and uses flags: [bypass_debuff: Whether to ignore card.debuff, all: Whether all values of the value_map must match (or just any)]
---@param ... ... Passed to getter func.
---@return boolean is
function Card:is_editions(value_map, args, ...) end

--- ! Injected by QuantumCardField.inject
---@param cards table<integer, Card> A list of cards.
---@param ... ... Passed to getter func.
---@return table<string|table, integer> tally A table map mapping a QField value to its tally, e.g. `{m_stone = 2}`. 
---@return table<string|table, table<Card, true>> value_to_cards A table map mapping a QField value to a table map of cards.
function SMODS.get_edition_tally(cards, ...) end

--- ! Injected by QuantumCardField.inject
---@param context CalcContext The context.
---@param ... ... Passed to getter func.
---@return table ret Effects table.
function Card:calculate_edition(context, ...) end

-------------------------------
----- Suit
-------------------------------

--- ! Injected by QuantumCardField.inject
---@param args table|nil Args table, used flags: [as_objs: Whether to return objs or obj keys.] 
---@return table<string|table, boolean> get SMODS.qfield_cache[card].get[qfield.return_flag]
function Card:get_suits(args) end

--- ! Injected by QuantumCardField.inject
---@param card Card The card to check.
---@param ... ... Passed to getter func.
---@return boolean any SMODS.qfield_cache[card].has[qfield.key].any
function SMODS.has_any_suit(card, ...) end

--- ! Injected by QuantumCardField.inject
---@param card Card The card to check.
---@param ... ... Passed to getter func.
---@return boolean no SMODS.qfield_cache[card].has[qfield.key].no and not SMODS.qfield_cache[card].has[qfield.key].any
function SMODS.has_no_suit(card, ...) end

--- ! Injected by QuantumCardField.inject
--- Calls plural_is func (see below)
---@param value string The obj.key to check, e.g. "Spades"
---@param args table|nil Passed to plural_is func and getter func.
---@param ... ... Passed to getter func.
---@return boolean is
function Card:is_suit(value, args, ...) end

--- ! Injected by QuantumCardField.inject
---@param value_map string A map of `obj.key`s to check against.
---@param args table|nil Passed to getter func and uses flags: [bypass_debuff: Whether to ignore card.debuff, all: Whether all values of the value_map must match (or just any)]
---@param ... ... Passed to getter func.
---@return boolean is
function Card:is_suits(value_map, args, ...) end

--- ! Injected by QuantumCardField.inject
---@param cards table<integer, Card> A list of cards.
---@param ... ... Passed to getter func.
---@return table<string|table, integer> tally A table map mapping a QField value to its tally, e.g. `{m_stone = 2}`. 
---@return table<string|table, table<Card, true>> value_to_cards A table map mapping a QField value to a table map of cards.
function SMODS.get_suit_tally(cards, ...) end

--- ! Injected by QuantumCardField.inject
---@param context CalcContext The context.
---@param ... ... Passed to getter func.
---@return table ret Effects table.
function Card:calculate_suit(context, ...) end

-------------------------------
----- Sticker
-------------------------------

--- ! Injected by QuantumCardField.inject
---@param args table|nil Args table, used flags: [as_objs: Whether to return objs or obj keys.] 
---@return table<string|table, boolean> get SMODS.qfield_cache[card].get[qfield.return_flag]
function Card:get_stickers(args) end

--- ! Injected by QuantumCardField.inject
---@param card Card The card to check.
---@param ... ... Passed to getter func.
---@return boolean any SMODS.qfield_cache[card].has[qfield.key].any
function SMODS.has_any_sticker(card, ...) end

--- ! Injected by QuantumCardField.inject
---@param card Card The card to check.
---@param ... ... Passed to getter func.
---@return boolean no SMODS.qfield_cache[card].has[qfield.key].no and not SMODS.qfield_cache[card].has[qfield.key].any
function SMODS.has_no_sticker(card, ...) end

--- ! Injected by QuantumCardField.inject
--- `**has**_sticker` instead of `**is**_sticker` via `inject_args = {is_func_prefix = "has"}` in obj definition.
--- Calls plural_is func (see below)
---@param value string The obj.key to check, e.g. "perishable"
---@param args table|nil Passed to plural_is func and getter func.
---@param ... ... Passed to getter func.
---@return boolean is
function Card:has_sticker(value, args, ...) end

--- ! Injected by QuantumCardField.inject
--- `**has**_sticker` instead of `**is**_sticker` via `inject_args = {is_func_prefix = "has"}` in obj definition.
---@param value_map string A map of `obj.key`s to check against.
---@param args table|nil Passed to getter func and uses flags: [bypass_debuff: Whether to ignore card.debuff, all: Whether all values of the value_map must match (or just any)]
---@param ... ... Passed to getter func.
---@return boolean is
function Card:has_stickers(value_map, args, ...) end

--- ! Injected by QuantumCardField.inject
---@param cards table<integer, Card> A list of cards.
---@param ... ... Passed to getter func.
---@return table<string|table, integer> tally A table map mapping a QField value to its tally, e.g. `{m_stone = 2}`. 
---@return table<string|table, table<Card, true>> value_to_cards A table map mapping a QField value to a table map of cards.
function SMODS.get_sticker_tally(cards, ...) end

--- ! Injected by QuantumCardField.inject
---@param context CalcContext The context.
---@param ... ... Passed to getter func.
---@return table ret Effects table.
function Card:calculate_sticker(context, ...) end