-- Made by fabuss254 for PsychEdit
-- The goal is to make a roblox like UI system

-- LIBS
local ErrorMessage = require("src/libs/ErrorMessage")

-- MODULE
local Module = {}
local GlobalID = 1
Module.Pool = {}

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

function Module.IsAdded(Obj)
    return rawget(Obj, "UIID")
end

function Module.Update(dt)
    for _,v in pairs(Module.Pool) do
        if rawget(v.Obj.class, "Update") then
            v.Obj:Update(dt)
        end
    end
end

function Module.Draw()
    for _,v in pairs(Module.Pool) do
        v.Obj:Draw()
    end
end

-- EXPORT
return setmetatable(Module, {
    __newindex = function(self, index, value)
        return error(ErrorMessage.NewIndexLocked:format(index))
    end
})