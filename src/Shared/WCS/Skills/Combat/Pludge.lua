local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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

local PlungeVFX = require(ReplicatedStorage.Shared.Refx.Combat.Plunge)
local FistVFX = require(ReplicatedStorage.Shared.Refx.Combat.Fist)
local CameraShake = require(ReplicatedStorage.Shared.Refx.Combat.Misc.CameraShake)
local Pludge = WCS.RegisterSkill("Pludge")

function Pludge:OnStartServer()
	self.Maid = Maid.new()
	local character = self.Character.Instance
	Animation.PlayAnimation(character, Animations.Combats[self.Character.Instance:GetAttribute("Moveset")].Plunge)

	Velocity:RemoveAllBodyMovers(character.HumanoidRootPart, false)
	Velocity:VelocityRelativeRoot(character, character, 0.2, 20, 10)

	local StunVal = NegativeEffects.Stun.new(self.Character)
	StunVal:Start(1)

	task.delay(0.5, function()
		local RayPerms = RaycastParams.new()
		RayPerms.FilterDescendantsInstances = { self.Character.Instance, workspace.Debris }
		RayPerms.FilterType = Enum.RaycastFilterType.Exclude

		self.Maid:GiveTask(RunService.Heartbeat:Connect(function()
			local result =
				workspace:Raycast(self.Character.Instance.HumanoidRootPart.Position, Vector3.new(0, -10, 0), RayPerms)
			if result then
				CameraShake.new("Small"):Start(Visuals:GetPlayers(self.Character.Instance,10))

				Animation.StopAnimation(character, Animations.Combats[self.Character.Instance:GetAttribute("Moveset")].Plunge)
				Animation.PlayAnimation(character, Animations.Combats[self.Character.Instance:GetAttribute("Moveset")].PlungeHit)

				Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Combat.SurfaceSlam, self.Character.Instance)
				PlungeVFX.new(self.Character.Instance, result.Position):Start(Visuals:GetPlayers(self.Character.Instance))

				Hitbox:createHitbox({
					Caster = self.Character.Instance,
					Size = Vector3.new(15, 6, 15),
					Offset = CFrame.new(0, -2, 0),
					HitType = "OneHit",
					Debris = 0.1,
					BlockBreak = true,
					Visualize = true,
				}, function(target, WCStarget)
					local StunVal2 = NegativeEffects.Stun.new(WCStarget)
					StunVal2:Start(1)

					local GettingHitAnim = Animations.HitReactions["Base" .. math.random(1, 5)]
					Animation.PlayAnimation(target, GettingHitAnim)

					Damage:TakeDamage(self.Character.Instance, target, 7)

					Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists[math.random(1, 5)], target)
					FistVFX.new(target):Start(Visuals:GetPlayers(self.Character.Instance))
				end)

				if self.Maid then
					self.Maid:Destroy()
				end
			end
		end))
	end)
end

return Pludge
