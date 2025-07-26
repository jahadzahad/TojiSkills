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

local Assets = ReplicatedStorage.Shared.Assets

--local VFX = ReplicatedStorage.Shared.Assets.VFX
--local Animations = ReplicatedStorage.Shared.Assets.Animations
--local SFX = ReplicatedStorage.Shared.Assets.SFX

local function loadTrack(animation, Character)
	local Humanoid = Character:FindFirstChild("Humanoid")

	local Track = Humanoid.Animator:LoadAnimation(animation)

	return Track
end
-----------------------------------

local Animations = {
	User = Assets.Animations.Movesets.BlackLeg.PartyTable.User,
	HitReactions = Assets.Animations.Movesets.BlackLeg.PartyTable.HitReactions,
}

local NegativeEffects = {
	Stun = require(ReplicatedStorage.Shared.WCS.StatusEffects.Stun),
	Cast = require(ReplicatedStorage.Shared.WCS.StatusEffects.Cast),
}

local WCS = require(ReplicatedStorage.Packages.WCS)

-- Make a new Refx file and require here
local Effect = require(ReplicatedStorage.Shared.Refx.Combat.Skills.BlackLeg["PartyTable"])
local VFX

local FistVFX = require(ReplicatedStorage.Shared.Refx.Combat.Fist)

local Skill = WCS.RegisterSkill(script.Name)

function Skill:OnStartServer()
	VFX = Effect.new(self.Character.Instance)
	VFX:Start(Visuals:GetPlayers(self.Character.Instance, 20))

	Velocity:SlowDownVelocity(self.Character.Instance, 50, 2)

	local CastVal = NegativeEffects.Cast.new(self.Character)
	CastVal:Start(2)

	local hb = Hitbox:createHitbox({
		Caster = self.Character.Instance,
		Size = Vector3.new(12, 6, 12),
		Offset = CFrame.new(0, 0, 0),
		HitType = "Tick",
		TickInterval = 0.15,
		Debris = 2,
		Visualize = true,
	}, function(target, WCStarget)
		print("Hit: " .. target.Name)
		local StunVal2 = NegativeEffects.Stun.new(WCStarget)
		StunVal2:Start(1)

		local GettingHitAnim = Animations.HitReactions["Base" .. math.random(1, 2)]
		Animation.PlayAnimation(target, GettingHitAnim)

		Damage:TakeDamage(self.Character.Instance, target, math.random(1, 2))

		--	Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists[math.random(1, 5)], target)
		FistVFX.new(target):Start(Visuals:GetPlayers(self.Character.Instance))
	end)

	task.delay(1.7, function()
		VFX:End()
	end)
end

function Skill:OnStartClient()
	local userAnimation = loadTrack(Animations.User, self.Character.Instance)
	userAnimation:Play()
end

return Skill
