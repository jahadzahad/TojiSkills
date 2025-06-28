local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local VFX = ReplicatedStorage.Shared.Assets.VFX

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)
local Maid = require(ReplicatedStorage.Packages.Maid)
local Rocks = require(ReplicatedStorage.Shared.Modules.Rocks)

local Refx = require(ReplicatedStorage.Packages.Refx)
local Fist = Refx.CreateEffect("Fist")

function Fist:OnStart(Character, Combo, Caster)
	local Spawn = Visuals:Spawn(VFX.Combat.Hit.Fists, Character.HumanoidRootPart.CFrame)
	Visuals:Emit(Spawn)

	local Highlight = Instance.new("Highlight")
	Highlight.Adornee = Character
	Highlight.Parent = Character
	Highlight.FillColor = Color3.new(1, 0.341176, 0.341176)
	Highlight.FillTransparency = 1
	Highlight.OutlineTransparency = 1
	Highlight.DepthMode = Enum.HighlightDepthMode.Occluded

	TweenService:Create(
		Highlight,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),
		{ ["FillTransparency"] = 0.2 }
	):Play()

	Debris:AddItem(Highlight, 2)
	Debris:AddItem(Spawn, 5)

	if Combo == 5 then
		local Trail = Visuals:Spawn(VFX.StatusEffects.RagdollFall, Character.HumanoidRootPart.CFrame)
		Trail.Anchored = false
		Visuals:Weld(Trail, Character.HumanoidRootPart)

		task.delay(1, function()
			local Spawn1 = Visuals:Spawn(VFX.StatusEffects.RagdollHit)
			Spawn1.Position = Character.HumanoidRootPart.Position
			Visuals:Emit(Spawn1)
			Trail:Destroy()
			Rocks.Crater(Character.HumanoidRootPart.CFrame, 7, 4, 5, false, true)
			Rocks.Crater(Character.HumanoidRootPart.CFrame, 10, 6, 8, false, true)
			Rocks.Explosion(Character.HumanoidRootPart.CFrame, 10, 0.5, 1.5, false, true)
		end)
	elseif Combo == 6 then
		local Trail = Visuals:Spawn(VFX.StatusEffects.RagdollFall, Character.HumanoidRootPart.CFrame)
		Trail.Anchored = false
		Visuals:Weld(Trail, Character.HumanoidRootPart)

		task.delay(1, function()
			local Spawn1 = Visuals:Spawn(VFX.StatusEffects.RagdollHit)
			Spawn1.Position = Character.HumanoidRootPart.Position
			Trail:Destroy()
			Visuals:Emit(Spawn1)
			Rocks.Crater(Character.HumanoidRootPart.CFrame, 5, 4, 5, false, true)
			Rocks.Crater(Character.HumanoidRootPart.CFrame, 8, 6, 8, false, true)
			Rocks.Explosion(Character.HumanoidRootPart.CFrame, 10, 0.5, 1.5, false, true)
		end)
	elseif Combo == 7 then
		local SpinWind = Visuals:Spawn(VFX.Combat.SpinWind, Caster.HumanoidRootPart.CFrame)
		Visuals:Enabled(SpinWind, true)
		task.delay(.7, function()
			Visuals:Enabled(SpinWind, false)
		end)
		Debris:AddItem(SpinWind, 5)

		local Wind = Visuals:Spawn(VFX.Combat.Wind3, Caster.HumanoidRootPart.CFrame)
		task.delay(0.2, function()
			Visuals:Emit(Wind)
			task.wait(0.3)
			Visuals:Emit(Wind)
			task.wait(0.2)
			Visuals:Emit(Wind)
			task.wait(0.1)
			Visuals:Emit(Wind)
		end)
		Debris:AddItem(Wind, 2)

		local Catch = Visuals:Spawn(VFX.Combat.ThrowCatch, Caster.HumanoidRootPart.CFrame)
		Visuals:Emit(Catch)

		local Trail = Visuals:Spawn(VFX.StatusEffects.RagdollFall, Character.HumanoidRootPart.CFrame)
		Trail.Anchored = false
		Visuals:Weld(Trail, Character.HumanoidRootPart)

		task.delay(2.5, function()
			local Spawn1 = Visuals:Spawn(VFX.StatusEffects.RagdollHit)
			Spawn1.Position = Character.HumanoidRootPart.Position
			Trail:Destroy()
			Visuals:Emit(Spawn1)
			Rocks.Crater(Character.HumanoidRootPart.CFrame, 5, 4, 5, false, true)
			Rocks.Crater(Character.HumanoidRootPart.CFrame, 8, 6, 8, false, true)
			Rocks.Explosion(Character.HumanoidRootPart.CFrame, 10, 0.5, 1.5, false, true)
		end)
	end
end

return Fist
