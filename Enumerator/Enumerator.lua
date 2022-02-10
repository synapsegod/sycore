local Proxy = Import(Package.."OOP\\Proxy.lua") ---@type Proxy

---@class Enumerator
local Enumerator = {_CLASS = "Enumerator"}
Enumerator.__index = Enumerator

---@class EnumValue
---@field Name string
---@field Value integer
local EnumValue = {_CLASS = "EnumValue"}
EnumValue.__index = EnumValue

---@param ... string
---@return Enumerator
function Enumerator:new(...)
	local keys = {...}

	local object = setmetatable({}, Enumerator) ---@type Enumerator
	for value, key in pairs (keys) do
		Assert(object[key] == nil, "Enum name", key, "is reserved")
		Assert(type(key) == "string", "Incorrect enum parameter", value, key)
		
		object[key] = EnumValue:new(key, value)
	end

	local proxy = Proxy.new(object, {
		__index = function(_, key)
			local found = object[key]

			---@type EnumValue
			if TypeOf(found) == "EnumValue" then
				return found.Value
			end

			return found
		end,

		__newindex = function(_, key, value)
			Assert(object[key] == nil, "Cannot write enumerator", key, ":", value)
			object[key] = value
		end
	})

	return proxy
end

---@return EnumValue[]
function Enumerator:Values()
	local values = {}

	---@param enumValue EnumValue
	for _, enumValue in pairs (self()) do
		if TypeOf(enumValue) == "EnumValue" then
			table.insert(values, EnumValue)
		end
	end

	return values
end

---@param value integer
---@return string?
function Enumerator:NameOf(value)
	return self:EnumValueOf(value).Name
end

---@param name string
---@return integer?
function Enumerator:ValueOf(name)
	return self:EnumValueOf(name).Value
end

---@param value string | integer Name or Value works
---@return EnumValue?
function Enumerator:EnumValueOf(value)
	for _, enumvalue in pairs (self:Values()) do
		if type(value) == "string" then
			if enumvalue.Name == value then return enumvalue end
		elseif (type(value)) == "number" then
			if enumvalue.Value == value then return enumvalue end
		end
	end
end

---@param name string
---@param value integer
---@return EnumValue
function EnumValue:new(name, value)
	local object = setmetatable({}, EnumValue)---@type EnumValue
	object.Name = name
	object.Value = value

	local proxy = Proxy.new(object, {
		__call = function()
			Assert(false, "Cannot bypass proxy for enumvalue")
		end,
		__newindex= function (_, k, v)
			Assert(k ~= "Name" and k ~= "Value", "Cannot write enum value", k, ":", v)
			object[k] = v
		end
	})
	
	return proxy
end

---@return string
function EnumValue:ToString()
	return self.Value .. " : " .. tostring(self.Name)
end

return Enumerator