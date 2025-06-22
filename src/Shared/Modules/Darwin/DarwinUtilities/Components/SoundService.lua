local TweenService = game:GetService("TweenService")

local components = script.Parent

local darwinUtils = components.Parent

local types = require(darwinUtils.Types)

local SoundService = {}

function SoundService:TweenVolume(sound : Sound, duration : number, chosenVolume : number?) : TweenBase
	local tweenInfo : TweenInfo = TweenInfo.new(duration,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0)
	local tweenConfiguration = {Volume = chosenVolume}
	local tween = TweenService:Create(sound,tweenInfo,tweenConfiguration)
	tween:Play()

	tween.Completed:Once(function()
		sound:Destroy()
	end)
	
	return tween
end

return SoundService
