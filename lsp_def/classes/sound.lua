---@meta

---@class SMODS.Sound: SMODS.GameObject
---@field super? SMODS.GameObject|table Parent class. 
---@field path? string Name of the sound file, including extension. 
---@field pitch? number Pitch for music tracks. 
---@field volume? number Volume for music tracks. 
---@field replace? string|table Replaces specific sound with this sound whenever played. Behaves like `SMODS.Sound:create_replace_sound()`. 
---@field sync? false|table Configured syncing for music tracks. Setting to `false` prevents the music track from syncing with anything. 
---@field __call? fun(self: SMODS.Sound|table, o: SMODS.Sound|table): nil|SMODS.Sound
---@field extend? fun(self: SMODS.Sound|table, o: SMODS.Sound|table): table Primary method of creating a class. 
---@field check_duplicate_register? fun(self: SMODS.Sound|table): boolean? Ensures objects already registered will not register. 
---@field check_duplicate_key? fun(self: SMODS.Sound|table): boolean? Ensures objects with duplicate keys will not register. Checked on __call but not take_ownerhsip. For take_ownership, the key must exist. 
---@field register? fun(self: SMODS.Sound|table) Registers the object. 
---@field check_dependencies? fun(self: SMODS.Sound|table): boolean? Returns true if there's no failed dependencies, else false
---@field process_loc_text? fun(self: SMODS.Sound|table) Called during `inject_class`. Handles injecting loc_text. 
---@field send_to_subclasses? fun(self: SMODS.Sound|table, ...: any) Starting from this class, recusively searches for functions with the given key on all subordinate classes and run all found functions with the given arguments. 
---@field pre_inject_class? fun(self: SMODS.Sound|table) Called before `inject_class`. Injects and manages class information before object injection. 
---@field post_inject_class? fun(self: SMODS.Sound|table) Called after `inject_class`. Injects and manages class information after object injection. 
---@field inject_class? fun(self: SMODS.Sound|table) Injects all direct instances of class objects by calling `obj:inject` and `obj:process_loc_text`. Also injects anything necessary for the class itself. Only called if class has defined both `obj_table` and `obj_buffer`. 
---@field inject? fun(self: SMODS.Sound|table, i?: number) Called during `inject_class`. Injects the object into the game. 
---@field take_ownership? fun(self: SMODS.Sound|table, key: string, obj: table, silent?: boolean): nil|SMODS.Sound Takes control of vanilla objects. Child class must have get_obj for this to function
---@field get_obj? fun(self: SMODS.Sound|table, key: string): table? Returns an object if one matches the `key`. 
---@field select_music_track? fun(self: SMODS.Sound|table): nil|number Called each frame. Determines what music track to play. Music track with the highest number is played. 
---@field create_replace_sound? fun(self: SMODS.Sound|table, replace: string|table) Replaces another sound with this one. 
---@field create_stop_sound? fun(self: SMODS.Sound|table, key: string, times: nil|number) Supress sounds with the given sound code `times` amount of times or indefinitely. 
---@field register_global? fun(self: SMODS.Sound|table) Registers all sound files of the current mod. 
---@field get_current_music? fun(self: SMODS.Sound|table): nil|string Polls `SMODS.Sound:select_music_track` and returns the key to the music to play.
---@overload fun(self: SMODS.Sound): SMODS.Sound
SMODS.Sound = setmetatable({}, {
    __call = function(self)
        return self
    end
})