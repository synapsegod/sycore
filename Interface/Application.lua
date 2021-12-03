---@type Object
local Object = Import(Package.."Object.lua")
---@type Instances
local Instances = Import(Package.."Instances.lua")
---@type Window
local Window = Import(Package.."Interface\\Window.lua")

local Applications = Instances.new()

---@class Application : Object
local Class = setmetatable({}, Object)
Class.Class = "Application"
Class.Name = "ApplicationName"
Class.AllowMultiple = false
Class.__index = Class

function Class:IsRunning(name)
    return not Applications:Get(name) == nil
end

function Class:Open()
    local name = self.Name

    if self.AllowMultiple then
        local newName = name..syn.crypt.random(5)

        while Applications:Get(newName) do
            newName = name..syn.crypt.random(5)
        end

        name = newName
    else
        Assert(Applications:Get(name), "Application" ..name.. " is already running")
    end

    Applications:Add(name, self)

    return self
end

function Class:GetRunningApplications(scope) --name of app incase app.AllowMultiple
    if scope then Assert(type(scope) == "string", "Incorrect parameter type") end

    local apps = {}

    for key, app in pairs (Applications) do
        if scope then
            if string.find(app.Name, scope) then
                table.insert(apps, app)
            end
        else
            table.insert(apps, app)
        end
    end

    return apps
end

function Class:Destroy()
    if self._destroyed then return end

    if self.Window and self.Window.Window.Parent then self.Window:Destroy() return end

    Object.Destroy(self)
    Applications:Remove(self.Name)
end

--Bind the application to a window for interface applications
function Class:AttachWindow()
    Assert(self.Window, "Application already has a window")

    self.Window = Window.new("Main")
    self.Window:SetTitle(self.Name)

    local app = self
    self.Window.OnClosed:Connect(function()
        app:Destroy()
    end)

    return self.Window
end

return Class