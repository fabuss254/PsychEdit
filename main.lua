--[[
    Title: PsychEngine Modchart Editor
    Author: Fabuss254
    Repo: https://github.com/fabuss254/PsychEngine-Modchart-Editor
    Description: A easy to use modchart editor for psych engine.
--]]

-- Basic classes import
local Vector2 = require("src/classes/Vector2")
local Signal = require("src/classes/Signal")

-- Basic lib import
local UI = require("src/libs/UIEngine")

-- Global overwrites
love.graphics.setDefaultFilter('nearest', 'nearest')
tick = love.timer.getTime
math.clamp = function(value, min, max) return math.min(math.max(value, min), max) end
table.find = function(tbl, obj)
    for _,v in pairs(tbl) do
        if v == obj then
            return v
        end
    end
end
ScreenSize = Vector2(love.graphics.getDimensions())
MouseClicked = Signal.new()

function typeof(obj)
    return type(obj) == "table" and obj._type or type(obj)
end

-- Global functions
function love.load()
    require("src/scripts/Topbar")
end

function love.update(dt)
    UI:Update(dt)
end

function love.draw()
    UI:Draw(dt)
end

function love.resize(w, h)
    ScreenSize = Vector2(w, h)
end

function love.mousepressed()
    MouseClicked:Fire(true)
end

function love.mousereleased()
    MouseClicked:Fire(false)
end