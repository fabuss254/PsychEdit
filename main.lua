--[[
    Title: PsychEngine Modchart Editor
    Author: Fabuss254
    Repo: https://github.com/fabuss254/PsychEngine-Modchart-Editor
    Description: A easy to use modchart editor for psych engine.
--]]

DEBUG_MODE = false

-- Basic classes import
local Vector2 = require("src/classes/Vector2")
local Signal = require("src/classes/Signal")
local Color = require("src/classes/Color")
local Delay = require("src/libs/Delay")

-- Basic lib import
local UI = require("src/libs/UIEngine")

-- Import FNF emulator
local Emulator = require("src/emulator/main")

-- Global overwrites
require("src/libs/Overwrite")

-- Global functions
function love.load()
    UIBuilder = require("src/libs/UIBuilder")

    for i,v in pairs(love.filesystem.getDirectoryItems("src/scripts")) do
        local FileName = string.sub(v, 1, #v-4)
        if FileName ~= "Topbar" then
            require("src/scripts/" .. FileName)
        end
    end
    require("src/scripts/Topbar")

    Emulator.Load()
    UI.Refresh()
end

function love.update(dt)
    Emulator.Update(dt)
    UI.Update(dt)
    Delay.StaticUpdate(dt)
    WheelDelta = 0
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

function love.keypressed(key, scancode, isRepeat)
    Emulator.Keypressed(key, scancode, isRepeat)

    if key == "f2" then
        DEBUG_MODE = not DEBUG_MODE
    end
end