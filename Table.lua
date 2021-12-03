local Object = Import(Package.."Object.lua") ---@type Object
local Proxy = Import(Package.."OOP\\Proxy.lua") ---@type Proxy
local Event = Import(Package.."Event.lua") ---@type Event
local Class = Object:Extend("Table", {}, false, false) ---@class Table : Object
Class.Data = nil ---@type Proxy
Class.ItemAdded = nil ---@type Event
Class.ItemRemoved = nil ---@type Event
Class.ItemUpdated = nil ---@type Event

---@param data ?table<any, any>
---@return Table
function Class:new(data)
	local object = Object.new(Class) ---@type Table
	object.ItemAdded = Event.new() ---@type Event
	object.ItemRemoved = Event.new() ---@type Event
	object.ItemUpdated = Event.new() ---@type Event

	---@type Proxy
	object.Data = Proxy.new(data or {}, {
		__newindex = function(_, key, value)
			local old = data[key]
			data[key] = value

			if value ~= nil then
				if typeof(value) == "Instance" then
					value.AncestryChanged:Connect(function(_, parent)
						if parent then return end

						object:Remove(object:FindByValue(value))
					end)
				end

				if old and value ~= old then
					object.ItemUpdated:Fire(key, old, value)
				elseif not old and value then
					object.ItemAdded:Fire(key, value)
				end
			else
				if old then
					object.ItemRemoved:Fire(key, old)
				end
			end
		end
	})

	return object
end

function Class:Remove(key)
	if not key then return end

	if type(key) == "number" then
		table.remove(self.Data, key)
	else
		self.Data[key] = nil
	end
end

---@param searchFunc fun(key: any, value: any): boolean
---@return any key The key if searchFunc -> true
function Class:Find(searchFunc)
	for key, value in pairs (self.Data()) do
		if searchFunc(key, value) == true then
			return key
		end
	end
end

---@return any key
function Class:FindByValue(object)
	for key, value in pairs (self.Data()) do
		if value == object then
			return key
		end
	end
end

---@param keyvaluepairs table<any, any>
---@return any key
function Class:FindByValues(keyvaluepairs)
	for key, value in pairs (self.Data()) do
		if type(value) == "table" or typeof(value) == "Instance" then
			for kkey, vvalue in pairs (keyvaluepairs) do
				if not value[kkey] == vvalue then
					break
				end
				return key
			end
		end
	end
end

---@return integer
function Class:Count()
	local length = 0

	for _, _ in pairs (self.Data()) do
		length = length + 1
	end

	return length
end

---@return table
function Class:CopyWithoutCyclic()

	local function copyTable(item, _cyclic)
		_cyclic = _cyclic or {}

		if typeof(item) == "table" then
			if table.find(_cyclic, item) then table.insert(_cyclic, item) return end
	
			local copy = {}
	
			for i, v in pairs (item) do
				copy[i] = Class.CopyWithoutCyclic(v, _cyclic)
			end
	
			return copy
		end

		return item
	end

	return copyTable(self.Data())
end

return Class