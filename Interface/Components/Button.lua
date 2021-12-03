local Object = Import(Package.."\\OOP\\Object.lua") ---@type Object
local Component = Import(Package.."Interface\\Component.lua") ---@type Component
local Instanc = Import(Package.."Roblox\\Instance.lua") ---@type Instance
local Tween = Import(Package.."Tween.lua") ---@type Tween

---**Inherits Component, Instance**. UI Button
---@class Button : Object
---@field Container RInstance @Inherited from Component
---@field Instance RInstance
---@field IsMouseOn boolean
---@field IsMouseDown boolean
local Class = Object:Extend("Button"):Implements(Component, Instanc)

---@param parent RInstance
---@param classname string TextButton or ImageButton
---@return Button
function Class:new(parent, classname)
    local button = Instance.new(classname) ---@type RInstance
    local uicorner = Instance.new("UICorner") ---@type RInstance
    
    button.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(0, 60, 0, 20)
    if classname == "TextButton" then
        button.Font = Enum.Font.Ubuntu
        button.TextColor3 = Color3.fromRGB(50, 50, 50)
        button.TextSize = 14
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.Text = "Button"
    else
        button.ImageColor3 = Color3.fromRGB(230, 230, 230)
    end
    
    button.Parent = parent
    uicorner.Parent = button

    ---@type Button
    local object = Object.new(self)
    Component.new(object, button)
    Instanc.new(object, button)

    button.Name = object.Name

    function object.Style:SetColor(value)
        local props = {BackgroundColor3 = self:GetColor()}
        if classname == "ImageButton" then
            props.ImageColor3 = props.BackgroundColor3
        end

        Tween:Create(object.Container, props, 0.3, "Quad", "Out"):Play()
    end

    if classname == "TextButton" then
        function object.Style:SetTextColor(value)
            Tween:Create(object.Container, {TextColor3 = self:GetTextColor()}, 0.3, "Quad", "Out"):Play()
        end
    end

    if classname == "TextButton" then
        function object.Style:SetFontFamily(value)
            object.Container.Font = Enum.Font[self.FontFamily]
        end
    end

    function object.Style:SetRounding(value)
        uicorner.CornerRadius = self:GetRounding()
    end

    ---@diagnostic disable-next-line: undefined-field
    object.Container.MouseButton1Down:Connect(function(...)
        object.IsMouseDown = true
        object:OnMouseDown(...)
    end)

    ---@diagnostic disable-next-line: undefined-field
    object.Container.MouseButton1Up:Connect(function(...)
        if object.IsMouseDown then
            object.IsMouseDown = false
            object:OnMouseUp(...)
        end
    end)

    ---@diagnostic disable-next-line: undefined-field
    object.Container.MouseEnter:Connect(function(...)
        object.IsMouseOn = true
        object:OnMouseEnter(...)
    end)

    ---@diagnostic disable-next-line: undefined-field
    object.Container.MouseLeave:Connect(function(...)
        object.IsMouseOn = false
        if object.IsMouseDown then
            object.IsMouseDown = false
            object:OnMouseUp(...)
        end

        object:OnMouseLeave(...)
    end)

    ---@diagnostic disable-next-line: undefined-field
    object.Container.Activated:Connect(function()
        object:Activated()
    end)

    object.Style:Refresh()

    return object
end

function Class:Activated()

end

function Class:OnMouseDown(x, y)

end

function Class:OnMouseUp(x, y)

end

function Class:OnMouseEnter(x, y)

end

function Class:OnMouseLeave(x, y)

end

function Class:Destroy()
    --Downside of multi inheritance if function names overlap you have to re-write function body, luckily not in this case because self.Container == self.Instance

    if self.Destroyed then return end
    if self.Container.Parent then self.Container:Destroy() return end
    --if self.Instance.Parent then self.Instance:Destroy() return end

    --self._SUPER.Destroy(self)

    self.IsMouseDown = false
    self.IsMouseOn = false
end

return Class