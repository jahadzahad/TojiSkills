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
local Type = require(ReplicatedStorage.Shared.Modules.Type)

local Animations = ReplicatedStorage.Shared.Assets.Animations

local NegativeEffects = {
	NoJump = require(ReplicatedStorage.Shared.WCS.StatusEffects.NoJump),
	Stun = require(ReplicatedStorage.Shared.WCS.StatusEffects.Stun),
	Cast = require(ReplicatedStorage.Shared.WCS.StatusEffects.Cast),
}

local Fist = WCS.RegisterSkill("Fist")

local FistVFX = require(ReplicatedStorage.Shared.Refx.Combat.Fist)
local CameraShake = require(ReplicatedStorage.Shared.Refx.Combat.Misc.CameraShake)

function Fist:OnConstructServer() end

function Fist:ShouldStart()
	self.Combo = self.Character.Instance:GetAttribute("Combo") or 1

	return true
end

function Fist:OnStartServer(Throw)
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
	if self.Character.Instance.Humanoid.FloorMaterial == Enum.Material.Air and self.Combo == 5 and not Throw then
		AnimationObject = Animations.Downslam
	elseif self.Character.Instance.Humanoid.FloorMaterial == Enum.Material.Air and self.Combo == 5 and Throw then
		AnimationObject = Animations.ThrowCast
	else
		AnimationObject = Animations.Combats.Fists[self.Combo]
	end

	local Track = Animation.GetAnimation(self.Character.Instance, AnimationObject)
	Animation.PlayAnimation(self.Character.Instance, AnimationObject)

	self.Maid:GiveTask(Track:GetMarkerReachedSignal("HitPoint"):Connect(function()
		Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists.Miss, self.Character.Instance)

		local BlockBreak = false
		if self.Combo == 5 then
			BlockBreak = true
		end

		Hitbox:createHitbox({
			Caster = self.Character.Instance,
			Size = Vector3.new(6, 6, 6),
			Offset = CFrame.new(0, 0, -4),
			HitType = "SingleTarget",
			BlockBreak = BlockBreak,
			Debris = 0.1,
			Visualize = true,
		}, function(target, WCStarget)
			local StunVal = NegativeEffects.Stun.new(WCStarget)
			StunVal:Start(1)

			local GettingHitAnim
			if
				self.Character.Instance.Humanoid.FloorMaterial == Enum.Material.Air
				and self.Combo == 5
				and not Throw
			then
				GettingHitAnim = Animations.HitReactions["Base" .. 5]
			elseif
				self.Character.Instance.Humanoid.FloorMaterial == Enum.Material.Air
				and self.Combo == 5
				and Throw
			then
				GettingHitAnim = nil
			else
				GettingHitAnim = Animations.HitReactions["Base" .. self.Combo]
			end

			if GettingHitAnim then
				Animation.PlayAnimation(target, GettingHitAnim)
			end

			if
				self.Combo == 5
				and not (self.Character.Instance.Humanoid.FloorMaterial == Enum.Material.Air)
				and not Throw
			then
				print("Normal")
				FistVFX.new(target, self.Combo, self.Character.Instance):Start(Visuals:GetPlayers(self.Character.Instance))

				Velocity:RemoveAllBodyMovers(target.HumanoidRootPart, false)
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
				}, function() end)

				CameraShake.new("Tiny"):Start(Visuals:GetPlayers(self.Character.Instance, 10))
				task.delay(1, function()
					Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Combat.SurfaceSlam, target)
					CameraShake.new("Small"):Start(Visuals:GetPlayers(target, 500))
				end)

				Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists[self.Combo], target)

				task.delay(2, function()
					Ragdoll:ragdoll(false, target)
				end)
			elseif
				self.Character.Instance.Humanoid.FloorMaterial == Enum.Material.Air
				and self.Combo == 5
				and not Throw
			then
				print("DownSlam")
				FistVFX.new(target, 6, self.Character.Instance):Start(Visuals:GetPlayers(self.Character.Instance))

				Velocity:RemoveAllBodyMovers(target.HumanoidRootPart, false)
				Velocity:VelocityRelativeRoot(self.Character.Instance, target, 0.2, 30)

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
				}, function() end)

				Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists[5], target)
				CameraShake.new("Tiny"):Start(Visuals:GetPlayers(self.Character.Instance, 10))
				task.delay(1, function()
					Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Combat.SurfaceSlam, target)
					CameraShake.new("Small"):Start(Visuals:GetPlayers(target, 500))
				end)

				task.delay(3, function()
					Ragdoll:ragdoll(false, target)
				end)
			elseif
				self.Character.Instance.Humanoid.FloorMaterial == Enum.Material.Air
				and self.Combo == 5
				and Throw
			then
				print("Throw")

				FistVFX.new(target, 7, self.Character.Instance):Start(Visuals:GetPlayers(self.Character.Instance))

				self.Weld = Visuals:Weld(
					self.Character.Instance.HumanoidRootPart,
					target.HumanoidRootPart,
					CFrame.new(0, 0, 0),
					CFrame.new(0, 0, 0)
				)
				local Action = Animation.GetAnimation(self.Character.Instance, Animations.ThrowHit)
				Animation.PlayAnimation(self.Character.Instance, Animations.ThrowHit)
				Animation.PlayAnimation(target, Animations.ThrowTarget)

				self.ZelestriaMaid = Maid.new()

				self.ZelestriaMaid:GiveTask(Action:GetMarkerReachedSignal("Action"):Connect(function()
					self.Weld:Destroy()
					self.ZelestriaMaid:Destroy()

					Velocity:RemoveAllBodyMovers(target.HumanoidRootPart, false)
					Velocity:VelocityRelativeRoot(self.Character.Instance, target, 0.2, 30)

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
					}, function() end)

					Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists[5], target)
					CameraShake.new("Tiny"):Start(Visuals:GetPlayers(self.Character.Instance, 10))
					task.delay(1, function()
						Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Combat.SurfaceSlam, target)
						CameraShake.new("Small"):Start(Visuals:GetPlayers(target, 500))
					end)

					task.delay(3, function()
						Ragdoll:ragdoll(false, target)
					end)
				end))
			else
				Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists[self.Combo], target)
				Damage:TakeDamage(self.Character.Instance, target, math.random(3, 5))
				FistVFX.new(target, self.Combo, self.Character.Instance):Start(Visuals:GetPlayers(self.Character.Instance))
			end
		end)

		if self.Maid then
			self.Maid:Destroy()
		end
	end))

	local CastVal = NegativeEffects.Cast.new(self.Character)
	local NoJump = NegativeEffects.NoJump.new(self.Character)
	local Length = self.Combo == 5 and 1 or Track.Length - 0.4

	NoJump:Start(Length + 1)
	CastVal:Start(Length)
	self:ApplyCooldown(Length)
end

return Fist
