local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local components = script.Parent
local camera : Camera = workspace.CurrentCamera

local darwinUtils = components.Parent

local types = require(darwinUtils.Types)

export type HeadTrackParams = types.HeadTrackParams
export type CallBackTweenFov = types.CallBackTweenFov
export type TweenInfosFov = types.TweenInfosFov
export type FovProperties = types.FovProperties

local headtrackConfig : {
	["EndTime"] : number,
	["Thread"] : thread,
	["Connection"] : RBXScriptConnection,
	["Offset"] : Vector3?,
	["Original"] : Vector3,
} = {}

local CameraService = {}

function CameraService:HeadTrack(duration : number?, params : HeadTrackParams?)
	local player : Player = Players.LocalPlayer
	local character : Model = player.Character or player.CharacterAdded:Wait()

	local humanoid : Humanoid = character:FindFirstChildOfClass("Humanoid")

	local originOffset : Vector3 = Vector3.new(0, -0.05, 0)
	local targetOffset : Vector3 = Vector3.new(0,-1,0)

	if params ~= nil then
		if params.OriginOffset ~= nil then
			originOffset = params.OriginOffset
		end

		if params.TargetOffset ~= nil then
			targetOffset = params.TargetOffset
		end
	end

	if humanoid == nil then
		humanoid = character:WaitForChild("Humanoid")
	end

	if headtrackConfig.Offset == nil then
		headtrackConfig.Offset = Vector3.zero
	end

	if params ~= nil then
		if params.Condition ~= nil then
			if params.Condition == "Start" then

				if params.Override == true then
					if headtrackConfig.Thread ~= nil then
						pcall(task.cancel, headtrackConfig.Thread)
					end

					if headtrackConfig.Connection ~= nil then
						headtrackConfig.Connection:Disconnect()
						headtrackConfig.Connection = nil
					end
				end

				headtrackConfig.Connection = RunService.RenderStepped:Connect(function(deltaTime : number)		
					headtrackConfig.Offset = headtrackConfig.Offset:Lerp(
						(character:GetPivot() + originOffset
						):PointToObjectSpace(character.Head.Position + targetOffset), deltaTime * 10
					)

					humanoid.CameraOffset = headtrackConfig.Offset
				end)

				humanoid.CameraOffset = headtrackConfig.Offset

			elseif params.Condition == "End" then

				if not params.Override  then
					if headtrackConfig.EndTime ~= nil then
						if workspace:GetServerTimeNow() < headtrackConfig.EndTime then return end
					end
				end

				if headtrackConfig.Thread ~= nil then
					pcall(task.cancel, headtrackConfig.Thread)
				end

				if headtrackConfig.Connection ~= nil then
					headtrackConfig.Connection:Disconnect()
					headtrackConfig.Connection = nil
				end
				
				local targetOffset : Vector3 = Vector3.zero
				local duration : number = 0.25
				local startTime : number = os.clock()

				while RunService.RenderStepped:Wait() do
					local currentTime : number = os.clock()
					local elapsed : number = currentTime - startTime
					local alpha : number = math.min(elapsed / duration, 1)

					headtrackConfig.Offset = headtrackConfig.Offset:Lerp(targetOffset, alpha)
					humanoid.CameraOffset = headtrackConfig.Offset

					if alpha >= 1 then
						break 
					end
				end
			end
			return
		end
	end

	if duration ~= nil then
		local endTime : number = workspace:GetServerTimeNow() + duration

		if headtrackConfig.EndTime ~= nil then
			if headtrackConfig.EndTime > endTime then return end
		end

		if headtrackConfig.Thread ~= nil then
			pcall(task.cancel, headtrackConfig.Thread)
		end

		if headtrackConfig.Connection ~= nil then
			headtrackConfig.Connection:Disconnect()
			headtrackConfig.Connection = nil
		end

		headtrackConfig.EndTime = endTime
		headtrackConfig.Connection = RunService.RenderStepped:Connect(function(deltaTime : number)
			headtrackConfig.Offset = headtrackConfig.Offset:Lerp(
				(character:GetPivot() + originOffset
				):PointToObjectSpace(character.Head.Position + targetOffset), deltaTime * 10
			)

			humanoid.CameraOffset = headtrackConfig.Offset
		end)

		headtrackConfig.Thread = task.delay(duration, function()
			if headtrackConfig.EndTime ~= endTime then return end

			if headtrackConfig.Connection ~= nil then
				headtrackConfig.Connection:Disconnect()
				headtrackConfig.Connection = nil
			end

			local targetOffset : Vector3 = Vector3.zero
			local duration : number = 0.25
			local startTime : number = os.clock()

			while RunService.RenderStepped:Wait() do
				local currentTime : number = os.clock()
				local elapsed : number = currentTime - startTime
				local alpha : number = math.min(elapsed / duration, 1)

				headtrackConfig.Offset = headtrackConfig.Offset:Lerp(targetOffset, alpha)
				humanoid.CameraOffset = headtrackConfig.Offset

				if alpha >= 1 then
					break 
				end
			end
		end)
	end
end

function CameraService:AdjustFOV(tweenInfoTable : TweenInfosFov, fov : FovProperties, duration : number) : CallBackTweenFov
	local tweenInfo : TweenInfo = tweenInfoTable.Start
	local tweenConfiguration = {FieldOfView = fov.Start}
	local tween : TweenBase = TweenService:Create(camera,tweenInfo,tweenConfiguration)
	tween:Play()
	
	local endTween : TweenBase
	
	task.delay(duration,function()
		tweenInfo = tweenInfoTable.End
		tweenConfiguration = {FieldOfView = fov.End}
		endTween  = TweenService:Create(camera,tweenInfo,tweenConfiguration)
		endTween:Play()
	end)

	return {Start = tween, End = endTween}
end

return CameraService
