local RunService = game:GetService("RunService")

---@class Threading
local Class = {
	_CLASS = "Threading"
}

---@param waittime number
---@return any
function Class:Wait(waittime)
	if not waittime or waittime == 0 then return RunService.Stepped:Wait() end

	while waittime > 0 do
		waittime = waittime - select(2, RunService.Stepped:Wait())
	end

	return true
end

---@param func function
function Class:Spawn(func)
	spawn(func)
end

return Class