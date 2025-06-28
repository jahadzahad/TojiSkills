local Debris = game:GetService("Debris")
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

local DashVFX = require(ReplicatedStorage.Shared.Refx.Movement.Dash)
local Dash = WCS.RegisterSkill("Dash")

function Dash:OnStartServer(Direction)
	self:ApplyCooldown(5)
	self.Maid = Maid.new()
	local character = self.Character.Instance
	local rootPart = character.HumanoidRootPart
	local dashSpeed = 80
	local dashVector

	self.Character.Instance:SetAttribute("Evade", true)
	task.delay(.25,function()
		self.Character.Instance:SetAttribute("Evade", false)
	end)

	if Direction == "Front" then
		Animation.PlayAnimation(character, Animations.Movement.Fists.ForwardDash)
		dashVector = rootPart.CFrame.LookVector * dashSpeed
	elseif Direction == "Right" then
		Animation.PlayAnimation(character, Animations.Movement.Fists.RightDash)
		dashVector = rootPart.CFrame.RightVector * dashSpeed
	elseif Direction == "Left" then
		Animation.PlayAnimation(character, Animations.Movement.Fists.LeftDash)
		dashVector = -rootPart.CFrame.RightVector * dashSpeed
	elseif Direction == "Back" then
		Animation.PlayAnimation(character, Animations.Movement.Fists.BackwardDash)
		dashVector = -rootPart.CFrame.LookVector * dashSpeed
	end

	local bv = Instance.new("BodyVelocity")
	bv.Parent = rootPart
	bv.MaxForce = Vector3.new(40000, 0, 40000)
	bv.Velocity = dashVector
	Debris:AddItem(bv, 0.2)

	DashVFX.new(character, Direction):Start(Visuals:GetPlayers(character))
end

return Dash
