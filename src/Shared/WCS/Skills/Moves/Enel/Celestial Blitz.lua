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
local VFX = require(ReplicatedStorage.Shared.Refx.Combat.Skills.Enel["Celestial Blitz"])
local FistVFX = require(ReplicatedStorage.Shared.Refx.Combat.Fist)
local CameraShake = require(ReplicatedStorage.Shared.Refx.Combat.Misc.CameraShake)

function Move:OnStartServer()
	local character = self.Character.Instance
	self.AlreadyHit = false

	--Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Combat.Parry, character)
	VFX.new(character):Start(Visuals:GetPlayers(character))

	local Track = Animation.GetAnimation(self.Character.Instance, Animations.Skills.Enel["Celestial Blitz"].User)
	Animation.PlayAnimation(self.Character.Instance, Animations.Skills.Enel["Celestial Blitz"].User)

	local CastVal = NegativeEffects.Cast.new(self.Character)
	CastVal:Start(1)

	Track:GetMarkerReachedSignal("Hitbox"):Once(function()
		Velocity:RemoveAllBodyMovers(character.HumanoidRootPart, false)
		Velocity:VelocityRelativeRoot(character, character, 0.2, 30)

		local hb = Hitbox:createHitbox({
			Caster = self.Character.Instance,
			Size = Vector3.new(6, 6, 20),
			Offset = CFrame.new(0, 0, -10),
			HitType = "SingleTarget",
			Debris = 0.1,
			Visualize = true,
		}, function(target, WCStarget)
			if self.AlreadyHit then
				return
			end
			self.AlreadyHit = true

			self.VFX = VFX.new(character):Start(Visuals:GetPlayers(character))

			local StunVal = NegativeEffects.Stun.new(WCStarget)
			StunVal:Start(4)

			local StunVal2 = NegativeEffects.Stun.new(self.Character)
			StunVal2:Start(3)

			--local GettingHitAnim = Animations.HitReactions["Base" .. math.random(1, 5)]
			--Animation.PlayAnimation(target, GettingHitAnim)

			Damage:TakeDamage(self.Character.Instance, target, math.random(5, 7))

			Packets.AutoRotate:FireClient(Players:GetPlayerFromCharacter(character), { Value = true })

			self.Weld = Visuals:Weld(
				self.Character.Instance.HumanoidRootPart,
				target.HumanoidRootPart,
				CFrame.new(0, 0, 0),
				CFrame.new(0, 0, 0)
			)

			local ActionTrack =
				Animation.GetAnimation(self.Character.Instance, Animations.Skills.Enel["Celestial Blitz"].Hit)

			Animation.PlayAnimation(self.Character.Instance, Animations.Skills.Enel["Celestial Blitz"].Hit)
			Animation.PlayAnimation(target, Animations.Skills.Enel["Celestial Blitz"].Victim)

			ActionTrack:GetMarkerReachedSignal("Indicator 2"):Once(function()
				self.VFX:Grab()
				CameraShake.new("Radar"):Start(Visuals:GetPlayers(self.Character.Instance, 10))
			end)

			ActionTrack:GetMarkerReachedSignal("Indicator 3"):Once(function()
				self.VFX:Throw()
				CameraShake.new("Shake"):Start(Visuals:GetPlayers(self.Character.Instance, 10))

				self.Weld:Destroy()

				Velocity:RemoveAllBodyMovers(target.HumanoidRootPart, false)
				Velocity:VelocityRelativeRoot(character, target, 0.2, 50, 10)
			end)

			ActionTrack:GetMarkerReachedSignal("Indicator 4"):Once(function()
				self.VFX:Teleport()
				CameraShake.new("Radar"):Start(Visuals:GetPlayers(self.Character.Instance, 10))

				character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame

				self.Weld = Visuals:Weld(
					self.Character.Instance.HumanoidRootPart,
					target.HumanoidRootPart,
					CFrame.new(0, 0, 0),
					CFrame.new(0, 0, 0)
				)
			end)

			ActionTrack:GetMarkerReachedSignal("Indicator 5"):Once(function()
				self.VFX:Jump()
				CameraShake.new("Shake"):Start(Visuals:GetPlayers(self.Character.Instance, 10))
			end)

			ActionTrack:GetMarkerReachedSignal("Indicator 6"):Once(function()
				self.VFX:Slam()
				CameraShake.new("Explosion"):Start(Visuals:GetPlayers(self.Character.Instance, 10))

				Damage:TakeDamage(self.Character.Instance, target, math.random(15, 18))
			end)

			ActionTrack.Stopped:Once(function()
				self.Weld:Destroy()
				Packets.AutoRotate:FireClient(Players:GetPlayerFromCharacter(character), { Value = false })

				Ragdoll:ragdoll(true, target)
				task.delay(3, function()
					Ragdoll:ragdoll(false, target)
				end)
			end)

			self:ApplyCooldown(4)

			--Sound:Play(ReplicatedStorage.Shared.Assets.SFX.Hit.Fists[math.random(1, 5)], target)
			--FistVFX.new(target):Start(Visuals:GetPlayers(self.Character.Instance))
		end)
	end)

	self:ApplyCooldown(1)
end

return Move
