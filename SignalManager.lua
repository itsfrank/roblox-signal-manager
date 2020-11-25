-- services
local ReplicatedStorage = game:WaitForChild("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SignalManager = {}

SignalManager.SignalType = {
	RemoteFunction = 1,
	RemoteEvent = 2
}

-- lazy loaded, server create SignalManager container folder
if RunService:IsServer() then
	local SignalsFolder = Instance.new("Folder", ReplicatedStorage)
	SignalsFolder.Name = "Signals"
end

function SignalManager:new(name, eventType)
	if RunService:IsServer() then
		if ReplicatedStorage.Signals:FindFirstChild(name) then
			error("SignalManager with name " .. name .. " already exists")
		end
		
		if eventType ~= SignalManager.SignalType.RemoteFunction and eventType ~= SignalManager.SignalType.RemoteEvent then
			error("Unsuported event type")
		end
		
		local SignalManagerFolder = Instance.new("Folder", ReplicatedStorage.Signals)
		SignalManagerFolder.Name = name
	end
	
	local newSignalManager = {
		_eventType = eventType,
		_loadedSignals = {},
		_signalFolder = ReplicatedStorage:WaitForChild("Signals"):WaitForChild(name)
	}

	return setmetatable(newSignalManager, self)
end

function SignalManager.__index(table, key)
	if table._loadedSignals[key] then
		return table._signalFolder[key]
	else
		table._loadedSignals[key] = table._signalFolder:WaitForChild(key)
		return table._loadedSignals[key]
	end
end

function SignalManager.__newindex(table, key, value)
	if RunService:IsClient() then
		error("Client should not be adding new indices to SignalManager")
	end
	
	if table._loadedSignals[key] then
		error("Signal with name " .. key .. "already exists")
	end
	
	local signal
	if table._eventType == SignalManager.SignalType.RemoteFunction then
		signal = Instance.new("RemoteFunction", table._signalFolder)
	elseif table._eventType == SignalManager.SignalType.RemoteEvent then
		signal = Instance.new("RemoteEvent", table._signalFolder)
	end

	table._loadedSignals[key] = true
	signal.Name = key
	signal.OnServerInvoke = value
end

return SignalManager
