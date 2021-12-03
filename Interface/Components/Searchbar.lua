local Component = Import(Package.."Interface\\Component.lua") ---@type Component
local Button = Import(Package.."Interface\\Components\\Button.lua") ---@type Button
local Event = Import(Package.."Event.lua") ---@type Event
local Tween = Import(Package.."Tween.lua") ---@type Tween

---@class Searchbar : Component
local Class = Component:Extend("Searchbar")

Class.Keyword = "keyword" ---@type string
Class.Data = nil ---@type table
Class.SortOrder = Enum.SortOrder ---@type SortOrder
Class.OnSelected = nil ---@type Event

Class.SearchFunction = function(object, keyword, key, value)
    return not string.find(value, keyword) == nil
end

Class.Found = {}

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
    object.OnSelected = Event.new()

    function object.Style:SetRounding(value)
        local rounding = object.Style:GetRounding()

        uiCorner.CornerRadius = rounding

        ---@param item RInstance
        for _, item in pairs (scroll:GetChildren()) do
            local corner = item:FindFirstChild("UICorner", true)
            if corner then
                corner.CornerRadius = rounding
            end
        end
    end

    function object.Style:SetSize(value)
        local size = self:GetSize()
        input.TextSize = size
        container.Size = UDim2.new(container.Size.X.Scale, container.Size.X.Offset, 0, size)
    end

    function object.Style:SetColor(value)
        container.BackgroundColor3 = self:GetColor()
    end

    function object.Style:SetFontFamily(value)
        input.Font = Enum.Font[self.FontFamily]
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

    uiCorner.CornerRadius = object.Style:GetRounding()
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
        object:AdjustSize()
    end)

    input.FocusLost:Connect(function(enterPressed, inputObj)
        if not enterPressed then return end

        object:Search(input.Text, nil, nil)
    end)

    object.Style:Refresh()

    return object
end

function Class:AdjustSize()
    local container = self.Container
    ---@diagnostic disable-next-line: undefined-field
    container.Size = UDim2.new(container.Size.X.Scale, container.Size.X.Offset, 0, self.Style:GetSize() + container.Data.UIListLayout.AbsoluteContentSize.Y)
    ---@diagnostic disable-next-line: undefined-field
    self._container.Data.CanvasSize = UDim2.new(0, 0, 0, self._container.Data.UIListLayout.AbsoluteContentSize.Y)
end

function Class:DisplayContent(key, value)
    local container = Instance.new("Frame")
    container.Name = key
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -10, 0, self.Style:GetSize())
    container.Name = tostring(value)

    local label = Instance.new("TextButton")
    label.BackgroundColor3 = self.ForegroundColor
    label.BorderSizePixel = 0
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font[self.Style.FontFamily]
    label.TextColor3 = Color3.fromRGB(50, 50, 50)
    label.TextSize = self.Style:GetSize()
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local corner = Instance.new("UICorner")
    corner.Name = "UICorner"
    corner.CornerRadius = self.Style:GetRounding()
    corner.Parent = label

    local object = self
    container.AncestryChanged:Connect(function(_, parent)
        if not parent then
            object:AdjustSize()
        end
    end)

    label.Activated:Connect(function()
        object.OnSelected:Fire(key, value)
        ---@diagnostic disable-next-line: undefined-field
        object._container.Input.Text = tostring(value)
        object:_clearScroll()
    end)

    ---@diagnostic disable-next-line: undefined-field
    container.Parent = self._container.Data

    table.insert(self.Container:WaitForChild("Data"), container)
end

function Class:_clearScroll()
    ---@diagnostic disable-next-line: undefined-field
    for _, child in pairs (self._container.Data:GetChildren()) do
        if not child.ClassName == "UIListLayout" then
            child:Destroy()
        end
    end

    ---@diagnostic disable-next-line: undefined-field
    table.clear(self._content)
end

function Class:Search(keyword, sort, data, searchFunction)
    keyword = keyword or self.Keyword
    Parameters.Keyword:Check(keyword)

    sort = sort or self.SortOrder
    Parameters.SortOrder:Check(sort)

    data = data or self.Data
    Parameters.Data:Check(data)

    searchFunction = searchFunction or self.SearchFunction
    Parameters.SearchFunction:Check(searchFunction)

    table.clear(self._found)
    local startSearch = tick()
    self._lastSearch = startSearch

    if string.len(keyword) == 0 then
        for key, value in pairs (data) do
            if not self._lastSearch == startSearch then return end

            table.insert(self._found, key)
        end
    else
        for key, value in pairs (data) do
            if not self._lastSearch == startSearch then return end

            if searchFunction(self, keyword, key, value) == true then
                table.insert(self._found, key)
            end
        end
    end

    ---@diagnostic disable-next-line: undefined-field
    self._container.Data.UIListLayout.SortOrder = sort

    for _, key in pairs (self._found) do
        if not self._lastSearch == startSearch then return end

        self:_displayContent(key, data[key])
    end
end

function Class:Destroy()
    if self._destroyed then return end
    if self._container.Parent then self._container:Destroy() return end

    Object.Destroy(self)
end

return Class