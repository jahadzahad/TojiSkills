local ReplicatedStorage = game:GetService("ReplicatedStorage")

--< MODULES >--
local Hitbox = require(ReplicatedStorage.Shared.Modules.Hitbox)
local Velocity = require(ReplicatedStorage.Shared.Modules.Velocity)
local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)
local Type = require(ReplicatedStorage.Shared.Modules.Type)
local Maid = require(ReplicatedStorage.Packages.Maid)

local Effect = require(ReplicatedStorage.Shared.Refx.Combat.Skills.BlackLeg["Triple Kicks"])
local VFX
local Animations = ReplicatedStorage.Shared.Assets.Animations

local NegativeEffects = {
	Stun = require(ReplicatedStorage.Shared.WCS.StatusEffects.Stun),
	Cast = require(ReplicatedStorage.Shared.WCS.StatusEffects.Cast),
}

local WCS = require(ReplicatedStorage.Packages.WCS)

local Skill = WCS.RegisterSkill(script.Name)

function Skill:OnStartServer()
	self.Maid = Maid.new()

	VFX = Effect.new(self.Character.Instance)
	VFX:Start(Visuals:GetPlayers(self.Character.Instance, 20))

	local AnimationObject = Animations.Skills.BlackLeg.TripleKick
	local Track = self.Character.Instance.Humanoid:LoadAnimation(AnimationObject)
	Track:Play()

	local CastVal = NegativeEffects.Cast.new(self.Character)
	CastVal:Start(Track.Length)

	self.Maid:GiveTask(Track:GetMarkerReachedSignal("Kick1"):Connect(function()
		VFX:Kick1()
		Hitbox:createHitbox({
			Caster = self.Character.Instance,
			Size = Vector3.new(12, 6, 12),
			Offset = CFrame.new(0, 0, 0),
			HitType = "SingleTarget",
			Debris = 0.1,
			Visualize = true,
		}, function(target, WCStarget) end)
	end))

	self.Maid:GiveTask(Track:GetMarkerReachedSignal("Kick2"):Connect(function()
		VFX:Kick2()
		Hitbox:createHitbox({
			Caster = self.Character.Instance,
			Size = Vector3.new(12, 6, 12),
			Offset = CFrame.new(0, 0, 0),
			HitType = "SingleTarget",
			Debris = 0.1,
			Visualize = true,
		}, function(target, WCStarget)
			local StunVal2 = NegativeEffects.Stun.new(WCStarget)
			StunVal2:Start(1)
		end)
	end))

	self.Maid:GiveTask(Track:GetMarkerReachedSignal("Kick3"):Connect(function()
		VFX:Kick3()
		Hitbox:createHitbox({
			Caster = self.Character.Instance,
			Size = Vector3.new(40, 15, 40),
			Offset = CFrame.new(0, 0, -15),
			HitType = "SingleTarget",
			Debris = 0.1,
			BlockBreak = true,
			Visualize = true,
		}, function(target, WCStarget)
			print(target)

			Velocity:RemoveAllBodyMovers(target.HumanoidRootPart, false)
			Velocity:VelocityRelativeRoot(self.Character.Instance, target, 0.2, 30, 10)

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
		end)

		if self.Maid then
			self.Maid:DoCleaning()
		end
	end))
end

return Skill
