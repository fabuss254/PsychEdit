--[[
    Title: PsychEngine Modchart Editor
    Author: Fabuss254
    Repo: https://github.com/fabuss254/PsychEngine-Modchart-Editor
    Description: A easy to use modchart editor for psych engine.
--]]

love.graphics.setDefaultFilter('nearest', 'nearest')

function love.load()
    -- init something here ...
    love.window.setTitle('Hello love2d!')

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    -- ...
end

function love.update(dt) 
    
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    -- change some values based on your actions

    love.keyboard.keysPressed = {}
    print("UPDATE !")
end

function love.draw()
    -- draw your stuff here
    love.graphics.print('Welcome to the Love2d world!', 10, 10)
end

