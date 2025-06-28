local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local VFX = ReplicatedStorage.Shared.Assets.VFX

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Refx = require(ReplicatedStorage.Packages.Refx)
local DaggerSwing = Refx.CreateEffect("DaggerSwing")

function DaggerSwing:OnStart(Character, Combo)
	if Combo <= 5 then
		local Spawn = Visuals:Spawn(VFX.Combat.Swing.Dagger[Combo].slash)
		Spawn.CFrame = Character.HumanoidRootPart.CFrame
		if Combo == 2 then
			Spawn.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -4)
		end
		Visuals:Emit(Spawn)
		Debris:AddItem(Spawn, 5)

		local GroundSpawn: Model = Visuals:Spawn(VFX.Combat.Swing.Dagger[1].funn)
		GroundSpawn.PrimaryPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, -1.5, 0)
		Visuals:Emit(GroundSpawn)
		Debris:AddItem(GroundSpawn, 5)
	else
		local Spawn = Visuals:Spawn(VFX.Combat.Swing.Dagger[6].slash)
		Spawn.CFrame = Character.HumanoidRootPart.CFrame
		Visuals:Emit(Spawn)
		Debris:AddItem(Spawn, 5)

		local GroundSpawn: Model = Visuals:Spawn(VFX.Combat.Swing.Dagger[1].funn)
		GroundSpawn.PrimaryPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, -1.5, 0)
		Visuals:Emit(GroundSpawn)
		Debris:AddItem(GroundSpawn, 5)
	end
end

return DaggerSwing
