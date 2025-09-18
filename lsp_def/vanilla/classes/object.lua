---@meta

---@class Object: table
---@overload fun(...?: any): Object|table
Object = {}
Object.__index = Object

---@param self Object
---@param ...? any
function Object:__call(...)
	local obj = setmetatable({}, self)
	obj:init(...)
	return obj
end

---@param T metatable
---@return boolean 
--- Checks if the Object is a specific metatable type. 
function Object:is(T) end

---@param self Object
---@return table
--- Extends the object's class. 
function Object:extend()
	local cls = {}
	cls.__call = Object.__call
	cls.__index = cls
	cls.super = self
	setmetatable(cls, self)
	return cls
end

---@param self Object
---@param ...? any
--- Initialized the object. 
function Object:init(...) end