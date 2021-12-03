---@class Proxy
local Class = {}

---@param proxy? table<string, function>
---@return Proxy
function Class:new(proxy)
    local object = self

    proxy = proxy or {}
    
    if not proxy.__call then
        proxy.__call = function()
			return object
		end
    end

    if not proxy.__index then
        ---@param key string
        ---@return Field
		proxy.__index = function(_, key)
			return object[key]
		end
    end

    if not proxy.__newindex then
        ---@param key string
		---@param value any
		proxy.__newindex = function(_, key, value)
            object[key] = value
		end
    end

    local fake = {_PROXY = true}
    fake.__index = fake

    return setmetatable(fake, proxy)
end

return Class