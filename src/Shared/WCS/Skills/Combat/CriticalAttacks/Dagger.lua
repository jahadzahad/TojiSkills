local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
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
local DaggerCritical = require(ReplicatedStorage.Shared.Refx.Combat.Weapons.Dagger.Critical)
local CameraShake = require(ReplicatedStorage.Shared.Refx.Combat.Misc.CameraShake)
local Action = WCS.RegisterSkill("DaggerCritical")

function Action:OnStartServer()
	self:ApplyCooldown(30)
	self.Maid = Maid.new()
	local character = self.Character.Instance

	local Track = Animation.GetAnimation(character, Animations.Combats.Dagger.CriticalAttack)
	Animation.PlayAnimation(character, Animations.Combats.Dagger.CriticalAttack)

	local CastVal = NegativeEffects.Cast.new(self.Character)
	CastVal:Start(1)

	self.Maid:GiveTask(Track:GetMarkerReachedSignal("Start"):Connect(function()
		DaggerCritical.new(self.Character.Instance, 5):Start(Visuals:GetPlayers(self.Character.Instance))
		--Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists.Miss, self.Character.Instance)
		CameraShake.new("Small"):Start(Visuals:GetPlayers(self.Character.Instance,10))
		character.Humanoid.AutoRotate = false

		local hb = Hitbox:createHitbox({
			Caster = self.Character.Instance,
			Size = Vector3.new(12, 12, 12),
			Offset = CFrame.new(0, 0, -8),
			HitType = "Tick",
			TickInterval = 0.1,
			Debris = .7,
			DDamage = 1,
			Visualize = true,
		}, function(target, WCStarget)
			local StunVal2 = NegativeEffects.Stun.new(WCStarget)
			StunVal2:Start(1)

			local GettingHitAnim = Animations.HitReactions["Base" .. math.random(1, 5)]
			Animation.PlayAnimation(target, GettingHitAnim)

			Damage:TakeDamage(self.Character.Instance, target, math.random(1,2))

			Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Katana[math.random(1, 5)], target)
			FistVFX.new(target):Start(Visuals:GetPlayers(self.Character.Instance))
		end)

		task.delay(.7, function()
			CameraShake.new("Small"):Start(Visuals:GetPlayers(self.Character.Instance,10))
			character.Humanoid.AutoRotate = true
		end)

		if self.Maid then
			self.Maid:Destroy()
		end
	end))
end

return Action
