local RunService = game:GetService("RunService")

local Proxy = Import(Package.."OOP\\Proxy.lua") ---@type Proxy
local Field = Import(Package.."OOP\\Field.lua") ---@type Field
local ClassNames = {"Object", "Field", "Proxy"} ---@type table<integer, string>
local Objects = {} ---@type table<integer, Object>
local LastID = 0 ---@type integer

---@class Object
---@field _CLASS string Unqiue classname
---@field _IS_CLASS boolean Is the object a class or not
---@field _EVENTS table<string, Event> Internal table containing property events
---@field _ABSTRACT boolean If the Class can be instantiated with :new()
---@field _FINAL boolean If the Class can be extended
---@field _SUPER table Objects or classes metatable
---@field _INHERITS table<integer, string> If the class inherits interface(s) they can be found in this list, use with :Inherits(name)
---@field Destroyed boolean If the object is destroyed or not
---@field Name string Name of the object, by default Classname + ID
---@field ID integer Unique ID of the object
local Class = {} 
Class._CLASS = "Object"
Class._IS_CLASS = true
Class._ABSTRACT = false
Class._FINAL = false
Class._INHERITS = {"Object"}
Class.Destroyed = false

---@param fields table<string, Field>
local function createFieldProxy(fields)
    return Proxy.new(fields, {
        __call = function()
            Assert(false, "Cannot bypass proxy for _FIELDS")
        end,
        __newindex = function(_, key, value)
            Assert(string.sub(key, 1, 2) ~= "__", "Forbidden field name:", key)
            Assert(TypeOf(value) == "Field", "Field", key, "is not a field")
            
            local field = rawget(fields, key)
            Assert(field == nil, "Field", key, "already exists, value:", value)

            local superField = fields[key]
            if superField then
                Assert(superField.Final == false, "Field", key, "is final, value:", value)
            end

            fields[key] = value
        end
    })
end

---@param object Object
---@param fields table<string, Field>
local function createWriteProxy(object, fields)
    return Proxy.new(object, {
        __newindex = function(_, key, value)
            local field = rawget(fields, key) ---@type Field
            local oldValue = rawget(object, key)
            
            if field and oldValue ~= nil then
                Assert(field:CanSet(key, value), "Field", key, "did not allow write, value:", value)
            end

            local superField = fields[key] ---@type Field
            local superValue = object[key]

            if superField and superValue ~= nil then
                Assert(superField.Final == false, "Field", key, "is final, value:", value)
            end

            object[key] = value

            if not object._IS_CLASS then
                local event = object._EVENTS[key] ---@type Event

                if event then
                    event:Fire(value)
                end
            end
        end
    })
end

local Fields = { ---@type table<string, Field>
    _IS_CLASS = Field.new(true, true),
    _CLASS = Field.new(true, true),
    ID = Field.new(true, true),
    _EVENTS = Field.new(true, true),
    _ABSTRACT = Field.new(true, true),
    _FINAL = Field.new(true, true),
    _SUPER = Field.new(true, true),
    _INHERITS = Field.new(true, true),
    Destroyed = Field.new(true, true),
}
Fields.__index = Fields
Class._FIELDS = createFieldProxy(Fields)
Class.__index = Class

---Creates a new object if the class is not abstract.
---@return Object
function Class:new()
    Assert(self._ABSTRACT == false, "Class", self._CLASS, "is abstract")

    if self._IS_CLASS then
        local object = setmetatable({
            _IS_CLASS = false,
            _EVENTS = Proxy.new({}, {
                __newindex = function(_, key, value)
                    Assert(false, "Cannot write to _EVENTS, ["..key.."] =", value)
                end
            }),
        }, self)
    
        local proxy = createWriteProxy(object, self._FIELDS)
    
        LastID = LastID + 1
        object.ID = LastID
        object.Name = object._CLASS..object.ID
        table.insert(Objects, proxy)
    
        print("Created object", self._CLASS, "ID:", object.ID)
    
        return proxy
    else
        local object = self

        return object
    end
end

