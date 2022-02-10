local Object = Import(Package.."OOP\\Object.lua") ---@type Object

local Instances = {} ---@type table<RInstance, Instance>

---Used to bind a roblox instance to a custom object, if the instance is already bound, 
---returns that object instead of creating a duplicate
---@class Instance : Object
local Class = Object:Extend("Instance", {
    Instance = Object:NewField(true, true),
    Bindings = Object:NewField(true, true)
}, false, false)
---**readonly, final** Roblox instance
Class.Instance = nil ---@type RInstance
---**readonly, final** Binding events are stored here, internal
Class.Bindings = nil ---@type table<string, Event>

---Properties of object are bound to the properties of the roblox instance
---@param instance RInstance
---@return Instance
function Class:new(instance)
    local found = Instances[instance] 
    if found then return found end

    local object = self._SUPER.new(self) ---@type Instance
    object.Instance = instance
    object.Bindings = {}

    instance.AncestryChanged:Connect(function(_, parent)
        if parent then return end

        object:Destroy()
    end)

    Instances[instance] = object

    return object
end

---Creates a one way reactive binding
---@param name string
function Class:BindProperty(name)
    Assert(self.Destroyed == false, self.Name, "has been destroyed")
    Assert(self.Bindings[name] == nil, name, "is already bound to", self.Instance)
    Assert(self.Instance[name] ~= nil, name, "is not a valid property")

    if self[name] == nil then
        self[name] = self.Instance[name]
    else
        self.Instance[name] = self[name]
    end
    local event = self:GetPropertyChangedEvent(name)
    self.Bindings[name] = event

    local object = self
    local connection = event:Connect(function()
        object.Instance[name] = object[name]
    end)

    return connection
end

---Unbinds a binding
---@param name string
function Class:UnbindProperty(name)
    Assert(self.Destroyed == false, self.Name, "has been destroyed")
    Assert(self[name] ~= nil or self.Bindings[name], name, "is not bound to", self.Instance)

    self.Bindings[name]:Destroy()
    self.Bindings[name] = nil
    self._EVENTS()[name] = nil
end

---Returns the object associated with instance if previously created
---@param instance RInstance
---@return Instance
function Class:GetObject(instance)
    return Instances[instance]
end

function Class:Destroy()
    if self.Destroyed then return end
    if self.Instance.Parent then self.Instance:Destroy() return end

    self._SUPER.Destroy(self)

    Instances[self.Instance] = nil
end

return Class