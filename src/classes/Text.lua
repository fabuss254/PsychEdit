-- LIBS
local UDim2 = require("src/classes/UDim2")
local Color = require("src/classes/Color")
local Frame = require("src/classes/Frame")

-- CLASS
local class = Frame:extend("Text")

function class:new(Font, x, y)
    self.super.new(self, x, y, 0, 0, 0)
    self._type = "TextLabel"
    self.Scale = 1

    self._TEXT = love.graphics.newText(Font, "TextLabel")
    self:SetText("TextLabel")

    return self
end

function class:SetText(newText)
    self._TEXT:set(newText)

    local width, height = self._TEXT:getDimensions()
    self.Size = UDim2(0, width, 0, height)
end

function class:Draw()
    local PosX, PosY, ScaleX, ScaleY = self:GetDrawingCoordinates()

    self.Color:Apply(1-self.Opacity)
    
    love.graphics.translate(PosX, PosY)
    love.graphics.draw(self._TEXT, 0, 0, 0, self.Scale, self.Scale)
    love.graphics.origin()
end

return class