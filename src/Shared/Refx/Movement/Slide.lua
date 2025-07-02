local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local VFX = ReplicatedStorage.Shared.Assets.VFX

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Refx = require(ReplicatedStorage.Packages.Refx)
local Slide = Refx.CreateEffect("Slide")

function Slide:OnStart(Character,Color)
	local Spawn = Visuals:Spawn(VFX.Movement.SlideTrail, Character.HumanoidRootPart.CFrame, workspace.Debris, false)
	Spawn.Anchored = false

	Spawn.dust.Color = ColorSequence.new(Color)
	Spawn.dust2.Color = ColorSequence.new(Color)
	Spawn.dust3.Color = ColorSequence.new(Color)

	Visuals:Weld(Spawn,Character.HumanoidRootPart,CFrame.new(0,0,0),CFrame.new(0,-4,-2))
	Debris:AddItem(Spawn,5)
	task.delay(1,function()
		Visuals:Enabled(Spawn,false)
	end)
end

return Slide
