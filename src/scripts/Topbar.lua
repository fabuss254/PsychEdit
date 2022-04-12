-- Libs
local Vector2 = require("src/classes/Vector2")
local UDim2 = require("src/classes/UDim2")
local Color = require("src/classes/Color")
local Frame = require("src/classes/Frame")
local Image = require("src/classes/Image")
local Text = require("src/classes/Text")

local ListLayout = require("src/classes/layout/ListLayout")

local UIBuilder = require("src/libs/UIBuilder")
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
        {"Open"},
        false,
        {"Save"},
        {"Save As..."}
    }},
    {"Edit"},
    {"Windows", {
        {"Timeline", EnableUI("Timeline")},
        {"Explorer", EnableUI("Explorer")},
        {"Properties", EnableUI("Properties")},
        {"File Explorer", EnableUI("File Explorer")},
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
            self.Size = UDim2(1, 0, 0, self:Get("Text").Size.Y.Offset + 10)
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

            self.Size = UDim2(0, ContentSize.X, 0, ContentSize.Y)
            print(self.Size)
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
            self.Size = UDim2(0, self:Get("Text").Size.X.Offset + 10, 1, 0)
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

--[[
local function MakeSubmenu(List, Parent)
    if not List then return end
    local Menu = Frame()
    Menu.Color = TopbarColor
    Menu.Position = UDim2(0, 0, 1, 0)
    Menu.ZIndex = 100000
    Menu:SetLayout(ListLayout)
    Menu.ChildLayout.Direction = 0

    Menu.Visible = false

    local FullSize = Vector2()
    for i,v in pairs(List) do
        if v then
            local ButtonFrame = Frame()
            ButtonFrame.Color = ButtonColor
            ButtonFrame.Opacity = 1
            ButtonFrame.LayoutOrder = i
            ButtonFrame.ZIndex = 100000+i

            ButtonFrame:Connect("Hover", function(IsHovering)
                ButtonFrame.Opacity = IsHovering and 0 or 1
            end)

            if v[2] then
                ButtonFrame:Connect("MouseClick", function(bool)
                    if not bool then return end
                    v[2]()
                    Menu.Visible = false
                end)
            end

            local Text = Text(Fonts.ConsolaSmall)
            Text.Name = v[1]
            Text.Anchor = Vector2.y/2
            Text.Position = UDim2(0, 10, 0.5, 0)
            Text.ZIndex = 1000000
            Text.Color = Text.Color:Lerp(ButtonColor, v[2] and 0.2 or 0.8)
            Text:SetText(v[1])
            Text:SetParent(ButtonFrame)

            ButtonFrame.Size = UDim2(1, 0, 0, Text.Size.Y.Offset + 10)

            ButtonFrame:SetParent(Menu)

            FullSize.X = math.max(FullSize.X, Text.Size.X.Offset + 20)
            FullSize.Y = FullSize.Y + Text.Size.Y.Offset + 10
        else
            local DecoFrame = Frame()
            DecoFrame.Size = UDim2(1, 0, 0, 14)
            DecoFrame.LayoutOrder = i
            DecoFrame.Opacity = 1

            local Delimiter = Frame()
            Delimiter.ZIndex = 1000000
            Delimiter.Position = UDim2(.5, 0, .5, 0)
            Delimiter.Anchor = Vector2.one/2
            Delimiter.Size = UDim2(1, 0, 0, 2)
            Delimiter.Color = TopbarColor:Lerp(Color.Black, 0.2)
            Delimiter:SetParent(DecoFrame)

            DecoFrame:SetParent(Menu)
            FullSize.Y = FullSize.Y + 14
        end
    end
    Menu.Size = UDim2(0, FullSize.X, 0, FullSize.Y)

    Menu:SetParent(Parent)

    Menu:Connect("Update", function()
        if not (Parent:IsHovering() or Menu:IsHovering()) then
            Menu.Visible = false
        end
    end)

    return Menu
end

-- Script

local Main = Frame()
Main.Opacity = 1
Main.Size = UDim2(1, 0, 1, 0)

local Topbar = Frame()
Topbar.META.IsMoving = false
Topbar.Name = "Topbar"
Topbar.Position = UDim2(0, 0, 0, 0)
Topbar.Color = TopbarColor
Topbar.Size = UDim2(1, 0, 0, 30)
Topbar.ZIndex = 99000
Topbar:SetLayout(ListLayout)

Topbar:SetParent(Main)

local Offset = 0
for i,v in pairs(Buttons) do
    local ButtonFrame = Frame()
    ButtonFrame.Name = v[1] .. "Button"
    ButtonFrame.Color = ButtonColor
    ButtonFrame.ZIndex = 99001
    ButtonFrame.Opacity = 1
    ButtonFrame.LayoutOrder = i

    ButtonFrame:Connect("Hover", function(IsHovering)
        ButtonFrame.Opacity = IsHovering and 0 or 1
    end)

    local Text = Text(Fonts.ConsolaSmall)
    Text.Name = v[1]
    Text.Position = UDim2(.5, 0, .55, 0)
    Text.Anchor = Vector2.one/2
    Text.ZIndex = 99100
    Text.Color = Text.Color:Lerp(ButtonColor, 0.2)
    Text:SetText(v[1])
    Text:SetParent(ButtonFrame)

    ButtonFrame.Size = UDim2(0, Text.Size.X.Offset + 16, 1, 0)

    ButtonFrame:SetParent(Topbar)

    local Submenu = MakeSubmenu(v[2], ButtonFrame)
    if Submenu then
        ButtonFrame:Connect("MouseClick", function(bool)
            if not bool then return end
    
            Submenu.Visible = not Submenu.Visible
        end)
    end
end

-- Background gradients
local Gradient = Image("assets/images/GradientTop.png")
Gradient.Position = UDim2(0, 0, 0, Topbar.Size.Y.Offset)
Gradient.Size = UDim2(1, 0, 0.25, 0)
Gradient.Color = Color.Black
Gradient.Opacity = .8
Gradient.ZIndex = -5
Gradient:SetParent(Main)

local Gradient = Image("assets/images/GradientBottom.png")
Gradient.Position = UDim2(0, 0, 1, 0)
Gradient.Anchor = Vector2.y
Gradient.Size = UDim2(1, 0, 0.25, 0)
Gradient.Color = Color.Black
Gradient.Opacity = .8
Gradient.ZIndex = -5
Gradient:SetParent(Main)

local Logo = Image("assets/images/Logo.png")
Logo.Position = UDim2(.5, 0, .5, 0)
Logo.Anchor = Vector2.one/2
Logo.Size = UDim2(.5, 0, 0.5, 0)
Logo:Ratio(1)
Logo.Opacity = .8
Logo.ZIndex = -5
Logo:SetParent(Main)
]]

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