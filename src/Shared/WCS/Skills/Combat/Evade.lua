local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WCS = require(ReplicatedStorage.Packages.WCS)

-- < Modules > --
local Animation = require(ReplicatedStorage.Shared.Modules.Animation)
local Maid = require(ReplicatedStorage.Packages.Maid)
local Sound = require(ReplicatedStorage.Shared.Modules.Sound)
local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)
local Ragdoll = require(ReplicatedStorage.Shared.Modules.Ragdoll)
local Velocity = require(ReplicatedStorage.Shared.Modules.Velocity)

local EvadeEffect = require(ReplicatedStorage.Shared.WCS.StatusEffects.Evade)

local Animations = ReplicatedStorage.Shared.Assets.Animations

local NegativeEffects = {
	Stun = require(ReplicatedStorage.Shared.WCS.StatusEffects.Stun),
	Cast = require(ReplicatedStorage.Shared.WCS.StatusEffects.Cast),
}

local Evade = WCS.RegisterSkill("Evade")
local ParryVFX = require(ReplicatedStorage.Shared.Refx.Combat.Parry)

function Evade:OnStartServer(Caster)
	local character = self.Character.Instance
	Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Combat.Parry, character)
	ParryVFX.new(character):Start(Visuals:GetPlayers(character))
	local EvadeVal = EvadeEffect.new(self.Character)
	EvadeVal:Start(2)
	self:ApplyCooldown(1)
end

return Evade
