-- LIBS
local Object = require("src/libs/Classic") 
local Vector2 = require("src/classes/Vector2")

-- CLASS
local class = Object:extend("UDim2")

function class:new(ScaleX, OffsetX, ScaleY, OffsetY)
    self.X = {Scale = ScaleX or 0, Offset = OffsetX or 0}
    self.Y = {Scale = ScaleY or 0, Offset = OffsetY or 0}

    return self
end

-- METHODS
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