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

-- Basic windows
local TabMenu = Tab({
    Title = "Game Viewport"
})
TabMenu.Menu:Ratio(16/9)

local InContent = New "Frame" {
    Size = UDim2(1, 0, 1, 0),
    
    ZIndex = 10,
}

InContent:SetParent(TabMenu.Content);

-- Export
UI.RegisterUI("Viewport", TabMenu.Menu)