-- This module is HEAVILY inspired off of Fusion, but only for simple UI building.
local Module = {}

-- Import and get all instances
local function scanForFile(Directory, Out)
    Out = Out or {}

    for _,v in pairs(love.filesystem.getDirectoryItems(Directory)) do
        local FileName = string.sub(v, 1, #v-4)
        local Ext = string.sub(v, #v-3, #v)

        if Ext == ".lua" then
            Out[FileName] = require(Directory .. "/" .. FileName)
        else
            Out = scanForFile(Directory .. "/" .. v, Out)
        end
    end

    return Out
end

Module.Instances = scanForFile("src/classes")

-- Tags
Module.Children = {}
Module.Exec = {}
Module.Connect = function(Connection) return ("CONNECTINSTANCE " .. Connection) end

function Module.New(InstanceName)
    if not Module.Instances[InstanceName] then return error(("Unknown instance given '%s'"):format(InstanceName)) end

    local obj = Module.Instances[InstanceName]()
    return function(Props)
        local Childs = {}
        local Connections = {}
        local Exec
        for i,v in pairs(Props) do
            if i == Module.Children then
                Childs = v
            elseif type(i) == "string" and string.sub(i, 1, 15) == "CONNECTINSTANCE" then
                Connections[string.sub(i, 17, #i)] = v
            elseif i == Module.Exec then
                Exec = v
            elseif obj.class["Set" .. i] then
                obj["Set" .. i](obj, v)
            else
                obj[i] = v
            end
        end

        local function RetrieveChilds(tbl, Out)
            local Out = Out or {}
            for _,v in pairs(tbl) do
                if type(v) == "table" then
                    if not v._type then
                        Out = RetrieveChilds(v, Out)
                    else
                        table.insert(Out, v)
                    end
                end
            end
            return Out
        end

        local Childs = (Childs.LayoutOrder and {Childs}) or RetrieveChilds((Childs or {}))
        for _,v in pairs(Childs) do
            if v.LayoutOrder then
                v:SetParent(obj)
            end
        end

        for i,v in pairs(Connections) do
            obj:Connect(i, v, true)
        end

        if Exec then
            Exec(obj)
        end

        return obj
    end
end

function Module.List(tbl, proc)
    if not tbl then return end

    local out = {}
    for i,v in pairs(tbl) do
        local ui = proc(i, v)
        if ui then
            table.insert(out, ui)
        end
    end
    return out
end

return Module