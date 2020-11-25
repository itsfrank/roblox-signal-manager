# Roblox SignalManager
Managing remote events and remote functions on Roblox is kind of tedious, I made this module to help out

# The Idea
Remote event and functions are just that: functions! I don't want to have to manage storing, organizing and finding them in multiple scripts.

This pattern specifically was really annoying me:

```lua
-------------------
-- ServerScript.lua
-------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Print a string on the server
local printStringOnServer = Instance.new("RemoteEvent", ReplicatedStorage)
printStringOnServer.Name = "PrintStringOnServer"

local function onPrintStringOnServer(player, string)
	print(string)
end

printStringOnServer.OnServerInvoke = onPrintStringOnServer

-------------------
-- ClientScript.lua
-------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local printStringOnServerRequest = ReplicatedStorage:WaitForChild("PrintStringOnServer")

printStringOnServerRequest:InvokeServer("Hello, tedious boilerplate")
```

You can imagine as a game scales, this boilerplate will start taking a ton of space. Instead, I would rather just define a function on the server, and call it on the client. SignalManager Works like this:

```lua
-------------------
-- ServerScript.lua
-------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalManager = require(ReplicatedStorage.SignalManager)

-- Instantiate one single signal manager
local MySingalManager = SignalManager:new("MySingalManager", SignalManager.EventType.RemoteEvent) 

-- Print a string on the server
MySingalManager.PrintStringOnServer = function(player, string)
	print(string)
end

-- Print 2 strings on the server
MySingalManager.PrintTwoStringsOnServer = function(player, string1, string1)
	print(string1 .. string2)
end

-------------------
-- ClientScript.lua
-------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalManager = require(ReplicatedStorage.SignalManager)

-- Instantiate one single signal manager
local MySingalManager = SignalManager:new("MySingalManager") 

MySingalManager.PrintStringOnServer:InvokeServer("Hello, less tedious boilerplate")
MySingalManager.PrintTwoStringsOnServer:InvokeServer("Hello, ", "less tedious boilerplate")
```

Not only does this solution have constant boiler-plate instead of added boilerplate for every remote signal, it also organizes your signals as such:

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

# More bonus features
The signal manager takes care of calling `WaitForChild("RemoteSignal")` the first time you try and access a signal on the client, but it then stores it internally so subsequent accesses are faster.

It will also detect typos, or re-registering of the same signal. And it allows you to have two remote signals have the same name in different contexes without having to do the folder organization yourself.
