local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFX = ReplicatedStorage.Shared.Assets.VFX

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Refx = require(ReplicatedStorage.Packages.Refx)
local Parry = Refx.CreateEffect("Parry")

function Parry:OnStart(Character)
	local Spawn = Visuals:Spawn(VFX.Combat.Parry, Character.HumanoidRootPart.CFrame)
	Visuals:Emit(Spawn)
	Debris:AddItem(Spawn,5)
end

return Parry
