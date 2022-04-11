-- Libs
local Vector2 = require("src/classes/Vector2")
local UDim2 = require("src/classes/UDim2")
local Color = require("src/classes/Color")
local Frame = require("src/classes/Frame")
local Image = require("src/classes/Image")
local Text = require("src/classes/Text")
local Tab = require("src/classes/advanced/Tab")

local ListLayout = require("src/classes/layout/ListLayout")

local UIBuilder = require("src/libs/UIBuilder")
local Fonts = require("src/libs/Fonts")
local UI = require("src/libs/UIEngine")

local New = UIBuilder.New
local Children = UIBuilder.Children
local Connect = UIBuilder.Connect
local List = UIBuilder.List
local Exec = UIBuilder.Exec

-- Config
local o = love.filesystem.getDirectoryItems("/")
for i,v in pairs(o) do
    print(i, v)
end

-- Basic windows
local TabMenu = Tab({
    Title = "File Explorer",
    Size = Vector2(600, 400),
    Position = Vector2(ScreenSize.X/2 - 300, ScreenSize.Y/2 - 200),
})

-- Functions
local function ListItem(Key, Value)
    return New "Frame" {
        Opacity = 1,
        LayoutOrder = Key,
        Size = UDim2(1, 0, 0, 20),

        [Exec] = function(self)
            self.META.Expand = false
        end,

        [Connect "Hover"] = function(self, bool) 
            self.Opacity = bool and 0.8 or 1
        end,

        [Connect "MouseClick"] = function(self, bool)
            if not bool then return end
            self.META.Expand = not self.META.Expand

            self:Get("Frame"):Get("Image").Rotation = self.META.Expand and 0 or -math.pi/2
        end,

        [Children] = {
            New "Frame" {
                Anchor = Vector2.y/2,
                Position = UDim2(0, 0, .5, 0),
                Size = UDim2(0, 20, 0, 20),
                Opacity = 1,

                [Children] = New "Image" {
                    Anchor = Vector2.one/2,
                    Position = UDim2(.5, 0, .5, 0),
                    Size = UDim2(.8, 0, .8, 0),
                    ZIndex = 100,

                    Rotation = -math.pi/2,

                    Image = "assets/images/icons/expand_icon.png"
                }
            },
            New "Text" {
                Anchor = Vector2.y/2,
                Position = UDim2(0, 20, .55, 0),

                Color = Color.White:Lerp(TabMenu.Content.Color, 0.2),
                Text = Value,
                ZIndex = 100
            }
        }
    }
end

local DahContent = {
    -- Left
    New "Frame" {
        Color = TabMenu.Content.Color:Lerp(Color.Black, .25),
        Size = UDim2(0.3, 0, 1, 0),
        ZIndex = 20,
        ChildLayout = ListLayout(0),
        [Children] = {
            List({"Test1", "Test2", "Test3"}, ListItem)
        }
    }
}

-- Add all ui to tab's content
for _,v in pairs(DahContent) do v:SetParent(TabMenu.Content) end

UI.Add(TabMenu.Menu)

-- Export
UI.RegisterUI("File Explorer", TabMenu.Menu)