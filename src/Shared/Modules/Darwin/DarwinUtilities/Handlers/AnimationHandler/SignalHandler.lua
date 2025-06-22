local animationHandler = script.Parent

local utils = animationHandler.Parent

local darwinUtil = utils.Parent

local darwinModules = darwinUtil.Parent

local generalUtil = darwinModules.Utilities

local signal = require(generalUtil.Signal)

local storedSignals : {signal.Signal} = {}

local Component = {}

Component.Setup = function()
	if storedSignals["Listener"] ~= nil then return end
	
	storedSignals["Listener"] = signal.new()
end

Component.New = function(name : string) : signal.Signal
	if storedSignals[name] then
		return storedSignals[name]
	end
	
	storedSignals[name] = signal.new()
	
	return storedSignals[name]
end

function Component:Connect(name : string, character : Model, func : (animation : Animation, animationTrack : AnimationTrack) -> ()) : RBXScriptConnection
	if storedSignals[name] == nil then return end
	
	local connection : RBXScriptConnection
	connection = storedSignals[name]:Connect(function(character : Model, ...)
		if character == nil then return end
		func(...)
	end)
	
	return connection
end

function Component:Once(name : string, character : Model, func : (animation : Animation, animationTrack : AnimationTrack) -> ()) : RBXScriptConnection
	if storedSignals[name] == nil then return end

	local connection : RBXScriptConnection
	connection = storedSignals[name]:Connect(function(character : Model, ...)
		if character == nil then return end
		connection:Disconnect()
		func(...)
	end)
	
	return connection
end

return Component
