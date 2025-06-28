local ServerScriptService = game:GetService("ServerScriptService")
local SocialService = game:GetService("SocialService")
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
local Packets = require(ReplicatedStorage.Shared.Packets)

local Animations = ReplicatedStorage.Shared.Assets.Animations

local NegativeEffects = {
	Stun = require(ReplicatedStorage.Shared.WCS.StatusEffects.Stun),
	Cast = require(ReplicatedStorage.Shared.WCS.StatusEffects.Cast),
}

local Move = WCS.RegisterSkill(script.Name)
local VFX = require(ReplicatedStorage.Shared.Refx.Combat.Skills.Enel["El Thor"])
local FistVFX = require(ReplicatedStorage.Shared.Refx.Combat.Fist)
local CameraShake = require(ReplicatedStorage.Shared.Refx.Combat.Misc.CameraShake)

function Move:OnStartServer()
	local character = self.Character.Instance

	Packets.AutoRotate:FireClient(Players:GetPlayerFromCharacter(character),{Value = true})
	--Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Combat.Parry, character)
	VFX.new(character):Start(Visuals:GetPlayers(character))

	local Track = Animation.GetAnimation(self.Character.Instance, Animations.Skills.Enel["El Thor"].User_Cast)
	Animation.PlayAnimation(self.Character.Instance, Animations.Skills.Enel["El Thor"].User_Cast)

	local CastVal = NegativeEffects.Cast.new(self.Character)
	CastVal:Start(1)

	Track.Stopped:Once(function()
		CameraShake.new("Shake"):Start(Visuals:GetPlayers(self.Character.Instance, 10))
		task.delay(0.2, function()
			CameraShake.new("Vibration"):Start(Visuals:GetPlayers(self.Character.Instance, 10))
		end)

		local hb = Hitbox:createHitbox({
			Caster = self.Character.Instance,
			Size = Vector3.new(12, 12, 60),
			Offset = CFrame.new(0, 0, -32),
			HitType = "Tick",
			TickInterval = 0.1,
			Debris = 1,
			DDamage = 1,
			Visualize = true,
		}, function(target, WCStarget)
			local StunVal2 = NegativeEffects.Stun.new(WCStarget)
			StunVal2:Start(1)

			local GettingHitAnim = Animations.HitReactions["Base" .. math.random(1, 5)]
			Animation.PlayAnimation(target, GettingHitAnim)

			Damage:TakeDamage(self.Character.Instance, target, math.random(1, 2))

			Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists[math.random(1, 5)], target)
			FistVFX.new(target):Start(Visuals:GetPlayers(self.Character.Instance))
		end)

		Animation.PlayAnimation(self.Character.Instance, Animations.Skills.Enel["El Thor"].User_Linger)
		task.delay(1, function()
			CameraShake.new("BigBump"):Start(Visuals:GetPlayers(self.Character.Instance, 10))
			Animation.StopAnimation(self.Character.Instance, Animations.Skills.Enel["El Thor"].User_Linger)
			Packets.AutoRotate:FireClient(Players:GetPlayerFromCharacter(character),{Value = false})
		end)
	end)

	self:ApplyCooldown(1)
end

return Move
