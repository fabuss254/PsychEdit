--[[
    Title: PsychEngine Modchart Editor
    Author: Fabuss254
    Repo: https://github.com/fabuss254/PsychEngine-Modchart-Editor
    Description: A easy to use modchart editor for psych engine.
--]]

-- Basic classes import
local Vector2 = require("src/classes/Vector2")
local Frame = require("src/classes/Frame")

-- Basic lib import
local UIEngine = require("src/libs/UIEngine")

-- Global overwrites
love.graphics.setDefaultFilter('nearest', 'nearest')
tick = love.timer.getTime
math.clamp = function(value, min, max) return math.min(math.max(value, min), max) end
ScreenSize = Vector2(love.graphics.getDimensions())

function typeof(obj)
    return type(obj) == "table" and obj._type or type(obj)
end

-- Global functions
local n = Frame()
n.Anchor = Vector2(.5, .5)

function love.load()
    
end

function love.update(dt)
    n.Position = ScreenSize/2
    n.Rotation = math.sin(tick()*2)*math.pi
end

function love.draw()
    n:Draw()
end

function love.resize(w, h)
    ScreenSize = Vector2(w, h)
end

