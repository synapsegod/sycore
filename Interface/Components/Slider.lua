local Object = Import(Package.."Object.lua")
local Event = Import(Package.."Event.lua")
local Tween = Import(Package.."Tween.lua")
local Interface = Import(Package.."Interface\\Interface.lua")
local Threading = Import(Package.."Threading.lua")
local Math = Import(Package.."Math.lua")

local Me = game.Players.LocalPlayer
local Mouse = Me:GetMouse()

local Class = setmetatable({
    Class = "Slider",
    ForegroundColor = Color3.fromRGB(85, 170, 255),
    BackgroundColor = Color3.fromRGB(200, 200, 200),

    _position = UDim2.new(0, 0, 0, 0),
    _current = 1,
    _size = Interface.ContentSize.DEFAULT,
    _style = Interface.Styles.ROUNDED,
    _min = 1,
    _max = 10,
    _length = UDim.new(0, 150),

}, Object)
Class.__index = Class

function Class.new(parent, position, size, style, length, min, max, start)
    Assert(typeof(parent) == "Instance", "Incorrect parent parameter")
    Assert(position == nil or typeof(position) == "UDim2", "Incorrect position parameter")
    Assert(size == nil or type(size) == "number", "Incorrect size parameter")
    Assert(style == nil or type(style) == "number", "Incorrect style parameter")
    Assert(length == nil or typeof(length) == "UDim", "Incorrect length parameter")
    Assert(min == nil or type(min) == "number", "Incorrect min parameter")
    Assert(max == nil or type(max) == "number", "Incorrect max parameter")
    Assert(start == nil or type(start) == "number", "Incorrect start parameter")
    

    local object = setmetatable({
        SelectionChanged = Event.new(),

        _position = position,
        _size = size,
        _min = min,
        _max = max,
        _style = style,
        _length = length,
        _current = start,
        _container = nil, --<Frame> {Button = <TextButton>, Bar = <Frame>}
        _isSelected = false,
    }, Class)

    -- Instances:

    local container = Instance.new("Frame")
    local background = Instance.new("Frame")
    local uiCorner_1 = Instance.new("UICorner")
    local bar = Instance.new("Frame")
    local uiCorner = Instance.new("UICorner")
    local button = Instance.new("TextLabel")
    local uiCorner_2 = Instance.new("UICorner")
    local tooltip = Instance.new("TextLabel")
    local uiCorner_3 = Instance.new("UICorner")

    local realButton = Instance.new("TextButton")

    --Properties:

    container.Name = object.Class
    container.Parent = parent
    container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    container.BackgroundTransparency = 1.000
    container.Position = object._position
    container.Size = UDim2.new(object._length.Scale, object._length.Offset, 0, Interface._contentSizes[object._size])

    background.Name = "Background"
    background.Parent = container
    background.AnchorPoint = Vector2.new(0, 0.5)
    background.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    background.BorderSizePixel = 0
    background.Position = UDim2.new(0, 0, 0.5, 0)
    background.Size = UDim2.new(1, 0, 0.5, 0)

    uiCorner_1.CornerRadius = UDim.new(0, Interface._styleRoundings[object._style])
    uiCorner_1.Name = "UICorner"
    uiCorner_1.Parent = background

    bar.Name = "Bar"
    bar.Parent = container
    bar.AnchorPoint = Vector2.new(0, 0)
    bar.BackgroundColor3 = object.BackgroundColor
    bar.BorderSizePixel = 0
    bar.Position = UDim2.new(0, 0, 0, 0)
    bar.Size = UDim2.new(1, 0, 0.5, 0)

    uiCorner.CornerRadius = UDim.new(0, Interface._styleRoundings[object._style])
    uiCorner.Name = "UICorner"
    uiCorner.Parent = bar

    button.Name = "Button"
    button.Parent = container
    button.AnchorPoint = Vector2.new(0, 0.5)
    button.BackgroundColor3 = object.ForegroundColor
    button.BorderSizePixel = 0
    button.Position = UDim2.new(0, 0, 0.5, 0)
    button.Size = UDim2.new(0, Interface._contentSizes[object._size], 0, Interface._contentSizes[object._size])
    button.Text = ""

    uiCorner_2.CornerRadius = UDim.new(0, Interface._styleRoundings[object._style])
    uiCorner_2.Name = "UICorner"
    uiCorner_2.Parent = button

    tooltip.Name = "Tooltip"
    tooltip.Parent = button
    tooltip.AnchorPoint = Vector2.new(0.5, 0)
    tooltip.BackgroundColor3 = object.ForegroundColor
    tooltip.BorderSizePixel = 0
    tooltip.Position = UDim2.new(0.5, 0, -1, -5)
    tooltip.Size = UDim2.new(2, 0, 1, 0)
    tooltip.Text = ""
    tooltip.Visible = false

    uiCorner_3.CornerRadius = UDim.new(0, Interface._styleRoundings[object._style])
    uiCorner_3.Name = "UICorner"
    uiCorner_3.Parent = tooltip

    realButton.Name = "FakeButton"
    realButton.Parent = container
    realButton.Size = UDim2.new(1, 30, 1, 0)
    realButton.Position = UDim2.new(0, -15, 0, 0)
    realButton.BackgroundTransparency = 1
    realButton.Text = ""

    object._container = container

    realButton.MouseButton1Down:Connect(function(...)
        object:_startDragging(...)
    end)

    realButton.MouseButton1Up:Connect(function(...)
        object:_stopDragging(...)
    end)

    container.AncestryChanged:Connect(function(_, p)
        if p then return end

        object:Destroy()
    end)

    object:SetStyle(object._style)
    object:RefreshColor()
    object:_setTooltip()

    return object
