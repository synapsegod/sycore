Assert(pcall(function()
    loadfile("sycore\\Core.lua")
end))

---@type Event
local Event = Import(Package.."Event.lua")
---@type Directory
local Directory = Import(Package.."IO\\Directory.lua")
---@type Application
local Application = Import(Package.."Interface\\Application.lua")

---@class Explorer
local Class = setmetatable({}, Application)
Class.Class = "ExplorerApplication"
Class.Name = "Explorer"
Class.AllowMultiple = true
Class.ItemSelected = nil
Class.__index = Class

function Class.new(directory)   --directory optional
    if directory and Directory:IsFile(directory) then directory = Directory:GetParent(directory) end

    ---@type Application
    local app = setmetatable({}, Class)
    app.Directory = Directory.new(directory or Package)
    app.Data = {}
    app.ItemSelected = Event.new()
    app.Scroll = nil

    app:Open()

    local window = app:AttachWindow()

    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollingFrame.BackgroundTransparency = 1

    app.Scroll = scrollingFrame
    --TODO LAYOUT OF APP

    window:AddContent(scrollingFrame)

    app:Explore(app.Directory)

    return app
end

--[[
    local picker = Explorer.PickFile("MyDirectory\\Subdirectory\\") --or nil
    local onPicked = picker.ItemSelected:Connect(function(directoryObj)
        print(directoryObj.Path)
        if directoryObj:IsFile() then
            directoryObj:Open()
            picker:Close()
        end
    end)
]]
Class.PickFile = Class.new

function Class:Clear()
    table.clear(self.Data)

    for _, child in pairs (self.Scroll:GetChildren()) do
        if not child:IsA("UIGridStyleLayout") then
            child:Destroy()
        end
    end
end

function Class:Explore(directory) --<string || ? : Directory>
    directory = directory or self.Directory

    if type(directory) == "string" then
        directory = Directory.new(directory)
    end

    Assert(type(directory) == "table" and directory.Class == "Folder", "Incorrect parameter type")
    Assert(directory:IsFolder(), "Directory must be a folder")

    self:Clear()
    self.Directory = directory

    for _, dir in pairs (directory:GetAll()) do
        local subDirectory = Directory.new(dir)

        local button = Instance.new("TextButton")
        button.Name = dir
        button.Text = subDirectory:GetName()
        button.Size = UDim2.new(1, 0, 0, 20)
        button.Parent = self.Scroll

        table.insert(self.Data, subDirectory)

        local app = self
        button.Activated:Connect(function()
            app.ItemSelected:Fire(subDirectory)

            if subDirectory:IsFolder() then
                app:Explore(subDirectory)
            elseif subDirectory:IsFile() then
                subDirectory:Open()
            end
        end)
    end
end

function Class:Close()
    if self._closed then return end

    Application.Close(self)
    self.OnItemSelected:Disconnect()
end

return Class