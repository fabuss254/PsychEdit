-- LIBS
local Object = require("src/libs/Classic") 

-- CLASS
local class = Object:extend("Vector2")

function class:new(X, Y)
    self.X = X or 0
    self.Y = Y or 0

    return self
end

class.MiddlePoint = class(.5, .5)
class.zero = class(0, 0)
class.one = class(1, 1)
class.x = class(1, 0)
class.y = class(0, 1)

-- METHODS
function class:GetMagnitude()
    return math.sqrt((self.X^2) + (self.Y^2))
end

function class:GetUnit()
    local Length = self:GetMagnitude()

    local x = self.X/Length
    local y = self.Y/Length

    return class((x == x and x) or 0, (y == y and y) or 0)
end

function class:Clone()
    return class(self.X, self.Y)
end

-- METATABLES
function class:__tostring()
    return string.format("Vector2(%i, %i)", self.X, self.Y)
end

function class.__eq(a, b)
    assert(typeof(b) == "Vector2", "Attempt to compare " .. typeof(a) .. " and " .. typeof(b))
    return a.X == b.X and a.Y == b.Y
end

function class.__add(a, b)
    local err = "unable to perform arithmetic (add) on " .. typeof(a) .. " and " .. typeof(b)
    assert(typeof(b) == "Vector2" or typeof(b) == "number", err)

    if typeof(a) == "number" then
        return class(a + b.X, a + b.Y)
    else
        if typeof(b) == "Vector2" then
            return class(a.X + b.X, a.Y + b.Y)
        else
            return class(a.X + b, a.Y + b)
        end
    end
end

function class.__sub(a, b)
    local err = "unable to perform arithmetic (sub) on " .. typeof(a) .. " and " .. typeof(b)
    assert(typeof(b) == "Vector2" or typeof(b) == "number", err)

    if typeof(a) == "number" then
        return class(a - b.X, a - b.Y)
    else
        if typeof(b) == "Vector2" then
            return class(a.X - b.X, a.Y - b.Y)
        else
            return class(a.X - b, a.Y - b)
        end
    end
end

function class.__mul(a, b)
    local err = "unable to perform arithmetic (mul) on " .. typeof(a) .. " and " .. typeof(b)
    assert(typeof(b) == "Vector2" or typeof(b) == "number", err)

    if typeof(a) == "number" then
        return class(a * b.X, a * b.Y)
    else
        if typeof(b) == "Vector2" then
            return class(a.X * b.X, a.Y * b.Y)
        else
            return class(a.X * b, a.Y * b)
        end
    end
end

function class.__div(a, b)
    local err = "unable to perform arithmetic (div) on " .. typeof(a) .. " and " .. typeof(b)
    assert(typeof(b) == "Vector2" or typeof(b) == "number", err)

    if typeof(a) == "number" then
        return class(a / b.X, a / b.Y)
    else
        if typeof(b) == "Vector2" then
            return class(a.X / b.X, a.Y / b.Y)
        else
            return class(a.X / b, a.Y / b)
        end
    end
end

return class