---@type Object
local Object = Import(Package.."Object.lua")
---@type Event
local Event = Import(Package.."Event.lua")
---@type Interface
local Interface = Import(Package.."Interface\\Interface.lua")
---@type Explorer
local Explorer = Import(Package.."DefaultApps\\Explorer\\App.lua")
---@type Parameter
local Parameter = Import(Package.."Parameter.lua")
---@type Style
local Style = Import(Package.."Interface\\Style.lua")

local Parameters = {
    Parent = Parameter.new("Parent", "Instance", true)
    --TODO params
}

---@class Upload : Object
local Class = setmetatable({}, Object)
Class.Class = "Upload"
Class.OnSelected = nil
Class.Parent = nil
Class.Style = nil
Class.Path = Package
Class.Position = UDim2.new(0, 0, 0, 0)
Class._current = nil
Class._container = nil
Class._filePicker = nil
Class.__index = Class

---@return Upload
function Class.new(object)
    object = setmetatable(object or {}, Class)
    for name, parameter in pairs (Parameters) do parameter:Check(rawget(object, name)) end

    -- Instances:

    local button = Instance.new("TextButton")
    local uiCorner = Instance.new("UICorner")

    if not object.OnSelected then object.OnSelected = Event.new() end
    if not object.Style then object.Style = Style.new() end

    if not rawget(object.Style, "SetRounding") then
        function object.Style:SetRounding(value)
            Style.SetRounding(self, value)
            uiCorner.CornerRadius = self:GetRounding()
        end
    end

    if not rawget(object.Style, "SetSize") then
        function object.Style:SetSize(value)
            Style.SetSize(self, value)

            local size = self:GetSize()
            button.TextSize = size
            button.Size = UDim2.new(0, 100 + size, 0, size)
        end
    end

    if not rawget(object.Style, "SetColor") then
        function object.Style:SetColor(value)
            Style.SetColor(self, value)
            button.BackgroundColor3 = self:GetColor()
        end
    end

    if not rawget(object.Style, "SetFontFamily") then
        function object.Style:SetFontFamily(value)
            Style.SetFontFamily(self, value)
            
            button.Font = Enum.Font[self.FontFamily]
        end
    end

    --Properties:

    button.Name = object.Class
    button.Parent = object.Parent
    button.AnchorPoint = Vector2.new(0, 0)
    button.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
    button.BorderSizePixel = 0
    button.Position = object.Position
    button.Size = UDim2.new(0, 100, 0, 30)
    button.Text = "Click to upload"

    uiCorner.CornerRadius = UDim.new(0, 0)
    uiCorner.Name = "UICorner"
    uiCorner.Parent = button

    object._container = button

    button.Activated:Connect(function()
        object:_askUpload()
    end)

    button.AncestryChanged:Connect(function(_, p)
        if p then return end

        object:Destroy()
    end)

    object.Style:SetRounding()
    object.Style:SetSize()
    object.Style:SetColor()
    object.Style:SetFontFamily()

    return object
end

function Class:_askUpload()
    if self._filePicker then return end

    local picker = Explorer.new(self.Path)
    self._filePicker = picker

    local obj = self
    picker.ItemSelected:Connect(function(directoryObj)
        if directoryObj:IsFile() then
            picker:Destroy()
            obj._filePicker = nil
            if not obj._current then obj._current = directoryObj end

            if not obj._current.Path == directoryObj.Path then
                obj.OnSelected:Fire(directoryObj)
            end
        end
    end)
end

function Class:GetSelection()
    return self._current
end

return Class