-- Made by fabuss254 for PsychEdit
-- The goal is to make a roblox like UI system

-- LIBS
local ErrorMessage = require("src/libs/ErrorMessage")
local Color = require("src/classes/Color")

-- MODULE
local Module = {}

Module.UIs = {}
Module.DrawMap = false
Module.UpdateMap = false

local ZIndexMenu = 0

-- PRIVATE FUNCTIONS
local function SortPool(tbl)
    table.sort(tbl, function(a, b)
        return a.ZIndex < b.ZIndex
    end)
    return tbl
end

-- FUNCTIONS
--[[
function Module.Add(Obj, ZIndex)
    if not Obj then error("Missing object argument") end
    if not Obj.Draw then error("Object isn't drawable") end
    rawset(Obj, "UIID", GlobalID)

    table.insert(Module.Pool, Obj = Obj)
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
    return print(("WARNING: Couldn't get object %s inside UI pool"):format(Obj.UIID))
end
]]

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
    UI.Visible = UIName == "Topbar"
end

function Module.Refresh()
    Module.DrawMap = false
    Module.UpdateMap = false
end

function Module.IsAdded(Obj)
    return rawget(Obj, "UIID")
end

function Module.GetDrawingMap(UI, UnsortedMap, NoFirst)
    UnsortedMap = UnsortedMap or {Update = {}, Draw = {}}
    for _,v in pairs(UI) do
        if v.Visible then
            UnsortedMap.Draw[#UnsortedMap.Draw+1] = v
            if v.class["Update"] then
                UnsortedMap.Update[v.Id] = true
            end

            UnsortedMap = Module.GetDrawingMap(v:GetChildren(), UnsortedMap, true)
        end
    end

    if not NoFirst then
        local SortedUpdateMax = 1
        local SortedUpdateMap = {} -- Do not sort with table.sort, but copy draw map's sorting
        local SortedDrawMap = SortPool(UnsortedMap.Draw)

        for _,v in ipairs(SortedDrawMap) do
            if UnsortedMap.Update[v.Id] then
                SortedUpdateMap[SortedUpdateMax] = v
                SortedUpdateMax = SortedUpdateMax + 1
            end
        end

        return SortedDrawMap, SortedUpdateMap
    else
        return UnsortedMap
    end
end

function Module.Update(dt)
    if not Module.DrawMap or not Module.UpdateMap then
        Module.DrawMap, Module.UpdateMap = Module.GetDrawingMap(Module.UIs)
    end

    for _,v in ipairs(Module.UpdateMap) do
        v:Update(dt)
    end
end

function Module.Draw()
    for _,v in ipairs(Module.DrawMap) do
        v:Draw()
    end
end

function Module.MouseClickEvent(bool)
    for i=#Module.UpdateMap, 1, -1 do
        local v = Module.UpdateMap[i]

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