local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local WCS = require(ReplicatedStorage.Packages.WCS)
local Maid = require(ReplicatedStorage.Packages.Maid)

local Animation = require(ReplicatedStorage.Shared.Modules.Animation)
local Sound = require(ReplicatedStorage.Shared.Modules.Sound)
local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)
local Ragdoll = require(ReplicatedStorage.Shared.Modules.Ragdoll)
local Velocity = require(ReplicatedStorage.Shared.Modules.Velocity)
local Hitbox = require(ReplicatedStorage.Shared.Modules.Hitbox)

local Promise = require(ReplicatedStorage.Packages.promise)

local Assets = ReplicatedStorage.Shared.Assets

local NegativeEffects = {
	Stun = require(ReplicatedStorage.Shared.WCS.StatusEffects.Stun),
	Cast = require(ReplicatedStorage.Shared.WCS.StatusEffects.Cast),
}

-- Animation assets
local AnimationAssets = ReplicatedStorage.Shared.Assets.Animations.Movesets.Toji["Chain Reel"]

local VFX

local Animations = {
	ChainSpin = AnimationAssets:WaitForChild("ChainSpin"),
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

	local Effect = require(ReplicatedStorage.Shared.Refx.Movesets.Toji[tostring(script.Name)])
	VFX = Effect.new(Character)

	self:ApplyCooldown(4)

	local Stun = NegativeEffects.Stun.new(self.Character)
	Stun:Start(6)

	VFX:Start(Visuals:GetPlayers(Character, 10))

	print("[Skill Start]", script.Name)

	task.wait(10)

	self.Ended:Once(function()
		print("[Skill End]", script.Name)
		Stun:End()
	end)
end

function Skill:Throw()
	VFX:Throw()
end

WCS.DefineMessage(Skill.Throw, {
	Type = "Event",
	Destination = "Server",
})

function Skill:Hit()
	VFX:Hit()
end

WCS.DefineMessage(Skill.Hit, {
	Type = "Event",
	Destination = "Server",
})

function Skill:PullEnd()
	VFX:PullEnd()
end

WCS.DefineMessage(Skill.PullEnd, {
	Type = "Event",
	Destination = "Server",
})

function Skill:PullStart()
	VFX:PullStart()
end

WCS.DefineMessage(Skill.PullStart, {
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

	local function addTojiDagger()
		local Dagger = Assets.Models.Movesets.Toji.TojiDagger:Clone()
		Dagger.Parent = Character
		local m6d = Instance.new("Motor6D")
		m6d.Name = "Weld"
		m6d.Part0 = Character:FindFirstChild("Left Arm")
		m6d.Part1 = Dagger:FindFirstChild("Handle")
		m6d.C0 = CFrame.new(0.073, -1, -0.567)
		m6d.C1 = CFrame.new(0, 0, -0.543)
		m6d.Parent = m6d.Part1

		return Dagger, m6d
	end

	local TojiDagger, daggerM6d = addTojiDagger()

	-- play the chain spin animation for 0.5 seconds before starting the skill
	local chainSpinTrack = Animator:LoadAnimation(Animations.ChainSpin)
	chainSpinTrack:Play()
	print("[Chain Spin Animation Started]")
	task.wait(2)
	print("[Chain Spin Animation Finished]")
	chainSpinTrack:Stop()

	local throwStartTrack = Animator:LoadAnimation(Animations.ThrowStart)
	local throwHoldTrack = Animator:LoadAnimation(Animations.ThrowHold)
	local throwPullTack = Animator:LoadAnimation(Animations.ThrowPull)

	throwStartTrack:Play()

	local throwHoldAnimationInitPromise = Promise.delay(throwStartTrack.length):andThen(
		function() -- starts the throw hold animation after the throw start animation finishes
			throwHoldTrack:Play()
		end
	)

	-- connect vfx to throw start
	-- start hitbox on throw start

	local function throwPullAnimation()
		throwHoldAnimationInitPromise:cancel()
		throwStartTrack:Stop()
		throwHoldTrack:Stop()

		throwPullTack:Play()
	end

	local function onChainHit(target, WCStarget)
		print("[Chain Hit] Target:", target, "WCSTarget:", WCStarget)
		throwPullAnimation()
	end

	local function addHitbox()
		local hb = Hitbox:createHitbox({
			Caster = TojiDagger.Handle,
			Size = Vector3.new(6, 6, 6),
			Offset = CFrame.new(0, 0, -4),
			HitType = "SingleTarget",
			BlockBreak = true,
			Debris = 0.1,
			Visualize = true,
		}, function(target, WCStarget)
			-- This fires when a target just got hit
			onChainHit(target, WCStarget)
		end)

		return hb
	end

	local function throwDagger()
		daggerM6d:Destroy()

		TojiDagger.Handle.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1.5)

		local forwardDir = Character.HumanoidRootPart.CFrame.lookVector * 60
		local forwardBodyVelocity = Instance.new("BodyVelocity")
		forwardBodyVelocity.Velocity = forwardDir
		forwardBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		forwardBodyVelocity.Parent = TojiDagger.Handle
		forwardBodyVelocity.P = math.huge

		addHitbox()

		--local outTween =
		--	TweenService:Create(TojiDagger.Handle, TweenInfo.new(10, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		--		CFrame = CFrame.lookAlong(Character.HumanoidRootPart.CFrame * forwardDir, forwardDir)
		--			* CFrame.Angles(math.rad(-90), 0, 0),
		--	})
		--			:Play()

		--outTween:Play()
		print("[Toji Dagger] Throwing dagger with tween")
		--outTween.Completed:Wait()
	end

	throwDagger()

	self.Ended:Once(function() end)
end

return Skill
