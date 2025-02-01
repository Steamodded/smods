---@meta

---@class SMODS.Center: SMODS.GameObject
---@field super? SMODS.GameObject|table Parent class. 
---@field atlas? string Key to the center's atlas. 
---@field pos? table Position of the center's sprite. 
---@field unlocked? boolean Sets the unlock state of the center. 
---@field discovered? boolean Sets the discovery state of the center. 
---@field no_collection? boolean Sets whether the card shows up in the collections menu. 
---@field loc_txt? table Contains data used for displaying text related to this object. See SMODS documentation for the class on format. 
---@field pools? string[] Array of keys to ObjectType pools this center will be added to.
---@field cost? number Sell cost of this center. 
---@field no_pool_flag? string Key to a pool flag defined in `G.GAME.pool_flags`. This center is removed from it's pool as long as this flag is `true`. 
---@field yes_pool_flag? string Key to the pool flag defined in `G.GAME.pool_flags`. This center is removed from it's pool as long as this flag is `false`. 
---@field __call? fun(self: SMODS.Center|table, o: SMODS.Center|table): nil|SMODS.Center
---@field extend? fun(self: SMODS.Center|table, o: SMODS.Center|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Center|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Center|table): boolean? Ensures objects with duplicate keys will not register. Checked on __call but not take_ownerhsip. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Center|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Center|table): boolean? Returns true if there's no failed dependencies, else false
---@field process_loc_text? fun(self: SMODS.Center|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Center|table, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Center|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Center|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Center|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Center|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Center|table, key: string, obj: table, silent?: boolean): nil|SMODS.Center Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Center|table, key: string): table? Returns an object if one matches the `key`. 
---@field delete? fun(self: SMODS.Center|table): boolean?  Removes provided center. 
---@field generate_ui? fun(self: SMODS.Center|table, info_queue: table, card: Card|table, desc_nodes: table, specific_vars: table, full_UI_table: table) Provides complex control over the UI display of the card. 
---@field loc_vars? fun(self: SMODS.Center|table, info_queue: table, card: Card|table): table? Provides simple control over displaying descriptions and tooltips of the card. 
---@field locked_loc_vars? fun(self: SMODS.Center|table, info_queue: table, card: Card|table): table Provides simple control over displaying descriptions and toolips of this center when not unlocked. 
---@field check_for_unlock? fun(self: SMODS.Center|table, args: table): boolean? Configures unlock conditions. See vanilla implementation of `check_for_unlock` for details on `args` parameters. 
---@field set_badges? fun(self: SMODS.Center|table, card: Card|table, badges: table) Append `badges` for additional badges on the UI display of the card. To override the rarity/card type badge, see `SMODS.Center:set_card_type_badge()`. 
---@field set_card_type_badge? fun(self: SMODS.Center|table, card: Card|table, badges: table) Overrides the rarity/card type badges, allowing you to Append `badges` to replace them. To add extra badges, see `SMODS.Center:sset_badges()`. 
---@field draw? fun(self: SMODS.Center|table, card: Card|table, layer: string) Draws the sprite and shader of the card. 
---@field update? fun(self: SMODS.Center|table, card: Card|table, dt: number) Allows logic to be run per-frame. 
---@field set_sprites? fun(self: SMODS.Center|table, card: Card|table, front?: Card|table) Used for setting and manipulating sprites of the card when created or loaded. 
---@field load? fun(self: SMODS.Center|table, card: Card|table, card_table: table, other_card?: table) Used when the card itself is being reloaded. 
---@field set_ability? fun(self: SMODS.Center|table, card: Card|table, initial?: boolean, delay_sprites?: boolean) Sets up initial ability and size parameters for the card. 
---@field add_to_deck? fun(self: SMODS.Center|table, card: Card|table, from_debuff: boolean) Allows modifying the game state when the card is being added. 
---@field remove_from_deck? fun(self: SMODS.Center|table, card: Card|table, from_debuff: boolean) Allows modifying the game state when the card is being removed. 
---@field in_pool? fun(self: SMODS.Center|table, args: table): boolean? , table? Allows configuring if the card is allowed to spawn. 
---@field calculate? fun(self: SMODS.Center|table, card: Card|table, context: table): nil|table?, boolean?  Calculates effects based on parameters in `context`. See SMODS calculations docs for details. 
---@field create_fake_card? fun(self: SMODS.Center|table): table Creates a fake card representing this center. Used internally for `generate_ui` in cases where recieved `card` param is nil. 
---@overload fun(self: SMODS.Center): SMODS.Center
SMODS.Center = setmetatable({}, {
    __call = function(self)
        return self
    end
})
