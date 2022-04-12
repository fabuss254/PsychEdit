local Vector2 = require("src/classes/Vector2")

-- This file is used to add overwrite some functions/variables in the global namespace

love.graphics.setDefaultFilter('nearest', 'nearest')
tick = love.timer.getTime
math.clamp = function(value, min, max) 
    if min > max then return min end
    return math.min(math.max(value, min), max) 
end

table.find = function(tbl, obj)
    for _,v in pairs(tbl) do
        if v == obj then
            return v
        end
    end
end

function string.split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end
ScreenSize = Vector2(love.graphics.getDimensions())
GetMousePosition = function()
    local x = love.mouse.getX()
    local y = love.mouse.getY()
    return Vector2(x, y)
end

local printFork = print
print = function(...)
    return printFork(("\x1B[93m[%s]\x1B[m"):format(os.date("%H:%M:%S")), ...)
end

function typeof(obj)
    return type(obj) == "table" and obj._type or type(obj)
end

-- Mouse wheel
WheelDelta = 0
GetWheelDelta = function()
    return WheelDelta
end

function love.wheelmoved(dx, dy)
    WheelDelta = dy
end