local Object = Import(Package.."OOP\\Object.lua") ---@type Object

---@class Exception
---@field Message string
---@field Success boolean
local Class = Object:Extend("Exception")

function Class:Try(func)

    local bool, arg = pcall(function()
        func()
    end)

    local exception = Object.new(self) ---@type Exception

    exception.Success = bool
    exception.Message = arg or "Success"

    return exception
end

function Class:Catch(func)
    if self.Success then return end

    func(self)
end

function Class:Throw()
    if self.Success then return end

    Assert(false, self.Message)
end

return Class