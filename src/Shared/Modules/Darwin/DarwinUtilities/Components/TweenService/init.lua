local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService('StarterGui')
local RunService = game:GetService('RunService')
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local componentsFolder = script.Parent

local darwinUtilsModule = componentsFolder.Parent

local darwinModules = darwinUtilsModule.Parent

local generalUtils = darwinModules.Utilities

local threadHandler = require(generalUtils.ThreadHandler)
local types = require(script.Types)
local signal = require(generalUtils.Signal)
local lerp = require(componentsFolder.Lerp)

export type TweenConfiguration = types.TweenConfiguration
export type TweenBase = types.TweenBase
export type TweenValues = types.TweenValues
export type Keypoint = types.Keypoint
export type Properties = types.Properties

local Component = {}

local stored = {}

--TweenService:Create(wind,tweenInfo,tweenConfiguration)

function Component:Create(base : any, tweenInfo : TweenInfo, tweeenConfiguration : TweenConfiguration) : TweenBase
	if base == nil then
		warn("Must define 'Base'.")
		return
	end
	
	local tweenConfiguration = {
		
	}
	
	local tweenBase, tweenConstructor = require(script.TweenBase)
	tweenConstructor.New(
		{
			Base = base,
			TweenInfo = TweenInfo,
			TweenConfiguration = tweeenConfiguration,
		}
	)
	
	return tweenBase
end

function Component:GetTweenValue(tweenData : TweenData, func : (tweenValues : {number | CFrame | Vector3}) -> ()) : TweenBase
	if tweenData.Base == nil then
		warn("Must define 'Base'.")
		return
	end

	if stored[tweenData.Base] == nil then
		stored[tweenData.Base] = {}
	end

	if stored[tweenData.Base].Active == true then
		if stored[tweenData.Base].Thread ~= nil then
			task.cancel(stored[tweenData.Base].Thread)
			stored[tweenData.Base].Thread = nil
		end
		if stored[tweenData.Base].Connection ~= nil then
			stored[tweenData.Base].Connection:Disconnect()
			stored[tweenData.Base].Connection = nil
		end
	end

	stored[tweenData.Base].Active = true

	local easingStyle = tweenData.TweenInfo.EasingStyle
	local easingDirection = tweenData.TweenInfo.EasingDirection
	local elapsed = 0
	local duration = tweenData.TweenInfo.Time
	local tweenConfiguration = tweenData.TweenConfiguration
	local tweenBase = {["Completed"] = signal.new()}

	local connection : RBXScriptConnection 
	connection = RunService.Heartbeat:Connect(function(deltaTime : number)
		elapsed = math.min(elapsed + deltaTime, duration)
		local alpha = elapsed / duration
		local tween = TweenService:GetValue(alpha,easingStyle, easingDirection)
		local targetValue = {}

		for index : string, variable : {number | CFrame | Vector3} in  tweenConfiguration.StartValues do
			if typeof(variable) == "table" then
				for key : number, value : number | CFrame | Vector3 in variable do
					if tweenConfiguration.TargetValues[index] == nil or tweenConfiguration.TargetValues[index][key] == nil then
						warn("Needs a target value.")
						continue
					end

					if targetValue[index] == nil then
						targetValue[index] = {}
					end

					targetValue[index][key] = value + (tweenConfiguration.TargetValues[index][key]  - value) * tween 
				end
			elseif typeof(variable) == "number" or typeof(variable) == "CFrame" or  typeof(variable) == "Vector3" then
				targetValue[index] = variable + (tweenConfiguration.TargetValues[index] - variable) * tween 
			elseif typeof(variable) == "NumberSequence" or typeof(variable) == "ColorSequence" then
				targetValue[index] = TweenSequence(variable, tweenConfiguration.TargetValues[index], tween)
			else
				targetValue[index] = variable + (tweenConfiguration.TargetValues[index] - variable) * tween 
			end

		end
		func(targetValue)
	end)

	stored[tweenData.Base].Connection = connection

	local thread : thread = task.delay(duration, function()
		stored[tweenData.Base].Thread = nil
		if connection ~= nil then
			connection:Disconnect()
			stored[tweenData.Base].Connection = nil
		end
		tweenBase.Completed:Fire()
		stored[tweenData.Base].Active = false
	end)

	stored[tweenData.Base].Thread = thread :: thread

	return tweenBase
end

function TweenSequence(start : NumberSequence | ColorSequence, target : NumberSequence | ColorSequence, tweenAlpha : number)
	local sequence : NumberSequence | ColorSequence
	local holder : {NumberSequenceKeypoint} = {}

	for key : number, keypoint : Keypoint in target.Keypoints do
		local value : number = keypoint.Value
		if start.Keypoints[key] ~= nil then
			value = lerp(start.Keypoints[key].Value, keypoint.Value, tweenAlpha)
		end

		table.insert(holder, key, NumberSequenceKeypoint.new(keypoint.Time,value))
	end

	sequence = NumberSequence.new(holder)

	return sequence
end

return Component
