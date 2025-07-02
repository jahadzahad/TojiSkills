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
local SlideJump = WCS.RegisterSkill("SlideJump")

function SlideJump:OnStartServer()
	self.Maid = Maid.new()
	local character = self.Character.Instance
	local Track = Animation.GetAnimation(character, Animations.Movement.DefaultMovement.SlideJumpStart)
	Animation.PlayAnimation(character, Animations.Movement.DefaultMovement.SlideJumpStart)

	self.Maid:GiveTask(Track.Stopped:Connect(function()
		--Animation.PlayAnimation(character, Animations.Movement.DefaultMovement.SlideJumpLoop)
	end))

	Velocity:RemoveAllBodyMovers(character.HumanoidRootPart,false)
	Velocity:VelocityRelativeRoot(character, character, .2, 40, 5)

	task.delay(.5,function()
		Animation.StopAnimation(character, Animations.Movement.DefaultMovement.SlideJumpLoop)
		Animation.PlayAnimation(character, Animations.Movement.DefaultMovement.SlideJumpLand)
		self.Maid:Destroy()
	end)

	--local StunVal = NegativeEffects.Stun.new(self.Character)
	--StunVal:Start(1)
end

return SlideJump
