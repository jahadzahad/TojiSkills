local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WCS = require(ReplicatedStorage.Packages.WCS)

-- < Modules > --
local Animation = require(ReplicatedStorage.Shared.Modules.Animation)
local Maid = require(ReplicatedStorage.Packages.Maid)
local Hitbox = require(ReplicatedStorage.Shared.Modules.Hitbox)
local Sound = require(ReplicatedStorage.Shared.Modules.Sound)
local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)
local Ragdoll = require(ReplicatedStorage.Shared.Modules.Ragdoll)
local Velocity = require(ReplicatedStorage.Shared.Modules.Velocity)
local Damage = require(ReplicatedStorage.Shared.Modules.Damage)

local Animations = ReplicatedStorage.Shared.Assets.Animations

local NegativeEffects = {
	NoJump = require(ReplicatedStorage.Shared.WCS.StatusEffects.NoJump),
	Stun = require(ReplicatedStorage.Shared.WCS.StatusEffects.Stun),
	Cast = require(ReplicatedStorage.Shared.WCS.StatusEffects.Cast),
}

local Dagger = WCS.RegisterSkill("NPCDagger")

local FistVFX = require(ReplicatedStorage.Shared.Refx.Combat.Fist)
local SwingVFX = require(ReplicatedStorage.Shared.Refx.Combat.Weapons.Dagger.DaggerSwing)
local CameraShake = require(ReplicatedStorage.Shared.Refx.Combat.Misc.CameraShake)

function Dagger:OnStartServer(Combo)
	self.Maid = Maid.new()

	local AnimationObject
	if Combo == 6 then
		AnimationObject = Animations.Downslam
	else
		AnimationObject = Animations.Combats.Dagger[Combo]
	end

	local Track = Animation.GetAnimation(self.Character.Instance, AnimationObject)
	Track.Priority = Enum.AnimationPriority.Action2
	Animation.PlayAnimation(self.Character.Instance, AnimationObject)

	if Combo < 6 then
		task.delay(0.2, function()
			SwingVFX.new(self.Character.Instance, Combo):Start(Visuals:GetPlayers(self.Character.Instance))
		end)
	end

	local BlockBreak = false
	if Combo == 5 then
		BlockBreak = true
	end

	self.Maid:GiveTask(Track:GetMarkerReachedSignal("HitPoint"):Connect(function()
		Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists.Miss, self.Character.Instance)
		Hitbox:createHitbox({
			Caster = self.Character.Instance,
			Size = Vector3.new(12, 4, 12),
			Offset = CFrame.new(0, 0, -2),
			HitType = "OneHit",
			BlockBreak = BlockBreak,
			Debris = 0.1,
			Visualize = true,
		}, function(target, WCStarget)
			local StunVal = NegativeEffects.Stun.new(WCStarget)
			StunVal:Start(1)

			local GettingHitAnim
			if Combo == 6 then
				GettingHitAnim = Animations.HitReactions["Base" .. 5]
			else
				GettingHitAnim = Animations.HitReactions["Base" .. Combo]
			end
			Animation.PlayAnimation(target, GettingHitAnim)

			FistVFX.new(target, Combo):Start(Visuals:GetPlayers(self.Character.Instance))

			if Combo == 5 then
				Velocity:VelocityRelativeRoot(self.Character.Instance, target, 0.2, 30, 10)

				Ragdoll:ragdoll(true, target)

				Damage:TakeDamage(self.Character.Instance, target, 7)

				Hitbox:createHitbox({
					Caster = target,
					Size = Vector3.new(6, 6, 6),
					Offset = CFrame.new(0, 0, 0),
					HitType = "OneHit",
					BlockBreak = BlockBreak,
					Debris = 1,
					DDamage = 5,
					Visualize = true,
				})

				CameraShake.new("Tiny"):Start(Visuals:GetPlayers(self.Character.Instance, 10))
				Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Katana[Combo], target)
				task.delay(1, function()
					Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Combat.SurfaceSlam, target)
					CameraShake.new("Small"):Start(Visuals:GetPlayers(target, 500))
				end)

				task.delay(2, function()
					Ragdoll:ragdoll(false, target)
				end)
			elseif Combo == 6 then
				Velocity:RemoveAllBodyMovers(target.HumanoidRootPart, false)
				Velocity:VelocityRelativeRoot(self.Character.Instance, target, 0.2, 30)

				Ragdoll:ragdoll(true, target)

				Hitbox:createHitbox({
					Caster = target,
					Size = Vector3.new(6, 6, 6),
					Offset = CFrame.new(0, 0, 0),
					HitType = "OneHit",
					BlockBreak = BlockBreak,
					Debris = 1,
					DDamage = 5,
					Visualize = true,
				})

				Damage:TakeDamage(self.Character.Instance, target, 7)
				Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists[5], target)
				task.delay(1, function()
					Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Combat.SurfaceSlam, target)
					CameraShake.new("Small"):Start(Visuals:GetPlayers(target, 500))
				end)

				CameraShake.new("Tiny"):Start(Visuals:GetPlayers(self.Character.Instance, 10))
				task.delay(1, function()
					CameraShake.new("Small"):Start(Visuals:GetPlayers(target, 100))
				end)

				task.delay(3, function()
					Ragdoll:ragdoll(false, target)
				end)
			else
				Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Katana[Combo], target)
				Damage:TakeDamage(self.Character.Instance, target, math.random(3, 5))
			end
		end)

		if self.Maid then
			self.Maid:Destroy()
		end
	end))

	local CastVal = NegativeEffects.Cast.new(self.Character)
	local NoJump = NegativeEffects.NoJump.new(self.Character)
	NoJump:Start(0.7)
	if Combo == 5 then
		CastVal:Start(1)
		self:ApplyCooldown(1)
	else
		CastVal:Start(0.5)
		self:ApplyCooldown(0.5)
	end
end

function Dagger:OnEndServer() end

return Dagger
