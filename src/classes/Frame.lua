-- LIBS
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Object = require("src/libs/Classic")

local UI = require("src/libs/UIEngine")
local ErrorMessage = require("src/libs/ErrorMessage")

-- CLASS
local class = Object:extend("Frame")
class.AllowedEvents = {"Hover", "MouseClicked"}

function class:new(x, y, w, h)
    -- UI Properties
    self.Name = "Frame" -- Only for debug purposes
    self.Position = Vector2(x, y)
    self.Size = Vector2(w or 100, h or 100)
    self.Anchor = Vector2(0, 0)
    self.Opacity = 0

    self.Color = Color(1, 1, 1)
    self.CornerRadius = 0
    self.ZIndex = 0

    -- UI interactive properties
    self.Visible = true
    self._IsHovering = false

    -- Basic 1 time connections
    self._Connections = {}

    -- UI Ancestry
    self._Childs = {}
    self.Parent = false

    return self
end

-- EVENTS
function class:MouseClicked()
    MouseClicked:Connect(function(bool)
        if self:IsHovering() then
            self._Connections.MouseClicked(bool)
        end
    end)
end

-- METHODS
function class:Ratio(AspectRatio)
    rawset(self, "AspectRatio", AspectRatio)
end

function class:SetParent(Obj)
    table.insert(Obj._Childs, self)
    self.Parent = Obj

    if not UI.IsAdded(self) then
        if self.ZIndex == 0 then
            self.ZIndex = Obj.ZIndex + 1
        end

        UI.Add(self, self.ZIndex)
    end
end

function class:GetChildren()
    return Obj._Childs
end

function class:GetDrawingCoordinates()
    --local Pos = typeof(self.Position) == "Vector2" and self.Position or self.Position:ToVector2(self, "Position")
    --local Size = typeof(self.Size) == "Vector2" and self.Size or self.Size:ToVector2(self, "Size")

    local OffsetX, OffsetY, SizeOffsetX, SizeOffsetY = 0, 0, ScreenSize.X, ScreenSize.Y
    if self.Parent then
        OffsetX, OffsetY, SizeOffsetX, SizeOffsetY = self.Parent:GetDrawingCoordinates()
    end

    local ParentPos = Vector2(OffsetX, OffsetY)
    local ParentSize = Vector2(SizeOffsetX, SizeOffsetY)

    local Size = self.Size:ToVector2(ParentSize)
    local Pos = self.Position:ToVector2(ParentSize) + ParentPos

    if rawget(self, "AspectRatio") then
        local Min = math.min(Size.X, Size.Y) / self.AspectRatio
        Size = Vector2(Min, Min)
    end

    local PosX = Pos.X - Size.X*self.Anchor.X
    local PosY = Pos.Y - Size.Y*self.Anchor.Y
    local ScaleX = Size.X
    local ScaleY = Size.Y

    return math.floor(PosX), math.floor(PosY), math.floor(ScaleX), math.floor(ScaleY)
end

function class:Draw()
    if not self.Visible then return end
    local PosX, PosY, ScaleX, ScaleY = self:GetDrawingCoordinates()

    self.Color:Apply(1-self.Opacity)
    
    --love.graphics.translate(PosX - ScaleX, PosY - ScaleY)
    --love.graphics.rotate(self.Rotation)
    --love.graphics.translate(-ScaleX, -ScaleY)
    love.graphics.translate(PosX, PosY)
    love.graphics.rectangle("fill", 0, 0, ScaleX, ScaleY, self.CornerRadius)
    love.graphics.origin()
end

function class:IsHovering()
    local x = love.mouse.getX()
    local y = love.mouse.getY()
    local PosX, PosY, ScaleX, ScaleY = self:GetDrawingCoordinates()

    local HoveringX = PosX < x and PosX + ScaleX > x
    local HoveringY = PosY < y and PosY + ScaleY > y

    return HoveringX and HoveringY
end

function class:Update(dt)
    if self._Connections["Hover"] then
        local Hovering = self:IsHovering()
        if self._IsHovering ~= Hovering then
            self._IsHovering = Hovering
    
            self._Connections.Hover(self._IsHovering)
        end
    end
end

function class:Connect(event, callback)
    if not table.find(class.AllowedEvents, event) then return error(("Attempt to connect instance '%s' to undefined event '%s'"):format(typeof(class), event)) end
    if self._Connections[event] then return error("Cannot connect to the same event twice") end

    if self.class[event] then self[event](self) end
    self._Connections[event] = callback
end

-- META METHODS
function class:__tostring()
    return self.Name
end

function class:__newindex(index, value)
    if not rawget(self, "_initialised") then
        return rawset(self, index, value)
    end
    error(ErrorMessage.NewIndexLocked:format(index))
end

return class