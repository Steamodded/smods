---@meta

---@class Tag: Object
---@overload fun(_tag: string, for_collection?: boolean, _blind_type?: string): Tag
Tag = {}
Tag.__index = Tag
Tag.super = Object

---@param self Tag
---@param _tag string
---@param for_collection? boolean
---@param _blind_type? string
---@return Tag
function Tag:__call(_tag, for_collection, _blind_type) end

---@param self Tag
---@param _tag string
---@param for_collection? boolean
---@param _blind_type? string
function Tag:init(_tag, for_collection, _blind_type) end

---@param self Tag
--- "Nopes" and removes the tag. 
function Tag:nope() end

---@param self Tag
---@param message string
---@param _colour table 
---@param func function Called within an event after displaying `message`
--- Applies the tag effect. 
function Tag:yep(message, _colour, func) end

---@param self Tag
--- Sets `tag.ability`. 
function Tag:set_ability() end

---@param self Tag
---@param _context table 
--- Calculates a Tag's effect and applies it. 
function Tag:apply_to_run(_context) end

---@param self Tag
--- Saves the Tag.
function Tag:save() end

---@param self Tag
--- Loads the Tag.
function Tag:load(tag_savetable) end

---@param self Tag
---@param _scale number
---@param _rot number
--- Juices up the Tag.
function Tag:juice_up(_scale, _rot) end

---@param self Tag
---@param _size? number
--- Generates UI for the Tag.
function Tag:generate_UI(_size) end

---@param self Tag|table
---@param tag_sprite Sprite|table
---@param vars_only boolean 
---@return Sprite|table? tag_sprite Returns `loc_vars` if `vars_only` is `true`. 
--- Sets the Tag's description UIBox. 
function Tag:get_uibox_table(tag_sprite, vars_only) end

---@param self Tag
--- Removes the Tag from the run.
function Tag:remove_from_game() end

---@param self Tag
--- Removes the Tag object.
function Tag:remove() end