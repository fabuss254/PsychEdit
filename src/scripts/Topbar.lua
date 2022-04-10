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

-- Properties
local TopbarColor = Color.FromRGB(54, 63, 77)
local ButtonColor = Color.FromRGB(79, 93, 112)

local Buttons = {
    {"File", {
        {"Open"},
        {"Save"},
        {"Save As..."}
    }},
    {"Edit"},
    {"Help"},
}

-- Functions
local function MakeSubmenu(List, Parent)
    if not List then return end
    local Menu = Frame()
    Menu.Color = TopbarColor
    Menu.Position = UDim2(0, 0, 1, 0)
    Menu.ZIndex = 100
    Menu:SetLayout(ListLayout)
    Menu.ChildLayout.Direction = 0

    Menu.Visible = false

    local FullSize = Vector2()
    for i,v in pairs(List) do
        if v[1] then
            local ButtonFrame = Frame()
            ButtonFrame.Color = ButtonColor
            ButtonFrame.Opacity = 1
            ButtonFrame.LayoutOrder = i
            ButtonFrame.ZIndex = 100+i

            ButtonFrame:Connect("Hover", function(IsHovering)
                ButtonFrame.Opacity = IsHovering and 0 or 1
            end)

            local Text = Text(Fonts.ConsolaSmall)
            Text.Name = v[1]
            Text.Anchor = Vector2.y/2
            Text.Position = UDim2(0, 10, 0.5, 0)
            Text.ZIndex = 1000
            Text.Color = Text.Color:Lerp(ButtonColor, 0.2)
            Text:SetText(v[1])
            Text:SetParent(ButtonFrame)

            ButtonFrame.Size = UDim2(1, 0, 0, Text.Size.Y.Offset + 12)

            ButtonFrame:SetParent(Menu)

            FullSize.X = math.max(FullSize.X, Text.Size.X.Offset + 20)
            FullSize.Y = FullSize.Y + Text.Size.Y.Offset + 12
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
local Topbar = Frame()
Topbar.META.IsMoving = false
Topbar.Name = "Topbar"
Topbar.Position = UDim2(0, 0, 0, 0)
Topbar.Color = TopbarColor
Topbar.Size = UDim2(1, 0, 0, 30)
Topbar:SetLayout(ListLayout)

UI.Add(Topbar)

local Offset = 0
for i,v in pairs(Buttons) do
    local ButtonFrame = Frame()
    ButtonFrame.Name = v[1] .. "Button"
    ButtonFrame.Color = ButtonColor
    ButtonFrame.Opacity = 1
    ButtonFrame.LayoutOrder = i

    ButtonFrame:Connect("Hover", function(IsHovering)
        ButtonFrame.Opacity = IsHovering and 0 or 1
    end)

    local Text = Text(Fonts.ConsolaSmall)
    Text.Name = v[1]
    Text.Position = UDim2(.5, 0, .55, 0)
    Text.Anchor = Vector2.one/2
    Text.ZIndex = 10
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