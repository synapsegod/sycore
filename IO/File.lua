local Directory = Import(Package.."IO\\Directory.lua")
local Table = Import(Package.."Table.lua")

---@class File : Directory
local Class = setmetatable({}, Directory)
Class.Class = "File"
Class.DefaultOpening = {
    lua = function(fileObj)
        return loadfile(fileObj.Path)
    end,

    txt = function(fileObj)

    end
}
Class.__index = Class

---@return File
function Class.new(path)
    Assert(type(path) == "string", "Incorrect path type")
    Assert(Directory:IsFile(path), "Path must be a file")

    local object = setmetatable({
        Path = path
    }, Class)

    return Table:Readonly(object)
end

function Class:GetFileType()
    return string.match(self.Path, "^.+(%..+)$") --.lua
end

function Class:Read()
    return readfile(self.Path)
end

function Class:Write(content)
    Assert(type(content) == "string", "Incorrect content type")

    writefile(self.Path, content)
end

function Class:Append(content)
    Assert(type(content) == "string", "Incorrect content type")

    appendfile(self.Path, content)
end

function Class:Open()
    return self.DefaultOpening[self:GetName()](self)
end

function Class:Load()
    return loadfile(self.Path)
end

function Class:Remove()
    delfile(self.Path)
end

return Class