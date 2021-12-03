---@type Object
local Object = Import(Package.."Object.lua")
---@type Event
local Event = Import(Package.."Event.lua")
---@type Tweening
local Tween = Import(Package.."Tween.lua")
---@type Style
local Style = Import(Package.."Interface\\Style.lua")
---@type Instances
local Instances = Import(Package.."Instances.lua")
---@type Parameter
local Parameter = Import(Package.."Parameter.lua")
---@type Button
local Button = Import(Package.."Interface\\Input\\Button.lua")

local Parameters = {
    Parent = Parameter.new("Parent", "Instance", true),
    Style = Parameter.new("Style", "Style"),
    Position = Parameter.new("Position", "UDim2"),
    Size = Parameter.new("Size", "UDim2"),
    Multiple = Parameter.new("Position", "boolean"),
    SortOrder = Parameter.new("Position", "SortOrder"),
    Data = Parameter.new("Position", "table"),

    SelectedColor = Parameter.new("SelectedColor", "Color3"),
    SelectedTextColor = Parameter.new("SelectedTextColor", "Color3"),
    DeselectedColor = Parameter.new("DeselectedColor", "Color3"),
    DeselectedTextColor = Parameter.new("DeselectedTextColor", "Color3"),
}

---@class Select : Object
local Class = setmetatable({}, Object)
Class.Class = "Select"
Class.Parent = nil ---@type Instance
Class.Title = "Title"

Class.Data = {} ---@type table<integer, string>
Class.SortOrder = Enum.SortOrder.LayoutOrder
Class.Multiple = false

Class.Style = nil ---@type Style
Class.SelectedColor = Style:GetColor() Color3.fromRGB(85, 170, 255)
Class.SelectedTextColor = Color3.fromRGB(50, 50, 50)
Class.DeselectedColor = Color3.fromRGB(230, 230, 230)
Class.DeselectedTextColor = Color3.fromRGB(50, 50, 50)

Class.Position = UDim2.new(0.5, 0, 0.5, 0) ---@type UDim2
Class.Size = UDim2.new(0, 150, 0, 20) ---@type UDim2

Class.OnSelected = nil ---@type Event
Class.OnDeselected = nil ---@type Event

Class._selected = nil ---@type Instances
Class._container = nil ---@type Instance
Class._content = nil ---@type Instances
Class.__index = Class



---@class SelectItem
local SelectItem = {}
SelectItem.Key = nil ---@type string
SelectItem.Value = nil ---@type string
SelectItem.Container = nil ---@type Instance
SelectItem.Button = nil ---@type Button
SelectItem.__index = SelectItem

---@param value string
---@param container Instance
---@param button Button
---@return SelectItem
function SelectItem.new(value, container, button)
    return setmetatable({Value = value, Container = container, Button = button}, SelectItem)
end



---@param object table<string, any>
---@return Select
function Class.new(object)
    object = setmetatable(object or {}, Class)
    for name, parameter in pairs (Parameters) do parameter:Check(rawget(object, name)) end

    object.OnSelected = Event.new()
    object.OnDeselected = Event.new()
    object._content = {}
    object._selected = {}

    if not object.Style then object.Style = Style.new() end

    -- Instances:

    local container = Instance.new("Frame")
    local input = Instance.new("TextButton")
    local uiCorner = Instance.new("UICorner")
    local scroll = Instance.new("ScrollingFrame")
    local uiListLayout = Instance.new("UIListLayout")

    if not object.Style then object.Style = Style.new() end

    if not rawget(object.Style, "SetRounding") then
        function object.Style:GetRounding(value)
            Style.SetRounding(object.Style, value)

            local rounding = self:GetRounding()

            ---@diagnostic disable-next-line: undefined-field
            uiCorner.CornerRadius = rounding

            for _, item in pairs (object._content) do
                item.Button.Style.RoundingPreset = self.RoundingPreset
            end
        end
    end

    --Properties:

    container.Name = object.Class
    container.Parent = object.Parent
    container.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Size = object.Size
    container.Position = object.Position

    input.Name = "Input"
    input.Parent = container
    input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    input.BackgroundTransparency = 1.000
    input.Position = UDim2.new(0, 5, 0, 0)
    input.Size = UDim2.new(1, -10, 0, object._size.Y.Offset)
    input.Font = Enum.Font[object.Style.FontFamily]
    input.Text = object._title
    input.TextColor3 = Color3.fromRGB(0, 0, 0)
    input.TextSize = object.Style:GetSize()
    input.TextXAlignment = Enum.TextXAlignment.Left

    uiCorner.CornerRadius = object.Style:GetRounding()
    uiCorner.Name = "UICorner"
    uiCorner.Parent = container

    scroll.Name = "Data"
    scroll.Parent = container
    scroll.Active = true
    scroll.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    scroll.BorderSizePixel = 0
    scroll.Position = UDim2.new(0, 0, 0, object._size.Y.Offset)
    scroll.Size = UDim2.new(1, 0, 1, -object._size.Y.Offset)
    scroll.ZIndex = 2
    scroll.ScrollBarThickness = 5

    uiListLayout.Name = "UIListLayout"
    uiListLayout.Parent = scroll
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListLayout.SortOrder = object.SortOrder
    uiListLayout.Padding = UDim.new(0, 0)

    scroll.ChildAdded:Connect(function(child)
        object:_adjustSize()
    end)

    object._container = container

    container.AncestryChanged:Connect(function(_, p)
        if p then return end

        object:Destroy()
    end)

    input.Activated:Connect(function()
        object:_toggle()
    end)

    object.Style:Refresh()

    for _, value in pairs (object._data) do
        object:_displayContent(value)
    end

    return object
