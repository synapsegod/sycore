--This class isnt actually used its just so that the ---@ documentation is proper

table.find = table.find or function() end
table.clear = table.clear or function() end
table.remove = table.remove or function() end
math.clamp = math.clamp or function() end

---@class game
local g = {
    GetService = function() end
}

---@class Enum
local enum = {
    ---@class EasingStyle
    EasingStyle = {
        Linear = 1,
        Quad = 2,
    },

    ---@class EasingDirection
    EasingDirection = {
        In = 1,
        Out = 2,
        InOut = 3
    },

    ---@class SortOrder
    SortOrder = {
        LayoutOrder = 1,
        Name = 2
    }
}

---@class RInstance
local instance = {
    ClassName = nil, ---@type string
    Name = nil, ---@type string
    Parent = nil, ---@type RInstance
    new = function(name) end, ---@type fun(name:string):RInstance
    FindFirstChild = function(name) end, ---@type fun(name:string):RInstance
    FindFirstChildOfClass = function(name) end, ---@type fun(name:string):RInstance
    WaitForChild = function(name) end, ---@type fun(name:string):RInstance

    GetChildren = function() end, ---@type fun():table<integer, RInstance>
    Destroy = function() end,

    AncestryChanged = nil ---@type Event
}

---@class RPlayer : RInstance
local player = {
    ---@return RMouse
    GetMouse = function() end
} 

---@class RMouse : RInstance
local mouse = {
    X = nil, ---@type integer
    Y = nil, ---@type integer
}

---@class RTween : RInstance
local tween = {
    Instance = nil, ---@type RInstance
    TweenInfo = nil, ---@type TweenInfo
    PlaybackState = nil,
    Completed = nil ---@type Event
}
function tween:Cancel() end
function tween:Pause() end
function tween:Play() end



---@class TweenInfo
local tweeninfo = {
    EasingDirection = enum.EasingDirection.Out, ---@type EasingDirection
    Time = 1, ---@type number
    DelayTime = 0, ---@type number
    RepeatCount = 0, ---@type number
    EasingStyle = enum.EasingStyle.Linear, ---@type EasingStyle
    Reverses = false, ---@type boolean,
    ---@type fun(time:number, easingStyle:EasingStyle, easingDirection:EasingDirection, repeatCount:number, reverses:boolean, delayTime:number):TweenInfo
    new = function(time, easingStyle, easingDirection, repeatCount, reverses, delayTime) end
}

---@class Color3
local color3 = {
    new = function(r, g, b) end, ---@type fun(r:number, g:number, b:number):Color3
    fromRGB = function(r, g, b) end, ---@type fun(r:integer, g:integer, b:integer):Color3
}

---@class UDim2
local udim2 = {
    new = function(scaleX, offsetX, scaleY, offsetY) end, ---@type fun(scaleX:number, offsetX:integer, scaleY:number, offsetY:integer):UDim2
}

---@class UDim
local udim = {
    new = function(scale, offset) end, ---@type fun(scale: number, offset: number):UDim
}

