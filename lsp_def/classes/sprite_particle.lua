---@meta

---@class SMODS.SpriteParticle: SMODS.GameObject 
---@field mod? Mod|table The mod this object is created by. 
---@field log_interval? number
---@field loc_txt? table|{name: string, text: string[]} Contains strings used for displaying text related to this object. 
---@field registered? boolean
---@field obj_table? table<string, SMODS.SpriteParticle|table> Table of objects registered to this class. 
---@field obj_buffer? string[] Array of keys to all objects registered to this class. 
---@field dependencies? string|string[] Array of mod IDs. Object will fail to register if any specified mods cannot load. 
---@field subclasses? SMODS.SpriteParticle[]|table[] Array of child classes. 
---@field super? table Parent class. 
---@field key? string Unique string to reference this object. 
---@field class_prefix? boolean|string All objects created with this class will have their key prefixed with this string. 
---@field prefix_config? boolean|table Controls how prefixes are applied. By default, excludes self.shader if set.
---@field required_params? string[] Array of parameters required for objects created by this class. 
---@field set? string Important for objects wanting to follow vanilla logic that depends on `set`. For classes, this is used for logging purposes. 
---@field shader? string Key of a shader to use when this SpriteParticle draws its Sprite. If nil, Sprite:draw() is called instead.
---@field sound? string|table|fun(self: SMODS.SpriteParticle|table, sprite: Sprite, args: table|nil): nil Key or table<key=key,per=per,vol=vol> for a Sound, played when the SpriteParticle instantiates a Sprite, or a function(self, sprite, args) also called when a Sprite is created. 
---@field life_time? number The amount of time a spawned Sprite should live. By default, this uses G.TIMERS.REAL, without G.SETTINGS.GAMESPEED. To use game speed, see spawn() below.
---@field should_remove? fun(self: SMODS.SpriteParticle|table, sprite: Sprite, card: Card|nil, args: table|nil): boolean Checked in an Event, if true, the Sprite is removed.
---@field spawn? fun(self: SMODS.SpriteParticle|table, args: table|nil): Sprite Creates a new Sprite according to args; If args.card is set, attaches the Sprite to the card, else places it at args.x, args.y. If args.centered, centers the Sprite on the Card/its coords. If args.game_speed_dependent, the Sprite's life_time depends on G.SETTINGS.GAMESPEED.
---@field remove_sprite? fun(self: SMODS.SpriteParticle|table, sprite: Sprite, card: Card|nil): nil `:remove()`s a spawned Sprite and clears it from card.children.
---@field update? fun(self: SMODS.SpriteParticle|table, sprite: Sprite, card: Card|nil): nil Upates the Sprite, by default this checks self:should_remove() for whether the Sprite should be :removed().
---@field draw? fun(self: SMODS.SpriteParticle|table, sprite: Sprite, card: Card|nil): nil Draws the Sprite.
---@field __call? fun(self: SMODS.SpriteParticle|table, o: SMODS.SpriteParticle|table): nil|table|SMODS.SpriteParticle
---@field extend? fun(self: SMODS.SpriteParticle|table, o: SMODS.SpriteParticle|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.SpriteParticle|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.SpriteParticle|table): boolean? Ensures objects with duplicate keys will not register. Checked on `__call` but not `take_ownership`. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.SpriteParticle|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.SpriteParticle|table): boolean? Returns `true` if there's no failed dependencies. 
---@field process_loc_text? fun(self: SMODS.SpriteParticle|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.SpriteParticle|table, func: string, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.SpriteParticle|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.SpriteParticle|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.SpriteParticle|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.SpriteParticle|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.SpriteParticle|table, key: string, obj: SMODS.SpriteParticle|table, silent?: boolean): nil|table|SMODS.SpriteParticle Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.SpriteParticle|table, key: string): SMODS.SpriteParticle|table? Returns an object if one matches the `key`. 
---@field obj_list? fun(self: SMODS.SpriteParticle|table, reversed: boolean): table Returns an object if one matches the `key`. 
---@overload fun(o: SMODS.SpriteParticle): SMODS.SpriteParticle
SMODS.SpriteParticle = setmetatable({
    __call = function(self)
        return self
    end
})

---@type table<string, SMODS.SpriteParticle|table>
SMODS.SpriteParticles = {}

---@param particle_key string
---@param args? table
---@return Sprite|table sprite
--- Spawns and returns a Sprite according to the given SpriteParticle
function SMODS.spawn_sprite_particle(particle_key, args) end