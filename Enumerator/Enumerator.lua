---@class Enumerator
local Class = {
	_CLASS = "Enumerator",
}
Class.__index = Class

---@class EnumValue
local EnumValue = nil

---@param keys table<integer, string>
---@return Enumerator
function Class.new(keys)
	Assert(type(keys) == "table", "Incorrect keys parameter")

	---@type Enumerator
	local object = setmetatable({}, Class)

	for i, key in pairs (keys) do
		--Assert(Class[key] ~= nil, "Reserved enum name", key)
		Assert(type(key) == "string", "Enum must be a string")

		object[key] = EnumValue.new(key, i)
	end

	local proxy = setmetatable({}, {
		__index = function(_, key)
			Assert(type(key) == "string", "Invalid index", key, "should be string")

			if object:ValueOf(key) ~= -1 then	--if they are looking for a value
				return object[key]._value
			end

			return object[key]	--looking for a method, if its not in enumerated then in metatable.__index
		end,
		__newindex = function(_, key, value)
			Assert(false, "Attempted to write enum with", key, value)
		end,
	})

    return proxy
end

---@return table<number, EnumValue>
function Class:Values()
	local values = {}

	for _, value in pairs (self) do
		if TypeOf(value) == "EnumItem" then
			table.insert(values, value)
		end
	end

	return values
end

---@param value integer
---@return string
function Class:NameOf(value)
	for _, enum in pairs (self:Values()) do
		if enum._value == value then
			return enum._name
		end
	end

	return "null"
end

---@param name string
---@return number
function Class:ValueOf(name)
	for _, enum in pairs (self:Values()) do
		if enum._name == name then
			return enum._value
		end
	end
	
	return -1
end

-------------------------------------------------------------------------------------------------------
EnumValue = {
	Class = "EnumValue",

	_name = "name",
	_value = 0
}
EnumValue.__index = EnumValue

---@param name string
---@param value integer
---@return EnumValue
function EnumValue.new(name, value)
	local object = setmetatable({
		_name = name,
		_value = value
	}, EnumValue)
	
	local proxy = setmetatable({}, {
		__index = function(_, key)
			return object[key]	--looking for a method, if its not in enumerated then in metatable.__index
		end,
		__newindex = function(_, key, val)
			Assert(key ~= "_name" and key ~= "_value", "Attempted to write readonly values:", key, value)
			Assert(type(key) == "string", "Incorrect index type:", key, value)

			object[key] = val
		end,
	})

	return proxy
end

---@return string
function EnumValue:ToString()
	return self._name .. " : " .. tostring(self._value)
end

-------------------------------------------------------------------------------------------------------

return Class