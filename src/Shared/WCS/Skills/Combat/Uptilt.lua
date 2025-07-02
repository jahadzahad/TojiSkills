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
local SwingVFX = require(ReplicatedStorage.Shared.Refx.Combat.Weapons.Katana.KatanaSwing)

local Uptilt = WCS.RegisterSkill("Uptilt")

function Uptilt:ShouldStart()
	self.Combo = self.Character.Instance:GetAttribute("Combo") or 1

	return true
end

function Uptilt:OnStartServer()
	for _, v in self.Character.Humanoid.Animator:GetPlayingAnimationTracks() do
		if v.Priority == Enum.AnimationPriority.Action2 or v.Priority == Enum.AnimationPriority.Action3 then
			v:Stop()
		end
	end

	self.Maid = Maid.new()
	
	local character = self.Character.Instance

	local Now_Clock = os.clock()
	self.Character.Instance:SetAttribute("LastM1", Now_Clock)

	task.delay(1.5, function()
		if self.Character.Instance and self.Character.Instance:GetAttribute("LastM1") == Now_Clock then
			self.Character.Instance:SetAttribute("Combo", 1)
		end
	end)

	self.Character.Instance:SetAttribute("Combo", self.Combo + 1 > 5 and 1 or self.Combo + 1)
	
	local Track = Animation.GetAnimation(character, Animations.Uptilt)
	Animation.PlayAnimation(character, Animations.Uptilt)

	local StunVal = NegativeEffects.Stun.new(self.Character)
	StunVal:Start(1)

	self.Maid:GiveTask(Track:GetMarkerReachedSignal("HitPoint"):Connect(function()
		Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists.Miss, self.Character.Instance)

		Hitbox:createHitbox({
			Caster = self.Character.Instance,
			Size = Vector3.new(6, 12, 6),
			Offset = CFrame.new(0, 0, -4),
			HitType = "OneHit",
			Debris = 0.1,
			Visualize = true,
		}, function(target, WCStarget)
			Velocity:RemoveAllBodyMovers(target.HumanoidRootPart, false)
			Velocity:VelocityRelativeRoot(target, target, 3, -2, 34)

			local StunVal2 = NegativeEffects.Stun.new(WCStarget)
			StunVal2:Start(1)

			local GettingHitAnim = Animations.HitReactions["Base" .. math.random(1, 5)]
			Animation.PlayAnimation(target, GettingHitAnim)

			Damage:TakeDamage(self.Character.Instance, target, 7)

			Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists[math.random(1, 5)], target)
			FistVFX.new(target):Start(Visuals:GetPlayers(self.Character.Instance))
		end)

		Velocity:RemoveAllBodyMovers(character.HumanoidRootPart, false)
		Velocity:VelocityRelativeRoot(character, character, 3, 1, 30)

		if self.Maid then
			self.Maid:Destroy()
		end
	end))
end

return Uptilt
