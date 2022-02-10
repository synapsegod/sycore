local Object = Import(Package.."OOP\\Object.lua") ---@type Object
local Window = Import(Package.."Interface\\Window.lua") ---@type Window
local Table = Import(Package.."Table.lua") ---@type Table

local Applications = Table:new()

---@class Application : Object
---@field Name string Name of the application
---@field IsRunning boolean Application state
local Class = Object:Extend("Application")
Class.AllowMultiple = false

---@param name string Name of the application
---@return Application
function Class:new(name)
    Assert(Applications[name] == nil, "Application", name, "is already running")

    local object = Object.new(self) ---@type Application
    object.Name = name
    object.IsRunning = false

    Applications[name] = object

    return object
end

function Class:Run()
    if self.IsRunning then return end

    self.IsRunning = true
end

function Class:Close()
    if self.IsRunning == false then return end

    self.IsRunning = false
end

---Bind the application to a window for interface applications
function Class:AttachWindow()
    Assert(self.Window, "Application already has a window")

    self.Window = Window:new()
    self.Window:SetTitle(self.Name)

    local app = self
    self.Window:GetPropertyChangedEvent("Destroyed"):Connect(function()
        app:Destroy()
    end)

    return self.Window
end

function Class:Destroy()
    if self.Destroyed then return end
    if self.Window and not self.Window.Destroyed then self.Window:Destroy() end

    Object.Destroy(self)
    Applications:Remove(self.Name)
end

return Class