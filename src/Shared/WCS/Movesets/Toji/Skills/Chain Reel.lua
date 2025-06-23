local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WCS = require(ReplicatedStorage.Packages.WCS)
local Maid = require(ReplicatedStorage.Packages.Maid)

local Animation = require(ReplicatedStorage.Shared.Modules.Animation)
local Sound = require(ReplicatedStorage.Shared.Modules.Sound)
local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)
local Ragdoll = require(ReplicatedStorage.Shared.Modules.Ragdoll)
local Velocity = require(ReplicatedStorage.Shared.Modules.Velocity)
local DarwinBox = require(ReplicatedStorage.Shared.Modules.Darwin.DarwinBox)

local NegativeEffects = {
	Stun = require(ReplicatedStorage.Shared.WCS.StatusEffects.Stun),
	Cast = require(ReplicatedStorage.Shared.WCS.StatusEffects.Cast),
}

-- Animation assets
local AnimationAssets = ReplicatedStorage.Shared.Assets.Animations.Movesets.Toji["Chain Reel"]

local VFX

local Animations = {
	ChainSpin = AnimationAssets:WaitForChild("Chain Spin"),
	ThrowStart = AnimationAssets:WaitForChild("Throw_Start"),
	ThrowHold = AnimationAssets:WaitForChild("Throw_Hold"),
	ThrowPull = AnimationAssets:WaitForChild("Throw_Pull"),
	Victim = AnimationAssets:WaitForChild("Victim"),
}

local Skill = WCS.RegisterSkill(tostring(script.Name))

function Skill:OnStartServer()
	self.Maid = Maid.new()

	local Character = self.Character.Instance
	local Humanoid = self.Character.Humanoid
	if not (Character and Humanoid) then
		return
	end

	local Effect = require(ReplicatedStorage.Shared.Refx.Movesets.Enel[tostring(script.Name)])
	VFX = Effect.new(Character)

	self:ApplyCooldown(4)

	local Stun = NegativeEffects.Stun.new(self.Character)
	Stun:Start(3)

	VFX:Start(Visuals:GetPlayers(Character, 10))

	print("[Skill Start]", script.Name)

	self.Ended:Once(function()
		Stun:End()
	end)
end

function Skill:Hit()
	VFX:Hit()
end

WCS.DefineMessage(Skill.Hit, {
	Type = "Event",
	Destination = "Server",
})

function Skill:Grab()
	VFX:Grab()
end

WCS.DefineMessage(Skill.Grab, {
	Type = "Event",
	Destination = "Server",
})

function Skill:Throw()
	VFX:Throw()
end

WCS.DefineMessage(Skill.Throw, {
	Type = "Event",
	Destination = "Server",
})

function Skill:Teleport()
	VFX:Teleport()
end

WCS.DefineMessage(Skill.Teleport, {
	Type = "Event",
	Destination = "Server",
})

function Skill:Jump()
	VFX:Jump()
end

WCS.DefineMessage(Skill.Jump, {
	Type = "Event",
	Destination = "Server",
})

function Skill:Slam()
	VFX:Slam()
end

WCS.DefineMessage(Skill.Slam, {
	Type = "Event",
	Destination = "Server",
})

function Skill:OnStartClient()
	local Character = self.Character.Instance
	local RootPart = Character and Character.PrimaryPart
	if not RootPart then
		return
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local Animator = Humanoid and Humanoid:FindFirstChildOfClass("Animator")
	if not Animator then
		return
	end

	local AnimationTrack = Animator:LoadAnimation(Animations.User)
	AnimationTrack:Play()

	AnimationTrack:GetMarkerReachedSignal("Hitbox"):Once(function()
		local Forward = RootPart.CFrame.LookVector
		RootPart.CFrame = RootPart.CFrame + (Forward * 20)

		local OverlapParameters = OverlapParams.new()
		OverlapParameters.FilterType = Enum.RaycastFilterType.Exclude
		OverlapParameters.FilterDescendantsInstances = { Character }

		local HitboxCFrame = RootPart.CFrame * CFrame.new(0, 0, 2.5)
		local HitboxSize = Vector3.new(5, 6, 10)

		DarwinBox.TrackerBox({
			Time = 0.25,
			Base = RootPart,
			CFrame = HitboxCFrame,
			Size = HitboxSize,
			Visual = true,
			OverlapParams = OverlapParameters,
			Duration = 0.25,
			ModelParams = { Once = true, Character = true },
		}, function(HitList)
			local Closest, ClosestDistance

			for _, Victim in ipairs(HitList) do
				if Victim and Victim ~= Character and Victim:FindFirstChild("HumanoidRootPart") then
					local Dist = (Victim.HumanoidRootPart.Position - RootPart.Position).Magnitude
					if not ClosestDistance or Dist < ClosestDistance then
						Closest = Victim
						ClosestDistance = Dist
					end
				end
			end

			if not Closest then
				self:End()
				return
			end

			local VictimRoot = Closest:FindFirstChild("HumanoidRootPart")
			local VictimHumanoid = Closest:FindFirstChildOfClass("Humanoid")
			local VictimAnimator = VictimHumanoid and VictimHumanoid:FindFirstChildOfClass("Animator")

			if not (VictimRoot and VictimHumanoid and VictimAnimator) then
				self:End()
				return
			end

			RootPart.Anchored = true
			VictimRoot.Anchored = true

			VictimRoot.CFrame = RootPart.CFrame

			local Animation2 = Animator:LoadAnimation(Animations.Hit)
			Animation2:Play()
			self:Hit()

			local Animation3 = VictimAnimator:LoadAnimation(Animations.Victim)
			Animation3:Play()

			Animation2:GetMarkerReachedSignal("Indicator 2"):Once(function()
				self:Grab()
			end)

			Animation2:GetMarkerReachedSignal("Indicator 3"):Once(function()
				self:Throw()
			end)

			Animation2:GetMarkerReachedSignal("Indicator 4"):Once(function()
				self:Teleport()
			end)

			Animation2:GetMarkerReachedSignal("Indicator 5"):Once(function()
				self:Jump()
			end)

			Animation2:GetMarkerReachedSignal("Indicator 6"):Once(function()
				self:Slam()
			end)

			Animation2.Stopped:Once(function()
				RootPart.Anchored = false
				VictimRoot.Anchored = false

				self:End()
			end)
		end)
	end)

	self.Ended:Once(function() end)
end

return Skill
