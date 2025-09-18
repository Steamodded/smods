---@meta

---@class Color
---@field [1]? number Red component of the current color
---@field [2]? number Green component of the current colour
---@field [3]? number Blue component of the current colour
---@field [4]? number Opacity component of the current colour

---@param hex string
---@return Color
---Returns HEX color attributed to the string. 
function HEX(hex) end

---@param num number
---@param hand Card[]|table[]
---@param or_more? boolean 
---@return table|(Card[]|table[])
--- Returns table containing all cards sharing the same rank equal to provided `num` (or higher). 
function get_X_same(num, hand, or_more) end

---@param num number
---@param e_switch_point? number
---@return string
--- Formats provided number and converts it to string. 
function number_format(num, e_switch_point) end

---@param number? number Returns `scale` if not provided. 
---@param scale number
---@param max? number
---@param e_switch_point? number
---@return number
--- Scales provided `number` by `scale`. 
function scale_number(number, scale, max, e_switch_point) end

---@param hand Card[]|table[]
---@param min_length? number Minimum length of the straight. 
---@param skip? boolean Sets if the straight can skip ranks. 
---@param wrap? boolean Allows straight to wrap. 
---@return table|(Card[]|table[])
--- Returns table of cards forming a straight. 
function get_straight(hand, min_length, skip, wrap) end

---@param pos table|{x: number, y: number}
---@param value string|{string: string, colour: table}[]
---@param tooltip string[]
---@param suit string
---@return table
--- Creates tally sprite UI. 
function tally_sprite(pos, value, tooltip, suit) end

---@param _t table[]
---@param seed string
---@param args table|{starting_deck?: boolean, in_pool?: fun(center: SMODS.GameObject|table, args: table)}
---@return table
---@return string key
--- Sets the seed to `seed` and randomly selects a table within `_t`. 
function pseudorandom_element(_t, seed, args) end
