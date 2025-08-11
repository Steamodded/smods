---@meta

---@class SMODS.Font: SMODS.GameObject
---@field obj_table? table<string, SMODS.Font|table> Table of objects registered to this class. 
---@field super? SMODS.GameObject|table Parent class. 
---@field path? string Name of the font file, including the extension. 
---@field render_scale? number Set the size of the font. This is generally better as a higher value so it can be scaled down. The default value is `200`.
---@field TEXT_HEIGHT_SCALE? number Determines line spacing. The default value is `0.83`.
---@field TEXT_OFFSET? table|{x: number, y: number} Determines the offset that the font is rendered. You might need to adjust this if the font renders in unexpected places. The default value is `{x=0, y=0}`.
---@field FONTSCALE? number Multiplier to scale down the font to the intended display size. Multiplies `render_scale` so that it renders at a proper size. The default value is `0.1`.
---@field squish? number Determines horizontal width of each character. The default value is `1`.
---@field DESCSCALE? number Determines how big the description text should be in relation to normal text. Keep in mind that mobile UI makes this 1.5x bigger. The default font's value is `1`.
---@field __call? fun(self: SMODS.Font|table, o: SMODS.Font|table): nil|table|SMODS.Font
---@field extend? fun(self: SMODS.Font|table, o: SMODS.Font|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Font|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Font|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Font|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Font|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Font|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Font|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Font|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Font|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Font|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Font|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Font|table, key: string, obj: SMODS.Font|table, silent?: boolean): nil|table|SMODS.Font Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Font|table, key: string): SMODS.Font|table? Returns an object if one matches the `key`. 
---@overload fun(self: SMODS.Font): SMODS.Font
SMODS.Font = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.Font|table>
SMODS.Fonts = {}