---@meta

---@class SMODS.Operator: SMODS.GameObject
---@field interpolation? string Interpolation type of the Operator. Currently supported: `'trig'`, '`linear'`.
---@field colours? table<number, table<number, number>> List of colours to interpolate between.
---@field cycle? number Amount of time (in seconds) for the Operator to cycle through all colours.
---@field __call? fun(self: SMODS.Operator|table, o: SMODS.Operator|table): nil|table|SMODS.Operator
---@field extend? fun(self: SMODS.Operator|table, o: SMODS.Operator|table): table Primary method of creating a class.
---@field check_duplicate_register? fun(self: SMODS.Operator|table): boolean? Ensures objects already registered will not register.
---@field check_duplicate_key? fun(self: SMODS.Operator|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist.
---@field register? fun(self: SMODS.Operator|table) Registers the object.
---@field check_dependencies? fun(self: SMODS.Operator|table): boolean? Returns `true` if there's no failed dependencies.
---@field process_loc_text? fun(self: SMODS.Operator|table) Called during `inject_class`. Handles injecting loc_text.
---@field send_to_subclasses? fun(self: SMODS.Operator|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments.
---@field pre_inject_class? fun(self: SMODS.Operator|table) Called before `inject_class`. Injects and manages class information before object injection.
---@field post_inject_class? fun(self: SMODS.Operator|table) Called after `inject_class`. Injects and manages class information after object injection.
---@field inject_class? fun(self: SMODS.Operator|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`.
---@field inject? fun(self: SMODS.Operator|table, i?: number) Called during `inject_class`. Injects the object into the game.
---@field take_ownership? fun(self: SMODS.Operator|table, key: string, obj: SMODS.Operator|table, silent?: boolean): nil|table|SMODS.Operator Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Operator|table, key: string): SMODS.Operator|table? Returns an object if one matches the `key`.
---@overload fun(self: SMODS.Operator): SMODS.Operator
SMODS.Operator = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.Operator|table>
SMODS.Operators = {}

--- Sets the current operator used on chips and mult.
---@param name string The name of the operator, plus the mod prefix.
function SMODS.set_operator(name)
end

--- Creates a `node_func` for a `SMODS.Operator` given display text and a colour. It's easier to use this if you don't need complexity.
---@param text string The text to display for the operator.
---@param colour table The color to display the operator as.
---@return function The function to be passed to `SMODS.Operator`.
function SMODS.operator_func(text, colour)
end

--- Calculates a final round score based on chips, mult, and the current operator.
---@param chips number
---@param mult number
---@return number
SMODS.calculate_round_score = function(chips, mult)
end
