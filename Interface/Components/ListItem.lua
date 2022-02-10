local Component = Import(Package.."Interface\\Component.lua") ---@type Component
local Button = Import(Package.."Interface\\Components\\Button.lua") ---@type Button

---@class ListItem : Component
local Class = Component:Extend("ListItem")
Class.Button = nil ---@type Button

---@param parent RInstance
---@param text? string
---@return ListItem
function Class:new(parent, text)
    local container = Instance.new("Frame")
    local label = Instance.new("TextButton")
    local corner = Instance.new("UICorner")
    
    local object = Component.new(self, container) ---@type ListItem

    container.Name = object.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 20)
    container.Parent = parent

    label.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    label.BorderSizePixel = 0
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.Ubuntu
    label.TextColor3 = Color3.fromRGB(50, 50, 50)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.Parent = container

    corner.Name = "UICorner"
    corner.CornerRadius = UDim.new(0, 0)
    corner.Parent = label

    local button = Button:new(label)
    object.Button = button

    ---@param value Color3
    function object.Style:SetColor(value)
        button.Style.Color = self.Color
    end

    ---@param value number
    function object.Style:SetSize(value)
        button.Style.Size = self.Size
    end

    object.Style:Refresh()

    return object
end