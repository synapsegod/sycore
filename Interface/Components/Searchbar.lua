local Component = Import(Package.."Interface\\Component.lua") ---@type Component
local Button = Import(Package.."Interface\\Components\\Button.lua") ---@type Button
local Event = Import(Package.."Event.lua") ---@type Event
local Tween = Import(Package.."Tween.lua") ---@type Tween

---@class SearchbarResult
---@field Data any
---@field Component Component
local SearchbarResult = {}

---@class Searchbar : Component
---@field Keyword string
---@field Data table<integer, any> | fun(self:Searchbar):table<integer, any>
---@field Results SearchbarResult[]
---@field SortOrder SortOrder
---@field OnSelected Event
---@field private LastSearch number
local Class = Component:Extend("Searchbar")
Class.SortOrder = Enum.SortOrder.LayoutOrder

---@param key integer
---@param value string
function Class:Filter(key, value)
    return (self.Keyword == nil or self.Keyword == "") or (not string.find(value, self.Keyword) == nil)
end

---@param parent RInstance
---@return Searchbar
function Class:new(parent)

    -- Instances:

    local container = Instance.new("Frame")
    local input = Instance.new("TextBox")
    local uiCorner = Instance.new("UICorner")
    local scroll = Instance.new("ScrollingFrame")
    local uiListLayout = Instance.new("UIListLayout")

    local object = Component.new(self, container) ---@type Searchbar
    object.OnSelected = Event:new()
    object.Data = {}
    object.Results = {}

    ---@param value UDim
    function object.Style:SetRounding(value)

        uiCorner.CornerRadius = value

        ---@param item RInstance
        for _, result in pairs (object.Results) do
            result.Component.Style.Rounding = self.Rounding
        end
    end

    ---@param value number
    function object.Style:SetSize(value)
        input.TextSize = value
        input.Size = UDim2.new(1, -10, 0, value)
        container.Size = UDim2.new(container.Size.X.Scale, container.Size.X.Offset, 0, value)
        object:AdjustSize()
    end

    ---@param value Color3
    function object.Style:SetColor(value)
        container.BackgroundColor3 = value
    end

    ---@param value string
    function object.Style:SetFontFamily(value)
        input.Font = Enum.Font[value]

        for _, result in pairs (object.Results) do
            result.Component.Style:SetFontFamily(value)
        end
    end

    --Properties:

    container.Name = object.Name
    container.Parent = parent
    container.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Size = UDim2.new(0, 200, 0, 30)

    input.Name = "Input"
    input.Parent = container
    input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    input.BackgroundTransparency = 1.000
    input.Position = UDim2.new(0, 5, 0, 0)
    input.Size = UDim2.new(1, -10, 0, 20)
    input.Font = Enum.Font.SourceSans
    input.PlaceholderText = "Search..."
    input.Text = ""
    input.TextColor3 = Color3.fromRGB(0, 0, 0)
    input.TextSize = 14.000
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.Multiline = false
    input.ClearTextOnFocus = false

    uiCorner.CornerRadius = UDim.new(0, 0)
    uiCorner.Name = "UICorner"
    uiCorner.Parent = container

    scroll.Name = "Data"
    scroll.Parent = container
    scroll.Active = true
    scroll.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    scroll.BorderSizePixel = 0
    scroll.Position = UDim2.new(0, 0, 0, 20)
    scroll.Size = UDim2.new(1, 0, 1, -20)
    scroll.ZIndex = 2
    scroll.ScrollBarThickness = 5

    uiListLayout.Name = "UIListLayout"
    uiListLayout.Parent = scroll
    uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiListLayout.SortOrder = object.SortOrder
    uiListLayout.Padding = UDim.new(0, 0)

    scroll.ChildAdded:Connect(function(child)
        object:AdjustSize(child)
    end)

    input.FocusLost:Connect(function(enterPressed, _)
        if not enterPressed then return end
        if string.len(input.Text) == 0 then return end

        object.Keyword = input.Text
    end)

    object:GetPropertyChangedEvent("Keyword"):Connect(function()
        object:Search(object.Keyword)
    end)

    object.Style:Refresh()

    return object
end

function Class:AdjustSize()
    local container = self.Container
    local data = container:WaitForChild("Data")

    ---@diagnostic disable-next-line: undefined-field
    local cSize = UDim2.new(container.Size.X.Scale, container.Size.X.Offset, 0, self.Style:GetSize() + data.UIListLayout.AbsoluteContentSize.Y)
    ---@diagnostic disable-next-line: undefined-field
    local dSize = UDim2.new(0, 0, 0, data.UIListLayout.AbsoluteContentSize.Y)

    Tween:Create(
        container,
        {Size = cSize},
        0.3, "Quad", "Out"
    ):Play()

   Tween:Create(
    data,
       {CanvasSize = dSize},
       0.3, "Quad", "Out"
    ):Play()
end

---@param key integer
---@param value any
---@return Component
function Class:AddResult(key, value)
    local parent = self.Container:WaitForChild("Data")
    local component = Button:new(parent, "Text") ---@type Button
    component.Container.Size = UDim2.new(1, 0, 0, self.Style.SizeEnum:Get(self.Style.Size))
    component.Container.Text = tostring(key) .. ": " .. tostring(value)
    component.Style:Apply(self.Style)
    component.Style.Color = component.Style.ColorEnum.BLACK

    local obj = self
    function component:Activated()
        obj.OnSelected:Fire(value)
        obj:Clear()
    end

    return component
end

function Class:Clear()
    for _, result in pairs (self.Results) do
        result.Component:Destroy()
    end

    table.clear(self.Results)

    self:AdjustSize()
end

---@param keyword string
function Class:Search(keyword)
    keyword = keyword or self.Keyword
    local startSearch = tick()
    self.LastSearch = startSearch
    self:Clear()

    local data = (type(self.Data) == "table" and self.Data) or self:Data()
    for key, value in pairs (data) do
        if self.LastSearch ~= startSearch then return end

        local filterPass = self:Filter(key, value)

        if filterPass then
            table.insert(self.Results, {Data = value, self:AddResult(key, value)})
        end
    end
end

function Class:Destroy()
    if self.Destroyed then return end

    self._SUPER.Destroy(self)
end

return Class