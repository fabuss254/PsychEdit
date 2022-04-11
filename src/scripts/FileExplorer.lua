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

-- Basic windows
local TabMenu = Tab({
    Title = "File Explorer",
    Size = Vector2(600, 400),
    Position = Vector2(ScreenSize.X/2 - 300, ScreenSize.Y/2 - 200),
})

local DahContent = {
    -- Left
    New "Frame" {
        Color = TabMenu.Content.Color:Lerp(Color.Black, .25),
        Size = UDim2(0.3, 0, 1, 0),
        ZIndex = 20,
        [Children] = {
            
        }
    }
}

-- Add all ui to tab's content
for _,v in pairs(DahContent) do v:SetParent(TabMenu.Content) end

UI.Add(TabMenu.Menu)

-- Export
UI.RegisterUI("File Explorer", TabMenu.Menu)