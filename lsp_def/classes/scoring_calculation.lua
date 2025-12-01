---@meta

---@class SMODS.Scoring_Calculation: SMODS.GameObject
---@field extend? fun(self: SMODS.Scoring_Calculation|table, o: SMODS.Scoring_Calculation|table): table Primary method of creating a class.
---@field check_duplicate_register? fun(self: SMODS.Scoring_Calculation|table): boolean? Ensures objects already registered will not register.
---@field check_duplicate_key? fun(self: SMODS.Scoring_Calculation|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist.
---@field register? fun(self: SMODS.Scoring_Calculation|table) Registers the object.
---@field check_dependencies? fun(self: SMODS.Scoring_Calculation|table): boolean? Returns `true` if there's no failed dependencies.
---@field process_loc_text? fun(self: SMODS.Scoring_Calculation|table) Called during `inject_class`. Handles injecting loc_text.
---@field send_to_subclasses? fun(self: SMODS.Scoring_Calculation|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments.
---@field pre_inject_class? fun(self: SMODS.Scoring_Calculation|table) Called before `inject_class`. Injects and manages class information before object injection.
---@field post_inject_class? fun(self: SMODS.Scoring_Calculation|table) Called after `inject_class`. Injects and manages class information after object injection.
---@field inject_class? fun(self: SMODS.Scoring_Calculation|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`.
---@field inject? fun(self: SMODS.Scoring_Calculation|table, i?: number) Called during `inject_class`. Injects the object into the game.
---@field take_ownership? fun(self: SMODS.Scoring_Calculation|table, key: string, obj: SMODS.Scoring_Calculation|table, silent?: boolean): nil|table|SMODS.Scoring_Calculation Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Scoring_Calculation|table, key: string): SMODS.Scoring_Calculation|table? Returns an object if one matches the `key`.
---@field new? fun(self, config): SMODS.Scoring_Calculation Creates a new instance of this operator.
---@field key string Used to reference your calculation, mod_prefix is applied
---@field func fun(self, chips, mult, flames): number Calculate your new score, flames respects animation timings
---@field text? string Replaces the `X` in the UI
---@field colour? table HEX colour of the `text` in the UI
---@field replace_ui? fun(self) Return a UI node to replace the display
---@field update_ui? fun(self: SMODS.Scoring_Calculation, container?: UIElement, chip_display?: UIElement, mult_display?: UIElement, operator?: UIElement)
---@field config? table Values saved to the scoring calculation
---@field parameters? string[] Table of Scoring Parameter keys that are used
---@overload fun(self: SMODS.Scoring_Calculation): SMODS.Scoring_Calculation
SMODS.Scoring_Calculation = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.Scoring_Calculation|table>
SMODS.Scoring_Calculations = {}

--- Sets the current operator used on chips and mult.
---@param key string|SMODS.Scoring_Calculation The key of the scoring calculation you want to use.
function SMODS.set_scoring_calculation(key) end

--- Calculates a final round score based on the current scoring calculation.
---@param flames boolean Flag for flame calculation - result respects animations
---@return number
SMODS.calculate_round_score = function(flames) end


---@class SMODS.Scoring_Parameter: SMODS.GameObject
---@field extend? fun(self: SMODS.Scoring_Parameter|table, o: SMODS.Scoring_Parameter|table): table Primary method of creating a class.
---@field check_duplicate_register? fun(self: SMODS.Scoring_Parameter|table): boolean? Ensures objects already registered will not register.
---@field check_duplicate_key? fun(self: SMODS.Scoring_Parameter|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist.
---@field register? fun(self: SMODS.Scoring_Parameter|table) Registers the object.
---@field check_dependencies? fun(self: SMODS.Scoring_Parameter|table): boolean? Returns `true` if there's no failed dependencies.
---@field process_loc_text? fun(self: SMODS.Scoring_Parameter|table) Called during `inject_class`. Handles injecting loc_text.
---@field send_to_subclasses? fun(self: SMODS.Scoring_Parameter|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments.
---@field pre_inject_class? fun(self: SMODS.Scoring_Parameter|table) Called before `inject_class`. Injects and manages class information before object injection.
---@field post_inject_class? fun(self: SMODS.Scoring_Parameter|table) Called after `inject_class`. Injects and manages class information after object injection.
---@field inject_class? fun(self: SMODS.Scoring_Parameter|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`.
---@field inject? fun(self: SMODS.Scoring_Parameter|table, i?: number) Called during `inject_class`. Injects the object into the game.
---@field take_ownership? fun(self: SMODS.Scoring_Parameter|table, key: string, obj: SMODS.Scoring_Parameter|table, silent?: boolean): nil|table|SMODS.Scoring_Calculation Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Scoring_Parameter|table, key: string): SMODS.Scoring_Parameter|table? Returns an object if one matches the `key`.
---@field key string Used to reference the parameter, mod_prefix is added
---@field default_value number Default value of the parameter
---@field colour? table HEX colour
---@field calculation_keys? string[] Valid return keys from calculate functions
---@field hands? table[] Used to add custom values for different poker hands
---@field modify? fun(self: SMODS.Scoring_Parameter, amount: number) Alters the value of the parameter
---@field calc_effect? fun(self: SMODS.Scoring_Parameter, effect: table, scored_card: Card|table, key: string, amount: number, from_edition: boolean) Handle how this parameter is calculated when return from a calculate functon
---@field level_up_hand? fun(self: SMODS.Scoring_Parameter, amount: number, hand: table, behaviour?: function) Handle how to upgrade this parameter's base value for a specific poker hand. If `behaviour` is included, it must take the current base value of the parameter and `amount` as arguments, in that order, and return the desired base value of the parameter.

---@type table<string, SMODS.Scoring_Parameter|table>
SMODS.Scoring_Parameters = {}

--- Gets the value of a scoring parameter
---@param key string The key of the parameter
---@param flames boolean Flag for flame calculation - result respects animations
function SMODS.get_scoring_parameter(key, flames) end
