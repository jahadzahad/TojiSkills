local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local VFX = ReplicatedStorage.Shared.Assets.VFX

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Refx = require(ReplicatedStorage.Packages.Refx)
local BlockBreak = Refx.CreateEffect("BlockBreak")

function BlockBreak:OnStart(Character)
	local Spawn = Visuals:Spawn(VFX.Combat.BlockBreak, Character.HumanoidRootPart.CFrame)
	Visuals:Emit(Spawn)
	Debris:AddItem(Spawn,5)
end

return BlockBreak
