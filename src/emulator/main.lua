local Sprite = require("src.classes.emulator.Sprite")

local Module = {}

-- // PROPERTIES

Module.CurrentProject = nil
Module.Selected = {
    Stage = nil,
    Song = nil,
    Difficulty = nil,
    Character1 = nil,
    Character2 = nil,
    Icon1 = nil,
    Icon2 = nil,
}

-- // FUNCTIONS

function Module.LoadProject(ProjectPath)

end

-- // BASIC EVENTS

function Module.Load()
    local Arrow = Sprite("assets/spritesheets/Note_assets")
end

function Module.Update()

end

return Module