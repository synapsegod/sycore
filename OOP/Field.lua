---@type Proxy
local Proxy = nil

---@class Field
local Class = {}
Class._CLASS = "Field"
Class.Readonly = false
Class.Final = false
Class.__index = Class

---@param readonly boolean
---@param final boolean
---@return Field
function Class.new(readonly, final)
    local field = setmetatable({}, Class)
    field.Readonly = readonly
    field.Final = final

    Proxy = Proxy or Import(Package.."OOP\\Proxy.lua")
    local proxy = Proxy.new(field, {
        __newindex = function(_, key, newValue)
            Assert(false, "Field", key, "is readonly!")
        end
    })

    return proxy
end

function Class:CanSet(key, value)
    return not self.Readonly
end

return Class