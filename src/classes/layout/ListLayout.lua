-- LIBS
local Vector2 = require("src/classes/Vector2")
local UDim2 = require("src/classes/UDim2")
local Object = require("src/libs/Classic")

local ErrorMessage = require("src/libs/ErrorMessage")

-- CLASS
local class = Object:extend("ListLayout")

function class:new(Direction, Offset)
    self.Direction = Direction or 1 -- 1: Horizontal, 2: Vertical
    self.Offset = Offset or 0

    return self
end

function class:Execute(Frame)
    local Parent = Frame.Parent
    local DirectionAxis = self.Direction == 1 and "X" or "Y"

    OffsetX, OffsetY, SizeOffsetX, SizeOffsetY = Parent:GetDrawingCoordinates()
    local ParentPos = Vector2(OffsetX, OffsetY)
    local ParentSize = Vector2(SizeOffsetX, SizeOffsetY)

    local ListOffset = 0
    for _,v in pairs(Parent:GetChildren()) do
        if v:IsVisible() then
            if v == Frame then
                break
            else
                ListOffset = ListOffset + v.Size:ToVector2(ParentSize) + self.Offset
            end
        end
    end

    local Size = Frame.Size:ToVector2(ParentSize)
    local Pos = Vector2[DirectionAxis] * ListOffset + ParentPos

    local PosX = Pos.X -- - Size.X*Frame.Anchor.X
    local PosY = Pos.Y --- Size.Y*Frame.Anchor.Y
    local ScaleX = Size.X
    local ScaleY = Size.Y

    return math.floor(PosX), math.floor(PosY), math.floor(ScaleX), math.floor(ScaleY)
end

return class