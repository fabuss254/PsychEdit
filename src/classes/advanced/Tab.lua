-- Libs
local Vector2 = require("src/classes/Vector2")
local UDim2 = require("src/classes/UDim2")
local Color = require("src/classes/Color")
local Frame = require("src/classes/Frame")
local Image = require("src/classes/Image")
local Text = require("src/classes/Text")
local Object = require("src/libs/Classic")

local ListLayout = require("src/classes/layout/ListLayout")

local Cursor = require("src/libs/Cursor")
local Fonts = require("src/libs/Fonts")
local UI = require("src/libs/UIEngine")

local New, Children, Connect, List, Exec

-- Function
function ResizeItem(Position, Size, Anchor, Axis, ChangeAnchor, MinSize)
    return New "Frame" {
        Position = Position,
        Size = Size,
        Anchor = Anchor,

        Opacity = 1,

        ZIndex = 100,

        [Connect "Hover"] = function(self, bool)
            local Cs
            if bool then
                if Axis.Y == 0 then
                    Cs = Cursor.sizewe
                elseif Axis == Vector2.y then
                    Cs = Cursor.sizens
                elseif Axis == Vector2.one then
                    Cs = Cursor.sizenwse
                else
                    Cs = Cursor.sizenesw
                end
            end

            love.mouse.setCursor(Cs)
            self.Opacity = bool and 0.9 or 1
        end,

        [Connect "MouseClick"] = function(self, bool)
            if not bool then return end
            self.META.Holding = {GetMousePosition(), self.Parent.Size:Clone(), self.Parent.Position:ToVector2(ScreenSize)}
        end,

        [Connect "Update"] = function(self, dt)
            if not self.META.Holding then return end
            if not love.mouse.isDown(1) then
                self.META.Holding = false
                return
            end

            local MousePos = GetMousePosition()
            local Delta = MousePos - self.META.Holding[1]

            local newSize = Vector2(self.META.Holding[2].X.Offset+Delta.X*Axis.X, self.META.Holding[2].Y.Offset+Delta.Y*Axis.Y)
            self.Parent:SetSize(UDim2(0, math.max(newSize.X, MinSize.X), 0, math.max(newSize.Y, MinSize.Y)))

            if ChangeAnchor then
                --Delta.X = Delta.X + (newSize.X - MinSize.X)
                if newSize.X <= MinSize.X then Delta.X = Delta.X-(MinSize.X - newSize.X) end

                local newPosition = UDim2(0, self.META.Holding[3].X-Delta.X*Axis.X, 0, self.META.Holding[3].Y)
                self.Parent:SetPosition(newPosition)
            end
        end,
    }
end

-- Class
local class = Object:extend("Tab")

function class:new(Props)
    -- Ugly hack to access UIBuilder inside an element the UIBuilder load.
    New = UIBuilder.New
    Children = UIBuilder.Children
    Connect = UIBuilder.Connect
    List = UIBuilder.List
    Exec = UIBuilder.Exec

    Props = Props or {}

    local MinSize = Vector2(Props.MinSize and Props.MinSize.X or 200, Props.MinSize and Props.MinSize.Y or 200)

    local MenuSize = UDim2(0, Props.Size and Props.Size.X or 300, 0, Props.Size and Props.Size.Y or 300)
    local MenuPos = UDim2(0, Props.Position and Props.Position.X or (ScreenSize.X/2 - MenuSize.X.Offset/2), 0, Props.Position and Props.Position.Y or (ScreenSize.Y/2 - MenuSize.Y.Offset/2))
    local MenuColor = Color.FromRGB(104, 123, 153)

    local Menu = New "Frame" {
        Size = MenuSize,
        Position = MenuPos,
    
        Color = MenuColor,

        [Children] = {
            -- Shadow
            New "Frame" {
                Size = UDim2(1, 0, 1, 0),
                Position = UDim2(.5, 10, .5, 10),
                Anchor = Vector2.one/2,

                Color = Color.Black,
                Opacity = .75,
                ZIndex = -1,
            },

            -- Content
            New "Frame" {
                Name = "Content",
                Position = UDim2(.5, 0, 1, -2),
                Size = UDim2(1, -4, 1, -22),
                Anchor = Vector2(.5, 1),

                Color = MenuColor:Lerp(Color.Black, 0.5),
            },

            -- Topbar
            New "Frame" {
                Name = "Topbar",
                Size = UDim2(1, 0, 0, 20),
                Opacity = 1,

                [Connect "MouseClick"] = function(self, bool)
                    if not bool then return end
            
                    self.META.IsDragged = true
                    self.META.Offset = self.Parent.Position:ToVector2(ScreenSize) - GetMousePosition()
                end,
            
                [Connect "Update"] = function(self, dt)
                    if not self.META.IsDragged then return end
                    if not love.mouse.isDown(1) then
                        self.META.IsDragged = false
                        return
                    end
            
                    local newPos = GetMousePosition() + self.META.Offset
                    self.Parent:SetPosition(UDim2(newPos.X/ScreenSize.X, 0, newPos.Y/ScreenSize.Y, 0))
                end,

                [Children] = {
                    New "Text" {
                        Position = UDim2(.5, 0, .6, 0),
                        Anchor = Vector2.one/2,

                        Text = Props.Title or "Menu missing property 'Props.Title'",
                    },

                    New "Frame" {
                        Size = UDim2(0, 20, 1, 0),
                        Position = UDim2(1, 0, 0, 0),
                        Anchor = Vector2.x,

                        Color = MenuColor:Lerp(Color.Black, 0.5),
                        Opacity = 1,
                        ZIndex = 2,

                        [Connect "Hover"] = function(self, bool)
                            self.Opacity = bool and 0 or 1
                        end,
        
                        [Connect "MouseClick"] = function(self, bool)
                            if not bool then return end
        
                            self.Parent.Parent:SetVisible(false)
                        end,

                        [Children] = New "Image" {
                            Position = UDim2(.5, 0, .5, 0),
                            Size = UDim2(1, 0, .75, 0),
                            Anchor = Vector2.one/2,
                            
                            Ratio = 1,
                            ZIndex = 4,

                            Image = "assets/images/icons/close_icon.png"
                        }
                    }
                }
            },

            -- // ResizeFrames
            ResizeItem(UDim2(.5, 0, 1, 0), UDim2(1, -15, 0, 6), Vector2.one/2, Vector2.y, false, MinSize),
            ResizeItem(UDim2(0, 0, .5, 5), UDim2(0, 6, 1, -25), Vector2.one/2, -Vector2.x, true, MinSize),
            ResizeItem(UDim2(1, 0, .5, 5), UDim2(0, 6, 1, -25), Vector2.one/2, Vector2.x, false, MinSize),

            -- Corners
            ResizeItem(UDim2(1, 0, 1, 0), UDim2(0, 15, 0, 15), Vector2.one/2, Vector2.one, false, MinSize),
            ResizeItem(UDim2(0, 0, 1, 0), UDim2(0, 15, 0, 15), Vector2.one/2, Vector2(-1, 1), true, MinSize),
        }
    }

    self.Menu = Menu
    self.Topbar = Menu:Get("Topbar")
    self.Content = Menu:Get("Content")
end

return class