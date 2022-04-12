-- Libs
local Vector2 = require("src/classes/Vector2")
local UDim2 = require("src/classes/UDim2")
local Color = require("src/classes/Color")
local Frame = require("src/classes/Frame")
local Image = require("src/classes/Image")
local Text = require("src/classes/Text")
local Tab = require("src/classes/advanced/Tab")

local ListLayout = require("src/classes/layout/ListLayout")

local Delay = require("src/libs/Delay")
local Fonts = require("src/libs/Fonts")
local UI = require("src/libs/UIEngine")
local fs = require("src/libs/nativefs")

local New = UIBuilder.New
local Children = UIBuilder.Children
local Connect = UIBuilder.Connect
local List = UIBuilder.List
local Exec = UIBuilder.Exec

-- Config
local DoubleClickInterval = 0.5
local SelectedColor = Color.FromRGB(8, 143, 255)

-- Basic windows
local Module = {}
local TabMenu = Tab({
    Title = "File Explorer - Open project",
    Size = Vector2(600, 400),
    Position = Vector2(ScreenSize.X/2 - 300, ScreenSize.Y/2 - 200),
})

local SelectedFrame, SelectionLastClick
local CurrentPath

-- Functions
local function ListItem(Key, Value)
    local fileInfo = fs.getInfo(Value)
    if not fileInfo then return end

    local isDirectory = fileInfo.type == "directory"
    local Args = string.split(Value, "/")
    local Name = Args[#Args]

    return New "Frame" {
        Name = Value,
        LayoutOrder = Key + (isDirectory and 0 or 1000) + (Name == ".." and -1000000 or 0),
        Opacity = (Key%2 == 1 and 1 or 0.95),
        Size = UDim2(1, 0, 0, 20),
        ZIndex = TabMenu.Menu.ZIndex + 25,

        [Exec] = function(self)
            Delay.new(1/60, function()
                self._Connections.Hover(self, false)
            end)
        end,

        [Connect "Hover"] = function(self, bool) 
            local o = self.META.LayoutKey or 0
            local IsSelected = self == SelectedFrame
            local OriginalColor = IsSelected and SelectedColor or Color.White

            self.Color = OriginalColor
            self.Opacity = IsSelected and (bool and 0 or .2) or bool and 0.8 or (o%2 == 1 and 1 or 0.95)
        end,

        [Connect "MouseClick"] = function(self, bool)
            if not bool then return end
            if SelectedFrame ~= self then
                local o = SelectedFrame
                SelectionLastClick = tick()
                SelectedFrame = self
                self._Connections.Hover(self, false)

                if o then
                    o._Connections.Hover(o, false)
                end
                return
            end
            if not isDirectory then return end

            if tick() - SelectionLastClick > DoubleClickInterval then SelectionLastClick = tick() return end

            SelectedFrame = nil

            if string.sub(Value, #Value, #Value) ~= "/" then
                Value = Value .. "/"
            end

            if Name == ".." then
                return Module.Back(Value)
            end

            Module.Goto(Value)
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

local function IconButton(Order, Img, Callback)
    return New "Frame" {
        Size = UDim2(0, 20, 0, 20),

        Color = TabMenu.Menu.Color,

        LayoutOrder = Order,
        ZIndex = 30,

        [Connect "Hover"] = function(self, bool)
            self.Color = bool and TabMenu.Menu.Color:Lerp(Color.White, .5) or TabMenu.Menu.Color
        end,
        [Connect "MouseClick"] = Callback and function(self, bool)
            if bool then return end
            Callback()
        end,
        
        [Children] = New "Image" {
            Position = UDim2(.5, 0, .5, 0),
            Size = UDim2(.8, 0, .8, 0),
            Anchor = Vector2.one/2,

            Image = Img
        },
    }
end

function Module.Back(Path)
    if Path == "../" then return end
    local Args = string.split(Path, "/")
    return Module.Goto(string.sub(Path, 0, #Path-(4 + #Args[#Args-1])))
end

function Module.Goto(Path)
    if Path ~= "" then
        Path = Path:gsub("\\", "/")
        if Path:sub(#Path) ~= "/" then
            Path = Path .. "/"
        end
    end

    local Parent = TabMenu.Content:Get("Center")
    Parent:ClearAllChildren()
    local o = (Path == "" and fs.getDriveList()) or fs.getDirectoryItems(Path)
            
    print("Searching directory", Path)
    for i,v in pairs(o) do
        o[i] = Path .. v
    end

    if Path ~= "" then
        table.insert(o, Path .. "..")
    end

    local CanvasSizeY = 0
    for _,v in pairs(List(o, ListItem)) do
        CanvasSizeY = CanvasSizeY + v.Size.Y.Offset
        v:SetParent(Parent)
    end

    Parent.CanvasSize = UDim2(0, 0, 0, CanvasSizeY)
    Parent:SetCanvasPosition(Vector2(0, 0))
    TabMenu.Content:Get("Bottom"):Get("Frame"):Get("Pathbox"):Get("Text"):SetText(Path == "" and ".." or Path)

    CurrentPath = Path
end

local DahContent = {
    -- Top
    New "Frame" {
        Name = "Top",
        Size = UDim2(1, 0, 0, 30),
        Position = UDim2(0, 0, 0, 0),

        Opacity = 1,

        [Children] = New "Frame" {
            Anchor = Vector2(.5, .5),
            Size = UDim2(1, -10, 1, -10),
            Position = UDim2(.5, 0, .5, 0),

            ChildLayout = ListLayout(1, 5),

            Opacity = 1,

            [Children] = {
                IconButton(1, "assets/images/icons/back_icon.png", function() Module.Back(CurrentPath .. "../") end),
                IconButton(2, "assets/images/icons/storage_icon.png", function() Module.Goto("") end),
                IconButton(3, "assets/images/icons/home_icon.png", function() Module.Goto(fs.getWorkingDirectory()) end),
                IconButton(4, "assets/images/icons/document_icon.png", function() Module.Goto(love.filesystem.getUserDirectory() .. "Documents/") end),
                IconButton(11, "assets/images/icons/refresh_icon.png", function() Module.Goto(CurrentPath) end),
                New "Frame" {
                    Opacity = 1,
                    Size = UDim2(1, -125, 1, 0),
                    LayoutOrder = 10
                }
            }
        }
    },

    -- Center
    New "ScrollingFrame" {
        Name = "Center",
        Size = UDim2(1, 0, 1, -60),
        Anchor = Vector2(.5, .5),
        Position = UDim2(.5, 0, .5, 0),

        Color = TabMenu.Content.Color:Lerp(Color.Black, .25),
        ChildLayout = ListLayout(0),
        ZIndex = 20,
        
        CanvasSize = UDim2(0, 0, 0, 0),
    },

    -- Bottom
    New "Frame" {
        Name = "Bottom",
        Size = UDim2(1, 0, 0, 30),
        Position = UDim2(0, 0, 1, 0),
        Anchor = Vector2.y,

        Opacity = 1,

        [Children] = New "Frame" {
            Anchor = Vector2(.5, .5),
            Size = UDim2(1, -10, 1, -10),
            Position = UDim2(.5, 0, .5, 0),

            ChildLayout = ListLayout(1, 5),

            Opacity = 1,

            [Children] = {
                New "Frame" {
                    Name = "Pathbox",
                    Size = UDim2(1, -45, 1, 0),

                    Color = TabMenu.Menu.Color:Lerp(Color.Black, 0.75),
                    ZIndex = 25,

                    [Children] = {
                        New "Frame" {
                            Position = UDim2(.5, 0, .5, 0),
                            Size = UDim2(1, 2, 1, 2),
                            Anchor = Vector2.one/2,

                            ZIndex = 20,

                            Color = TabMenu.Menu.Color,
                        },
                        New "Text" {
                            Position = UDim2(0, 5, .55, 0),
                            Anchor = Vector2.y/2,

                            Text = "..",

                            ZIndex = 30,

                            Color = TabMenu.Menu.Color,
                        }
                    }

                },
                New "Frame" {
                    Size = UDim2(0, 40, 1, 0),

                    Color = TabMenu.Menu.Color,
                    ZIndex = 25,

                    [Children] = New "Text" {
                        Position = UDim2(.5, 0, .55, 0),
                        Anchor = Vector2.one/2,

                        Text = "Open",
                        ZIndex = 30,

                        Color = Color.White,
                    }
                }
            }
        }
    }
}

-- Add all ui to tab's content
for _,v in pairs(DahContent) do v:SetParent(TabMenu.Content) end

-- Export
UI.RegisterUI("File Explorer", TabMenu.Menu)

-- Launch
Module.Goto(fs.getWorkingDirectory():gsub("\\", "/") .. "/")