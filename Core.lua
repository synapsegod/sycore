if shared._core then
    --load globals into the stack

    Core = shared._core
    Package = "sycore\\"
    Assert = shared._core.Assert
    Print = shared._core.Print
    Import = shared._core.Import
    TypeOf = shared._core.TypeOf
    
    return shared._core
end

TweenService = game:GetService("TweenService")
RunService = game:GetService("RunService")
HttpService = game:GetService("HttpService")

Package = "sycore\\"
Me = game.Players.LocalPlayer

local Mods = {} ---@type table<string, any>

---@class Core
Core = {
    _CLASS = "Core",
    Debug = true,
    Package = Package,
}
shared._core = Core

---@param condition boolean
---@param ... any
function Assert(condition, ...)
    if not condition then warn(...) error("") end
end
Core.Assert = Assert

function Print(...)
    if Core.Debug then
        local params = {...}
        if #params == 0 then print(nil) return end

        for _, param in pairs (params) do
            if type(param) == "table" then
                print(param, ":")
                if #param == 0 then
                    print("    empty")
                else
                    for i, v in pairs (param) do
                        print("    ", i, v)
                    end
                end
            else
                print(param)
            end
        end
    end
end
Core.Print = Print

---Combines (typeof | type) with custom classes if they are a table
---@return string
function TypeOf(value)
    if type(value) == "table" and value["_CLASS"] then return value._CLASS end
    return (typeof or type)(value)
end
Core.TypeOf = TypeOf

---Used to import modules from workspace, global Package variable points to sycore (this project)
---@param path string
---@return any
function Import(path)
    Assert(type(path) == "string", "Path is not a string")

    if Mods[path] == true then
        warn(path, "is still loading")
        while Mods[path] == true do
            RunService.Stepped:Wait()
        end

        if Mods[path] == nil then
            warn("A previous Import of", path, "failed")
        end

        return Mods[path]
    end

    if Mods[path] then return Mods[path] end

    Mods[path] = true

    warn("Installing", path)

    local loaded = nil
    local bool, arg = pcall(function()
        loaded = loadfile(path)()
    end)

    if not bool then
        Mods[path] = nil
        Assert(bool, arg)
    end

    if not type(loaded) == "table" then
        Mods[path] = nil
        return
    end

    Mods[path] = loaded

    warn("Installed", path)
    return loaded
end
Core.Import = Import

function Core:Destroy()
    pcall(function()
        --local applications = Import(Package.."Interface\\Application.lua"):GetRunningApplications()
        --for _, app in pairs (applications) do
        --    app:Destroy()
        --end

        --Import(Package.."Interface\\Interface.lua"):Destroy()
    end)

    shared._core = nil

    warn("Destroyed sycore")
end

local Threading = Import(Package.."Threading.lua")
Threading:Spawn(function()
    Import(Package.."OOP\\Object.lua")
    --Import(Package.."Event.lua")
    --Import(Package.."Interface\\Interface.lua")
end)

warn("Installed", Core._CLASS)

return Core