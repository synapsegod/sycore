local Object = Import(Package.."OOP\\Object.lua") ---@type Object
local Style = Import(Package.."Interface\\Style.lua") ---@type Style
local Table = Import(Package.."Table.lua") ---@type Table

local Components = Table:new()

---Class to represent UI item
---@class Component : Object
---@field Container RInstance @**readonly, final** Instance containing all children
---@field OriginalPosition UDim2 @**final** Original position of the container on creation
---@field OriginalSize UDim2 @**final** Original size of the container on creation
---@field Style Style @**readonly, final** Components style
local Component = Object:Extend("Component", {
    Container = Object:NewField(true, true),
    OriginalPosition = Object:NewField(false, true),
    OriginalSize = Object:NewField(false, true),
    Style = Object:NewField(true, true)
})

---Creates a blank component, if the container is already bound to component, returns existing component
---@param container RInstance
---@return Component
function Component:new(container)
    local existing = Components:Find(function (key, value)
        return key == container
    end)
    if existing then return Components[container] end

    local object = Object.new(self)
    object.Container = container
    object.OriginalPosition = container["Position"]
    object.OriginalSize = container["Size"]
    object.Style = Style:new()

    container.AncestryChanged:Connect(function(_, parent)
        if not parent then object:Destroy() end
    end)

    Components:Insert(container, object)

    return object
end

function Component:Destroy()
    if self.Destroyed then return end
    if self.Container.Parent then self.Container:Destroy() return end

    self._SUPER.Destroy(self)

    table.remove(Components, table.find(Components, self))
end

return Component