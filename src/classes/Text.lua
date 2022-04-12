-- LIBS
local UDim2 = require("src/classes/UDim2")
local Color = require("src/classes/Color")
local Frame = require("src/classes/Frame")
local Fonts = require("src/libs/Fonts")

-- CLASS
local class = Frame:extend("Text")

function class:new(Font, x, y)
    class.super.new(self, x, y, 0, 0, 0)
    self.Scale = 1

    self._TEXT = love.graphics.newText(Font or Fonts.ConsolaSmall, "TextLabel")
    self:SetText("TextLabel")

    return self
end

function class:SetText(newText)
    self._TEXT:set(newText)
    self.Text = newText

    local width, height = self._TEXT:getDimensions()
    self.Size = UDim2(0, width, 0, height)
end

function class:DrawInternal(PosX, PosY, ScaleX, ScaleY)
    self.Color:Apply(1-self.Opacity)

    love.graphics.translate(PosX, PosY)
    love.graphics.draw(self._TEXT, 0, 0, 0, self.Scale, self.Scale)
    love.graphics.origin()
end

function class:__tostring()
    return "TEXT" -- ("Text_%s"):format(self.Name)
end

return class