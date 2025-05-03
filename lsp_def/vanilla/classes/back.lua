---@meta

---@class Back: Object
---@overload fun(args: {T: table, container: Back}): Back
Back = {}
Back.__index = Back
Back.super = Object

---@param self Back
---@param selected_back SMODS.Back|table
---@return Back
function Back:__call(selected_back) end

---@param self Back
---@param selected_back SMODS.Back|table
function Back:init(selected_back) end

---@param self Back
---@return string
--- Returns the localized name of the Back.
function Back:get_name() end

---@param self Back
---@param other? SMODS.Back|table
---@param ui_scale? number
---@param min_dims? number
---@param challenge? string
---@return UINode
--- Generates the Back's name and description.
function Back:generate_UI(other, ui_scale, min_dims, challenge) end

---@param self Back
---@param new_back? table Defaults to `G.P_CENTERS.b_red`
--- Changes the Back from current to provided `new_back`.
function Back:change_to(new_back) end

---@param self Back
---@return table
--- Returns a table representing this Back to be saved.
function Back:save() end

---@param self Back
---@param args CalcContext
---@return ...
--- Calculates the effect of the Back.
function Back:trigger_effect(args) end

---@param self Back
--- Applies the Back's effect to the run.
function Back:apply_to_run() end

---@param self Back
---@param backTable table
--- Loads the Back.
function Back:load(backTable) end
