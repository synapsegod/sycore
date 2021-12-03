---@class Math
local Class = {
    _CLASS = "Math",
}

---@return integer
function Class:Round(value)
    return value % 1 >= 0.5 and math.ceil(value) or math.floor(value)
end

return Class