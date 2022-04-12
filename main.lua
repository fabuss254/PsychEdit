--[[
    Title: PsychEngine Modchart Editor
    Author: Fabuss254
    Repo: https://github.com/fabuss254/PsychEngine-Modchart-Editor
    Description: A easy to use modchart editor for psych engine.
--]]

-- Basic classes import
local Vector2 = require("src/classes/Vector2")
local Signal = require("src/classes/Signal")
local Color = require("src/classes/Color")

-- Basic lib import
local UI = require("src/libs/UIEngine")

-- Global overwrites
require("src/libs/Overwrite")

-- Global functions
function love.load()
    UIBuilder = require("src/libs/UIBuilder")
    print("MAIN", UIBuilder)

    for i,v in pairs(love.filesystem.getDirectoryItems("src/scripts")) do
        local FileName = string.sub(v, 1, #v-4)
        if FileName ~= "Topbar" then
            require("src/scripts/" .. FileName)
        end
    end
    require("src/scripts/Topbar")

    UI.Refresh()
end

function love.update(dt)
    UI.Update(dt)
end

function love.draw()
    UI.Draw()

    Color.Green:Apply()
    love.graphics.printf("FPS:" .. love.timer.getFPS(), ScreenSize.X-110, 5, 100, "right")
end

function love.resize(w, h)
    ScreenSize = Vector2(w, h)
    for _,v in pairs(UI.UIs) do
        v.CachedData = false
        for _,g in pairs(v:GetDescendants()) do
            g.CachedData = false
        end
    end
end