Assert(pcall(function()
    loadfile("sycore\\Core.lua")
end))

local Instances = Import(Package.."Instances.lua")
local Application = Import(Package.."Interface\\Application.lua")

local Commands = Instances.new({
    Print = {
        Params = {},
        Method = function(...)
            print(...)
        end
    }
})

local Class = setmetatable({
    Class = "CommandApplication",
    
    Name = "Command",
    AllowMultiple = false
}, Application)
Class.__index = Class

function Class.new()
    local app = setmetatable({
        
    }, Class)

    app:Open()

    local window = app:AttachWindow()
    --TODO LAYOUT OF APP

    return app
end

function Class:Close()
    if self._closed then return end

    Application.Close(self)
end

function Class:AddCommand(name, params, method)
    Assert(type(name) == "string", "Incorrect parameter type")
    Assert(Commands:Get(name) == nil, "Command ".. name .. " already exists")

    Commands:Add(name, {Params = params, Method = method})
end

function Class:Run(name, params)
    Assert(pcall(function() Commands:Get(name).Method(params) end))
end

return Class