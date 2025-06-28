local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local VFX = ReplicatedStorage.Shared.Assets.VFX

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Refx = require(ReplicatedStorage.Packages.Refx)
local KatanaSwing = Refx.CreateEffect("KatanaSwing")

function KatanaSwing:OnStart(Character, Combo)
	local Spawn = Visuals:Spawn(VFX.Combat.Swing.Katana[Combo].slash)
	Spawn.CFrame = Character.HumanoidRootPart.CFrame
	Visuals:Emit(Spawn)
	Debris:AddItem(Spawn, 5)

	if not (Combo == 6) then
		local GroundSpawn: Model = Visuals:Spawn(VFX.Combat.Swing.Katana[1].funn)
		GroundSpawn.PrimaryPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, -1.5, 0)
		Visuals:Emit(GroundSpawn)
		Debris:AddItem(GroundSpawn, 5)
	end
end

return KatanaSwing
