local Object = Import(Package.."Object.lua")
local Event = Import(Package.."Event.lua")
local Tween = Import(Package.."Tween.lua")
local Interface = Import(Package.."Interface\\Interface.lua")

local Class = setmetatable({
    Class = "Switch",

    SelectedButtonColor = Color3.fromRGB(250, 250, 250),
    SelectedBarColor = Color3.fromRGB(85, 170, 255),
    DeselectedButtonColor = Color3.fromRGB(250, 250, 250),
    DeselectedBarColor = Color3.fromRGB(200, 200, 200),

    _position = UDim2.new(0.5, 0, 0.5, 0),
    _state = false,
    _style = Interface.Styles.ROUNDED,
    _size = Interface.ContentSize.DEFAULT,
}, Object)
Class.__index = Class

--<Instance> parent, <Vector2>, <boolean> state = false, <Interface.Styles> style = 1
--local toggle = Class.new(Instance.new("Frame", workspace), Vector2.new(1, -200), false, Class.Styles.BEVELED)
function Class.new(parent, position, state, size, style)
    Assert(typeof(parent) == "Instance", "Incorrect parent parameter")
    Assert(position == nil or typeof(position) == "UDim2", "Incorrect position parameter")
    Assert(size == nil or type(size) == "number", "Incorrect size parameter")
    Assert(state == nil or type(state) == "boolean", "Incorrect state parameter")
    Assert(style == nil or type(style) == "number", "Incorrect style parameter")

    local object = setmetatable({
        State = state,
        OnStateChanged = Event.new(),

        _position = position,
        _size = size,
        _state = state,
        _style = style,
        _container = nil, --<Frame> {Button = <TextButton>, Bar = <Frame>}
    }, Class)

    -- Instances:

    local container = Instance.new("Frame")
    local bar = Instance.new("Frame")
    local uiCorner = Instance.new("UICorner")
    local button = Instance.new("TextButton")
    local uiCorner_2 = Instance.new("UICorner")

    --Properties:

    container.Name = object.Class
    container.Parent = parent
    container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    container.BackgroundTransparency = 1.000
    container.Position = object._position
    container.Size = UDim2.new(0, Interface._contentSizes[object._size] * 2, 0, Interface._contentSizes[object._size])

    bar.Name = "Bar"
    bar.Parent = container
    bar.AnchorPoint = Vector2.new(0, 0)
    bar.BackgroundColor3 = object.DeselectedBarColor
    bar.BorderSizePixel = 0
    bar.Position = UDim2.new(0, 0, 0, 0)
    bar.Size = UDim2.new(1, 0, 1, 0)

    uiCorner.CornerRadius = UDim.new(0, Interface._styleRoundings[object._style])
    uiCorner.Name = "UICorner"
    uiCorner.Parent = bar

    button.Name = "Button"
    button.Parent = container
    button.AnchorPoint = Vector2.new(0, 0.5)
    button.BackgroundColor3 = object.DeselectedButtonColor
    button.BorderSizePixel = 0
    button.Position = UDim2.new(0, 0, 0.5, 0)
    button.Size = UDim2.new(0, Interface._contentSizes[object._size], 0, Interface._contentSizes[object._size])
    button.Text = ""

    uiCorner_2.CornerRadius = UDim.new(0, Interface._styleRoundings[object._style])
    uiCorner_2.Name = "UICorner"
    uiCorner_2.Parent = button

    object._container = container

    button.Activated:Connect(function()
        object:Toggle()
    end)

    container.AncestryChanged:Connect(function(_, p)
        if p then return end

        object:Destroy()
    end)

    object:Toggle(object._state)
    object:SetStyle(object._style)
    object:RefreshColor()
    
    return object
end

function Class:GetState()
    return self._state
end

function Class:Toggle(state)
    state = state or not self._state
    Assert(type(state) == "boolean", "Incorrect state parameter")

    self._state = state

    self.OnStateChanged:Fire(state)

    self:_slide()

    return state
end

function Class:SetStyle(index)
    index = index or self._style
    self._style = index
    
    local rounding = UDim.new(0, Interface._styleRoundings[index])
    
    self._container.Button.UICorner.CornerRadius = rounding
    self._container.Bar.UICorner.CornerRadius = rounding
end

function Class:RefreshColor()
    self._container.Button.BackgroundColor3 = (self._state and self.SelectedButtonColor) or self.DeselectedButtonColor
    self._container.Bar.BackgroundColor3 = (self._state and self.SelectedBarColor) or self.DeselectedBarColor
end

function Class:_slide()
    local dir = (self._state and 1) or 0
    local buttonPos = UDim2.new(dir, -(self._container.Button.AbsoluteSize.X * dir), 0.5, 0)
    local barColor = (dir == 1 and self.SelectedBarColor) or self.DeselectedBarColor
    local buttonColor = (dir == 1 and self.SelectedButtonColor) or self.DeselectedButtonColor

    local buttonTween = Tween:Create(
        self._container.Button, {Position = buttonPos, BackgroundColor3 = buttonColor}, 0.3, "Linear", "Out"
    )

    local barTween = Tween:Create(
        self._container.Bar, {BackgroundColor3 = barColor}, 0.3, "Linear", "Out"
    )

    buttonTween:Play()
    barTween:Play()
end

function Class:Destroy()
    if self._destroyed then return end
    if self._container.Parent then self._container:Destroy() return end

    Object.Destroy(self)
end

return Class