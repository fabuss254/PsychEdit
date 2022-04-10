-- Libs
local Vector2 = require("src/classes/Vector2")
local UDim2 = require("src/classes/UDim2")
local Color = require("src/classes/Color")
local Frame = require("src/classes/Frame")

local UI = require("src/libs/UIEngine")

-- Properties
local TopbarColor = Color.FromRGB(54, 63, 77)
local ButtonColor = Color.FromRGB(79, 93, 112)

local Buttons = {
    "File",
    "Edit",
    "Help"
}

-- Methods
local Topbar = Frame()
Topbar.Name = "Topbar"
Topbar.Position = UDim2(0, 0, 0, 0)
Topbar.Color = TopbarColor
Topbar.Size = UDim2(1, 0, 0, 30)

Topbar:Connect("Hover", function(IsHovering)
    Topbar.Color = IsHovering and Color.Green or TopbarColor
end)

UI.Add(Topbar)

local Close = Image()
Close.Name = "CloseButton"
Close.Position = UDim2(1, 0, 0, 0)
print(Close.Position:ToVector2(Close, "Position"))
Close.Size = UDim2(0, 45, 1, 0)
Close.Anchor = Vector2.x
Close.Color = Color.Red
Close:Ratio(1)

Close:SetParent(Topbar)