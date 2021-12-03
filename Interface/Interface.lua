local Object = Import(Package.."OOP\\Object.lua") ---@type Object

---@class Interface : Object
local Class = Object:Extend("Interface", {
    Windows = Object.NewField(true, true),
    Gui = Object.NewField(true, true)
}, true, false)
Class.Windows = {} ---@type table<integer, Window>
Class.Gui = Instance.new("ScreenGui") ---@type RInstance
Class.Gui.Name = "sycore"
Class.Gui.ResetOnSpawn = false
syn.protect_gui(Class.Gui)
Class.Gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

Class.Gui.AncestryChanged:Connect(function(_, parent)
    if not parent then return end

    Class:Destroy()
end)

---@param window Window
function Class:AddWindow(window)
    Assert(TypeOf(window) == "Window", "Incorrect parameter type")
    Assert(table.find(self.Windows, window) == nil, "Window already exists in Interface")

    table.insert(self.Windows, window)

    local interface = self
    window.OnClosed:Connect(function()
        table.remove(interface.Windows, table.find(interface.Windows, window.Window))
    end)
end

function Class:Destroy()
    if self.Destroyed then return end
    if self.Gui.Parent then self.Gui:Destroy() return end

    Object.Destroy(self)
end

return Class