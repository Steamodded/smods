---@meta

-- Balatro vanilla classes declared here, allows typing SMODS functions. 
---@class Object
---@class Node: Object
---@class Event: Object
---@class EventManager: Object
---@class Back: Object
---@class Tag: Object
---@class Game: Object
---@class Moveable: Node
---@class UIBox: Moveable
---@class UIElement: Moveable
---@class DynaText: Moveable
---@class Particles: Moveable
---@class Sprite: Moveable
---@class AnimatedSprite: Sprite
---@class Blind: Moveable
---@class Card: Moveable
---@field ability? table
---@class Card_Character: Moveable
---@class CardArea: Moveable

-- Commonly used functions (either typed as @class or defined)

---@param hex string
---@return table
---Returns HEX color attributed to the string. 
function HEX(hex) end