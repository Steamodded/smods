---@meta

---@class SMODS.TabDialog: SMODS.UIBox
---@field key string The key of this TabDialog. Tabs with a matching tab_dialog field will be displayed in this tab dialog.
---@field g_funcs? table Array of member functions to add to G.FUNCS.
---@field back_button? string Controller button for backing out of the UIBox.
---@field back_colour? table HEX color fill of the back button.
---@field back_delay? number Button delay for the back button.
---@field back_id? string ID for the back button.
---@field back_label? string Localization key for the label on the back button.
---@field bg_colour? table Background color for the UIBox
---@field colour? table Inner background color for the UIBox
---@field minw? number The minimum width of the UIBox.
---@field no_back? boolean Whether to hide the back button for the UIBox.
---@field no_pip? boolean Whether to prevent the creation of a binding controller pip on the back button.
---@field outline_colour? table Colour for the outline between the background and inner background.
---@field padding? number Padding value around the contents of the UIBox.
---@field snap_back? boolean Whether to snap the controller to the back button.
---@field content_alignment? string Alignment of the tab contents within the UIBox.
---@field content_minh? number Minimum height for the tab contents container.
---@field content_minw? number Minimum width for the tab contents container.
---@field content_padding? number The padding of the tab contents.
---@field no_loop? boolean Disables shoulder buttons looping around on controllers when switching tabs.
---@field no_shoulders? boolean Disables shoulder buttons on controllers from switching tabs.
---@field scale? number The scale of the tab buttons.
---@field snap_to_nav? boolean Whether to snap the controller to the navigation buttons (tabs)
---@field tab_colour? table Background color of the tab buttons.
---@field text_scale? number The scale of the text on the tab buttons.
---@field __call? fun(self: SMODS.TabDialog|table, o: SMODS.TabDialog|table): nil|table|SMODS.TabDialog
---@field extend? fun(self: SMODS.TabDialog|table, o: SMODS.TabDialog|table): table Primary method of creating a class.
---@field check_duplicate_register? fun(self: SMODS.TabDialog|table): boolean? Ensures objects already registered will not register.
---@field check_duplicate_key? fun(self: SMODS.TabDialog|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist.
---@field register? fun(self: SMODS.TabDialog|table) Registers the object.
---@field check_dependencies? fun(self: SMODS.TabDialog|table): boolean? Returns `true` if there's no failed dependencies.
---@field process_loc_text? fun(self: SMODS.TabDialog|table) Called during `inject_class`. Handles injecting loc_text.
---@field send_to_subclasses? fun(self: SMODS.TabDialog|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments.
---@field pre_inject_class? fun(self: SMODS.TabDialog|table) Called before `inject_class`. Injects and manages class information before object injection.
---@field post_inject_class? fun(self: SMODS.TabDialog|table) Called after `inject_class`. Injects and manages class information after object injection.
---@field inject_class? fun(self: SMODS.TabDialog|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`.
---@field inject? fun(self: SMODS.TabDialog|table, i?: number) Called during `inject_class`. Injects the object into the game.
---@field take_ownership? fun(self: SMODS.TabDialog|table, key: string, obj: SMODS.Tab|table, silent?: boolean): nil|table|SMODS.Tab Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.TabDialog|table, key: string): SMODS.Tab|table? Returns an object if one matches the `key`.
---@field contents? fun(self: SMODS.TabDialog|table, args?: table): UINode? Generates the contents of the TabDialog. Called automatically by create_UIBox().
---@field func_key? fun(self: SMODS.TabDialog|table, func_name: string): string Returns the key in G.FUNCS where this object's function of name func_name is available, if it was a member of the g_funcs array.
---@field generate_infotip? fun(self: SMODS.TabDialog|table, args?: table): table? Generates an optional, dynamic infotip to display with this UIBox. The returned value should be an table contaning an array of text lines and an optional lang code.
---@field create_UIBox? fun(self: SMODS.TabDialog|table, args?: table): UINode Returns the generated UIBox with the configured options.
---@field back_func? fun(self: SMODS.TabDialog|table, e: table?) Called when the back button is pressed.
---@field filter_visible_tabs? fun(self: SMODS.TabDialog|table, args?: table): table? Returns an ordered array of tabs compatible with args.tabs of create_tabs. Called automatically by contents().
---@field opt_callback? fun(self: SMODS.TabDialog|table, e: table?) Additional callback to call when tab is switched.
---@overload fun(self: SMODS.TabDialog): SMODS.TabDialog
SMODS.TabDialog = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.TabDialog|table>
SMODS.TabDialogs = {}
