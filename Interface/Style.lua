local Object = Import(Package.."OOP\\Object.lua") ---@type Object
local Enumerator = Import(Package.."Enumerator\\Enumerator.lua") ---@type Enumerator

---@class Style : Object
local Class = Object:Extend("Style")

Class.FontFamily = "Ubuntu"

Class.RoundingPresets = Enumerator.new({"ROUNDED", "BEVELED", "CORNERED"})
Class._roundingPresets = {8, 5, 0}
Class.RoundingPreset = Class.RoundingPresets:ValueOf("BEVELED")

Class.SizePresets = Enumerator.new({"SMALL", "DEFAULT", "MEDIUM", "LARGE"})
Class._sizePresets = {12, 16, 20, 24}
Class.SizePreset = Class.SizePresets:ValueOf("DEFAULT")

Class.ColorPresets = Enumerator.new({"DEFAULT", "INFO", "SUCCESS", "DANGER", "WARNING", "DARK", "LIGHT", "BLACK", "WHITE"})
Class._colorPresets = {
    Color3.fromRGB(85, 85, 255),
    Color3.fromRGB(85, 170, 255),
    Color3.fromRGB(0, 170, 127),
    Color3.fromRGB(206, 61, 61),
    Color3.fromRGB(255, 243, 111),
    Color3.fromRGB(50, 50, 50),
    Color3.fromRGB(240, 240, 240),
}
Class.ColorPreset = Class.ColorPresets:ValueOf("DEFAULT")
Class.TextColorPreset = Class.ColorPresets:ValueOf("LIGHT")

Class.PositionPresets = Enumerator.new({
    "TOPLEFT", "TOP", "TOPRIGHT",
    "LEFT", "CENTER", "RIGHT",
    "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"
})
Class._positionPresets = {
    UDim2.new(0, 0, 0, 0), UDim2.new(0.5, 0, 0, 0), UDim2.new(1, 0, 0, 0),
    UDim2.new(0, 0, 0.5, 0), UDim2.new(0.5, 0, 0.5, 0), UDim2.new(1, 0, 0.5, 0),
    UDim2.new(0, 0, 1, 0), UDim2.new(0.5, 0, 1, 0), UDim2.new(1, 0, 1, 0)
}
Class.PositionPreset = Class.PositionPresets:ValueOf("TOP")

function Class:new()
    local object = Object.new(self) ---@type Style

    object:GetPropertyChangedEvent("RoundingPreset"):Connect(function(_, new)
        object:SetRounding(new)
    end)

    object:GetPropertyChangedEvent("SizePreset"):Connect(function(_, new)
        object:SetSize(new)
    end)

    object:GetPropertyChangedEvent("ColorPreset"):Connect(function(_, new)
        object:SetColor(new)
    end)

    object:GetPropertyChangedEvent("TextColorPreset"):Connect(function(_, new)
        object:SetTextColor(new)
    end)

    object:GetPropertyChangedEvent("PositionPreset"):Connect(function(_, new)
        object:SetPosition(new)
    end)

    object:GetPropertyChangedEvent("FontFamily"):Connect(function(_, new)
        object:SetFontFamily(new)
    end)

    return object
end

---Creates a blank Style and sets the Presets
function Class:Clone()
    local copy = Class:new()

    copy.RoundingPreset = self.RoundingPreset
    copy.SizePreset = self.SizePreset
    copy.ColorPreset = self.ColorPreset
    copy.TextColorPreset = self.TextColorPreset
    copy.PositionPreset = self.PositionPreset
    copy.FontFamily = self.FontFamily

    return copy
end

function Class:Refresh()
    self:SetRounding()
    self:SetSize()
    self:SetColor()
    self:SetTextColor()
    self:SetPosition()
    self:SetFontFamily()
end

---@param value integer
---@return UDim
function Class:GetRounding(value)
    value = value or self.RoundingPreset

    return UDim.new(0, self._roundingPresets[value])
end

---@param value integer
function Class:SetRounding(value)
    
end

---@param value integer
---@return number
function Class:GetSize(value)
    value = value or self.SizePreset

    return self._sizePresets[value]
end

---@param value integer
function Class:SetSize(value)
    
end

---@param value integer
---@return Color3
function Class:GetColor(value)
    value = value or self.ColorPreset

    return self._colorPresets[value]
end

---@param value integer
function Class:SetColor(value)
    
end

---@param value integer
---@return Color3
function Class:GetTextColor(value)
    value = value or self.TextColorPreset

    return self._colorPresets[value]
end

---@param value integer
function Class:SetTextColor(value)
    
end

---@param value integer
---@return UDim2
function Class:GetPosition(value)
    value = value or self.PositionPreset

    return self._positionPresets[value]
end

---@param value integer
function Class:SetPosition(value)

end

---@param value integer
function Class:SetFontFamily(value)
    
end

return Class