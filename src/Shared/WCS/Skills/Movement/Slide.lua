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

local Animations = ReplicatedStorage.Shared.Assets.Animations

local NegativeEffects = {
	Stun = require(ReplicatedStorage.Shared.WCS.StatusEffects.Stun),
	Cast = require(ReplicatedStorage.Shared.WCS.StatusEffects.Cast),
}

local SlideVFX = require(ReplicatedStorage.Shared.Refx.Movement.Slide)
local Slide = WCS.RegisterHoldableSkill("Slide")

function Slide:OnConstructServer()
	self:SetMaxHoldTime(1)
	self.VFX = nil
end

function Slide:OnStartServer()
	local character = self.Character.Instance
	local origin = character.HumanoidRootPart.Position
	local direction = Vector3.new(0, -5, 0)
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = { character }
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(origin, direction, rayParams)

	if result and result.Instance and result.Instance:IsA("BasePart") then
		local hitColor = result.Instance.Color
	
		Animation.PlayAnimation(character, Animations.Combats.Fists.Slide)
		character.Humanoid.AutoRotate = false
		Velocity:SlowDownVelocity(self.Character.Instance, self.Character.Instance, 1, 40)

		character:SetAttribute("Sliding", true)

		self.VFX = SlideVFX.new(character,hitColor)
		self.VFX:Start(Visuals:GetPlayers(character))

		task.delay(1,function()
			Animation.StopAnimation(character, Animations.Combats.Fists.Slide)
			character.Humanoid.AutoRotate = true
			character:SetAttribute("Sliding", false)
		end)
		self:ApplyCooldown(1)
	end
end

function Slide:OnEndServer()
	local character = self.Character.Instance
	self.VFX:Destroy()
	self.VFX = nil
	Velocity:RemoveAllBodyMovers(character.HumanoidRootPart,false)
end

return Slide
