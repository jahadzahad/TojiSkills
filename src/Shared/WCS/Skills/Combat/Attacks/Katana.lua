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

local Katana = WCS.RegisterSkill("Katana")
local FistVFX = require(ReplicatedStorage.Shared.Refx.Combat.Fist)
local SwingVFX = require(ReplicatedStorage.Shared.Refx.Combat.Weapons.Katana.KatanaSwing)
local CameraShake = require(ReplicatedStorage.Shared.Refx.Combat.Misc.CameraShake)

function Katana:ShouldStart()
	self.Combo = self.Character.Instance:GetAttribute("Combo") or 1

	return true
end

function Katana:OnStartServer()
	for _, v in self.Character.Humanoid.Animator:GetPlayingAnimationTracks() do
		if v.Priority == Enum.AnimationPriority.Action2 or v.Priority == Enum.AnimationPriority.Action3 then
			v:Stop()
		end
	end

	self.Maid = Maid.new()

	local Now_Clock = os.clock()
	self.Character.Instance:SetAttribute("LastM1", Now_Clock)
	
	task.delay(1.5, function()
		if self.Character.Instance and self.Character.Instance:GetAttribute("LastM1") == Now_Clock then
			self.Character.Instance:SetAttribute("Combo", 1)
		end
	end)

	self.Character.Instance:SetAttribute("Combo", self.Combo + 1 > 5 and 1 or self.Combo + 1)

	local AnimationObject
	if self.Character.Instance.Humanoid.FloorMaterial == Enum.Material.Air and self.Combo == 5 then
		AnimationObject = Animations.Downslam
	else
		AnimationObject = Animations.Combats.Katana[self.Combo]
	end

	local Track = Animation.GetAnimation(self.Character.Instance, AnimationObject)
	Track.Priority = Enum.AnimationPriority.Action2
	Animation.PlayAnimation(self.Character.Instance, AnimationObject)

	if self.Combo < 6 then
		task.delay(0.2, function()
			SwingVFX.new(self.Character.Instance, self.Combo):Start(Visuals:GetPlayers(self.Character.Instance))
		end)
	end

	local BlockBreak = false
	if self.Combo == 5 then
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
			if self.Combo == 6 then
				GettingHitAnim = Animations.HitReactions["Base" .. 5]
			else
				GettingHitAnim = Animations.HitReactions["Base" .. self.Combo]
			end
			Animation.PlayAnimation(target, GettingHitAnim)

			FistVFX.new(target, self.Combo):Start(Visuals:GetPlayers(self.Character.Instance))

			if self.Combo == 5 then
				Velocity:VelocityRelativeRoot(self.Character.Instance, target, 0.2, 30, 10)

				Ragdoll:ragdoll(true, target)

				Damage:TakeDamage(self.Character.Instance, target, 7)

				CameraShake.new("Tiny"):Start(Visuals:GetPlayers(self.Character.Instance, 10))
				Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Katana[self.Combo], target)

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

				task.delay(1, function()
					Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Combat.SurfaceSlam, target)
					CameraShake.new("Small"):Start(Visuals:GetPlayers(target, 500))
				end)

				task.delay(2, function()
					Ragdoll:ragdoll(false, target)
				end)
			elseif self.Combo == 6 then
				Velocity:RemoveAllBodyMovers(target.HumanoidRootPart, false)
				Velocity:VelocityRelativeRoot(self.Character.Instance, target, 0.2, 30)

				Ragdoll:ragdoll(true, target)

				Damage:TakeDamage(self.Character.Instance, target, 7)
				Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists[5], target)

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
				task.delay(1, function()
					Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Combat.SurfaceSlam, target)
					CameraShake.new("Small"):Start(Visuals:GetPlayers(target, 500))
				end)

				task.delay(3, function()
					Ragdoll:ragdoll(false, target)
				end)
			else
				Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Katana[self.Combo], target)
				Damage:TakeDamage(self.Character.Instance, target, math.random(3, 5))
			end
		end)

		if self.Maid then
			self.Maid:Destroy()
		end
	end))

	local CastVal = NegativeEffects.Cast.new(self.Character)
	local NoJump = NegativeEffects.NoJump.new(self.Character)
	local Length = self.Combo == 5 and 1 or Track.Length - .1

	NoJump:Start(Length + 1)
	CastVal:Start(Length)
	self:ApplyCooldown(Length)
end

function Katana:OnEndServer() end

return Katana
