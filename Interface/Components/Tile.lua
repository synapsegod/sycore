local Component = Import(Package.."Interface\\Components\\Button.lua") ---@type Component
local Button = Import(Package.."Interface\\Component.lua") ---@type Button

---@class Tile : Button
local Tile = Component:Extend("Tile")

function Tile:new(parent, title, icon)
    local tile = Instance.new("Frame")
    tile.BorderSizePixel = 2
    tile.BorderColor3 = Color3.fromRGB(250, 250, 250)
    tile.Parent = parent

    local object = Component.new(self, tile) ---@type Tile
    


    return object
end