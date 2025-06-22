local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local components = script.Parent

local darwinUtils = components.Parent

local types = require(darwinUtils.Types)

export type CoreCallMethod = types.CoreCallMethods
export type CoreGuiType = types.CoreGuiType

local CoreGuiService = {}

function CoreGuiService:CoreCall(method : CoreCallMethod, coreGuiType : Enum.CoreGuiType | CoreGuiType, ... : A...)
	local MAX_RETRIES = 8
	local result = {}
	for retries = 1, MAX_RETRIES do
		result = {pcall(StarterGui[method], StarterGui, coreGuiType, ...)}
		if result[1] then
			break
		end
		RunService.Stepped:Wait()
	end
	return unpack(result)
end

return CoreGuiService
