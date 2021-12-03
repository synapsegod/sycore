---@type Directory
local Directory = Import(Package.."Directory.lua")
---@type Table
local Table = Import(Package.."Table.lua")

---@class Folder : Directory
local Class = setmetatable({}, Directory)
Class.Class = "Folder"
Class.__index = Class

function Class.new(path)
    Assert(type(path) == "string", "Incorrect path type")
    Assert(Directory:IsFolder(path), "Path must be a folder")

    local object = setmetatable({
        Path = path
    }, Class)

    return Table:Readonly(object)
end

function Class:GetAll(path)
    path = path or self.Path
    Assert(type(path) == "string", "Incorrect path type")

    return listfiles(path)
end

function Class:GetFolders(path)
    path = path or self.Path
    Assert(type(path) == "string", "Incorrect path type")

    local folders = {}

    for _, item in pairs (self:GetAll(path)) do
        if self:IsFolder(item) then
            table.insert(folders, item)
        end
    end

    return folders
end

function Class:GetFiles(path)
    path = path or self.Path
    Assert(type(path) == "string", "Incorrect path type")

    local files = {}

    for _, item in pairs (self:GetAll(path)) do
        if self:IsFile(item) then
            table.insert(files, item)
        end
    end

    return files
end

function Class:MakeFolder(name)
    local path = self.Path .. name
    makefolder(path)

    return Directory.new(path)
end

function Class:Remove()
    delfolder(self.Path)
end

return Class