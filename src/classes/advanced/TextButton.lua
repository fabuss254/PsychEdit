-- Libs
local Vector2 = require("src/classes/Vector2")
local UDim2 = require("src/classes/UDim2")
local Color = require("src/classes/Color")
local Frame = require("src/classes/Frame")
local Image = require("src/classes/Image")
local Text = require("src/classes/Text")
local Object = require("src/libs/Classic")

local ListLayout = require("src/classes/layout/ListLayout")

local Fonts = require("src/libs/Fonts")
local UI = require("src/libs/UIEngine")

-- Class
local class = Text:extend("TextButton")

function class:new()
    class.super.new(self)

    self.TextOpacity = 0
    self.TextColor = Color.Black

    self.Padding = Vector2(4, 4)

    return self
end

function class:DrawInternal(PosX, PosY, ScaleX, ScaleY)
    love.graphics.translate(PosX, PosY)
    self.Color:Apply(1-self.Opacity)
    love.graphics.rectangle("fill", -self.Padding.X/4, -self.Padding.Y/4, ScaleX + self.Padding.X/2, ScaleY + self.Padding.Y/2)
    self.TextColor:Apply(1-self.TextOpacity)
    love.graphics.draw(self._TEXT, 0, 0, 0, self.Scale, self.Scale)
    love.graphics.origin()
end

return class