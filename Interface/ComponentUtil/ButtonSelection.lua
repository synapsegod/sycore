local Object = Import(Package.."OOP\\Object.lua") ---@type Object
local Event = Import(Package.."Event.lua") ---@type Event

---@class ButtonSelection : Object
---@field Multiple boolean
---@field Group Button[]
---@field SelectionAdded Event
---@field SelectonRemoved Event
local Class = Object:Extend("ButtonSelection")

function Class:new()
    local object = self._SUPER.new(self) ---@type ButtonSelection

    object.Group = {}
    object.SelectionAdded = Event:new()
    object.SelectonRemoved = Event:new()

    return object
end

---@param button Button
function Class:Add(button)
    Assert(self.Destroyed == false, "Object has been destroyed")

    local object = self

    function button:Select()
        if self.Selected then return end
        self._SUPER.Select(button)

        object.SelectionAdded:Fire(self)

        if not object.Multiple then
            for _, other in pairs (object.Group) do
                if other ~= self then
                    other:Deselect()
                end
            end
        end
    end

    function button:Deselect()
        if not self.Selected then return end
        self._SUPER.Select(button)

        object.SelectonRemoved:Fire(self)
    end

    button:GetPropertyChangedEvent("Destroyed"):Connect(function()
        object:Remove(button)
    end)
end

---@param button Button
function Class:Remove(button)
    table.remove(self.Group, table.find(self.Group, button))
end

---@return table<integer, Button>
function Class:GetSelectedButtons()
    local selected = {}

    for _, button in pairs (self.Group) do
        if button.Selected then
            table.insert(selected, button)
        end
    end

    return selected
end

function Class:Destroy()
    if self.Destroyed then return end
    self._SUPER.Destroy(self)

    for _, button in pairs (self.Group) do
        button:Destroy()
    end

    table.clear(self.Group)
end