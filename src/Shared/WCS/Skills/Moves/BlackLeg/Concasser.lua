local ReplicatedStorage = game:GetService("ReplicatedStorage")

--< MODULES >--
local Hitbox = require(ReplicatedStorage.Shared.Modules.Hitbox)
local Velocity = require(ReplicatedStorage.Shared.Modules.Velocity)
local Maid = require(ReplicatedStorage.Packages.Maid)
local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Animations = ReplicatedStorage.Shared.Assets.Animations
local Effect = require(ReplicatedStorage.Shared.Refx.Combat.Skills.BlackLeg["Concasser"])
local VFX

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

	local AnimationObject = Animations.Skills.BlackLeg.Concasser
	local Track = self.Character.Instance.Humanoid:LoadAnimation(AnimationObject)
	Track:Play()

	local CastVal = NegativeEffects.Cast.new(self.Character)
	CastVal:Start(Track.Length)

	local humanoidRootPart = self.Character.Instance.HumanoidRootPart
	local bodyVelocity = nil

	self.Maid:GiveTask(Track:GetMarkerReachedSignal("Start"):Connect(function()
		VFX:Leap()
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
		bodyVelocity.Velocity = Vector3.new(0, 50, 0)
		bodyVelocity.Parent = humanoidRootPart

		self.Maid:GiveTask(bodyVelocity)
	end))

	self.Maid:GiveTask(Track:GetMarkerReachedSignal("Slow"):Connect(function()
		VFX:FlareNotify()
		if bodyVelocity then
			bodyVelocity.Velocity = Vector3.new(0, 10, 0)
		end
	end))

	function doHit(target)
		Velocity:RemoveAllBodyMovers(target.HumanoidRootPart, false)
		Velocity:VelocityRelativeRoot(self.Character.Instance, target, 0.2, 30, 10)

		task.delay(1, function() end)

		task.delay(2, function() end)
	end

	self.Maid:GiveTask(Track:GetMarkerReachedSignal("Fall"):Connect(function()
		if bodyVelocity then
			local lookDirection = humanoidRootPart.CFrame.LookVector
			bodyVelocity.Velocity = lookDirection * 120 + Vector3.new(0, -150, 0)
			VFX:FlareNotify()

			task.delay(0.4, function()
				Hitbox:createHitbox({
					Caster = self.Character.Instance,
					Size = Vector3.new(40, 15, 40),
					Offset = CFrame.new(0, 0, -15),
					HitType = "SingleTarget",
					Debris = 0.1,
					BlockBreak = true,
					Visualize = true,
				}, function(target, WCStarget)
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
			end)
		end
	end))

	self.Maid:GiveTask(Track:GetMarkerReachedSignal("Land"):Connect(function()
		doHit(workspace.TheVictim)
		-- do raycast from the character's hrp to the ground
		local landPosition = humanoidRootPart.Position + Vector3.new(0, -3, -0.5)
		VFX:LandImpact(landPosition)
		if bodyVelocity then
			bodyVelocity:Destroy()
			bodyVelocity = nil
		end

		if self.Maid then
			self.Maid:DoCleaning()
		end
	end))
end

return Skill
