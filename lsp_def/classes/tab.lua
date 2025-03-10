---@meta

---@class SMODS.Tab: SMODS.GameObject
---@field order number Sets the order. `Tab` objects in a group are displayed left to right from lowest to highest order.
---@field tab_group string The name of the group to add the tab to. Tabs in the same tab group will be displayed on the same UIBox.
---@field chosen? boolean Whether the tab is the one initially selected in the tab group. The leftmost (lowest order) tab with chosen set to true is the default tab.
---@field conditions? table<string, any> Table of conditions. This object will not draw if any condition is not `true` when evaluated.
---@field __call? fun(self: SMODS.Tab|table, o: SMODS.Tab|table): nil|table|SMODS.Tab
---@field extend? fun(self: SMODS.Tab|table, o: SMODS.Tab|table): table Primary method of creating a class.
---@field check_duplicate_register? fun(self: SMODS.Tab|table): boolean? Ensures objects already registered will not register.
---@field check_duplicate_key? fun(self: SMODS.Tab|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist.
---@field register? fun(self: SMODS.Tab|table) Registers the object.
---@field check_dependencies? fun(self: SMODS.Tab|table): boolean? Returns `true` if there's no failed dependencies.
---@field process_loc_text? fun(self: SMODS.Tab|table) Called during `inject_class`. Handles injecting loc_text.
---@field send_to_subclasses? fun(self: SMODS.Tab|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments.
---@field pre_inject_class? fun(self: SMODS.Tab|table) Called before `inject_class`. Injects and manages class information before object injection.
---@field post_inject_class? fun(self: SMODS.Tab|table) Called after `inject_class`. Injects and manages class information after object injection.
---@field inject_class? fun(self: SMODS.Tab|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`.
---@field inject? fun(self: SMODS.Tab|table, i?: number) Called during `inject_class`. Injects the object into the game.
---@field take_ownership? fun(self: SMODS.Tab|table, key: string, obj: SMODS.Tab|table, silent?: boolean): nil|table|SMODS.Tab Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Tab|table, key: string): SMODS.Tab|table? Returns an object if one matches the `key`.
---@field func? fun(self: SMODS.Tab|table) Handles generating the contents of the `Tab`. Must return a UI table starting from a G.UIT.ROOT element.
---@field is_visible? fun(self: SMODS.Tab|table, args: table): boolean? If undefined or nil, the tab is always visible. Otherwise must be a function that returns true if the tab should be visible. Args are the table of arguments passed to the tab group function.
---@overload fun(self: SMODS.Tab): SMODS.Tab
SMODS.Tab = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.Tab|table>
SMODS.Tabs = {}

---@param tab_group string
---@param args table
---@return table
--- Returns all visible tabs which belong to `tab_group` as an array sorted by order correctly formatted to pass to create_tabs argument args.tabs.
function SMODS.filter_visible_tabs(tab_group, args) end

---@param tab_group string
---@param args table
---@return table
--- Returns a UIBox with all visible tabs from `tab_group` rendered.
function SMODS.generate_tabs_uibox(tab_group, args) end
