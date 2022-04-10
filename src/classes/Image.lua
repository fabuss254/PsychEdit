-- LIBS
local Vector2 = require("src/classes/Vector2")
local Frame = require("src/classes/Frame")

-- CLASS
local class = Frame:extend()

function class:new(ImagePath, ImageMode)
    self.super.new(self)

    self.Texture = love.graphics.newImage(ImagePath)
    self.Texture:setFilter(ImageMode or "nearest")
end

function class:Draw()
    local PosX, PosY, ScaleX, ScaleY = self:GetDrawingCoordinates()
    local TextureWidth, TextureHeight = self.Texture:getDimensions()

    self.Color:Apply(1-self.Opacity)

    love.graphics.translate(PosX, PosY)
    love.graphics.draw(self.Texture, 0, 0, 0, ScaleX/TextureWidth, ScaleY/TextureHeight)
    love.graphics.origin()
end

return class