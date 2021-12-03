---@type Object
local Object = Import(Package.."Object.lua")

---@class Directory : Object
local Class = setmetatable({}, Object)
Class.Class = "Directory"
Class.Path = ""
Class.__index = Class

---@return Directory
function Class.new(path)
    Assert(type(path) == "string", "Incorrect path type")

    if Class:IsFile(path) then
        return Import(Package.."IO\\File.lua").new(path)
    end

    if Class:IsFolder(path) then
        return Import(Package.."IO\\Folder.lua").new(path)
    end

    Assert(false, "Unknown path type")
end

function Class:GetName(path)
    path = path or self.Path

    Assert(type(path) == "string", "Incorrect path type")

    --"^.+(%..+)$" with .
    --"[^.]+$"     without .
    --"[^\\]+$"    filename.lua

    if self:IsFile(path) then
        local nameextension = string.match(path, "[^\\]+$")
        local ending = string.match(path, "^.+(%..+)$")

        return string.sub(nameextension, 1, string.len(nameextension) - string.len(ending))
    end

    --IsFolder

    local names = self:Split("\\", path)
    return names[#names]
end

function Class:Split(separator, path)
    separator = separator or "\\"
    path = path or self.Path

    Assert(type(separator) == "string", "Incorrect separator type")
    Assert(type(path) == "string", "Incorrect path type")

    local fields = {}

    for match in (path..separator):gmatch("(.-)"..separator) do
        table.insert(fields, match)
    end

    return fields
end

function Class:Join(separator, items)
    separator = separator or "\\"
    local path = ""

    for _, item in pairs (items) do
        path = path .. tostring(item)..separator
    end

    if self:IsFile(items[#items]) then
        return string.sub(path, 1, string.len(path) - 2) --remove \\ at the end if its a file
    end

    return path
end

function Class:GetParent(path)
    path = path or self.Path

    local split = self:Split("\\", path)
    if #split <= 1 then return "" end

    return split[#split -1]
end

function Class:IsFile(path)
    path = path or self.Path

    return isfile(path)
end

function Class:IsFolder(path)
    path = path or self.Path

    return isfolder(path)
end

return Class