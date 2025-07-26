local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WCS = require(ReplicatedStorage.Packages.WCS)
local Maid = require(ReplicatedStorage.Packages.Maid)

local Assets = ReplicatedStorage.Shared.Assets
local Animation = require(ReplicatedStorage.Shared.Modules.Animation)
local Sound = require(ReplicatedStorage.Shared.Modules.Sound)
local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)
local Ragdoll = require(ReplicatedStorage.Shared.Modules.Ragdoll)
local Velocity = require(ReplicatedStorage.Shared.Modules.Velocity)
local Signal = require(ReplicatedStorage.Shared.Modules.GoodSignal)

local NegativeEffects = {
	Stun = require(ReplicatedStorage.Shared.WCS.StatusEffects.Stun),
	Cast = require(ReplicatedStorage.Shared.WCS.StatusEffects.Cast),
}

-- Animation assets
local AnimationAssets = ReplicatedStorage.Shared.Assets.Animations.Movesets.Toji[script.Name]

local VFX

local Animations = {
	User = AnimationAssets:WaitForChild("User"),
	Victim = AnimationAssets:WaitForChild("Victim"),
	Camera = AnimationAssets:WaitForChild("Camera"),
}

local Skill = WCS.RegisterSkill(tostring(script.Name))

function Skill:OnStartServer()
	self.Maid = Maid.new()

	local Character = self.Character.Instance
	local Humanoid = self.Character.Humanoid
	if not (Character and Humanoid) then
		return
	end

	local Effect = require(ReplicatedStorage.Shared.Refx.Combat.Skills.Toji[tostring(script.Name)])
	VFX = Effect.new(Character, Animations.Camera)
	VFX:Start(Visuals:GetPlayers(Character, 10))

	self:ApplyCooldown(4)
	local Stun = NegativeEffects.Stun.new(self.Character)
	Stun:Start(6)

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

	function counterHitboxQuery()
		local hbSize = Vector3.new(8, 8, 8)
		local hbOffset = Vector3.new(0, 0, -4)
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Exclude
		overlapParams.FilterDescendantsInstances = { Character, TojiDagger }

		local calculatedCFrame = Character.HumanoidRootPart.CFrame * CFrame.new(hbOffset)
		local hits = workspace:GetPartBoundsInBox(calculatedCFrame, hbSize, overlapParams)
		for _, hit in pairs(hits) do
			if hit:IsA("BasePart") and hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
				print("[Counter] Hit detected:", hit.Parent)
				return hit.Parent
			end
		end
	end

	local cutsceneVictimOffset = CFrame.new(0.19, 0, 0.175) * CFrame.Angles(0, 0, math.rad(0))
	local characterHit = counterHitboxQuery()
	if characterHit then
		local RootPart = characterHit:FindFirstChild("HumanoidRootPart")
		self.VictimRoot = RootPart
		RootPart.Anchored = true
		RootPart.CFrame = Character.HumanoidRootPart.CFrame * cutsceneVictimOffset
		Character.HumanoidRootPart.Anchored = true
		Character.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame
		VFX:Hit(characterHit, Animations.Victim) -- will run victim animation on client
	end

	print("[Skill Start]", script.Name)
	self._End = Signal.new()
	self._End:Fire()
	task.wait(233 / 60)
	self.Ended:Once(function()
		Character.HumanoidRootPart.Anchored = false
		if self.VictimRoot then
			self.VictimRoot.Anchored = false
		end
		TojiDagger:Destroy()
		print("[Skill End]", script.Name)
		Stun:End()
	end)
end
function Skill:Blood()
	VFX:Blood()
end
WCS.DefineMessage(Skill.Blood, {
	Type = "Event",
	Destination = "Server",
})

function Skill:Floor()
	VFX:Floor()
end
WCS.DefineMessage(Skill.Floor, {
	Type = "Event",
	Destination = "Server",
})

function Skill:Boom()
	VFX:Boom()
end
WCS.DefineMessage(Skill.Boom, {
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

	local userAnimation = Animator:LoadAnimation(Animations.User)
	userAnimation:Play()
	print("[User Animation Started]")

	local con = userAnimation.KeyframeReached:Connect(function(kfName)
		if Skill[kfName] then
			print(kfName .. " Event!")
			self[kfName](self)
		end
	end)

	self.Ended:Once(function() end)
end

return Skill
