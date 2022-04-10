--[[
    Title: PsychEngine Modchart Editor
    Author: Fabuss254
    Repo: https://github.com/fabuss254/PsychEngine-Modchart-Editor
    Description: A easy to use modchart editor for psych engine.
--]]

-- Global overwrites
love.graphics.setDefaultFilter('nearest', 'nearest')
tick = love.timer.getTime
math.clamp = function(value, min, max) return math.min(math.max(value, min), max) end

function typeof(obj)
    return type(obj) == "table" and obj._type or type(obj)
end

-- Global functions
function love.load()
    
end

function love.update(dt)
    
end

function love.draw()
    
end

