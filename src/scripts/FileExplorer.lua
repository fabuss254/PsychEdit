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
local fs = require("src/libs/nativefs")

local New = UIBuilder.New
local Children = UIBuilder.Children
local Connect = UIBuilder.Connect
local List = UIBuilder.List
local Exec = UIBuilder.Exec

-- Config

-- Basic windows
local TabMenu = Tab({
    Title = "File Explorer",
    Size = Vector2(600, 400),
    Position = Vector2(ScreenSize.X/2 - 300, ScreenSize.Y/2 - 200),
})

-- Functions
local function ListItem(Key, Value)
    local fileInfo = fs.getInfo(Value)
    if not fileInfo then return end

    local isDirectory = fileInfo.type == "directory"
    local Args = string.split(Value, "/")
    local Name = Args[#Args]

    return New "Frame" {
        Name = Value,
        Opacity = (Key%2 == 1 and 1 or 0.95),
        LayoutOrder = Key + (isDirectory and 0 or 1000) + (Name == ".." and -1000000 or 0),
        Size = UDim2(1, 0, 0, 20),
        ZIndex = TabMenu.Menu.ZIndex + 25,

        [Connect "Hover"] = function(self, bool) 
            self.Opacity = bool and 0.8 or (Key%2 == 1 and 1 or 0.95)
        end,

        [Connect "MouseClick"] = function(self, bool)
            if not bool then return end
            if not isDirectory then return end
            local Parent = self.Parent
            Parent:ClearAllChildren()

            if string.sub(Value, #Value, #Value) ~= "/" then
                Value = Value .. "/"
            end

            if Name == ".." then
                Value = string.sub(Value, 0, #Value-(4 + #Args[#Args-1]))
            end

            local o = (Value == "" and fs.getDriveList()) or fs.getDirectoryItems(Value)
            print("Searching directory", Value)
            for i,v in pairs(o) do
                o[i] = Value .. v
            end

            if Value ~= "" then
                table.insert(o, Value .. "..")
            end

            for _,v in pairs(List(o, ListItem)) do
                v:SetParent(Parent)
            end
        end,

        [Children] = {
            New "Frame" {
                Anchor = Vector2.y/2,
                Position = UDim2(0, 0, .5, 0),
                Size = UDim2(0, 20, 0, 20),
                Opacity = 1,

                [Children] = New "Image" {
                    Opacity = isDirectory and 0 or 1,
                    Anchor = Vector2.one/2,
                    Position = UDim2(.5, 0, .5, 0),
                    Size = UDim2(.8, 0, .8, 0),
                    ZIndex = TabMenu.Menu.ZIndex + 30,

                    Rotation = -math.pi/2,

                    Image = "assets/images/icons/expand_icon.png"
                }
            },
            New "Text" {
                Anchor = Vector2.y/2,
                Position = UDim2(0, isDirectory and 20 or 5, .55, 0),

                Color = Color.White:Lerp(TabMenu.Content.Color, 0.2),
                Text = Name,
                ZIndex = TabMenu.Menu.ZIndex + 30,
            }
        }
    }
end

local DahContent = {
    -- Center
    New "Frame" {
        Color = TabMenu.Content.Color:Lerp(Color.Black, .25),
        Size = UDim2(1, 0, 1, -60),
        Anchor = Vector2(.5, .5),
        Position = UDim2(.5, 0, .5, 0),
        ZIndex = 20,
        ChildLayout = ListLayout(0),
        [Children] = {
            List(fs.getDriveList(), ListItem) -- love.filesystem.getDirectoryItems("/")
        }
    }
}

-- Add all ui to tab's content
for _,v in pairs(DahContent) do v:SetParent(TabMenu.Content) end

-- Export
UI.RegisterUI("File Explorer", TabMenu.Menu)