local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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
local Signal = require(ReplicatedStorage.Shared.Modules.GoodSignal)

local Promise = require(ReplicatedStorage.Packages.promise)

local Assets = ReplicatedStorage.Shared.Assets

local NegativeEffects = {
	Stun = require(ReplicatedStorage.Shared.WCS.StatusEffects.Stun),
	Cast = require(ReplicatedStorage.Shared.WCS.StatusEffects.Cast),
}

-- Animation assets
local AnimationAssets = ReplicatedStorage.Shared.Assets.Animations.Movesets.Toji["Chain Reel"]

local VFX

local ClientSignals = {
	Throw = Signal.new(),
	PullStart = Signal.new(),
	PullEnd = Signal.new(),
	Hit = Signal.new(),
}

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
	self._End = Signal.new()

	local Character = self.Character.Instance
	local Humanoid = self.Character.Humanoid
	if not (Character and Humanoid) then
		return
	end

	local Effect = require(ReplicatedStorage.Shared.Refx.Combat.Skills.Toji[tostring(script.Name)])
	VFX = Effect.new(Character)

	self:ApplyCooldown(4)

	local Stun = NegativeEffects.Stun.new(self.Character)
	Stun:Start(6)

	VFX:Start(Visuals:GetPlayers(Character, 10))

	print("[Skill Start]", script.Name)

	local function addTojiDagger()
		local Chains = Assets.Models.Movesets.Toji.Chains:Clone()
		Chains.Parent = Character
		local chainStartPoint = Chains.Start
		local chainEndPoint = Chains.End
		local weldStart = Instance.new("Weld")
		local weldEnd = Instance.new("Weld")
		weldStart.Parent = chainStartPoint
		weldEnd.Parent = chainEndPoint

		local Dagger = Assets.Models.Movesets.Toji.TojiDagger:Clone()
		Dagger.Parent = Character
		local m6d = Instance.new("Motor6D")
		m6d.Name = "Weld"
		m6d.Part0 = Character:FindFirstChild("Left Arm")
		m6d.Part1 = Dagger:FindFirstChild("Handle")
		m6d.C0 = CFrame.new(0.073, -1, -0.567)
		m6d.C1 = CFrame.new(0, 0, -0.543)
		m6d.Parent = m6d.Part1

		local daggerEndAttachment = Dagger.Parts["Torus.006"].Attachment

		weldStart.Part0 = Character:FindFirstChild("Left Arm")
		weldStart.Part1 = chainStartPoint
		weldStart.C0 = CFrame.new(0.073, -1, -0.567)
		weldEnd.Part0 = daggerEndAttachment.Parent
		weldEnd.Part1 = chainEndPoint
		weldEnd.C0 = CFrame.new(daggerEndAttachment.Position)

		return Dagger, m6d
	end

	local TojiDagger, daggerM6d = addTojiDagger()
	local hitbox
	local mainChain

	local daggerVelocity: BodyVelocity

	local function bringbackDagger(characterHit)
		local distance = (TojiDagger.Handle.Position - Character.HumanoidRootPart.Position).Magnitude
		local duration = 0.5
		local speed = distance * 0.99 / duration

		print(characterHit, "is the character hit")
		if characterHit then
			local hrp = characterHit:FindFirstChild("HumanoidRootPart")
			if hrp then
				daggerVelocity.Parent = hrp
				print("[Toji Dagger] Bringing back dagger to character:", hrp)
			end
		end

		local con
		con = RunService.Heartbeat:Connect(function(delta)
			local direction = (Character.HumanoidRootPart.Position - TojiDagger.Handle.Position).Unit
			distance = (TojiDagger.Handle.Position - Character.HumanoidRootPart.Position).Magnitude
			daggerVelocity.Velocity = direction * speed

			if distance < 1 then
				con:Disconnect()
				daggerVelocity.Velocity = Vector3.new(0, 0, 0)
			end
		end)
		Promise.delay(duration):andThen(function()
			con:Disconnect()
			daggerVelocity.Velocity = Vector3.new(0, 0, 0)
			TojiDagger:Destroy()
			daggerVelocity:Destroy()
			Character:FindFirstChild("Chains"):Destroy()
			self._End:Fire()
		end)
	end

	local function bindCharacter(character)
		local hrp = character:FindFirstChild("HumanoidRootPart")
		local weld = Instance.new("Weld")
		weld.Part0 = TojiDagger.Handle
		weld.Part1 = hrp
		weld.Parent = TojiDagger.Handle

		-- make them play animation till they reach end point
	end

	local function onChainHit(target)
		bindCharacter(target.Parent)
		print("[Chain Hit] Target:", target)
		mainChain:cancel()
		hitbox:Disconnect()
		self:PullStart()
		bringbackDagger(target.Parent)
	end

	local function addHitbox()
		local hbSize = Vector3.new(8, 8, 8)
		local hbOffset = Vector3.new(0, 0, 0)
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude
		overlapParams.FilterDescendantsInstances = { Character, TojiDagger }
		local DebounceList = {}

		local hb
		hb = RunService.Heartbeat:Connect(function(delta)
			local calculatedCFrame = TojiDagger.Handle.CFrame * CFrame.new(hbOffset)
			local hits = workspace:GetPartBoundsInBox(calculatedCFrame, hbSize, overlapParams)
			for _, hit in pairs(hits) do
				if
					not DebounceList[hit]
					and hit:IsA("BasePart")
					and hit.Parent
					and hit.Parent:FindFirstChild("Humanoid")
				then
					print("[Chain Hit] Hit detected:", hit.Parent)
					DebounceList[hit] = true
					onChainHit(hit)
					hb:Disconnect()
					break
				end
			end
		end)

		return hb
	end

	local function throwDagger()
		daggerM6d:Destroy()

		TojiDagger.Handle.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1.5)

		local forwardDir = Character.HumanoidRootPart.CFrame.lookVector * 60
		daggerVelocity = Instance.new("BodyVelocity")
		daggerVelocity.Velocity = forwardDir
		daggerVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		daggerVelocity.Parent = TojiDagger.Handle
		daggerVelocity.P = math.huge

		hitbox = addHitbox()

		mainChain = Promise.resolve():andThenCall(Promise.delay, 3):andThen(function()
			hitbox:Disconnect()
			self:PullStart()
			bringbackDagger()
		end)

		print("[Toji Dagger] Throwing dagger with tween")
	end

	Promise.delay(2):andThen(function()
		self:Throw()
		throwDagger()
	end)

	self._End:Wait()

	self.Ended:Once(function()
		print("[Skill End]", script.Name)
		Stun:End()
	end)
end

function Skill:Throw()
	ClientSignals.Throw:Fire()
	VFX:Throw()
end

WCS.DefineMessage(Skill.Throw, {
	Type = "Event",
	Destination = "Client",
})

function Skill:Hit(characterHit)
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
	ClientSignals.PullStart:Fire()
	--	VFX:PullStart()
end

WCS.DefineMessage(Skill.PullStart, {
	Type = "Event",
	Destination = "Client",
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

	local chainSpinTrack = Animator:LoadAnimation(Animations.ChainSpin)
	chainSpinTrack:Play()
	print("[Chain Spin Animation Started]")
	-- instead you will wait for the throw message from the server
	ClientSignals.Throw:Once(function()
		print("T_T")
		chainSpinTrack:Stop()
	end)
	ClientSignals.Throw:Wait()
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

	local function throwPullAnimation()
		throwHoldAnimationInitPromise:cancel()
		throwStartTrack:Stop()
		throwHoldTrack:Stop()
		throwPullTack:Play()
	end

	ClientSignals.PullStart:Once(function()
		print("[Pull Start Animation]")
		throwPullAnimation()
	end)

	self.Ended:Once(function() end)
end

return Skill
