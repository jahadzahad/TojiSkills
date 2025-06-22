local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local signalHandler = require(script.SignalHandler)

type animationHolderType = {
	Animator : Animator,
	AnimationTracks : {AnimationTrack},
}

signalHandler.Setup()

local animationHolder : animationHolderType = {}
local playingAnimations : {[string] : AnimationTrack} = {}

local AnimationHandler = {}

AnimationHandler.Init = function(character : Model)
	if animationHolder[character] == nil then
		animationHolder[character] = {}
	else
		return
	end
	animationHolder[character].Animator = character:FindFirstChildWhichIsA("Animator", true)
	animationHolder[character].AnimationTracks = {}
end

AnimationHandler.NewTrackPlaying = require(script.ListenerBase)

function AnimationHandler:AdjustWeight(character : Model, animation : Animation, weight : number?, fadeTime : number?)
	local storedAnimationTracks = animationHolder[character].AnimationTracks
	local animationTrack : AnimationTrack = storedAnimationTracks[animation.AnimationId]

	if animationTrack == nil then return end

	if playingAnimations[animation.Name] ~= nil then
		playingAnimations[animation.Name] = nil
	end

	animationTrack:AdjustWeight(weight, fadeTime)
end

function AnimationHandler:PauseAll(character : Model) : AnimationTrack?
	local playingAnimationTracks = animationHolder[character].Animator:GetPlayingAnimationTracks()
	local animationTrack : AnimationTrack= nil
	for _, animationTrackFound : AnimationTrack in playingAnimationTracks do
		animationTrackFound:AdjustSpeed(0)
		animationTrack = animationTrackFound
	end
	return animationTrack
end

function AnimationHandler:StopAll(character : Model, fade : number?)
	local playingAnimationTracks = animationHolder[character].Animator:GetPlayingAnimationTracks()

	for _, animationTrack : AnimationTrack in playingAnimationTracks do
		animationTrack:Stop(fade)
	end
end

function AnimationHandler:GetPlayingAnimations(character : Model) : {[string] : AnimationTrack}
	return playingAnimations
end

function AnimationHandler:GetAllTracks(character : Model) : {[string] : AnimationTrack}
	if animationHolder[character] == nil then return end
	return animationHolder[character].AnimationTracks
end

function AnimationHandler:FindPlayingAnimation(character : Model, animation : string) : AnimationTrack?
	return playingAnimations[animation]
end

function AnimationHandler:StopAnimation(character : Model, animation : Animation, fade : number?)
	local storedAnimationTracks = animationHolder[character].AnimationTracks
	local animationTrack : AnimationTrack = storedAnimationTracks[animation.AnimationId]

	if animationTrack == nil then return end
	
	if playingAnimations[animation.Name] ~= nil then
		playingAnimations[animation.Name] = nil
	end

	animationTrack:Stop(fade)
end

function AnimationHandler:PlayAnimation(character : Model, animation : Animation | string, fadeTime : number?, weight : number?, speed : number?): AnimationTrack?
	if animationHolder[character] == nil then
		AnimationHandler.Init(character)
	end

	local storedAnimationTracks = animationHolder[character].AnimationTracks
	
	if typeof(animation) == "string" then
		animation = CreateAnimationInstance(character, animation)
	end
	
	if animation.AnimationId == nil or animation.AnimationId == "" then
		warn(`Animation {animation} does not exist`)
		return
	end
	
	local animationTrack : AnimationTrack = storedAnimationTracks[animation.AnimationId]

	playingAnimations[animation.Name] = animationTrack

	if animationTrack ~= nil then
		animationTrack:Play(fadeTime, weight, speed)
		signalHandler.New("Listener"):Fire(character, animation, animationTrack)
		
		animationTrack.Stopped:Once(function()
			playingAnimations[animation.Name] = nil
		end)
		
		return animationTrack
	end

	animationTrack = animationHolder[character].Animator:LoadAnimation(animation)
	storedAnimationTracks[animation.AnimationId] = animationTrack
	animationTrack:Play(fadeTime, weight, speed)
	signalHandler.New("Listener"):Fire(character, animation, animationTrack)
	
	animationTrack.Stopped:Once(function()
		playingAnimations[animation.Name] = nil
	end)

	return animationTrack
end

function AnimationHandler:ClearAll(character : Model)
	table.clear(animationHolder[character].AnimationTracks)
end

function AnimationHandler:PreloadAnimations(animations : Folder | {Animation | string}, 
	callbackFunction : (assetId : string, assetFetchStatus : Enum.AssetFetchStatus) -> ()?)
	if typeof(animations) == "Folder" then
		animations = animations:GetDescendants()
	end
	
	ContentProvider:PreloadAsync(animations, callbackFunction)
end

function AnimationHandler:PreLoadAnimationTracks(character : Model, preLoadAnimationList : Folder | {Animation | string})
	if animationHolder[character] == nil then
		AnimationHandler.Init(character)
	end
	
	local loadAnimationTable : {Animation | string} = preLoadAnimationList
	
	if typeof(preLoadAnimationList) == "Instance" then
		if preLoadAnimationList:IsA("Folder") == false then
			warn(`{preLoadAnimationList} must be a folder or table`)
			return
		end
		
		loadAnimationTable = preLoadAnimationList:GetDescendants()
	end
	
	for _, animation : Animation in loadAnimationTable do
		if typeof(animation) == "Instance" then
			if animation:IsA("Animation") == false then continue end
		end
		
		if typeof(animation) == "string" then
			animation = CreateAnimationInstance(character, animation)
		end
		
		if animation.AnimationId == nil or animation.AnimationId == "" then
			warn(`Animation {animation} does not exist`)
			continue
		end
		
		local storedAnimationTracks = animationHolder[character].AnimationTracks
		local animationTrack : AnimationTrack = storedAnimationTracks[animation.AnimationId]

		if animationTrack ~= nil then continue end

		animationTrack = animationHolder[character].Animator:LoadAnimation(animation)
		storedAnimationTracks[animation.AnimationId] = animationTrack
	end
end

function CreateAnimationInstance(character : Model, animationId : string)
	local mainAnimationFolder : Folder = ReplicatedStorage:FindFirstChild("DarwinAnimationFolder")
	
	if mainAnimationFolder == nil then
		mainAnimationFolder = Instance.new("Folder")
		mainAnimationFolder.Name = "DarwinAnimationFolder"
		mainAnimationFolder.Parent = ReplicatedStorage
	end
	
	local animationFolder : Folder = mainAnimationFolder:FindFirstChild(character.Name)
	
	if animationFolder == nil then
		animationFolder = Instance.new("Folder")
		animationFolder.Name = character.Name
		animationFolder.Parent = ReplicatedStorage
	end
	
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	animation.Parent = animationFolder
	
	return animation
end

return AnimationHandler