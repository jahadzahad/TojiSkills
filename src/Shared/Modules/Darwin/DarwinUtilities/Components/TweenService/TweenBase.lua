local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService('StarterGui')
local RunService = game:GetService('RunService')
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local componentsFolder = script.Parent.Parent

local darwinUtilsModule = componentsFolder.Parent

local darwinModules = darwinUtilsModule.Parent

local generalUtils = darwinModules.Utilities

local threadHandler = require(generalUtils.ThreadHandler)
local types = require(script.Parent.Types)
local signal = require(generalUtils.Signal)
local lerp = require(componentsFolder.Lerp)

export type TweenConfiguration = types.TweenConfiguration
export type TweenBase = types.TweenBase
export type TweenValues = types.TweenValues
export type TweenData = types.TweenData
export type StoredBase = types.StoredBase

local storedSignal : typeof(signal.new()) = signal.new()
local storedData : TweenData = {}
local storedBase : {[any] : {}} = {}

local TweenBase = {}
local TweenConstructor = {}

TweenConstructor.New = function(tweenData : TweenData)
	storedData = tweenData
end

TweenBase.Completed = storedSignal

function TweenBase:Play()
	if storedData == nil then return end
	
	if storedBase[storedData.Base] == nil then
		storedBase[storedData.Base] = {}
	end

	if storedBase[storedData.Base].Active == true then
		if storedBase[storedData.Base].Thread ~= nil then
			task.cancel(storedBase[storedData.Base].Thread)
			storedBase[storedData.Base].Thread = nil
		end
		if storedBase[storedData.Base].Connection ~= nil then
			storedBase[storedData.Base].Connection:Disconnect()
			storedBase[storedData.Base].Connection = nil
		end
	end

	storedBase[storedData.Base].Active = true

	local easingStyle = storedData.TweenInfo.EasingStyle
	local easingDirection = storedData.TweenInfo.EasingDirection
	local elapsed = 0
	local duration = storedData.TweenInfo.Time
	local tweenConfiguration = storedData.TweenConfiguration

	local connection : RBXScriptConnection 
	connection = RunService.Heartbeat:Connect(function(deltaTime : number)
		elapsed = math.min(elapsed + deltaTime, duration)
		local alpha = elapsed / duration
		local tween = TweenService:GetValue(alpha,easingStyle, easingDirection)
		local targetValue = {}

		for index : string, variable : {number | CFrame | Vector3} in tweenConfiguration do
			if storedData.Base[index] == nil then continue end
			
			if typeof(variable) == "table" then
				for key : number, value : number | CFrame | Vector3 in variable do
					if tweenConfiguration.TargetValues[index] == nil or tweenConfiguration.TargetValues[index][key] == nil then
						warn("Needs a target value.")
						continue
					end

					if targetValue[index] == nil then
						targetValue[index] = {}
					end

					storedData.Base[index] = value + (tweenConfiguration.TargetValues[index][key]  - value) * tween 
				end
			elseif typeof(variable) == "number" or typeof(variable) == "CFrame" or  typeof(variable) == "Vector3" then
				targetValue[index] = variable + (tweenConfiguration.TargetValues[index] - variable) * tween 
			elseif typeof(variable) == "NumberSequence" or typeof(variable) == "ColorSequence" then
				targetValue[index] = TweenSequence(variable, tweenConfiguration.TargetValues[index], tween)
				
			else
				targetValue[index] = variable + (tweenConfiguration.TargetValues[index] - variable) * tween 
			end
		end
	end)

	storedBase[storedData.Base].Connection = connection

	local thread : thread = task.delay(duration, function()
		storedBase[storedData.Base].Thread = nil
		if connection ~= nil then
			connection:Disconnect()
			storedBase[storedData.Base].Connection = nil
		end
		storedSignal.Completed:Fire()
		storedBase[storedData.Base].Active = false
	end)

	storedBase[storedData.Base].Thread = thread
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

return TweenBase, TweenConstructor
