---@meta lovely

local lovely = {}

---@type function
---@param target string
---@param buffer string
---@return string | boolean
---@return string
--- Lovely version >= 0.9.0: Applies patches for `target` on `buffer`, returns patched buffer. Can fail, returning `false` and an error message.
lovely.apply_patches = function(target, buffer) end

---@type string
--- Lovely version. 
lovely.version = ""

---@type string
--- Current mod directory. 
lovely.mod_dir = ""

---@type string
--- Link to the Lovely GitHub repository. 
lovely.repo = ""

return lovely