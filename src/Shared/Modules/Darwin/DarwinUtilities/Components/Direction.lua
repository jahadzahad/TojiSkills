local components = script.Parent

local darwinUtil = components.Parent

local types = require(darwinUtil.Types)

export type DirectionOptions = types.DirectionOptions
export type GetDirectionConfig = types.GetDirectionConfig

return function(root : BasePart, position : Vector3, config : GetDirectionConfig?) : DirectionOptions?
	local forward = root.CFrame.LookVector
	local right = root.CFrame.RightVector
	local up = root.CFrame.UpVector

	if config ~= nil then
		if config.Offset ~= nil then
			forward = root.CFrame.LookVector * config.Offset
			right = root.CFrame.RightVector * config.Offset
			up = root.CFrame.UpVector * config.Offset
		end
	end

	local forwardDot : number = position:Dot(forward)
	local rightDot : number = position:Dot(right)
	local upDot : number = position:Dot(up)

	local threshold : number = 0.5

	local direction : DirectionOptions 

	if config ~= nil then
		if config.Threshold ~= nil then
			threshold = config.Threshold
		end
		
		if config.Diagonal == true then
			if forwardDot > threshold and rightDot > threshold then
				direction = "Forward-Right"
			elseif forwardDot > threshold and rightDot < -threshold then
				direction = "Forward-Left"
			elseif forwardDot < -threshold and rightDot > threshold then
				direction = "Backward-Right"
			elseif forwardDot < -threshold and rightDot < -threshold then
				direction = "Backward-Left"
			elseif forwardDot > threshold and upDot > threshold then
				direction = "Forward-Up"
			elseif forwardDot > threshold and upDot < -threshold then
				direction = "Forward-Down"
			elseif forwardDot < -threshold and upDot > threshold then
				direction = "Backward-Up"
			elseif forwardDot < -threshold and upDot < -threshold then
				direction = "Backward-Down"
			elseif rightDot > threshold and upDot > threshold then
				direction = "Right-Up"
			elseif rightDot > threshold and upDot < -threshold then
				direction = "Right-Down"
			elseif rightDot < -threshold and upDot > threshold then
				direction = "Left-Up"
			elseif rightDot < -threshold and upDot < -threshold then
				direction = "Left-Down"
			elseif forwardDot > threshold then
				direction = "Forward"
			elseif forwardDot < -threshold then
				direction = "Backward"
			elseif rightDot > threshold then
				direction = "Right"
			elseif rightDot < -threshold then
				direction = "Left"
			elseif upDot > threshold then
				direction = "Up"
			elseif upDot < -threshold then
				direction = "Down"
			end
			return direction
		end
	end

	if forwardDot > threshold then
		direction = "Forward"
	elseif forwardDot < -threshold then
		direction = "Backward"
	elseif rightDot > threshold then
		direction = "Right"
	elseif rightDot < -threshold then
		direction = "Left"
	elseif upDot > threshold then
		direction = "Up"
	elseif upDot < -threshold then
		direction = "Down"
	end

	return direction
end

