-- LIBS
local UDim2 = require("src/classes/UDim2")
local Color = require("src/classes/Color")
local Frame = require("src/classes/Frame")

local XMLParser = require("src/libs/XML")

-- CLASS
local class = Frame:extend("Text")

function class:new(Path)
    self.XML = XMLParser:ParseXmlText(love.filesystem.read(Path .. ".xml"))
    self.TEXTURE = love.graphics.newImage(Path .. ".png")
    
    self:BuildAnimations()

    self:PlayAnimation(self.DefaultAnimation)
    return self
end

function class:BuildAnimations()
    self.Animations = {}

    for _,v in pairs(self.XML.TextureAtlas:children()) do
        local AnimName = string.sub(v["@name"], 1, #v["@name"]-4)
        local AnimId = tonumber(string.sub(v["@name"], #v["@name"]-3, #v["@name"]))

        if not self.Animations[AnimName] then
            self.Animations[AnimName] = {}
        end

        self.Animations[AnimName][AnimId] = {X = v["@x"], Y = v["@y"], SizeX = v["@width"], SizeY = v["@height"]} --x="488" y="238" width="155" height="158"
        if not self.DefaultAnimation then
            self.DefaultAnimation = AnimName
        end
    end
end

function class:SetDefaultAnimation(Name)
    self.DefaultAnimation = Name
end

function class:PlayAnimation(Name, Loop, Priority)

end

function class:DrawInternal(PosX, PosY, ScaleX, ScaleY)
    self.Color:Apply(1-self.Opacity)

    love.graphics.translate(PosX, PosY)
    love.graphics.draw(self._TEXT, 0, 0, 0, self.Scale, self.Scale)
    love.graphics.origin()
end

return class