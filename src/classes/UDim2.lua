-- LIBS
local Object = require("src/libs/Classic") 
local Vector2 = require("src/classes/Vector2")

-- CLASS
local class = Object:extend("UDim2")

function class:new(ScaleX, OffsetX, ScaleY, OffsetY)
    self.X = {Scale = ScaleX or 0, Offset = OffsetX or 100}
    self.Y = {Scale = ScaleY or 0, Offset = OffsetY or 100}

    return self
end

-- METHODS
--[[
function class:ToVector2(obj)
    local ParentSize = obj.Parent and obj.Parent.Size:ToVector2(obj.Parent) or ScreenSize
    local ParentPosition = obj.Parent and obj.Parent.Position:ToVector2(obj.Parent) or Vector2(0, 0)

    --if rawget(obj, "AspectRatio") then
    --    local Min = math.min(ParentSize.X, ParentSize.Y) / obj.AspectRatio
    --    ParentSize = Vector2(Min, Min)
    --end

    --print(obj, obj.Parent, ParentSize)
    local Result = Vector2(self.X.Scale * ParentSize.X + self.X.Offset + ParentPosition.X, self.Y.Scale * ParentSize.Y + self.Y.Offset + ParentPosition.Y)
    return Result
end
]]

function class:ToVector2(Scale)
    return Vector2(self.X.Scale * Scale.X + self.X.Offset, self.Y.Scale * Scale.Y + self.Y.Offset)
end

-- METATABLES
function class:__tostring()
    return string.format("Vector2(%i, %i)", self.X, self.Y)
end

function class.__eq(a, b)
    assert(typeof(b) == "UDim2", "Attempt to compare " .. typeof(a) .. " and " .. typeof(b))
    return a.X == b.X and a.Y == b.Y
end

return class