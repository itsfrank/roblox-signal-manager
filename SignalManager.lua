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

-- Parameters:
--	@name: 			name of the manager, it will also ne the name of the folder created under ReplicatedStorage.Signals
--	@eventType: 	[SERVER ONLY] type of signals created; options are EventType.RemoteFunction or EventType.RemoteEvent
--	@dontCreateNew: [SERVER ONLY] use this if you want to use the same SignalManager in two different server-side scripts.
--						All but one such instantiations should set this to true. This can also be used to place RemoteEvents
--						and RemoteFunctiosn under the same folder that can be accessed by one single SignalManager on the Client
function SignalManager:new(name, eventType, dontCreateNew)
	if RunService:IsServer() then
		if eventType ~= SignalManager.SignalType.RemoteFunction and eventType ~= SignalManager.SignalType.RemoteEvent then
			error("Unsuported event type")
		end
		
		if not dontCreateNew then
			if ReplicatedStorage.Signals:FindFirstChild(name) then
				error("SignalManager with name " .. name .. " already exists")
			end
			
			local SignalManagerFolder = Instance.new("Folder", ReplicatedStorage.Signals)
			SignalManagerFolder.Name = name
		end
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
		signal.OnServerInvoke = value
	elseif table._eventType == SignalManager.SignalType.RemoteEvent then
		signal = Instance.new("RemoteEvent", table._signalFolder)
		signal.OnServerEvent:Connect(value)
	end

	table._loadedSignals[key] = true
	signal.Name = key
end

return SignalManager
