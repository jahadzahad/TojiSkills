local ReplicatedStorage = game:GetService("ReplicatedStorage")

--< MODULES >--
local Animation = require(ReplicatedStorage.Shared.Modules.Animation)
local Damage = require(ReplicatedStorage.Shared.Modules.Damage)
local Hitbox = require(ReplicatedStorage.Shared.Modules.Hitbox)
local Ragdoll = require(ReplicatedStorage.Shared.Modules.Ragdoll)
local Sound = require(ReplicatedStorage.Shared.Modules.Sound)
local Velocity = require(ReplicatedStorage.Shared.Modules.Velocity)
local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)
local Type = require(ReplicatedStorage.Shared.Modules.Type)
local Maid = require(ReplicatedStorage.Packages.Maid)

local Animations = ReplicatedStorage.Shared.Assets.Animations

local NegativeEffects = {
	Stun = require(ReplicatedStorage.Shared.WCS.StatusEffects.Stun),
	Cast = require(ReplicatedStorage.Shared.WCS.StatusEffects.Cast),
}
local Effect = require(ReplicatedStorage.Shared.Refx.Combat.Skills.BlackLeg["Grill Shot"])

local WCS = require(ReplicatedStorage.Packages.WCS)
local VFX

local FistVFX = require(ReplicatedStorage.Shared.Refx.Combat.Fist)

local Skill = WCS.RegisterSkill(script.Name)

