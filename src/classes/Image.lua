-- LIBS
local Vector2 = require("src/classes/Vector2")
local Frame = require("src/classes/Frame")

-- CLASS
local class = Frame:extend("Image")

function class:new(ImagePath, ImageMode)
    self.super.new(self)

    self.Rotation = 0

    self.Texture = love.graphics.newImage(ImagePath or "assets/images/MissingTexture.png")
    self.Texture:setFilter(ImageMode or "nearest")
end

function class:SetImage(Path)
    self.Texture = love.graphics.newImage(Path)
    self.Texture:setFilter("nearest")
end

function class:SetFilter(Filter)
    self.Texture:setFilter(Filter)
end

function class:Draw()
    local PosX, PosY, ScaleX, ScaleY = self:GetDrawingCoordinates()
    local TextureWidth, TextureHeight = self.Texture:getDimensions()

    self.Color:Apply(1-self.Opacity)

    love.graphics.translate(PosX + ScaleX * self.Anchor.X, PosY + ScaleY * self.Anchor.Y)
    love.graphics.rotate(self.Rotation)
    love.graphics.translate(-ScaleX * self.Anchor.X, -ScaleY * self.Anchor.Y)
    love.graphics.draw(self.Texture, 0, 0, 0, ScaleX/TextureWidth, ScaleY/TextureHeight)
    love.graphics.origin()
end

return class