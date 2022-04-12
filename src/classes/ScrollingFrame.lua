-- LIBS
local UDim2 = require("src/classes/UDim2")
local Vector2 = require("src/classes/Vector2")
local Color = require("src/classes/Color")
local Frame = require("src/classes/Frame")
local Fonts = require("src/libs/Fonts")

-- CLASS
local class = Frame:extend("ScrollingFrame")

function class:new(Font, x, y)
    self.super.new(self, x, y, 0, 0, 0)

    self:SetClipDescendants(true)
    self.Active = true

    self.CanvasPosition = Vector2()
    self.CanvasSize = UDim2(1, 0, 2, 0)

    self.ScrollbarSize = 5
    self.ScrollbarOpacity = 0.4
    self.ScrollbarColor = Color.White
    self.ScrollbarClip = true
    self.ScrollStrength = 60
    self.ScrollSmooth = 0.075

    self:Connect("Hover", function(bool)
        self.ScrollbarOpacity = bool and 0 or 0.4
    end)

    -- Internal
    self._SmoothPosition = Vector2()

    return self
end

function class:GetBoundaries()
    PosX, PosY, ScaleX, ScaleY = self:GetDrawingCoordinates()

    PosX = PosX - self.CanvasPosition.X
    PosY = PosY - self.CanvasPosition.Y
    ScaleX = math.max(self.CanvasSize.X.Scale * ScaleX + self.CanvasSize.X.Offset - ScaleX, ScaleX)
    ScaleY = math.max(self.CanvasSize.Y.Scale * ScaleY + self.CanvasSize.Y.Offset - ScaleY, ScaleY)

    if self.ScrollbarClip then
        PosX = PosX - self.ScrollbarSize
    end

    return PosX, PosY, ScaleX, ScaleY
end

function class:GetMaxScroll()
    local _, _, _, ScaleY = self:GetDrawingCoordinates()
    return ScaleY * self.CanvasSize.Y.Scale + self.CanvasSize.Y.Offset - ScaleY
end

function class:SetCanvasPosition(newPos, internal)
    if not newPos then return end

    newPos = newPos:Clamp(0, self:GetMaxScroll())
    if newPos.Y == self.CanvasPosition.Y then return end
    if math.abs(newPos.Y - self.CanvasPosition.Y) < 0.05 then return end

    if not internal then
        self._SmoothPosition = newPos
    end

    self.CanvasPosition = newPos:Clone()

    -- If there is a layout, refresh might not be required on all elements
    if self.ChildLayout then
        if not self.META.LastVisibleElementKey or not self:GetChildren()[self.META.LastVisibleElementKey] then
            for i,v in pairs(self:GetChildren()) do
                v:RefreshAll() 
                if not v:IsClipping() then
                    self.META.LastVisibleElementKey = i
                end
            end
        else
            local Startkey = self.META.LastVisibleElementKey
            local Childs = self:GetChildren()

            self.META.LastVisibleElementKey = nil

            for i=Startkey+1, #Childs do
                local v = Childs[i]
                v:RefreshAll()
                if v:IsClipping() then
                    break
                else
                    self.META.LastVisibleElementKey = math.max(self.META.LastVisibleElementKey or 0, i)
                end
            end

            for i=Startkey, 1, -1 do
                local v = Childs[i]
                v:RefreshAll()
                if v:IsClipping() then
                    if self.META.LastVisibleElementKey then
                        break
                    end
                else
                    self.META.LastVisibleElementKey = math.max(self.META.LastVisibleElementKey or 0, i)
                end
            end
        end
        
        return
    end

    for _,v in pairs(self:GetDescendants()) do
        v:Refresh() 
    end
end

function class:IsHoveringOnScrollbar()
    local x, _ = love.mouse.getPosition()
    local posX, _, sizeX, _ = self:GetDrawingCoordinates()
    return x <= posX + sizeX and x >= posX + sizeX - self.ScrollbarSize
end

function class:Update(dt)
    if self.ScrollSmooth > 0 then
        self:SetCanvasPosition(self.CanvasPosition:Lerp(self._SmoothPosition, dt/self.ScrollSmooth), true)
    end

    local Hovering = self:IsHovering()
    if self._Connections["Hover"]  then
        local H = Hovering and self:IsHoveringOnScrollbar()
        if self._IsHovering ~= H then
            self._IsHovering = H

            self._Connections.Hover(self:DoReturnSelf(self._IsHovering))
        end
    end

    local WheelDelta = -GetWheelDelta()*self.ScrollStrength
    if WheelDelta == 0 then return end

    if Hovering then
        if self.ScrollSmooth > 0 then
            self._SmoothPosition.Y = math.clamp(self._SmoothPosition.Y + WheelDelta, 0, self:GetMaxScroll())
        else
            self:SetCanvasPosition(Vector2(0, self.CanvasPosition.Y+WheelDelta))
        end
    end
end

function class:DrawInternal(PosX, PosY, ScaleX, ScaleY)
    local ViewportSize = ScaleY
    local CanvasSize = ScaleY * self.CanvasSize.Y.Scale + self.CanvasSize.Y.Offset
    local CanvasPosition = self.CanvasPosition.Y

    local ScrollbarSize = ViewportSize / CanvasSize * ViewportSize
    
    local PositionPercent = CanvasPosition / (CanvasSize - ViewportSize)
    local ScrollbarPos = PositionPercent * (ViewportSize - ScrollbarSize)

    self.Color:Apply(1-self.Opacity)

    love.graphics.translate(PosX, PosY)
    love.graphics.rectangle("fill", 0, 0, ScaleX, ScaleY, self.CornerRadius)
    
    if ViewportSize < CanvasSize then
        self.ScrollbarColor:Apply(1-self.ScrollbarOpacity)
        love.graphics.rectangle("fill", ScaleX-self.ScrollbarSize, ScrollbarPos, self.ScrollbarSize, ScrollbarSize, self.CornerRadius)
    end
    
    love.graphics.origin()
end

function class:__tostring()
    return ("ScrollingFrame_%s"):format(self.Name)
end

return class