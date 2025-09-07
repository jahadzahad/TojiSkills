local ReplicatedStorage = game:GetService("ReplicatedStorage")

--< MODULES >--
local Damage = require(ReplicatedStorage.Shared.Modules.Damage)
local Hitbox = require(ReplicatedStorage.Shared.Modules.Hitbox)
local Sound = require(ReplicatedStorage.Shared.Modules.Sound)
local Velocity = require(ReplicatedStorage.Shared.Modules.Velocity)
local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)
local Maid = require(ReplicatedStorage.Packages.Maid)

local Effect = require(ReplicatedStorage.Shared.Refx.Combat.Skills.BlackLeg["Projectile Kick"])
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

	local AnimationObject = Animations.Skills.BlackLeg.ProjectileKick
	local Track = self.Character.Instance.Humanoid:LoadAnimation(AnimationObject)
	Track:Play()

	local CastVal = NegativeEffects.Cast.new(self.Character)
	CastVal:Start(Track.Length)

	function doHit(target) end

	self.Maid:GiveTask(Track:GetMarkerReachedSignal("Shoot"):Connect(function()
		local hb = Hitbox:createHitbox({
			Caster = self.Character.Instance,
			Size = Vector3.new(12, 6, 12),
			Offset = CFrame.new(0, 0, 0),
			HitType = "Tick",
			TickInterval = 0.15,
			Debris = 0.7,
			Visualize = true,
		}, function(target, WCStarget)
			local StunVal2 = NegativeEffects.Stun.new(WCStarget)
			StunVal2:Start(1)
		end)

		hb:Move(CFrame.new(0, 0, -54), 0.7)

		local Direction = (self.Character.Instance.HumanoidRootPart.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit * 54

		VFX:FireTornado(Direction, 0.7)

		if self.Maid then
			self.Maid:Destroy()
		end
	end))
end

return Skill
