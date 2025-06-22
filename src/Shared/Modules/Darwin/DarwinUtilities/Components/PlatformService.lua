local UserInputService = game:GetService("UserInputService")

local Component = {}

function Component:IsMobile()
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled then
		return true
	end

	return false
end

function Component:IsPC()
	if UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled then
		return true
	end

	return false
end

return Component
