---@meta

---@param _c? table Object center. 
---@param full_UI_table? table UI Table. 
---@param specific_vars? table
---@param card_type? string
---@param badges? table Table of badges added below the card desc. 
---@param hide_desc? boolean Undiscovered description instead of normal. 
---@param main_start? table Added text above the card's normal description. 
---@param main_end? table Added text below the card's normal description. 
---@param card? table Card or Card-like object. 
---@return table full_UI_table
--- Generates description UI for Cards and Card-like objects. 
function generate_card_ui(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card) end

---@param card Card|table
---@param context CalcContext|table
---@return table effect
---@return table post_trig
--- Evaluates provided `card` for scoring. 
function eval_card(card, context) end
