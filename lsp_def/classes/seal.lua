---@meta

---@class SMODS.Seal: SMODS.GameObject
---@field obj_buffer? Seals|string[] Array of keys to all objects registered to this class. 
---@field obj_table? table<Seals|string, SMODS.Seal|table> Table of objects registered to this class. 
---@field loc_txt? table|{name: string|string[], text: string[]|string[][], label: string} Contains strings used for displaying text related to this object. 
---@field super? SMODS.GameObject|table Parent class. 
---@field atlas? string Key to the seal's atlas. 
---@field pos? table|{x: integer, y: integer} Position of the seal's sprite. 
---@field unlocked? boolean Sets the unlock state of the center. 
---@field badge_colour? table HEX color the seal badge uses. 
---@field sound? table|{} Controls the sound that plays when the seal is applied. `sound`: Key to the sound, `per`: Sound pitch, `vol`: Sound volume. 
---@field badge_to_key? string[] Contains keys to each seal indexed by seal badge (`key:lower()..'_seal`). 
---@field __call? fun(self: SMODS.Seal|table, o: SMODS.Seal|table): nil|table|SMODS.Seal
---@field extend? fun(self: SMODS.Seal|table, o: SMODS.Seal|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Seal|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Seal|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Seal|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Seal|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Seal|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Seal|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Seal|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Seal|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Seal|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Seal|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Seal|table, key: string, obj: SMODS.Seal|table, silent?: boolean): nil|table|SMODS.Seal Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Seal|table, key: string): SMODS.Seal|table? Returns an object if one matches the `key`. 
---@field loc_vars? fun(self: SMODS.Seal|table, info_queue: table, card: Card|table): table? Provides control over displaying the tooltip of this seal. See [`loc_vars`](https://github.com/Steamodded/smods/wiki/Localization#loc_vars) documentation for details. 
---@field calculate? fun(self: SMODS.Seal|table, card: Card|table, context: CalcContext|table): table?, boolean?  Calculates effects based on parameters in `context`. See [SMODS calculation](https://github.com/Steamodded/smods/wiki/calculate_functions) docs for details. 
---@field get_p_dollars? fun(self: SMODS.Seal|table, card: Card|table): number? Gives money when a card with this seal is played. 
---@field draw? fun(self: SMODS.Seal|table, card: Card|table, layer: string) Draws the sprite and shader of the seal. 
---@field update? fun(self: SMODS.Seal|table, card: Card|table, dt: number) Allows logic for this card to be run per-frame. 
---@field generate_ui? fun(self: SMODS.Seal|table, info_queue: table, card: Card|table, desc_nodes: table, specific_vars: table, full_UI_table: table) Provides complex control over the UI display of the seal. See [`generate_ui`](https://github.com/Steamodded/smods/wiki/Localization#generate_ui-advanced) documentation for details. 
---@field create_fake_card? fun(self: SMODS.Seal|table): table Creates a fake card with this seal. Used internally for `generate_ui` in cases where recieved `card` param is nil. 
---@field new? fun(self, name, label, full_name, pos, loc_txt, atlas, discovered, color): any DEPRECATED. DO NOT USE
---@overload fun(self: SMODS.Seal): SMODS.Seal
SMODS.Seal = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<Seals|string, SMODS.Seal|table>
SMODS.Seals = {}

---@param args table|{key?: string, mod?: number, guaranteed?: boolean, options?: table, type_key?: string}
---@return Seals|string?
--- Polls seals. 
function SMODS.poll_seal(args) end
