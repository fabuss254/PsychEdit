-- Libs
local Vector2 = require("src/classes/Vector2")
local UDim2 = require("src/classes/UDim2")
local Color = require("src/classes/Color")
local Frame = require("src/classes/Frame")
local Image = require("src/classes/Image")
local Text = require("src/classes/Text")

local ListLayout = require("src/classes/layout/ListLayout")

local Fonts = require("src/libs/Fonts")
local UI = require("src/libs/UIEngine")

local New = UIBuilder.New
local Children = UIBuilder.Children
local Connect = UIBuilder.Connect
local List = UIBuilder.List
local Exec = UIBuilder.Exec

-- Properties
local TopbarColor = Color.FromRGB(54, 63, 77)
local ButtonColor = Color.FromRGB(79, 93, 112)
local BaseZIndex = 99999999

-- Definer Functions
local function EnableUI(UIName)
    if not UI.UIs[UIName] then return print(("No UI named '%s' found"):format(UIName)) end
    return function()
        UI.UIs[UIName]:SetVisible(not UI.UIs[UIName].Visible)
    end
end

local Buttons = {
    {"File", {
        {"Open", EnableUI("File Explorer")},
        false,
        {"Save"},
        {"Save As..."}
    }},
    {"Edit"},
    {"Windows", {
        {"Timeline", EnableUI("Timeline")},
        {"Explorer", EnableUI("Explorer")},
        {"Properties", EnableUI("Properties")},
        {"Viewport", EnableUI("Viewport")},
    }},
    {"Help", {
        {"Open README", function()
            love.system.openURL("file://D:/Developpement/FNF-Pysch-editor/README.md")
        end},
        {"Open Github", function()
            love.system.openURL("https://github.com/fabuss254/PsychEdit")
        end},
        false,
        {"Made by Fabuss254"}
    }},
}

-- Functions
local function SubmenuItem(Key, Value)
    if not Value then 
        return New "Frame" {
            Size = UDim2(1, 0, 0, 14),
            LayoutOrder = Key,
            Opacity = 1,

            [Children] = New "Frame" {
                Position = UDim2(.5, 0, .5, 0),
                Size = UDim2(1, 0, 0, 2),
                Anchor = Vector2.one/2,

                Color = TopbarColor:Lerp(Color.Black, 0.2),
                ZIndex = BaseZIndex + 10,
            }
        }
    end
    return New "Frame" {
        Color = ButtonColor,
        Opacity = 1,
        LayoutOrder = Key,
        ZIndex = BaseZIndex+Key,

        [Exec] = function(self)
            self:SetSize(UDim2(1, 0, 0, self:Get("Text").Size.Y.Offset + 10))
        end,

        [Connect "Hover"] = function(self, bool)
            self.Opacity = bool and 0 or 1
        end,

        [Connect "MouseClick"] = Value[2] and function(self, bool)
            if not bool then return end

            Value[2]()
            self.Parent:SetVisible(false)
        end,

        [Children] = New "Text" {
            Position = UDim2(0, 10, 0.55, 0),
            Anchor = Vector2.y/2,
            
            Color = Color.White:Lerp(ButtonColor, Value[2] and 0.2 or 0.8),
            ZIndex = BaseZIndex+Key+10,

            Text = Value[1],
        }
    }
end

local function Submenu(Tbl)
    return New "Frame" {
        Name = "Submenu",
        Position = UDim2(0, 0, 1, 0),

        Color = TopbarColor,
        ChildLayout = ListLayout(0),
        ZIndex = BaseZIndex,

        Visible = false,

        [Exec] = function(self)
            local ContentSize = Vector2()
            for _,v in pairs(self:GetChildren()) do
                local txt = v:Get("Text")
                if not txt then
                    ContentSize.Y = ContentSize.Y + v.Size.Y.Offset
                else
                    ContentSize.X = math.max(txt.Size.X.Offset + 20, ContentSize.X)
                    ContentSize.Y = ContentSize.Y + (txt.Size.Y.Offset + 10)
                end
            end

            self:SetSize(UDim2(0, ContentSize.X, 0, ContentSize.Y))
        end,

        [Connect "Update"] = function(self) -- Only execute when visible
            if not self:IsHovering() and not self.Parent:IsHovering() then
                return self:SetVisible(false)
            end
        end,

        [Children] = List(Tbl, SubmenuItem)
    }
end

local function TopbarItem(Key, Value)
    return New "Frame" {
        Color = ButtonColor,
        Opacity = 1,
        LayoutOrder = Key,

        [Connect "Hover"] = function(self, bool)
            self.Opacity = bool and 0 or 1
        end,

        [Connect "MouseClick"] = function(self, bool)
            if not bool then return end
            local sub = self:Get("Submenu")
            sub:SetVisible(not sub.Visible)
        end,

        [Exec] = function(self)
            self:SetSize(UDim2(0, self:Get("Text").Size.X.Offset + 10, 1, 0))
        end,

        [Children] = {
            New "Text" {
                Position = UDim2(.5, 0, .55, 0),
                Anchor = Vector2.one/2,

                Color = Color.White:Lerp(ButtonColor, 0.2),
                ZIndex = BaseZIndex+10,

                Text = Value[1]
            },

            Submenu(Value[2]) 
        }
    }
end

Main = New "Frame" {
    Size = UDim2(1, 0, 1, 0),
    Opacity = 1,

    [Children] = {
        New "Frame" {
            Position = UDim2(0, 0, 0, 0),
            Size = UDim2(1, 0, 0, 30),

            Color = TopbarColor,
            ChildLayout = ListLayout(),

            ZIndex = BaseZIndex,
            [Children] = List(Buttons, TopbarItem)
        },

        -- Workflow background
        New "Image" {
            Position = UDim2(0, 0, 0, 30),
            Size = UDim2(1, 0, 0.25, 0),

            Color = Color.Black,
            Opacity = .8,
            ZIndex = -5000000,

            Image = "assets/images/GradientTop.png"
        },

        New "Image" {
            Position = UDim2(0, 0, 1, 0),
            Anchor = Vector2.y,
            Size = UDim2(1, 0, 0.25, 0),

            Color = Color.Black,
            Opacity = .8,
            ZIndex = -5000000,

            Image = "assets/images/GradientBottom.png"
        },

        New "Image" {
            Position = UDim2(.5, 0, .5, 0),
            Anchor = Vector2.one/2,
            Size = UDim2(.5, 0, 0.5, 0),

            Ratio = 1,
            Opacity = .8,
            ZIndex = -5000000,

            Image = "assets/images/Logo.png"
        }
    }
}

UI.RegisterUI("Topbar", Main)