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

                [Children] = New "Frame" {
                    Position = UDim2(1, -4, 1, -4),
                    Size = UDim2(0, 6, 0, 6),
                    Anchor = Vector2.one,
                    
                    Color = MenuColor,
                    ZIndex = 10,

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
                        self.Parent.Parent.Size = UDim2(0, math.max(NewSize.X, Props.MinSize and Props.MinSize.X or self.Parent.Parent:Get("Topbar"):Get("Text").Size.X.Offset + 50), 0, math.max(NewSize.Y, Props.MinSize and Props.MinSize.Y or 100))
                    end
                }
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
                    self.Parent.Position = UDim2(newPos.X/ScreenSize.X, 0, newPos.Y/ScreenSize.Y, 0)
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

    --[[
    local Menu = Frame()
    Menu.Size = UDim2(0, Props.Size and Props.Size.X or 300, 0, Props.Size and Props.Size.Y or 300)
    Menu.Position = UDim2(0, Props.Position and Props.Position.X or (ScreenSize.X/2 - Menu.Size.X.Offset/2), 0, Props.Position and Props.Position.Y or (ScreenSize.Y/2 - Menu.Size.Y.Offset/2))
    Menu.Color = Color.FromRGB(104, 123, 153)
    --Menu:Ratio(0.5)

    local Shadow = Frame()
    Shadow.ZIndex = -1
    Shadow.Size = UDim2(1, 0, 1, 0)
    Shadow.Position = UDim2(.5, 10, .5, 10)
    Shadow.Anchor = Vector2.one/2
    Shadow.Color = Color.Black
    Shadow.Opacity = .75
    Shadow:SetParent(Menu)

    local Content = Frame()
    Content.Position = UDim2(.5, 0, 1, -2)
    Content.Anchor = Vector2(.5, 1)
    Content.Color = Menu.Color:Lerp(Color.Black, 0.5)
    Content.Size = UDim2(1, -4, 1, -22)
    Content:SetParent(Menu)

    local Topbar = Frame()
    Topbar.Size = UDim2(1, 0, 0, 20)
    Topbar.Opacity = 1

    Topbar.META.IsDragged = false
    Topbar:Connect("MouseClick", function(bool)
        if not bool then return end

        Topbar.META.IsDragged = true
        Topbar.META.Offset = Menu.Position:ToVector2(ScreenSize) - GetMousePosition()
    end)

    Topbar:Connect("Update", function(dt)
        if not Topbar.META.IsDragged then return end
        if not love.mouse.isDown(1) then
            Topbar.META.IsDragged = false
            return
        end

        local newPos = GetMousePosition() + Topbar.META.Offset
        Menu.Position = UDim2(newPos.X/ScreenSize.X, 0, newPos.Y/ScreenSize.Y, 0)
    end)

    local Title = Text(Fonts.ConsolaSmall)
    Title.Anchor = Vector2.one/2
    Title.Position = UDim2(.5, 0, .6, 0)
    Title:SetText(Props.Title or "Menu missing property 'Props.Title'")
    Title:SetParent(Topbar)

    local Icons = {
        {"close", function() Menu:SetVisible(false) end}
    }
    for i,v in pairs(Icons) do
        local ButtonFrame = Frame()
        ButtonFrame.Anchor = Vector2.x
        ButtonFrame.Size = UDim2(0, 20, 1, 0)
        ButtonFrame.Position = UDim2(1, 0, 0, 0)
        ButtonFrame.Opacity = 1
        ButtonFrame.ZIndex = 2
        ButtonFrame.Color = Menu.Color:Lerp(Color.Black, 0.5)
        
        ButtonFrame:Connect("Hover", function(bool)
            ButtonFrame.Opacity = bool and 0 or 1
        end)

        ButtonFrame:Connect("MouseClick", function(bool)
            if not bool then return end
            v[2]()
        end)

        local Icon = Image("assets/images/icons/" .. v[1] .. "_icon.png")
        Icon.Anchor = Vector2.one/2
        Icon.Size = UDim2(1, 0, .75, 0)
        Icon:Ratio(1)
        Icon.ZIndex = 4
        Icon.Position = UDim2(.5, 0, .5, 0)
        Icon:SetParent(ButtonFrame)
        
        ButtonFrame:SetParent(Topbar)
    end

    -- Bottom right corner extensive
    local ResizeFrame = Frame()
    ResizeFrame.Position = UDim2(1, -4, 1, -4)
    ResizeFrame.ZIndex = 10
    ResizeFrame.Size = UDim2(0, 6, 0, 6)
    ResizeFrame.Anchor = Vector2.one
    ResizeFrame.Color = Menu.Color
    ResizeFrame:SetParent(Content)

    ResizeFrame.META.Holding = false
    ResizeFrame:Connect("Hover", function(bool)
        ResizeFrame.Color = bool and Menu.Color:Lerp(Color.White, 0.5) or Menu.Color
    end)

    ResizeFrame:Connect("MouseClick", function(bool)
        if not bool then return end

        ResizeFrame.META.Holding = true
    end)

    ResizeFrame:Connect("Update", function(dt)
        if not ResizeFrame.META.Holding then return end
        if not love.mouse.isDown(1) then
            ResizeFrame.META.Holding = false
            return
        end

        local NewSize = GetMousePosition() - Menu.Position:ToVector2(ScreenSize) + Vector2(8, 8)
        Menu.Size = UDim2(0, math.max(NewSize.X, Props.MinSize and Props.MinSize.X or Title.Size.X.Offset + 50), 0, math.max(NewSize.Y, Props.MinSize and Props.MinSize.Y or 100))
    end)

    Topbar:SetParent(Menu)

    ]]

    self.Menu = Menu
    self.Topbar = Menu:Get("Topbar")
    self.Content = Menu:Get("Content")
end

return class