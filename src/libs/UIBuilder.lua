-- This module is HEAVILY inspired off of Fusion, but only for simple UI building.
local Module = {}

-- Import and get all instances
function scanForFile(Directory, Out)
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
Module.Connect = function(Connection) return ("CONNECTINSTANCE " .. Connection) end

function Module.New(InstanceName)
    if not Module.Instances[InstanceName] then return error(("Unknown instance given '%s'"):format(InstanceName)) end

    local obj = Module.Instances[InstanceName]()
    return function(Props)
        local Childs = {}
        local Connections = {}
        for i,v in pairs(Props) do
            if i == Module.Children then
                Childs = v
            elseif type(i) == "string" and string.sub(i, 1, 15) == "CONNECTINSTANCE" then
                Connections[string.sub(i, 17, #i)] = v
            elseif obj.class["Set" .. i] then
                obj["Set" .. i](obj, v)
            else
                obj[i] = v
            end
        end

        local function RetrieveChilds(tbl, Out)
            local Out = Out or {}
            for _,v in pairs(tbl) do
                if type(v) == "table" and not v._type then
                    Out = RetrieveChilds(v, Out)
                else
                    table.insert(Out, v)
                end
            end
            return Out
        end

        for _,v in pairs(RetrieveChilds((type(Childs) ~= "table" and {Childs}) or Childs or {})) do
            v:SetParent(obj)
        end

        for i,v in pairs(Connections) do
            obj:Connect(i, v, true)
        end

        return obj
    end
end

function Module.List(tbl, proc)
    local out = {}
    for i,v in pairs(tbl) do
        table.insert(out, proc(i, v))
    end
    return out
end

return Module