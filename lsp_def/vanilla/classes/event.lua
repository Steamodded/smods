---@meta

---@class Event: Object
---@overload fun(config: table): Event
Event = {}
Event.__index = Event
Event.super = Object

---@param self Event
---@param config table
---@return Event
function Event:__call(config) end

---@param self Event
---@param config table
function Event:init(config) end

---@param self Event
---@param _results table
--- Handles the Event.
function Event:handle(_results) end

---@class EventManager: Object
---@overload fun(): EventManager
EventManager = {}
EventManager.__index = EventManager
EventManager.super = Object

---@param self EventManager
---@return EventManager
function EventManager:__call() end

---@param self EventManager
function EventManager:init() end

---@param self EventManager
---@param event Event
---@param queue? string Queue type
---@param front? boolean Puts even at the front of the queue.
--- Adds Event to the EventManager's queue.
function EventManager:add_event(event, queue, front) end

---@param self EventManager
---@param queue? string Queue type
---@param exception? string Clears all other queues except provided.
function EventManager:clear_queue(queue, exception) end

---@param self EventManager
---@param dt number
---@param forced? boolean
--- Updates the EventManager.
function EventManager:update(dt, forced) end
