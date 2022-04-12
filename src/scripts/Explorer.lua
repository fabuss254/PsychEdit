-- Libs
local Vector2 = require("src/classes/Vector2")
local UDim2 = require("src/classes/UDim2")
local Color = require("src/classes/Color")
local Frame = require("src/classes/Frame")
local Image = require("src/classes/Image")
local Text = require("src/classes/Text")
local Tab = require("src/classes/advanced/Tab")

local ListLayout = require("src/classes/layout/ListLayout")

local Fonts = require("src/libs/Fonts")
local UI = require("src/libs/UIEngine")

-- Basic windows
local TabMenu = Tab({
    Title = "Explorer"
})

-- Export
UI.RegisterUI("Explorer", TabMenu.Menu)