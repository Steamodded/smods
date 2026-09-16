---@meta

---@class SMODS_poll_object_args
---@field type? string Set to poll.
---@field types? table Array of sets to poll.
---@field rarity? string|integer Rarity to poll an object from.
---@field rarities? table Rarities to poll an object from.
---@field attributes? string[] Polls objects with these attributes.
---@field union? boolean If `true` polls objects that have any of the specified attributes instead of all of them. 
---@field pool? table Custom pool to poll from.
---@field seed? string Seed for the RNG.
---@field filter? fun(pool:table):table Filter function for the pool.
---@field guaranteed? boolean If `true` it will always return an object even if the set has a chance to not return one.
---@field chance? number Chance to return an object.
---@field no_negative? boolean Excludes Negative from Editions.
---@field print? boolean Prints debug logs.
---@field closest_match? boolean

-- Returns a `key` of the polled object type
---@param args SMODS_poll_object_args|table
---@return string?
function SMODS.poll_object(args) end

-- Returns the `weight` and `modified_weight` or a given object
---@param obj? table Object to poll
---@param opt_weight? number Custom weight
---@param args? table Arguments to pass to the object's get_weight
---@return number
---@return number
function SMODS.get_weight_of_object(obj, opt_weight, args) end

-- Polls an object from a pool
---@param pool table
---@param poll number
---@param low number
---@param high number
---@param depth? integer
---@return table?
function SMODS.select_by_weight(pool, poll, low, high, depth) end

---@type table<string, number>
--- Default rate to obtain an object of the set when polling with SMODS.poll_object
SMODS.base_rate_percentage = {}

---@type table<string, boolean>
--- Prevents an object from repolling if it hits an unavailable object with SMODS.poll_object
SMODS.no_repoll = {}

---@type table<string|integer, string>
--- List of sets with their associated prototype table field in `G`
SMODS.game_table_from_type = {}

---@type table<string, table>
--- List of sets with their associated key parameters for the key_append/random seed
SMODS.poll_keys = {}

-- Returns the appropriate random seed for the object type
---@param type string Set the object to poll belongs to
---@param infill? string Appends to the key
---@return string
function SMODS.get_poll_key(type, infill) end

-- Returns a pool of available blinds
---@param blind_type string|'small'|'big'|'boss'
---@param skip_cull? boolean Skips checking for bosses used this run
---@return table
function SMODS.create_blind_pool(blind_type, skip_cull) end

-- Create a table of {key = string, type = label} items to be polled
---@param labels table Sets/attributes polled
---@param args? SMODS_poll_object_args|table
---@return table
function SMODS.create_poll_pool(labels, args) end

-- Replaces create_card_for_shop with object weights enabled
---@param area CardArea|table
---@return Card|table
function SMODS.create_shop_card(area) end

-- Polls a set between multiple
---@param args? SMODS_poll_object_args|table
---@return string
function SMODS.poll_object_type(args) end

-- Removes cards from the pool if they're unavailable (By setting them to 'UNAVAILABLE')
---@param pool table
---@param args? SMODS_poll_object_args|table
---@return table
function SMODS.cull_pool(pool, args) end