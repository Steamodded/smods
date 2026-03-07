---@meta

--- Vanilla classes & functions. 

-- Balatro vanilla classes declared here, allows typing SMODS functions. 
---@class Object: metatable
---@overload fun(...: any): Object|table
Object = {}
function Object:__call(...) return self end

---@class Node: Object
---@overload fun(...: any): Node|table
Node = {}
function Node:__call(...) return self end

---@class Event: Object
---@overload fun(...: any): Event|table
Event = {}
function Event:__call(...) return self end

---@class EventManager: Object
---@overload fun(...: any): EventManager|table
EventManager = {}
function EventManager:__call(...) return self end

---@class Back: Object
---@overload fun(...: any): Back|table
Back = {}
function Back:__call(...) return self end

---@class Tag: Object
---@overload fun(...: any): Tag|table
Tag = {}
function Tag:__call(...) return self end

---@param self Tag|table
---@param tag_sprite Sprite|table
---@param vars_only boolean 
---@return Sprite|table? tag_sprite Returns `loc_vars` if `vars_only` is `true`. 
--- Sets the Tag's description UIBox. 
function Tag:get_uibox_table(tag_sprite, vars_only) end

---@class Game: Object
---@overload fun(...: any): Game|table
Game = {}
function Game:__call(...) return self end

---@class Moveable: Node
---@overload fun(...: any): Moveable|table
Moveable = {}
function Moveable:__call(...) return self end

---@class UIBox: Moveable
---@overload fun(...: any): UIBox|table
UIBox = {}
function UIBox:__call(...) return self end

---@class UIElement: Moveable
---@overload fun(...: any): UIElement|table
UIElement = {}
function UIElement:__call(...) return self end

---@class DynaText: Moveable
---@overload fun(...: any): DynaText|table
DynaText = {}
function DynaText:__call(...) return self end

---@class Particles: Moveable
---@overload fun(...: any): Particles|table
Particles = {}
function Particles:__call(...) return self end

---@class Sprite: Moveable
---@overload fun(...: any): Sprite|table
Sprite = {}
function Sprite:__call(...) return self end

---@class AnimatedSprite: Sprite
---@overload fun(...: any): AnimatedSprite|table
AnimatedSprite = {}
function AnimatedSprite:__call(...) return self end

---@class Blind: Moveable
---@overload fun(...: any): Blind|table
Blind = {}
function Blind:__call(...) return self end

---@type Blind|table|nil
G.GAME.blind = Blind()

---@param self Blind
---@param area CardArea
---@param card Card|table
---@param from_area CardArea
---@return boolean? 
--- Determines if the card should stay flipped when drawn. 
function Blind:stay_flipped(area, card, from_area) end

---@param self Blind
---@param cards (Card|table)[]
---@param poker_hands table[]
---@param text string
---@param mult number
---@param hand_chips number
---@param scoring_hand (table|Card)[]
---@return number mult
---@return number hand_chips
---@return boolean modded
--- Calculates modifications of played hand. 
function Blind:modify_hand(cards, poker_hands, text, mult, hand_chips, scoring_hand) end

---@class Card: Moveable
---@field ability? table
---@field ignore_base_shader? table
---@field ignore_shadow? table
---@overload fun(...: any): Card|table
Card = {}
function Card:__call(...) return self end

---@param self Card
---@param vars_only? boolean Only return description values
---@return table # Becomes `loc_vars` if `vars_only` is `true`. 
---@return table? man_start Only returns if `vars_only` is `true`. 
---@return table? main_end Only returns if `vars_only` is `true`. 
--- Handles variables before passing into `generate_card_ui()`. 
function Card:generate_UIBox_ability_table(vars_only) end

---@param self Card
---@return number
--- Returns card Mult. 
function Card:get_chip_mult() end

---@param self Card
---@return number
--- Returns card XMult.
function Card:get_chip_x_mult() end

---@param self Card
---@return number
--- Returns card hand Mult.
function Card:get_chip_h_mult() end

---@param self Card
---@return number
--- Returns card hand XMult.
function Card:get_chip_h_x_mult() end

---@param self Card
---@return number
--- Returns card XChips.
function Card:get_chip_x_bonus() end

---@param self Card
---@return number
--- Returns card hand Chips.
function Card:get_chip_h_bonus() end

---@param self Card
---@return number
--- Returns card hand XChips.
function Card:get_chip_h_x_bonus() end

---@param self Card
---@return number
--- Returns card dollars.
function Card:get_p_dollars() end

---@param self Card
---@return number
--- Returns card hand dollars.
function Card:get_h_dollars() end

---@class Card_Character: Moveable
---@overload fun(...: any): Card_Character|table
Card_Character = {}
function Card_Character:__call(...) return self end

---@class CardArea: Moveable
---@overload fun(...: any): CardArea|table
CardArea = {}
function CardArea:__call(...) return self end

--- Vanilla functions

---@param hex string
---@return table
---Returns HEX color attributed to the string. 
function HEX(hex) end

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

---@param _t table
---@param seed string|number
---@param args? table|{starting_deck?: boolean, in_pool?: fun(v: any, args: table):boolean}
---@return any
---@return string|number key
--- Sets the seed to `seed` and randomly selects an element within `_t`.
---
--- First filters the elements of `_t` using `args.in_pool`,
--- or else each element `v`'s `v.in_pool` field, if given.
function pseudorandom_element(_t, seed, args) end

--- Vanilla Pools

---@alias Enhancements
---| 'm_bonus'
---| 'm_mult'
---| 'm_wild'
---| 'm_glass'
---| 'm_steel'
---| 'm_stone'
---| 'm_gold'
---| 'm_lucky'

---@alias Editions
---| 'e_foil'
---| 'e_holo'
---| 'e_polychrome'
---| 'e_negative'

---@alias Seals
---| 'Red'
---| 'Blue'
---| 'Gold'
---| 'Purple'

---@alias Stickers
---| 'perishable'
---| 'eternal'
---| 'rental'
---| 'pinned'

---@alias PokerHands
---| 'Flush Five'
---| 'Flush House'
---| 'Five of a Kind'
---| 'Straight Flush'
---| 'Four of a Kind'
---| 'Full House'
---| 'Flush'
---| 'Straight'
---| 'Three of a Kind'
---| 'Two Pair'
---| 'Pair'
---| 'High Card'

---@alias Ranks
---| '2'
---| '3'
---| '4'
---| '5'
---| '6'
---| '7'
---| '8'
---| '9'
---| '10'
---| 'Jack'
---| 'Queen'
---| 'King'
---| 'Ace'

---@alias Suits
---| 'Hearts'
---| 'Diamonds'
---| 'Clubs'
---| 'Spades'

---@alias Rarities
---| 'Legendary'
---| 'Rare'
---| 'Uncommon'
---| 'Common'