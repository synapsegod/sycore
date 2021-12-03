---@type Object
local Object = Import(Package.."Object.lua")
---@type Threading
local Threading = Import(Package.."Threading.lua")
---@type Interface
local Interface = Import(Package.."Interface\\Interface.lua")
---@type Style
local Style = Import(Package.."Interface\\Style.lua")
---@type Parameter
local Parameter = Import(Package.."Parameter.lua")
---@type Tweening
local Tween = Import(Package.."Tween.lua")
---@type Button
local Button = Import(Package.."Interface\\Input\\Button.lua")

local Parameters = {
    Parent = Parameter.new("Parent", "Instance"),
    Style = Parameter.new("Style", "Style"),
    Message = Parameter.new("Message", "string"),
    Duration = Parameter.new("Duration", "number"),
    PauseOnHover = Parameter.new("PauseOnHover", "boolean"),
}

local Toasts = {}

---@class Toast : Object
local Class = setmetatable({
    Class = "Toast",

    Style = Style,
    Parent = Interface.Gui,
    Message = "Hello world",
    Duration = 2,
    PauseOnHover = true,

    _queue = 1,
    _isOpen = false,
    _container = nil,
    _lifetime = 2,
}, Object)
Class.__index = Class

---@return Toast
function Class.new(object)
    object = object or {}
    for name, parameter in pairs (Parameters) do parameter:Check(rawget(object, name)) end

    object = setmetatable(object, Class)
    if not rawget(object, "Style") then object.Style = Style.new() end

    local container = Instance.new("TextButton")
    container.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    container.BorderSizePixel = 0
    container.RichText = true
    container.TextWrapped = true
    container.Size = UDim2.new(0, 100, 0, 30)
    container.Position = object.Style:GetPosition() - UDim2.new(0, 0, 0, container.Size.Y.Offset)
    container.Font = Enum.Font[object.Style["FontFamily"]]
    container.TextSize = 14
    container.TextColor3 = Color3.fromRGB(240, 240, 240)
    container.Parent = object["Parent"]

    local corner = Instance.new("UICorner")
    corner.CornerRadius = object.Style:GetRounding()
    corner.Parent = container

    local button = Button.new({Button = container})
    object._container = button

    if not rawget(object.Style, "SetRounding") then
        function object.Style:SetRounding(value)
            Style.SetRounding(self, value)
            corner.CornerRadius = self:GetRounding()
        end
    end

    if not rawget(object.Style, "SetSize") then
        function object.Style:SetSize(value)
            Style.SetSize(self, value)

            local size = self:GetSize()
            container.TextSize = size
            container.Size = UDim2.new(0, 100 + size, 0, size)
        end
    end

    if not rawget(object.Style, "SetColor") then
        function object.Style:SetColor(value)
            Style.SetColor(self, value)
            container.BackgroundColor3 = self:GetColor()
        end
    end

    if not rawget(object.Style, "SetFontFamily") then
        function object.Style:SetFontFamily(value)
            Style.SetFontFamily(self, value)
            
            container.Font = Enum.Font[self.FontFamily]
        end
    end

    container.AncestryChanged:Connect(function(_, parent)
        if not parent then object:Destroy() end
    end)

    container.Activated:Connect(function()
        container:Destroy()
    end)

    object.Style:SetColor()
    object.Style:SetRounding()
    object.Style:SetSize()
    object.Style:SetFontFamily()

    return object
end

function Class:Open()
    if self._isOpen or self._destroyed then return end
    self._isOpen = true

    table.insert(Toasts, self)
    self._queue = #Toasts

    --wait for my turn

    while self._destroyed ~= true and self._queue > 1 do
        Threading:Wait(0.3)
    end

    self._lifetime = self["Duration"]
    self["_container"].Button.Visible = true
    Tween:Create(self["_container"].Button, {Position = self["Style"]:GetPosition()}, 0.3, "Quad", "In"):Play()

    --drain lifetime with transparency fade
    local step = nil
    while not self._destroyed and self._lifetime > 0 do
        step = RunService.Stepped:Wait()

        --refill lifetime if mouse on it
        if self["PauseOnHover"] and self["_container"]._mouseOn then
            self._lifetime = self["Duration"]
        else
            self._lifetime = self._lifetime - step
        end

        local ratio = self._lifetime / self["Duration"]
        self["_container"].Button.BackgroundTransparency = 1 - ratio
        self["_container"].Button.TextTransparency = 1 - ratio
    end

    self:Destroy()
end

function Class:Destroy()
    if self._destroyed then return end
    if self["_container"].Parent then self["_container"]:Destroy() return end

    Object.Destroy(self)

    self._isOpen = false
    table.remove(Toasts, self._queue)
    for _, toast in pairs (Toasts) do
        toast._queue = toast._queue - 1
    end
end

return Class