local utils = script.Parent

local signal = require(utils.Signal)

export type Signal = typeof(require(utils.Signal).new())

local storedSignals = {}

local SignalHandler = {}

SignalHandler.New = function(name : string) : Signal
	if storedSignals[name] == nil then
		storedSignals[name] = signal.new()
	end
	
	return storedSignals[name]
end

return SignalHandler
