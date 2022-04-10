-- LIBS
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Object = require("src/libs/Classic")

-- CLASS
local class = Object:extend("Frame")

function class:new(x, y, w, h, r)
    self.Position = Vector2(x, y)
    self.Size = Vector2(w or 100, h or 100)
    self.Anchor = Vector2(0, 0)
    self.Opacity = 0

    self.Color = Color(1, 1, 1)
    self.Rotation = r or 0
    self.Shader = nil
    self.CornerRadius = 0

    return self
end

function class:GetDrawingCoordinates()
    local PosX = self.Position.X + self.Size.X*self.Anchor.X
    local PosY = self.Position.Y + self.Size.Y*self.Anchor.Y
    local ScaleX = self.Size.X*self.Anchor.X
    local ScaleY = self.Size.Y*self.Anchor.Y

    return PosX, PosY, ScaleX, ScaleY
end

function class:Draw()
    local PosX, PosY, ScaleX, ScaleY = self:GetDrawingCoordinates()

    self.Color:Apply(1-self.Opacity)
    
    love.graphics.translate(PosX - ScaleX, PosY - ScaleY)
    love.graphics.rotate(self.Rotation)
    love.graphics.translate(-ScaleX, -ScaleY)
    love.graphics.rectangle("fill", 0, 0, self.Size.X, self.Size.Y, self.CornerRadius)
    love.graphics.origin()
end

-- META METHODS
function class:__newindex(index, value)
    if not rawget(self, "_initialised") then
        return rawset(self, index, value)
    end
    error(("Attempt to insert new index '%s' in a locked object"):format(index))
end

return class