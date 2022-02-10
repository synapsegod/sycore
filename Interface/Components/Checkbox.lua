local Component = Import(Package.."Interface\\Component.lua") ---@type Component

---Checkbox component for simple boolean editing
---@class Checkbox : Component
local Class = Component:Extend("Checkbox", {}, false, false)
---State of the Checkbox
Class.State = false ---@type boolean
---Display the state as string (self.State and "Yes" or "No")
Class.DisplayState = false
Class.Title = "Checkbox"

---@param parent RInstance
function Class:new(parent)
    -- Instances:

    local container = Instance.new("Frame")
    local label = Instance.new("TextLabel")
    local button = Instance.new("TextButton")
    local fakeBorder = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local fakeButton = Instance.new("ImageLabel")
    local UICorner_2 = Instance.new("UICorner")
    local UICorner_3 = Instance.new("UICorner")

    local object = Component.new(self, container) ---@type Checkbox

    ---@param value UDim
    function object.Style:SetRounding(value)
        UICorner.CornerRadius = value
        UICorner_2.CornerRadius = value
        UICorner_3.CornerRadius = value
    end

    ---@param value number
    function object.Style:SetSize(value)
        container.Size = UDim2.new(container.Size.X.Scale, container.Size.X.Offset, container.Size.Y.Scale, value)
        label.Position = UDim2.new(0, value, 0, 0)
        label.Size = UDim2.new(1, -value, 1, 0)
        label.TextSize = value
    end

    function object.Style:SetColor(value)
        container.BorderColor3 = value
        fakeBorder.BackgroundColor3 = value
        fakeButton.ImageColor3 = value
    end

    function object.Style:SetFontFamily(value)
        label.Font = Enum.Font[self.FontFamily]
    end

    container.Name = "Container"
    container.Parent = parent
    container.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    container.BorderColor3 = Color3.fromRGB(85, 170, 255)
    container.ClipsDescendants = true
    container.Size = UDim2.new(0, 66, 0, 16)

    label.Name = "Label"
    label.Parent = container
    label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1.000
    label.BorderSizePixel = 0
    label.Position = UDim2.new(0, 16, 0, 0)
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Font = Enum.Font.SourceSans
    label.Text = "true"
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.TextSize = 16.000

    button.Name = "Button"
    button.Parent = container
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundTransparency = 1.000
    button.Size = UDim2.new(1, 0, 1, 0)
    button.Font = Enum.Font.SourceSans
    button.Text = ""
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextSize = 14.000

    fakeBorder.Name = "FakeBorder"
    fakeBorder.Parent = container
    fakeBorder.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
    fakeBorder.BorderSizePixel = 0
    fakeBorder.Size = UDim2.new(1, 0, 1, 0)
    fakeBorder.SizeConstraint = Enum.SizeConstraint.RelativeYY

    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = fakeBorder

    fakeButton.Name = "FakeButton"
    fakeButton.Parent = container
    fakeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    fakeButton.BorderSizePixel = 0
    fakeButton.Position = UDim2.new(0, 1, 0, 1)
    fakeButton.Size = UDim2.new(1, -2, 1, -2)
    fakeButton.SizeConstraint = Enum.SizeConstraint.RelativeYY
    fakeButton.Image = "rbxassetid://103461041"
    fakeButton.ImageColor3 = Color3.fromRGB(85, 170, 255)
    fakeButton.Visible = false

    UICorner_2.CornerRadius = UDim.new(0, 5)
    UICorner_2.Parent = fakeButton

    UICorner_3.CornerRadius = UDim.new(0, 5)
    UICorner_3.Parent = container

    object.Style:Refresh()
    object:Toggle(object.State)

    return object
end

---@param state ?boolean
---@return string
function Class:FormatText(state)
    state = state or self.State

    if self.DisplayState then
        return self.Title .. " " .. (state and "Yes" or "No")
    end

    return self.Title
end

---@param state ?boolean
function Class:Toggle(state)
    state = state or not self.State

    self.State = state

    ---@diagnostic disable-next-line: undefined-field
    self._container.Label.Text = self:FormatText(state) 
    ---@diagnostic disable-next-line: undefined-field
    self._container.FakeButton.Visible = state
end

function Class:Destroy()
    if self.Destroyed then return end
    self._SUPER.Destroy(self)
end

return Class