end

function Class:_toggle(state)
    local scroll = self._container:FindFirstChild("Data")
    state = state or not scroll.Visible

    if state == true then
        scroll.Visible = true
        self:_adjustSize()
    else
        self._container.Size = self.Size
        scroll.Visible = false
    end
end

function Class:_adjustSize()
    ---@diagnostic disable-next-line: undefined-field
    self._container.Size = self.Size + UDim2.new(0, 0, 0, self._container.Data.UIListLayout.AbsoluteContentSize.Y)
    ---@diagnostic disable-next-line: undefined-field
    self._container.Data.CanvasSize = UDim2.new(0, 0, 0, self._container.Data.UIListLayout.AbsoluteContentSize.Y)
end

function Class:_displayContent(value)
    local container = Instance.new("Frame")
    container.Name = tostring(value)
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -10, 0, 20)
    container.Name = tostring(value)

    local label = Instance.new("TextButton")
    label.Name = "Label"
    label.BackgroundColor3 = self.DeselectedColor
    label.BorderSizePixel = 0
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font[self.Style.FontFamily]
    label.TextColor3 = self.DeselectedTextColor
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local corner = Instance.new("UICorner")
    corner.Name = "UICorner"
    corner.CornerRadius = self.Style:GetRounding()
    corner.Parent = label

    ---@type SelectItem
    local item = SelectItem.new(value, container, Button.new(label, {
        Style = self.Style:Clone()
    }))

    local object = self
    container.AncestryChanged:Connect(function(_, parent)
        if not parent then
            object:_adjustSize()
        end
    end)

    label.Activated:Connect(function()
        if not object.Multiple then
            object:_toggle(false)
        end

        if object:_isSelected(item) then
            object:_deselect(item)
        else
            object:_select(item)
        end
    end)

    container.Parent = self._container:FindFirstChild("Data")
    table.insert(self._content, item)
end

---@param value string
function Class:_select(value)
    table.insert(self._selected, value)
    self.OnSelected:Fire(self:_selectContent(value))
end

---@param key string
function Class:_selectContent(key)
    for _, item in pairs (self._content) do
        if item.Container.Name == key then
            local label = item.Container:FindFirstChild("Label")
            label.Font = Enum.Font[self.Style.FontFamily.."Bold"]
            label.BackgroundColor3 = self.SelectedColor
            label.TextColor3 = self.SelectedTextColor
            return item
        end
    end
end

function Class:_deselect(key)
    ---@diagnostic disable-next-line: undefined-field
    self._container.Input.Text = self._title
    
    local index = table.find(self._selected, key)
    if index then
        table.remove(self._selected, index)
    end

    self:_deselectContent(key)
    self.OnDeselected:Fire(key, self.Data[key])
end

function Class:_deselectContent(key)
    for _, item in pairs (self._content) do
        if item.Container.Name == key then
            local label = item.Button.Button
            label.Font = Enum.Font[self.Style.FontFamily]
            label.BackgroundColor3 = self.DeselectedColor
            label.TextColor3 = self.DeselectedTextColor
        end
    end
end

function Class:_isSelected(key)
    return table.find(self._selected, key)
end

function Class:Destroy()
    if self._destroyed then return end
    if self._container.Parent then self._container:Destroy() return end

    Object.Destroy(self)
end

return Class