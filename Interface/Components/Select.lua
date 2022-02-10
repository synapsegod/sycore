local Searchbar = Import(Package.."Interface\\Components\\Searchbar.lua") ---@type Searchbar
local Event = Import(Package.."Event.lua") ---@type Event
local Button = Import(Package.."Interface\\Input\\Button.lua") ---@type Button
local ButtonSelection = Import(Package.."Interface\\ComponentUtil\\ButtonSelection.lua") ---@type ButtonSelection

---@class Select : Searchbar
---@field Multiple boolean
---@field OnDeselected Event
---@field Buttons ButtonSelection
local Class = Searchbar:Extend("Select")

---@param parent RInstance
function Class:new(parent)
    local object = self._SUPER.new(self) ---@type Select
    object.OnDeselected = Event:new()
    object.Buttons = ButtonSelection:new()

    local input = object.Container:WaitForChild("Input")
    input:Destroy()

    input = Instance.new("TextButton")
    input.Name = "Input"
    input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    input.BackgroundTransparency = 1.000
    input.Position = UDim2.new(0, 5, 0, 0)
    input.Size = UDim2.new(1, -10, 0, 20)
    input.Font = Enum.Font.SourceSans
    input.Text = "Select"
    input.TextColor3 = Color3.fromRGB(0, 0, 0)
    input.TextSize = 14.000
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.Parent = object.Container

    ---@param value number
    function object.Style:SetSize(value)
        input.TextSize = value
        input.Size = UDim2.new(1, -10, 0, value)

        for _, result in pairs (object.Results) do
            result.Component.Style:SetSize(value)
        end

        object:AdjustSize()
    end

    ---@param value string
    function object.Style:SetFontFamily(value)
        input.Font = Enum.Font[value]

        for _, result in pairs (object.Results) do
            result.Component.Style:SetFontFamily(value)
        end
    end

    input.Activated:Connect(function()
        local data = object.Container:WaitForChild("Data")
        if data.Visible then
            object:Clear()
        else
            object:Search()
        end
    end)

    return object
end

---@Override
---@param key integer
---@param value any
---@return Button button
function Class:AddResult(key, value)
    local parent = self.Container:WaitForChild("Data")
    local button = Button:new(parent, "Text", self.Buttons) ---@type Button
    button.Selectable = self.Multiple
    button.Style:Apply(self.Style)
    button.Style.Color = button.Style.ColorEnum.DARK

    button.Container.Size = UDim2.new(1, 0, 0, button.Style.SizeEnum:Get(button.Style.Size))
    button.Container.Text = tostring(key) .. ": " .. tostring(value)

    local obj = self
    function button:Activated()
        if not obj.Multiple then
            obj:Clear()
        end
    end

    self.Buttons:Add(button)

    return button
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

function Class:Destroy()
    if self.Destroyed then return end

    self._SUPER.Destroy(self)
end

return Class