local Object = Import(Package.."OOP\\Object.lua") ---@type Object
local Enumerator = Import(Package.."Enumerator\\Enumerator.lua") ---@type Enumerator

---@class Style : Object
local Class = Object:Extend("Style")
Class.StyleFields = {"Rounding", "Size", "Color", "TextColor", "Position"}

Class.FontFamily = "Ubuntu"

---@class StyleRoundingEnum : Enumerator
---@field ROUNDED integer
---@field BEVELED integer
---@field CORNERED integer
local RoundingEnum = Enumerator:new(
    "ROUNDED", "BEVELED", "CORNERED"
)
---@type table<string, UDim>
RoundingEnum.Roundings = {
    ROUNDED = UDim.new(0, 8),
    BEVELED = UDim.new(0, 5),
    CORNERED = UDim.new(0, 0)
}

---@param value integer | string Can use enum name or value
---@return UDim rounding The rounding associated with the enum key/value
function RoundingEnum:Get(value)
    if type(value) == "number" then
        return self.Roundings[self:NameOf(value)]
    end
    return self.Roundings[value]
end
Class.RoundingEnum = RoundingEnum
Class.Rounding = RoundingEnum:ValueOf("BEVELED")

---@class StyleSizeEnum : Enumerator
---@field SMALL integer
---@field DEFAULT integer
---@field MEDIUM integer
---@field LARGE integer
local SizeEnum = Enumerator:new(
    "SMALL", "DEFAULT", "MEDIUM", "LARGE"
)
---@type table<string, UDim>
SizeEnum.Sizes = {
    SMALL = 12,
    DEFAULT = 16,
    MEDIUM = 20,
    LARGE = 30
}

---@param value integer | string Can use enum name or value
---@return number size The size associated with the enum key/value
function SizeEnum:Get(value)
    if type(value) == "number" then
        return self.Sizes[self:NameOf(value)]
    end
    return self.Sizes[value]
end
Class.SizeEnum = SizeEnum
Class.Size = SizeEnum:ValueOf("DEFAULT")

---@class StyleColorEnum : Enumerator
---@field DEFAULT integer 1
---@field INFO integer 2
---@field SUCCESS integer 3
---@field DANGER integer 4
---@field WARNING integer 5
---@field DARK integer 6
---@field LIGHT integer 7
---@field BLACK integer 8
---@field WHITE integer 9
local ColorEnum = Enumerator:new(
    "DEFAULT", "INFO", "SUCCESS", "DANGER", "WARNING", "DARK", "LIGHT", "BLACK", "WHITE"
)

---@type table<string, Color3>
ColorEnum.Colors = {
    DEFAULT = Color3.fromRGB(85, 85, 255),
    INFO = Color3.fromRGB(85, 170, 255),
    SUCCESS = Color3.fromRGB(0, 170, 127),
    DANGER = Color3.fromRGB(206, 61, 61),
    WARNING = Color3.fromRGB(255, 243, 111),
    DARK = Color3.fromRGB(50, 50, 50),
    LIGHT = Color3.fromRGB(240, 240, 240),
    BLACK = Color3.fromRGB(10, 10, 10),
    WHITE = Color3.fromRGB(250, 250, 250)
}

---@param value integer | string Can use enum name or value
---@return Color3 color The color associated with the enum key/value
function ColorEnum:Get(value)
    if type(value) == "number" then
        return self.Colors[self:NameOf(value)]
    end
    return self.Colors[value]
end
Class.ColorEnum = ColorEnum
Class.Color = ColorEnum.DARK
Class.TextColor = ColorEnum.LIGHT

---@class StylePositionEnum : Enumerator
---@field TOPLEFT integer 1
---@field TOP integer 2
---@field TOPRIGHT integer 3
---@field LEFT integer 4
---@field CENTER integer 5
---@field RIGHT integer 6
---@field BOTTOMLEFT integer 7
---@field BOTTOM integer 8
---@field BOTTOMRIGHT integer 9
local PositionEnum = Enumerator:new(
    "TOPLEFT", "TOP", "TOPRIGHT",
    "LEFT", "CENTER", "RIGHT",
    "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"
)
---@type table<string, UDim2>
PositionEnum.Positions = {
    TOPLEFT = UDim2.new(0, 0, 0, 0), TOP = UDim2.new(0.5, 0, 0, 0), TOPRIGHT = UDim2.new(1, 0, 0, 0),
    LEFT = UDim2.new(0, 0, 0.5, 0), CENTER = UDim2.new(0.5, 0, 0.5, 0), RIGHT= UDim2.new(1, 0, 0.5, 0),
    BOTTOMLEFT = UDim2.new(0, 0, 1, 0), BOTTOM = UDim2.new(0.5, 0, 1, 0), BOTTOMRIGHT = UDim2.new(1, 0, 1, 0)
}
---@param value integer | string Can use enum name or value
---@return UDim2 position The position associated with the enum key/value
function PositionEnum:Get(value)
    if type(value) == "number" then
        return self.Positions[self:NameOf(value)]
    end
    return self.Positions[value]
end
Class.PositionEnum = PositionEnum
Class.Position = PositionEnum:ValueOf("TOPLEFT")

function Class:new()
    local object = Object.new(self) ---@type Style

    ---@param new integer
    object:GetPropertyChangedEvent("Rounding"):Connect(function(_, new)
        object:SetRounding(object.RoundingEnum:Get(new))
    end)

    ---@param new number
    object:GetPropertyChangedEvent("Size"):Connect(function(_, new)
        object:SetSize(object.SizeEnum:Get(new))
    end)

    ---@param new integer
    object:GetPropertyChangedEvent("Color"):Connect(function(_, new)
        object:SetColor(object.ColorEnum:Get(new))
    end)

    ---@param new integer
    object:GetPropertyChangedEvent("TextColor"):Connect(function(_, new)
        object:SetTextColor(object.ColorEnum:Get(new))
    end)

    ---@param new integer
    object:GetPropertyChangedEvent("Position"):Connect(function(_, new)
        object:SetPosition(object.PositionEnum:Get(new))
    end)

    ---@param new string
    object:GetPropertyChangedEvent("FontFamily"):Connect(function(_, new)
        object:SetFontFamily(new)
    end)

    return object
end

function Class:Refresh()
    self:SetRounding(self.RoundingEnum:Get(self.Rounding))
    self:SetSize(self.SizeEnum:Get(self.Size))
    self:SetColor(self.ColorEnum:Get(self.Color))
    self:SetTextColor(self.ColorEnum:Get(self.TextColor))
    self:SetPosition(self.PositionEnum:Get(self.Position))
    self:SetFontFamily(self.FontFamily)
end

---@param style Style
function Class:Apply(style)
    for _, key in pairs (style.StyleFields) do
        self[key] = style[key]
    end
end

---@param value UDim
function Class:SetRounding(value)
    
end

---@param value number
function Class:SetSize(value)
    
end

---@param value Color3
function Class:SetColor(value)
    
end

---@param value Color3
function Class:SetTextColor(value)
    
end

---@param value UDim2
function Class:SetPosition(value)

end

---@param value string
function Class:SetFontFamily(value)
    
end

return Class