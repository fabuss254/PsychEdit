-- Libs
local Vector2 = require("src/classes/Vector2")
local UDim2 = require("src/classes/UDim2")
local Color = require("src/classes/Color")
local Frame = require("src/classes/Frame")
local Image = require("src/classes/Image")

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

UI.Add(Topbar)

local Icons = {
    {Name = "close", Size = 0.6, OnClick = function()
        love.event.quit()
    end}, 
    {Name = "window", Size = 0.5, OnClick = function()
        love.window.maximize()
    end},
    {Name = "minimize", Size = 0.5, OnClick = function()
        love.window.minimize()
    end},
}


for i,v in pairs(Icons) do
    local ButtonFrame = Frame()
    ButtonFrame.Name = v.Name .. "Button"
    ButtonFrame.Position = UDim2(1, (i-1) * -45, 0, 0)
    ButtonFrame.Size = UDim2(0, 45, 1, 0)
    ButtonFrame.Anchor = Vector2.x
    ButtonFrame.Color = v.Name == "close" and Color.Red:Lerp(ButtonColor, 0.25) or ButtonColor
    ButtonFrame.Opacity = 1
    ButtonFrame:SetParent(Topbar)

    ButtonFrame:Connect("Hover", function(IsHovering)
        ButtonFrame.Opacity = IsHovering and 0 or 1
    end)

    ButtonFrame:Connect("MouseClicked", function(bool)
        if not bool then return end
        v.OnClick()
    end)

    local ButtonIcon = Image("/assets/images/icons/" .. v.Name .. "_icon.png", "linear")
    ButtonIcon.Name = v.Name .. "Icon"
    ButtonIcon.Position = UDim2(.5, 0, .5, 0)
    ButtonIcon.Size = UDim2(1, 0, v.Size, 0)
    ButtonIcon.Color = Color.FromRGB(200, 200, 200)
    ButtonIcon.Anchor = Vector2.one/2
    ButtonIcon:Ratio(1)
    ButtonIcon:SetParent(ButtonFrame)
end

