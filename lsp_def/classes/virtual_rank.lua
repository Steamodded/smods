---@meta

---@class SMODS.VirtualRank: SMODS.GameObject
---@field obj_buffer? string[] Array of keys to all objects registered to this class. 
---@field obj_table? table<string, SMODS.VirtualRank|table> Table of objects registered to this class. 
---@field super? SMODS.GameObject|table Parent class. 
---@field base_ranks? table<SMODS.Rank|string, true> A map of rank keys this VirtualRank overrides.
---@field next? Ranks|string[] List of keys to other ranks that come after this VirtualRank. 
---@field prev? Ranks|string[] List of keys to other ranks that come before this VirtualRank.
---@field next_redirs? table<SMODS.Rank|string, boolean> A map of ranks this VirtualRank overrides .next for. If value is false, doesn't add self to redirs but still removes base .next
---@field prev_redirs? table<SMODS.Rank|string, boolean> A map of ranks this VirtualRank overrides .prev for. If value is false, doesn't add self to redirs but still removes base .prev
---@field next_wrap? table<SMODS.Rank|string, boolean> A map of ranks this VirtualRank additionally returns in get_straight_next("next") if do_wrap = true.
---@field prev_wrap? table<SMODS.Rank|string, boolean> A map of ranks this VirtualRank additionally returns in get_straight_next("prev") if do_wrap = true.
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
---@field delete? fun(self: SMODS.Rank|table) Deletes this suit. 
---@field get_straight_next? fun(self: SMODS.VirtualRank|table, direction: "next"|"prev", do_wrap?: boolean) Function to get a virtual rank's .next/.prev, added to be interchangeable with SMODS.Rank.
---@overload fun(self: SMODS.Rank): SMODS.Rank
SMODS.VirtualRank = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.VirtualRank|table>
SMODS.VirtualRanks = {}
