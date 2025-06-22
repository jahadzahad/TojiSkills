local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService('StarterGui')
local RunService = game:GetService('RunService')
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local darwinModules = script.Parent
local handlers = script.Handlers

local generalUtils = darwinModules.Utilities
local componentFolder = script.Components

local threadHandler = require(generalUtils.ThreadHandler)
local signal = require(generalUtils.Signal)
local types = require(script.Types)

-- components --
local lerpComponent = require(componentFolder.Lerp)
local mouseComponent = require(componentFolder.Mouse)
local directionComponent = require(componentFolder.Direction)

export type DirectionOptions = types.DirectionOptions
export type GetDirectionConfig = types.GetDirectionConfig
export type MouseResult = types.MouseResult
export type HeadTrackParams = types.HeadTrackParams
export type CallBackTweenFov = types.CallBackTweenFov
export type TweenInfosFov = types.TweenInfosFov
export type FovProperties = types.FovProperties

local DarwinUtilities = {}

DarwinUtilities.AnimationHandler = require(handlers.AnimationHandler)
DarwinUtilities.SoundService = require(componentFolder.SoundService)
DarwinUtilities.TweenService = require(componentFolder.TweenService)
DarwinUtilities.VFXService = require(componentFolder.VFXService)
DarwinUtilities.CoreGuiService = require(componentFolder.CoreGuiService)
DarwinUtilities.CameraService = require(componentFolder.CameraService)
DarwinUtilities.PlatformService = require(componentFolder.PlatformService)
DarwinUtilities.RagdollHandler = require(handlers.RagdollHandler)
DarwinUtilities.ObjectService = require(componentFolder.ObjectService)
DarwinUtilities.ThreadHandler = require(handlers.ThreadHandler)

function DarwinUtilities:Lerp(start : number, target : number, alpha : number) : number
	return lerpComponent(start, target, alpha)
end

function DarwinUtilities:GetMouse(rayDistance : number?, raycastParams : RaycastParams?) : MouseResult
	return mouseComponent(rayDistance, raycastParams)
end

function DarwinUtilities:GetDirection(root : BasePart, position : Vector3, config : GetDirectionConfig?) : DirectionOptions
	return directionComponent(root, position, config)
end

return DarwinUtilities
