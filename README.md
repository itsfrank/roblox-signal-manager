# Roblox SignalManager
Managing remote events and remote functions on Roblox is kind of tedious, I made this module to help out

## The Problem
Remote event and functions are just that: functions! I don't want to have to manage storing, organizing and finding them in multiple scripts.

This pattern specifically was really annoying me:

```lua
-------------------
-- ServerScript.lua
-------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Print a string on the server
local printStringOnServer = Instance.new("RemoteEvent", ReplicatedStorage) -- boilerplate (grows with # of signals)
printStringOnServer.Name = "PrintStringOnServer" -- boilerplate (grows with # of signals)

local function onPrintStringOnServer(player, string) -- the actual valuable code
	print(string)
end

printStringOnServer.OnServerInvoke = onPrintStringOnServer -- boilerplate (grows with # of signals)

-------------------
-- ClientScript.lua
-------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local printStringOnServerRequest = ReplicatedStorage:WaitForChild("PrintStringOnServer") -- boilerplate (grows with # of signals)

printStringOnServerRequest:InvokeServer("Hello, tedious boilerplate") -- the actual valuable code
```

All this boilerplate is required for every single signal you add! You can imagine as a game scales, this boilerplate will start taking a ton of space, make code less readable and generally be annoying. Instead, I would rather just define a function on the server, and call it on the client.

## My Solution
Enter SignalManager

### Reduced, and constant boilerplate regardless of how many signals you have
```lua
-------------------
-- ServerScript.lua
-------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalManager = require(ReplicatedStorage.SignalManager)

-- Instantiate one single signal manager
local MySingalManager = SignalManager:new("MySingalManager", SignalManager.EventType.RemoteEvent) -- boilerplate (does not grow with # of signals)

-- Print a string on the server
MySingalManager.PrintStringOnServer = function(player, string) -- valuable code
	print(string)
end

-- Print 2 strings on the server
MySingalManager.PrintTwoStringsOnServer = function(player, string1, string1) -- valuable code
	print(string1 .. string2)
end

-------------------
-- ClientScript.lua
-------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalManager = require(ReplicatedStorage.SignalManager)

-- Instantiate one single signal manager
local MySingalManager = SignalManager:new("MySingalManager") -- boilerplate (does not grow with # of signals)

MySingalManager.PrintStringOnServer:InvokeServer("Hello, less tedious boilerplate") -- valuable code
MySingalManager.PrintTwoStringsOnServer:InvokeServer("Hello, ", "less tedious boilerplate") -- valuable code
```

### Free Organization

SignalManager also organizes your signals into folders under ReplicatedStorage, hidden away for free:

```
ReplicatedStorage
│
└─── Signals
    │
    └─── SomeSignalManager
    │   |    CoolRemoteSignal
    │   |    AlsoCoolRemoteSignal
    │   
    └─── AnOtherSignalManager
        |    CoolRemoteSignal
        |    AlsoCoolRemoteSignal
```

### Free nil protection
The signal manager takes care of calling `WaitForChild("RemoteSignal")` the first time you try and access a signal on the client, but it then stores it internally so subsequent accesses are faster.

## Free namespace management
It prevents the re-registering of the same signal and allows you to have two remote signals have the same name in different contexes for free. This can significantly shorten the remote signal names. E.g.:
```lua
-------------------
-- ClientScript.lua
-------------------
local PlayerSignals = SignalManager:new("PlayerSignals")
local MonsterSignals = SignalManager:new("MonsterSignals")

PlayerSignals.SetState:InvokeServer(somePlayerState)
MonsterSignals.SetState:InvokeServer(someMonsterState)
```
