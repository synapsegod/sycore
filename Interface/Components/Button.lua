local Component = Import(Package.."Interface\\Component.lua") ---@type Component
local Tween = Import(Package.."Tween.lua") ---@type Tween
local Style = Import(Package.."Interface\\Style.lua") ---@type Style
local Event = Import(Package.."Event.lua") ---@type Event

---@class Button : Component
---@field SelectedColor Color3
---@field DeselectedColor Color3
---@field IsMouseOn boolean
---@field IsMouseDown boolean
---@field Selectable boolean If selectable then button will stay activated
---@field Selected boolean If Selectable is true this indicates if selected
---@field Group Button[] If selectable then all other buttons in group will deselect, can be nil
---@field OnSelected Event
---@field OnDeselected Event
local Class = Component:Extend("Button")
Class.SelectedColor = Style.ColorEnum:Get(Style.ColorEnum.INFO)
Class.DeselectedColor = Style.ColorEnum:Get(Style.ColorEnum.DARK)
Class.Selected = false

---@param parent RInstance
---@param buttonType string Text or Image
---@param group? table<integer, Button>
---@return Button
function Class:new(parent, buttonType, group)
    local button = Instance.new(buttonType) ---@type RInstance
    local uicorner = Instance.new("UICorner") ---@type RInstance
    
    button.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(0, 60, 0, 20)
    if buttonType == "Text" then
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
    local object = Class.new(self, button)
    if group then
        object.Group = group
        table.insert(group, object)
    end
    object.OnSelected = Event:new()
    object.OnDeselected = Event:new()

    button.Name = object.Name

    ---@param value number
    function object.Style:SetSize(value)
        button.Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, button.Size.Y.Scale, value)
        if buttonType == "Text" then
            button.TextSize = value
        end
    end

    ---@param value Color3
    function object.Style:SetColor(value)
        if object.Selectable then
            value = object.Selected and object.SelectedColor or object.DeselectedColor
        end
        
        local props = {BackgroundColor3 = value}
        if buttonType == "Image" then
            props.ImageColor3 = props.BackgroundColor3
        end

        Tween:Create(object.Container, props, 0.3, "Quad", "Out"):Play()
    end

    if buttonType == "Text" then
        ---@param value Color3
        function object.Style:SetTextColor(value)
            Tween:Create(object.Container, {TextColor3 = value}, 0.3, "Quad", "Out"):Play()
        end
    end

    if buttonType == "Text" then
        ---@param value string
        function object.Style:SetFontFamily(value)
            object.Container.Font = Enum.Font[value]
        end
    end

    ---@param value UDim
    function object.Style:SetRounding(value)
        uicorner.CornerRadius = value
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
        if object.Selectable then
            if object.Selected then object:Deselect() else object:Select() end
        end
    end)

    object.Style:Refresh()

    return object
end

function Class:Select()
    if not self.Selectable then return end
    if self.Selected then return end

    self.Selected = true
    self.Style:SetColor(self.SelectedColor)

    if not self.Group then return end
    for _, item in pairs (self.Group) do
        if item ~= self then
            item:Deselect()
        end
    end
end

function Class:Deselect()
    if not self.Selectable then return end
    if not self.Selected then return end

    self.Selected = false
    self.Style:SetColor(self.DeselectedColor)
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
    if self.Destroyed then return end
    self._SUPER.Destroy(self)

    self.IsMouseDown = false
    self.IsMouseOn = false
    self.Selected = false

    if self.Group then
        table.remove(self.Group, table.find(self.Group, self))
    end
end

return Class