local TweenService = game:GetService("TweenService")

---@class Tween
local Class = {}

---@param instance RInstance
---@param propertyTable table<string, any>
---@param time number
---@param easingStyle string | EasingStyle
---@param easingDirection string | EasingDirection
---@param repeatCount number
---@param reverses boolean
---@param delayTime number
---@return RTween
function Class:Create(instance, propertyTable, time, easingStyle, easingDirection, repeatCount, reverses, delayTime)
    if type(easingStyle) == "string" then easingStyle = Enum.EasingStyle[easingStyle] end
    if type(easingDirection) == "string" then easingDirection = Enum.EasingDirection[easingDirection] end

    ---@type TweenInfo
    local tweenInfo = TweenInfo.new(
        time or 1,
        easingStyle or Enum.EasingStyle.Linear,
        easingDirection or Enum.EasingDirection.Out,
        repeatCount or 0,
        reverses or false,
        delayTime or 0
    )
    ---@type Tween
    local tween = TweenService:Create(
        instance , tweenInfo , propertyTable 
    )

    return tween
end

return Class