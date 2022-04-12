-- Made by fabuss254 for PsychEdit
-- The goal is to make a roblox like UI system

-- LIBS
local ErrorMessage = require("src/libs/ErrorMessage")
local Color = require("src/classes/Color")

-- MODULE
local Module = {}
local GlobalID = 1
Module.Pool = {}
Module.UIs = {}
local ZIndexMenu = 0

-- PRIVATE FUNCTIONS
local function SortPool()
    table.sort(Module.Pool, function(a, b)
        return a.ZIndex < b.ZIndex
    end)
end

-- FUNCTIONS
function Module.Add(Obj, ZIndex)
    if not Obj then error("Missing object argument") end
    if not Obj.Draw then error("Object isn't drawable") end
    ZIndex = ZIndex or rawget(Obj, "ZIndex") or 0
    rawset(Obj, "UIID", GlobalID)

    table.insert(Module.Pool, {Obj = Obj, ZIndex = ZIndex})
    SortPool()

    GlobalID = GlobalID + 1
end

function Module.Rem(Obj)
    if not Obj then error("Missing object argument") end
    if not rawget(Obj, "UIID") then error("Object wasn't added beforehand") end

    for i,v in pairs(Module.Pool) do
        if v.UIID == Obj.UIID then
            rawset(v.UIID, nil)
            table.remove(Module.Pool, i)
            return
        end
    end
end

function Module.RegisterUI(UIName, UI)
    Module.UIs[UIName] = UI
    local function ManageZIndex(Childs)
        for _,v in pairs(Childs) do
            v.ZIndex = v.ZIndex + ZIndexMenu*1000
            ManageZIndex(v:GetChildren())
        end
    end

    ManageZIndex({UI})
    ZIndexMenu = ZIndexMenu + 1
    UI.Visible = false
end

function Module.ReloadZIndexes()
    for _,v in pairs(Module.Pool) do
        if v.Obj.ZIndex ~= v.ZIndex then
            v.ZIndex = v.Obj.ZIndex
        end
    end

    return SortPool()
end

function Module.IsAdded(Obj)
    return rawget(Obj, "UIID")
end

function Module.Update(dt)
    for _,v in pairs(Module.Pool) do
        if v.Obj:IsVisible() and v.Obj.class["Update"] then
            v.Obj:Update(dt)
        end
    end
end

function Module.Draw()
    --[[
    local function DrawChild(Childs)
        for _,v in pairs(Childs) do
            if v.Visible then
                v:Draw()
                DrawChild(v:GetChildren())
            end
        end
    end

    for _,v in pairs(Module.Pool) do
        DrawChild({v.Obj})
    end
    ]]
    for _,v in pairs(Module.Pool) do
        if v.Obj:IsVisible() then
            v.Obj:Draw()
        end
    end
end

function Module.MouseClickEvent(bool)
    for i=#Module.Pool, 1, -1 do
        local v = Module.Pool[i].Obj

        if v._Connections["MouseClick"] and v:IsVisible() and v:IsHovering() then
            return v._Connections["MouseClick"](v:DoReturnSelf(bool))
        end
    end
end

-- RUNNER
function love.mousepressed()
    Module.MouseClickEvent(true)
end

function love.mousereleased()
    Module.MouseClickEvent(false)
end

-- EXPORT
Color.FromRGB(54, 63, 77):Lerp(Color.Black, 0.2):ApplyBackground()--:Lerp(Color.Black, 0.5):ApplyBackground()
return setmetatable(Module, {
    __newindex = function(self, index, value)
        return error(ErrorMessage.NewIndexLocked:format(index))
    end
})