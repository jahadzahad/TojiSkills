local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFX = ReplicatedStorage.Shared.Assets.VFX

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Refx = require(ReplicatedStorage.Packages.Refx)
local Plunge = Refx.CreateEffect("Plunge")
local Rocks = require(ReplicatedStorage.Shared.Modules.Rocks)

function Plunge:OnStart(Character, Position)
	local Spawn = Visuals:Spawn(
		VFX.Combat.Plunges[Character:GetAttribute("Moveset")],
		CFrame.new(Position)
	)
	Visuals:Emit(Spawn)
	Debris:AddItem(Spawn, 5)
	Rocks.Crater(Character.HumanoidRootPart.CFrame, 5, 4, 5, false, true)
	Rocks.Crater(Character.HumanoidRootPart.CFrame, 8, 6, 8, false, true)
	Rocks.Explosion(Character.HumanoidRootPart.CFrame, 10, 0.5, 1.5, false, true)
end

return Plunge
