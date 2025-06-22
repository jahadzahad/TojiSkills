local UserInputService = game:GetService("UserInputService")

local components = script.Parent

local darwinUtils = components.Parent

local types = require(darwinUtils.Types)

export type MouseResult = types.MouseResult

return function(rayDistance : number?, raycastParams : RaycastParams?) : MouseResult
	local camera : Camera = workspace.CurrentCamera 
	local mouse : Vector2  = UserInputService:GetMouseLocation()
	local viewportRay : Ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
	local rayDistance = rayDistance or 100

	local result : RaycastResult = workspace:Raycast(viewportRay.Origin, viewportRay.Direction * rayDistance, raycastParams)

	local mouseResult : MouseResult = {
		Hit = nil,
		Target = result
	}

	if result == nil then
		local position = viewportRay.Origin + viewportRay.Direction * rayDistance
		mouseResult.Hit = CFrame.lookAt(
			position,
			position + viewportRay.Direction
		)
	else
		local position : Vector3 = result.Position
		mouseResult.Hit = CFrame.lookAt(position, position + result.Normal)
	end
	return mouseResult
end