end

function Class:_selectionFromPosition(absoluteX)
    local ratio = ((absoluteX - self._container.AbsolutePosition.X) / self._container.AbsoluteSize.X)
    ---@diagnostic disable-next-line: undefined-field
    local choice = math.clamp(Math:Round(ratio * self._max), self._min, self._max)

    return choice
end

function Class:_startDragging(x, y)
    if self._isSelected then return end
    self._isSelected = true

    self:_toggleTooltip(true)

    local selection = self:_selectionFromPosition(Mouse.X)
    while self._isSelected and not self._destroyed do
        selection = self:_selectionFromPosition(Mouse.X)

        if selection ~= self._current then
            self._current = selection
            self:_setTooltip(self._current)
            self:_clampButton()
            self.SelectionChanged:Fire(selection)
        end

        Threading:Wait()
    end
end

function Class:_stopDragging(x, y)
    if not self._isSelected then return end
    self._isSelected = false
    
    Threading:Wait() --make sure we arent doing anything while the while loop from _startDragging is still going

    self:_toggleTooltip(false)
    self:_clampButton()
end

function Class:_clampButton()
    local ratioX = ((self._current - 1) / self._max)
    local pos = UDim2.new(ratioX, 0, 0.5, 0)
    if self._current > self._min and self._current < self._max then
        pos = pos + UDim2.new(0, self._container.Button.AbsoluteSize.X / 2, 0, 0)
    end
    Tween:Create(
        self._container.Button, {Position = pos}, 0.2, "Linear"
    ):Play()
    
end

function Class:_toggleTooltip(state)
    state = state or not self._container.Button.Tooltip.Visible

    self._container.Button.Tooltip.Visible = state
end

function Class:_setTooltip(value)
    value = value or self._current
    self._container.Button.Tooltip.Text = self:FormatTooltip(value)
end

function Class:FormatTooltip(value)
    value = value or self._current
    return tostring(value) -- tostring(math.floor((value / self._max) * 100)) .."%"
end

function Class:SetStyle(index)
    index = index or self._style
    self._style = index
    
    local rounding = UDim.new(0, Interface._styleRoundings[index])

    self:MassAction(self._container, function(item)
        if item.ClassName == "UICorner" then
            item.CornerRadius = rounding
        end
    end)
end

function Class:RefreshColor()
    self._container.Bar.BackgroundColor3 = self.BackgroundColor
    self._container.Button.BackgroundColor3 = self.ForegroundColor
    self._container.Button.Tooltip.BackgroundColor3 = self.ForegroundColor
end

return Class