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
local Hitbox = require(ReplicatedStorage.Shared.Modules.Hitbox)
local Damage = require(ReplicatedStorage.Shared.Modules.Damage)

local Animations = ReplicatedStorage.Shared.Assets.Animations

local NegativeEffects = {
	Stun = require(ReplicatedStorage.Shared.WCS.StatusEffects.Stun),
	Cast = require(ReplicatedStorage.Shared.WCS.StatusEffects.Cast),
}

local FistVFX = require(ReplicatedStorage.Shared.Refx.Combat.Fist)
local CameraShake = require(ReplicatedStorage.Shared.Refx.Combat.Misc.CameraShake)
local SwingVFX = {
	Katana = require(ReplicatedStorage.Shared.Refx.Combat.Weapons.Katana.KatanaSwing),
	Dagger = require(ReplicatedStorage.Shared.Refx.Combat.Weapons.Dagger.DaggerSwing),
}

local SlideAttack = WCS.RegisterSkill("SlideAttack")

function SlideAttack:OnStartServer()
	self.Maid = Maid.new()
	local character = self.Character.Instance
	local Track = Animation.GetAnimation(
		character,
		Animations.Combats[self.Character.Instance:GetAttribute("Moveset")].SlideAttack
	)
	Animation.PlayAnimation(character, Animations.Combats[self.Character.Instance:GetAttribute("Moveset")].SlideAttack)

	Velocity:RemoveAllBodyMovers(character.HumanoidRootPart, false)
	Velocity:VelocityRelativeRoot(character, character, 0.2, 30)

	if self.Character.Instance:GetAttribute("Moveset") == "Katana" then
		task.delay(0.2, function()
			SwingVFX.Katana.new(self.Character.Instance, 5):Start(Visuals:GetPlayers(self.Character.Instance))
		end)
	elseif self.Character.Instance:GetAttribute("Moveset") == "Dagger" then
		task.delay(0.2, function()
			SwingVFX.Dagger.new(self.Character.Instance, 6):Start(Visuals:GetPlayers(self.Character.Instance))
		end)
	end

	local CastVal = NegativeEffects.Cast.new(self.Character)
	CastVal:Start(1)

	self.Maid:GiveTask(Track:GetMarkerReachedSignal("HitPoint"):Connect(function()
		Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists.Miss, self.Character.Instance)

		Hitbox:createHitbox({
			Caster = self.Character.Instance,
			Size = Vector3.new(6, 6, 6),
			Offset = CFrame.new(0, 0, -4),
			HitType = "OneHit",
			Debris = 0.1,
			Visualize = true,
		}, function(target, WCStarget)
			local StunVal2 = NegativeEffects.Stun.new(WCStarget)
			StunVal2:Start(1)

			local GettingHitAnim = Animations.HitReactions["Base" .. math.random(1, 5)]
			Animation.PlayAnimation(target, GettingHitAnim)

			Damage:TakeDamage(self.Character.Instance, target, 7)

			Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists[math.random(1, 5)], target)
			FistVFX.new(target):Start(Visuals:GetPlayers(self.Character.Instance))
		end)

		if self.Maid then
			self.Maid:Destroy()
		end
	end))
end

return SlideAttack
