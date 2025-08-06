---@meta

---@class SMODS.Rank: SMODS.GameObject
---@field obj_buffer? Ranks|string[] Array of keys to all objects registered to this class. 
---@field obj_table? table<Ranks|string, SMODS.Rank|table> Table of objects registered to this class. 
---@field loc_txt? table|{name: string} Contains strings used for displaying text related to this object. 
---@field super? SMODS.GameObject|table Parent class. 
---@field atlas? string Key to the rank's atlas. 
---@field pos? table|{x: integer} Position of the center's sprite. `y` is handled automatically.
---@field card_key? string Used for creating keys for playing cards. Card keys follow `S_R`, `S` being the rank and `R` being the rank. 
---@field lc_atlas? string Atlas used for low-contrast cards. 
---@field hc_atlas? string Atlas used for high-contrast cards. 
---@field nominal? number Amount of chips this rank should score. 
---@field shorthand? string Short description of this rank in deck preview. 
---@field face_nominal? number Determines the displayed order of ranks with the same nominal value. 
---@field face? boolean Sets if this rank counts as a "face" card. 
---@field next? Ranks|string[] List of keys to other ranks that come after this card. 
---@field prev? Ranks|string[] List of keys to other ranks that come before this card. Used when evaluating straights. 
---@field strength_effect? table|{fixed?: number, random?: boolean, ignore?: boolean} Determines how cards with this rank behave when Strength is used. 
---@field straight_edge? boolean Sets if this rank behaves like an Ace for straights. 
---@field suit_map? table<string, number> For any suit keys in this table, use this rank's atlas over the suit's atlas. Provided number is the `y` position of the suit on the rank's atlas. 
---@field __call? fun(self: SMODS.Rank|table, o: SMODS.Rank|table): nil|table|SMODS.Rank
---@field extend? fun(self: SMODS.Rank|table, o: SMODS.Rank|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Rank|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Rank|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Rank|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Rank|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Rank|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Rank|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Rank|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Rank|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Rank|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Rank|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Rank|table, key: string, obj: SMODS.Rank|table, silent?: boolean): nil|table|SMODS.Rank Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Rank|table, key: string): SMODS.Rank|table? Returns an object if one matches the `key`. 
---@field loc_vars? fun(self: SMODS.Rank|table, info_queue: table, card: Card|table) Allows adding tooltips onto cards with this suit. Return values not respected. 
---@field draw? fun(self: SMODS.Rank|table, card: Card|table, layer: string) Allows drawing additional sprites or shaders onto cards with this suit. 
---@field in_pool? fun(self: SMODS.Rank|table, args: table): boolean? Allows configuring if cards with this suit should spawn. 
---@field delete? fun(self: SMODS.Rank|table) Deletes this suit. 
---@overload fun(self: SMODS.Rank): SMODS.Rank
SMODS.Rank = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<Ranks|string, SMODS.Rank|table>
SMODS.Ranks = {}
