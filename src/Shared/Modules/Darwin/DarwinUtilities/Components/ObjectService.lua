local components = script.Parent

local darwinUtils = components.Parent

local types = require(darwinUtils.Types)

local Service = {}

function Service:CheckHasProperty(instance : Instance, propertyName : types.Properties) : boolean
	local success : boolean, _ = pcall(function() 
		instance[propertyName] = instance[propertyName]
	end)
	
	return success
end

return Service
