local Interface = Import(Package.."Interface\\Interface.lua") ---@type Interface
local Component = Import(Package.."Interface\\Component.lua") ---@type Component
local Event = Import(Package.."Event.lua") ---@type Event
local Threading = Import(Package.."Threading.lua") ---@type Threading

local Me = game.Players.LocalPlayer ---@type RPlayer
local Mouse = Me:GetMouse() ---@type RMouse

---@class Window : Component
local Class = Component:Extend("Window")
Class.OnMaximized = nil ---@type Event
Class.OnMaximized = nil ---@type Event
Class.Title = "Title"
Class.BackgroundColor = Color3.fromRGB(230, 230, 230)
Class.IsDragging = false
Class.IsMaximized = false

function Class:new()
    -- Instances:

    local window = Instance.new("Frame")
    local topbar = Instance.new("Frame")
    local header = Instance.new("TextButton")
    local closeButton = Instance.new("TextButton")
    local toggleButton = Instance.new("TextButton")
    local content = Instance.new("Frame")
    local corner1 = Instance.new("UICorner", window)
    local corner2 = Instance.new("UICorner", content)

    local object = Component.new(self, window) ---@type Window

    object.OnMaximized = Event.new()
    object.OnMinimized = Event.new()

    ---@param value Color3
    function object.Style:SetColor(value)
        topbar.BackgroundColor3 = value

        for _, child in pairs (topbar:GetChildren()) do
            child.BackgroundColor3 = value
        end
    end

    ---@param value Color3
    function object.Style:SetTextColor(value)
        header.TextColor3 = value
    end

    ---@param value UDim
    function object.Style:SetRounding(value)
        corner1.CornerRadius = value
        corner2.CornerRadius = value
    end

    ---@param value number
    function object.Style:SetSize(value)
        topbar.Size = UDim2.new(1, 0, 0, value)

        for _, child in pairs (topbar:GetChildren()) do
            child.TextSize = value
        end
    end

    --Properties:

    window.Name = object.Name
    window.Parent = Interface.Gui
    window.AnchorPoint = Vector2.new(0.5, 0)
    window.BackgroundTransparency = 0
    window.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    window.BorderColor3 = Color3.fromRGB(230, 230, 230)
    window.Position = UDim2.new(0.5, 0, 0.5, 0)
    window.Size = UDim2.new(0, 200, 0, 200)

    topbar.Name = "Topbar"
    topbar.Parent = window
    topbar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    topbar.BackgroundTransparency = 0
    topbar.BorderSizePixel = 0
    topbar.Size = UDim2.new(1, 0, 0, 20)

    header.Name = "Header"
    header.Parent = topbar
    header.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, -40, 1, 0)
    header.Font = Enum.Font.Ubuntu
    header.TextColor3 = Color3.fromRGB(230, 230, 230)
    header.TextSize = 14
    header.Text = object.Title

    closeButton.Name = "CloseButton"
    closeButton.Parent = topbar
    closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -20, 0, 0)
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
    closeButton.Font = Enum.Font.Ubuntu
    closeButton.Text = "x"
    closeButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    closeButton.TextSize = object.Style:GetSize()

    toggleButton.Name = "ToggleButton"
    toggleButton.Parent = topbar
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleButton.BorderSizePixel = 0
    toggleButton.Position = UDim2.new(1, -40, 0, 0)
    toggleButton.Size = UDim2.new(0, 20, 0, 20)
    toggleButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
    toggleButton.Font = Enum.Font.Ubuntu
    toggleButton.Text = "_"
    toggleButton.TextColor3 = Color3.fromRGB(230, 230, 230)
    toggleButton.TextSize = object.Style:GetSize()

    content.Name = "Content"
    content.Parent = window
    content.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    content.BorderSizePixel = 0
    content.Position = UDim2.new(0, 0, 0, 20)
    content.Size = UDim2.new(1, 0, 1, -20)

    corner1.CornerRadius = UDim.new(0, 8)
    corner2.CornerRadius = UDim.new(0, 8)

    window.AncestryChanged:Connect(function(_, parent)
        if parent then return end

        object:Destroy()
    end)

    header.MouseButton1Down:Connect(function()
        object:StartDragging()
    end)

    header.MouseButton1Up:Connect(function()
        object:StopDragging()
    end)

    closeButton.Activated:Connect(function()
        window:Destroy()
    end)

    toggleButton.Activated:Connect(function()
        object:Toggle()
    end)

    object:GetPropertyChangedEvent("BackgroundColor"):Connect(function(...)
        content.BackgroundColor3 = object.BackgroundColor
    end)

    Interface:AddWindow(object)
    object.Style:Refresh()

    return object
end

function Class:StartDragging()
    if self.IsDragging then return end

    self.IsDragging = true
    while self.IsDragging do
        ---@diagnostic disable-next-line: undefined-field
        self.Container.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y - (self.Container.Topbar.AbsoluteSize.Y/2))
        Threading:Wait()
    end
end

function Class:StopDragging()
    if not self.IsDragging then return end

    self.IsDragging = false
    Threading:Wait()

end

---@param title? string
function Class:SetTitle(title)
    title = title or self.Title

    self.Title = title
    ---@diagnostic disable-next-line: undefined-field
    self.Container.Topbar.Header.Text = self.Title
end

---@param content Instance
function Class:AddContent(content)
    ---@diagnostic disable-next-line: undefined-field
    content.Parent = self.Container.Content
end

function Class:Toggle()
    if self.IsMaximized then self:Minimize() return end
    self:Maximize()
end

function Class:Destroy()
    if self.Destroyed then return end
    if self.Container.Parent then self.Container:Destroy() return end

    self._SUPER.Destroy(self)

    self.OnMaximized:Destroy()
    self.OnMinimized:Destroy()
end

function Class:Maximize()
    if self.IsMaximized then return end

    self.IsMaximized = true

    self.OnMaximized:Fire()
end

function Class:Minimize()
    if not self.IsMaximized then return end

    self.IsMaximized = false

    self.OnMinimized:Fire()
end

return Class