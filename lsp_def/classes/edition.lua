---@meta

---@class SMODS.Edition: SMODS.Center
---@field loc_txt? table|{name: string, text: string[], label: string} Contains strings used for displaying text related to this object. 
---@field shader? string|false Key to the shader drawn on cards with this Edition. If set to `false`, a shader will not be drawn. 
---@field atlas? string Defines the atlas for the card this Edition is drawn on in the collection. 
---@field pos? table|{x: integer, y: integer} Defined the position of the card's sprite this Edition is drawn on in the collection.
---@field in_shop? boolean Sets if the Edition spawns naturally in the shop. 
---@field weight? number The weight of the Edition. 
---@field extra_cost? number Extra cost applied to cards in the shop with this Edition. 
---@field apply_to_float? boolean Sets if the shader is drawn on floating sprites. 
---@field badge_colour? table HEX color of the Edition's badge
---@field sound? table|{sound: string, per?: number, vol?: number} Used to set a custom sound when the Edition is applied. 
---@field disable_shadow? boolean Sets if the shadow is drawn under the card with this Edition. 
---@field disable_base_shader? boolean Sets if the default shader for the card is disabled. 
---@field super? SMODS.Center|table Parent class. 
---@field __call? fun(self: SMODS.Edition|table, o: SMODS.Edition|table): nil|table|SMODS.Edition
---@field extend? fun(self: SMODS.Edition|table, o: SMODS.Edition|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Edition|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Edition|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Edition|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Edition|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.Edition|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Edition|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Edition|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Edition|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Edition|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Edition|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Edition|table, key: string, obj: SMODS.Edition|table, silent?: boolean): nil|table|SMODS.Edition Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Edition|table, key: string): SMODS.Edition|table? Returns an object if one matches the `key`. 
---@field get_weight? fun(self: SMODS.Edition|table): number? Allows modifying the weight of this Edition. 
---@field on_apply? fun(card: Card|table) Used to modify the card when this Edition is applied. 
---@field on_remove? fun(card: Card|table) Used to modify the card when this Edition is removed. 
---@field on_load? fun(card: Card|table) Used to modify the card when a card with this Edition is loaded from a save. 
---@field draw? fun(self: SMODS.Edition|table, card: Card|table, layer: string) Draws the edition's shader. By default, `self.shader` is drawn. 
---@field get_edition_cards? fun(self: SMODS.Edition|table, card_area: CardArea|table, edition: boolean): table
---@field in_pool? fun(self: SMODS.Edition|table, args: table|{source: string}): boolean? Allows configuring if the edition is allowed to spawn.
---@overload fun(self: SMODS.Edition): SMODS.Edition
SMODS.Edition = setmetatable({}, {
    __call = function(self)
        return self
    end
})

---@param self Card|table
---@param context CalcContext|table
---@return table?
--- Calculates Editions on cards. 
function Card:calculate_edition(context) end

---@param self Card|table
---@param edition? string|{[string]: true} Both `string` values are the key of the edition to apply. 
---@param immediate? boolean
---@param silent? boolean 
---@param delay? boolean
--- Sets the card's edition. 
function Card:set_edition(edition, immediate, silent, delay) end

---@param _key string Used as the seed
---@param _mod? number Scales the chance of landing on an Edition. 
---@param _no_neg? boolean Exclude negative from edition polling. 
---@param _guaranteed? boolean Function will always return an Edition. 
---@param _options? string[]|{name: string, weight: number}[] Allows defining options for what editions should be polled. 
---@return string?
--- Polls editions. Returns the key of the edition if successful. 
function poll_edition(_key, _mod, _no_neg, _guaranteed, _options) end
