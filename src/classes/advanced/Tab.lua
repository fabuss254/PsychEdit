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
local class = Object:extend("Tab")

function class:new(Props)
    local New = UIBuilder.New
    local Children = UIBuilder.Children
    local Connect = UIBuilder.Connect
    local List = UIBuilder.List
    local Exec = UIBuilder.Exec

    Props = Props or {}

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

                --[[
                [Children] = New "Frame" {
                    Position = UDim2(1, -4, 1, -4),
                    Size = UDim2(0, 6, 0, 6),
                    Anchor = Vector2.one,
                    
                    Color = MenuColor,
                    ZIndex = 30,

                    [Connect "Hover"] = function(self, bool)
                        self.Color = bool and MenuColor:Lerp(Color.White, 0.5) or MenuColor
                    end,

                    [Connect "MouseClick"] = function(self, bool)
                        if not bool then return end
                
                        self.META.Holding = true
                    end,
                
                    [Connect "Update"] = function(self, dt)
                        if not self.META.Holding then return end
                        if not love.mouse.isDown(1) then
                            self.META.Holding = false
                            return
                        end
                
                        local NewSize = GetMousePosition() - self.Parent.Parent.Position:ToVector2(ScreenSize) + Vector2(8, 8)
                        self.Parent.Parent:SetSize(UDim2(0, math.max(NewSize.X, Props.MinSize and Props.MinSize.X or self.Parent.Parent:Get("Topbar"):Get("Text").Size.X.Offset + 50), 0, math.max(NewSize.Y, Props.MinSize and Props.MinSize.Y or 100)))
                    end
                }
                ]]
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
            }
        }
    }

    self.Menu = Menu
    self.Topbar = Menu:Get("Topbar")
    self.Content = Menu:Get("Content")
end

return class