---Creates a new class extending self if the class is not final. If name is nil its from an interface extending (internal)
---@param name? string Classname
---@param customFields table<string, Field> Fields for value accessibility. Key needs to correspond to Class key.
---@param abstract? boolean If the class can be instantiated with :new()
---@param final? boolean If the class can be extended
---@return Object
function Class:Extend(name, customFields, abstract, final)
    Assert(table.find(ClassNames, name) == nil, "Class", name, "already exists")
    Assert(self._FINAL == false, "Class", self._CLASS, "is final")

    local class = setmetatable({
        _CLASS = name,
        _IS_CLASS = true,
        _SUPER = self,
        _ABSTRACT = abstract or false,
        _FINAL = final or false,
        _INHERITS = {name, unpack(self._INHERITS)}
    }, self)
    class.__index = class
    table.insert(class._INHERITS, class._CLASS)

    local fields = {} for i, v in pairs (Fields) do fields[i] = v end
    fields = setmetatable({}, self._FIELDS)
    fields.__index = fields
    class._FIELDS = createFieldProxy(fields)

    for key, field in pairs (customFields or {}) do
        class._FIELDS[key] = field
    end

    print("Created class", class._CLASS)
    
    return createWriteProxy(class, fields)
end

---Used for multi-inheritance, this COPIES class fields into the new class, technically does not inherit. Any instances created with :new()
---will only inherit from the class it was extended from. Only class fields NOT already present will be copied into the new class, first implementing class being dominant.
---@param ... Object A list of classes to inherit from
function Class:Implements(...)
    local classes = {...}

    for _, class in pairs (classes) do
        Assert(self:Inherits(class._CLASS) == false, self._CLASS, "already inherits", class._CLASS)

        table.insert(self._INHERITS, class._CLASS)

        for _, key in pairs (class:Keys()) do
            if self[key] == nil then
                pcall(function() self[key] = class[key] end)
            end
        end
    end

    return self
end

---String representation of the object
---@return string
function Class:ToString()
	local total = tostring(self)..":"

    for _, key in pairs (self:Keys()) do
        local value = self[key]
        local str = "\n  ["..tostring(key).."] = "..tostring(value)

        if type(value) == "table" then
            for k, v in pairs (value) do
                str = str .. "\n    ["..tostring(k).."] = "..tostring(v)
            end
            
        end

        total = total .. str
    end

	return total
end

---Returns an event that fires each time the property (name) inside object changes.
---@param name string Corresponding value name (For example Name or Destroyed)
function Class:GetPropertyChangedEvent(name)
	Assert(self[name], "Field", name, "does not exist")
	local eventClass = Import(Package.."Event.lua") ---@type Event

    local event = self._EVENTS[name]

	if not event then
        event = eventClass:new()
		self._EVENTS()[name] = event
	end

	return event
end

---Returns true if the object extends a specific class. Object is the base ancestor for all objects. Does not check for interfaces.
---@param name string Classname
function Class:IsA(name)
    local object = self

    while object do
        if object._CLASS == name then
            return true
        end

        object = object._SUPER
    end

    return false
end

---Returns true if the object implements a specific class. Use for interfaces.
function Class:Inherits(name)
    return table.find(self._INHERITS, name) ~= nil
end

---Returns all keys inside an object/class
---@return table<string, any>
function Class:Keys()
	local keys = {}

	for key, _ in pairs (self()) do
		table.insert(keys, key)
	end

	return keys
end

---Destroys the object and disconnects property bound events.
---Please only override inside class field and use self._SUPER.Destroy(self)
function Class:Destroy()
    if self.Destroyed == true then return end

    self().Destroyed = true

    table.remove(Objects, table.find(Objects, self))

    self:GetPropertyChangedEvent("Destroyed"):Fire()

    RunService.Stepped:Wait()

    ---@param key string
    ---@param event Event
    for key, event in pairs (self._EVENTS()) do
        event:Destroy()
        self._EVENTS()[key] = nil
    end
end

---@param readonly ?boolean
---@param final ?boolean
function Class:NewField(readonly, final)
    return Field.new(readonly, final)
end

return Proxy.new(Class, {
    __newindex = function (_, ...)
        Assert(false, "Cannot write to", Class._CLASS, ...)
    end,

    __gc = function(self)
        for key, object in pairs (Objects) do
            if object.ID == self.ID then
                table.remove(Objects, key)
                return
            end
        end
    end
})