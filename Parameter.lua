---@class Parameter
local Class = {}
Class._CLASS = "Parameter"
Class.Name = "Parameter_name"
Class.Value = nil
Class.Type = "string"
Class.Required = false

---@param name string
---@param paramType string
---@param required boolean
---@return Parameter
function Class:new(name, paramType, required)
    local object = setmetatable({}, self)
    object.Name = name
    object.Type = paramType
    object.Required = required

    return object
end

---@param value any
function Class:Check(value)
    if typeof(value) == "EnumItem" then
        Assert((tostring(value.EnumType) == self.Type), "Incorrect", self.Name, "parameter")
    else
        Assert((not self.Required and value == nil) or (TypeOf(value) == self.Type), "Incorrect", self.Name, "parameter")
    end
end

return Class