function Skill:OnStartServer()
	self.Maid = Maid.new()
	self.AlreadyHit = false

	--	local AnimationObject = Animations.Skills.BlackLeg.GrillShotCast
	--	local CastTrack = Animation.GetAnimation(self.Character.Instance, AnimationObject)
	--	Animation.PlayAnimation(self.Character.Instance, AnimationObject)

	VFX = Effect.new(self.Character.Instance)
	VFX:Start(Visuals:GetPlayers(self.Character.Instance, 20))

	local GrillShotCast = self.Character.Instance.Humanoid:LoadAnimation(Animations.Skills.BlackLeg.GrillShotCast)
	local GrillShotLoop = self.Character.Instance.Humanoid:LoadAnimation(Animations.Skills.BlackLeg.GrillShotLoop)

	local CastTrack = GrillShotCast
	GrillShotCast:Play()

	local bv = nil

	local CastVal = NegativeEffects.Cast.new(self.Character)
	CastVal:Start(1)

	GrillShotCast:GetMarkerReachedSignal("Hit"):Connect(function()
		print("Hit Marker Reached")
		VFX:CastKick()
		--		Animation.PlayAnimation(self.Character.Instance, Animations.Skills.BlackLeg.GrillShotLoop)
		GrillShotLoop:Play()
		print("BV Created")

		bv = Velocity:SlowDownVelocity(self.Character.Instance, 150, 1)
		print(bv, "bv")

		task.delay(1, function()
			if self.AlreadyHit then
				return
			end
			--Animation.StopAnimation(self.Character.Instance, Animations.Skills.BlackLeg.GrillShotLoop)
			GrillShotLoop:Stop()
			if self.Maid then
				self.Maid:DoCleaning()
			end
		end)
	end)

	local function DoDamage(target)
		Damage:TakeDamage(self.Character.Instance, target, math.random(1, 2))

		Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists[math.random(1, 5)], target)
		FistVFX.new(target):Start(Visuals:GetPlayers(self.Character.Instance))
	end

	local function DoHit(target)
		GrillShotLoop:Stop()
		local HitTrack = self.Character.Instance.Humanoid:LoadAnimation(Animations.Skills.BlackLeg.GrillShotHit)
		HitTrack:Play()

		self.Weld = Visuals:Weld(
			self.Character.Instance.HumanoidRootPart,
			target.HumanoidRootPart,
			CFrame.new(0, 0, 0),
			CFrame.new(0, 0, 0)
		)

		local GettingHitAnim = target.Humanoid:LoadAnimation(Animations.Skills.BlackLeg.GrillShotEnemy)
		GettingHitAnim:Play()

		self.AlreadyHit = true

		if bv then
			bv:Destroy()
		end

		HitTrack:GetMarkerReachedSignal("Kick"):Connect(function()
			--DoDamage(target)
			VFX:KickHit()
			print("KICK BAM! POW!")
		end)

		HitTrack:GetMarkerReachedSignal("KickEnd"):Connect(function()
			self.Weld:Destroy()
			VFX:KickEnd(target.HumanoidRootPart)
			--	FistVFX.new(target, 5, self.Character.Instance):Start(Visuals:GetPlayers(self.Character.Instance))

			Velocity:RemoveAllBodyMovers(target.HumanoidRootPart, false)
			Velocity:VelocityRelativeRoot(self.Character.Instance, target, 0.2, 30, 10)

			--	Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists[math.random(1, 5)], target)

			Hitbox:createHitbox({
				Caster = target,
				Size = Vector3.new(6, 6, 6),
				Offset = CFrame.new(0, 0, 0),
				HitType = "OneHit",
				BlockBreak = false,
				Debris = 1,
				DDamage = 5,
				Visualize = false,
			}, function() end)

			task.delay(1, function() end)

			task.delay(2, function() end)

			if self.Maid then
				self.Maid:DoCleaning()
			end
		end)
	end

	local hb = Hitbox:createHitbox({
		Caster = self.Character.Instance,
		Size = Vector3.new(6, 6, 12),
		Offset = CFrame.new(0, 0, -6),
		HitType = "SingleTarget",
		Debris = 1.3,
		Visualize = true,
	}, function(target)
		--Animation.StopAnimation(self.Character.Instance, Animations.Skills.BlackLeg.GrillShotLoop)
		GrillShotLoop:Stop()

		if true then
			return
		end

		--	local HitTrack = Animation.GetAnimation(self.Character.Instance, Animations.Skills.BlackLeg.GrillShotHit)
		--	Animation.PlayAnimation(self.Character.Instance, Animations.Skills.BlackLeg.GrillShotHit)
		local HitTrack = self.Character.Instance.Humanoid:LoadAnimation(Animations.Skills.BlackLeg.GrillShotHit)
		HitTrack:Play()

		self.Weld = Visuals:Weld(
			self.Character.Instance.HumanoidRootPart,
			target.HumanoidRootPart,
			CFrame.new(0, 0, 0),
			CFrame.new(0, 0, 0)
		)

		--	local GettingHitAnim = Animations.Skills.BlackLeg.GrillShotEnemy
		--	Animation.PlayAnimation(target, GettingHitAnim)
		local GettingHitAnim = target.Humanoid:LoadAnimation(Animations.Skills.BlackLeg.GrillShotEnemy)
		GettingHitAnim:Play()

		local CastVal2 = NegativeEffects.Cast.new(self.Character)
		CastVal2:Start(HitTrack.Length)

		self.AlreadyHit = true

		bv:Destroy()

		self.Maid:GiveTask(HitTrack:GetMarkerReachedSignal("Kick"):Connect(function()
			DoDamage(target)
		end))

		self.Maid:GiveTask(HitTrack:GetMarkerReachedSignal("KickEnd"):Connect(function()
			self.Weld:Destroy()
			FistVFX.new(target, 5, self.Character.Instance):Start(Visuals:GetPlayers(self.Character.Instance))

			Velocity:RemoveAllBodyMovers(target.HumanoidRootPart, false)
			Velocity:VelocityRelativeRoot(self.Character.Instance, target, 0.2, 30, 10)

			Ragdoll:ragdoll(true, target)

			Damage:TakeDamage(self.Character.Instance, target, 7)

			Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists[math.random(1, 5)], target)

			Hitbox:createHitbox({
				Caster = target,
				Size = Vector3.new(6, 6, 6),
				Offset = CFrame.new(0, 0, 0),
				HitType = "OneHit",
				BlockBreak = false,
				Debris = 1,
				DDamage = 5,
				Visualize = false,
			}, function() end)

			task.delay(1, function()
				Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Combat.SurfaceSlam, target)
			end)

			task.delay(2, function()
				Ragdoll:ragdoll(false, target)
			end)

			if self.Maid then
				self.Maid:DoCleaning()
			end
		end))
	end)

	task.delay(1.2, function()
		DoHit(workspace.TheVictim)
	end)
end

return Skill
