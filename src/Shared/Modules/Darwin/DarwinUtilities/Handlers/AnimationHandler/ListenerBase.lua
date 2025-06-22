local animationHandler = script.Parent

local signalHandler = require(animationHandler.SignalHandler)

local Base = {}

function Base:Connect(character : Model, func : (animation : Animation, animationTrack : AnimationTrack) -> ()) : RBXScriptConnection
	return signalHandler:Connect("Listener", character, func)
end

function Base:Once(character : Model, func : (animation : Animation, animationTrack : AnimationTrack) -> ()) : RBXScriptConnection
	return signalHandler:Once("Listener", character, func)
end

return Base
