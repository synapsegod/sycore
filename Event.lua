local RunService = game:GetService("RunService")

---@class Event
local Event = {}
Event._CLASS = "Event"
Event._IS_CLASS = true
Event.LastFired = tick() ---@type number
Event.Connections = nil ---@type table<integer, Connection>
Event.LastArgs = nil ---@type table<integer, any>
Event.Destroyed = false
Event.__index = Event

---@class Connection : Object
local Connection = {}
Connection._CLASS = "Connection"
Event._IS_CLASS = true
Connection.Connected = false
Connection.Function = function(...)
	print("Value changed", ...)
end
Connection.Destroyed = false
Connection.__index = Connection

---@param method fun(...)
---@return Connection
function Connection:new(method)
	local object = setmetatable({}, self)
	object._IS_CLASS = false
	object.Connected = true
	object.Function = method

	return object
end

function Connection:Connect()
	Assert(not self.Destroyed, "Connection was destroyed")
	self.Connected = true
end

function Connection:Disconnect()
	self.Connected = false
end

function Connection:Destroy()
	if self.Destroyed then return end
	self.Destroyed = true

	if self.Connected then
		self:Disconnect()
	end
end



---@return Event
function Event:new()
	local object = setmetatable({}, self)
	object._IS_CLASS = false
	object.Connections = {}
	object.LastArgs = {}

	return object
end

---@param method fun(...)
---@return Connection
function Event:Connect(method)
	Assert(not self.Destroyed, "Event destroyed")
	Assert(method and type(method) == "function", "Invalid method parameter")

	local existing = table.find(self.Connections, method)
	if existing then
		existing = self.Connections[existing]
		existing.Connected = true

		return existing
	end

	local connection = Connection:new(method)
	table.insert(self.Connections, connection)

	return connection
end

function Event:Fire(...)
	Assert(not self.Destroyed == true, "Event destroyed")
	
	local args = {...}

	self.LastArgs = args
	self.LastFired = tick()

	for _, connection in pairs (self.Connections) do
		if connection.Connected then
			coroutine.wrap(function()
				connection.Function(table.unpack(args))
			end)()
		end
	end
end

---Yields for the Event to be :Fire()'d, returns arguments
---@return ...
function Event:Wait()
	Assert(not self.Destroyed == true, "Event destroyed")

	local start = self.LastFired

	while self.LastFired == start and not self.Destroyed do
		RunService.Stepped:Wait()
	end

	return table.unpack(self.LastArgs)
end

function Event:Destroy()
	if self.Destroyed then return end
	self.Destroyed = true

	for _, connection in pairs (self.Connections) do
		connection:Destroy()
	end

	table.clear(self.Connections)
end

return Event