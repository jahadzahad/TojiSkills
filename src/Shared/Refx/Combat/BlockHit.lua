local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local VFX = ReplicatedStorage.Shared.Assets.VFX

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Refx = require(ReplicatedStorage.Packages.Refx)
local BlockHit = Refx.CreateEffect("BlockHit")

function BlockHit:OnStart(Character)
	local Spawn = Visuals:Spawn(VFX.Combat.BlockHit, Character.HumanoidRootPart.CFrame)
	Visuals:Emit(Spawn)
	Debris:AddItem(Spawn,5)
end

return BlockHit
