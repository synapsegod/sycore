local Component = Import(Package.."Interface\\Component.lua") ---@type Component
local Math = Import(Package.."Math.lua") ---@type Math
local Tween = Import(Package.."Tween.lua") ---@type Tween

---@type Event
local Event = Import(Package.."Event.lua")

---@class Progress : Component
local Class = Component:Extend("Progress", {
    OnFinished = Component.NewField(true, true),
    Progress = Component.NewField(false, true),
    Speed = Component.NewField(false, true),
    StartColor = Component.NewField(false, true)
})

Class.OnFinished = nil ---@type Event
Class.Progress = 0 ---@type number
---Bar length grow per second in pixels
Class.Speed = 300 ---@type number
---Bar will gradient from this color to color of its style color depending on self.Progress. By default equals self.Style:GetColor()
Class.StartColor = Color3.fromRGB(32, 32, 32) ---@type Color3

---@param parent RInstance
---@return Progress
function Class:new(parent)
    local object = self._SUPER.new(self, parent) ---@type Progress

    -- Instances:

    local container = Instance.new("Frame")
    local bar = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local label = Instance.new("TextLabel")
    local UICorner_2 = Instance.new("UICorner")

    object.OnFinished = Event.new()

    function object.Style:SetRounding(value)
        local rounding = self:GetRounding()
        UICorner.CornerRadius = rounding
        UICorner_2.CornerRadius = rounding
    end

    function object.Style:SetSize(value)
        local size = self:GetSize()
        label.TextSize = size
        container.Size = UDim2.new(container.Size.X.Scale, container.Size.X.Offset, 0, size)
    end

    function object.Style:SetColor(value)
        bar.BackgroundColor3 = Color3:lerp(self:GetColor(), object.Progress)
    end

    function object.Style:SetFontFamily(value)
        label.Font = Enum.Font[self.FontFamily]
    end

    object.StartColor = object.Style:GetColor()

    --Properties:

    container.Name = "Container"
    container.Parent = parent
    container.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Position = UDim2.new(0, 0, 0, 0)
    container.Size = UDim2.new(0, 200, 0, 16)

    bar.Name = "Bar"
    bar.Parent = container
    bar.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
    bar.BorderSizePixel = 0
    bar.Size = UDim2.new(0, 0, 1, 0)

    UICorner.CornerRadius = UDim.new(0, 0)
    UICorner.Parent = bar

    label.Name = "Label"
    label.Parent = container
    label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1.000
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.Ubuntu
    label.Text = "0%"
    label.TextColor3 = Color3.fromRGB(50, 50, 50)
    label.TextSize = 14
    label.RichText = true

    UICorner_2.CornerRadius = UDim.new(0, 0)
    UICorner_2.Parent = container

    object.Style:Refresh()
    object:Update()

    return object
end

---@param ratio? number
function Class:FormatTooltip(ratio)
    ratio = ratio or self.Progress

    return tostring(Math:Round(ratio * 100)) .. "%"
end

---@param ratio? number
function Class:Update(ratio)
    ratio = ratio or self.Progress

    self.Progress = math.clamp(ratio, 0, 1)

    ---@diagnostic disable-next-line: undefined-field
    self.Container.Label.Text = self:FormatTooltip(self.Progress)

    ---@diagnostic disable-next-line: undefined-field
    local distance = self.Container.AbsoluteSize.X - self.Container.Bar.AbsoluteSize.X 

    Tween:Create(
        self.Container["Bar"], {
            Size = UDim2.new(self.Progress, 0, 1, 0),
            BackgroundColor3 = Color3:lerp(self.Style:GetColor(), self.Progress)
        }, distance / self.Speed, "Linear"
    ):Play()

    if ratio == 1 then
        self.OnFinished:Fire()
    end
end

function Class:Destroy()
    if self.Destroyed then return end

    self._SUPER.Destroy(self)

    self.OnFinished:Destroy()
end

return Class