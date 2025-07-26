local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local REFX = require(ReplicatedStorage.Packages.Refx)

local Effect = REFX.CreateEffect(tostring(script.Name))

local Assets = ReplicatedStorage.Shared.Assets.Visuals.Movesets.Toji["Chain Reel"]

local Rocks = require(ReplicatedStorage.Shared.Modules.RockModule)

local function EmitAll(Parent: Instance, IgnoreNames: {}?)
	local IgnoreList = IgnoreNames or {}

	for _, Descendant in ipairs(Parent:GetDescendants()) do
		if Descendant.ClassName == "ParticleEmitter" and not IgnoreList[Descendant.Parent.Name] then
			local Count = Descendant:GetAttribute("EmitCount")
			if Count then
				task.spawn(function()
					local Delay = Descendant:GetAttribute("EmitDelay")

					if Delay then
						task.wait(Delay)
					end

					Descendant:Emit(Count)
				end)
			end
		end
	end

	return true
end

local function DisableAll(Parent: Instance)
	for _, Descendant in ipairs(Parent:GetDescendants()) do
		if
			Descendant.ClassName == "ParticleEmitter"
			or Descendant.ClassName == "Trail"
			or Descendant.ClassName == "PointLight"
			or Descendant.ClassName == "Beam"
		then
			Descendant.Enabled = false
		end
	end
end

local function EnableAll(Parent: Instance)
	for _, Descendant in ipairs(Parent:GetDescendants()) do
		if
			Descendant.ClassName == "ParticleEmitter"
			or Descendant.ClassName == "Trail"
			or Descendant.ClassName == "Beam"
		then
			Descendant.Enabled = true
		end
	end
end

local DebrisFolder = workspace.World.Debris

local EffectFunctions = {

	Throw = function(RootPart: BasePart, SpinVFX, Dagger)
		DisableAll(SpinVFX)

		local ThrowVFX = Assets.throw:Clone()
		ThrowVFX.take.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(90), math.rad(90)) * CFrame.new(0, -8, 0)
		ThrowVFX.take.Transparency = 1
		ThrowVFX.Parent = DebrisFolder

		local WindTrailEmitter = Assets.DaggerWind.Attachment:Clone()
		WindTrailEmitter.Parent = Dagger.Handle
		print(WindTrailEmitter)

		EmitAll(ThrowVFX, {})
		Debris:AddItem(ThrowVFX, 3)
	end,

	PullEnd = function(RootPart: BasePart) end,

	PullStart = function(characterHit, victimAnimationID)
		local RootPart = characterHit.HumanoidRootPart
		local Humanoid = characterHit:FindFirstChildOfClass("Humanoid")
		local Animator = Humanoid and Humanoid:FindFirstChildOfClass("Animator")
		if not Animator then
			return
		end
		print(victimAnimationID)
		local victimAnim = Animator:LoadAnimation(victimAnimationID)

		victimAnim:Play()

		local ThrowVFX = Assets.throw:Clone()
		ThrowVFX.take.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(90), math.rad(90)) * CFrame.new(0, -8, 0)
		ThrowVFX.take.Transparency = 1
		ThrowVFX.Parent = DebrisFolder
		EmitAll(ThrowVFX, {})
		Debris:AddItem(ThrowVFX, 3)

		return victimAnim
	end,

	Hit = function(Character: Model) end,
}

function Effect:OnConstruct(Character: Model, Animation: AnimationTrack)
	self.Character = Character
	self.DestroyOnEnd = false
	self.MaxLifetime = 30

	print("[Constructed] " .. tostring(script.Name))
end

function Effect:Hit()
	local RootPart = self.Character.PrimaryPart

	print("TELEPORT EFFECT")
	EffectFunctions.Hit(self.Character)
end

function Effect:Throw(Dagger)
	local RootPart = self.Character.PrimaryPart
	_G.NewShake("Shake", RootPart.Position, 2)
	_G.NewShake("Vibration", RootPart.Position, 2)

	EffectFunctions.Throw(RootPart, self.SpinVFX, Dagger)
end

function Effect:PullStart(characterHit, victimAnimationID)
	local RootPart = characterHit.PrimaryPart
	_G.NewShake("Radar", RootPart.Position, 40)

	self.victimAnim = EffectFunctions.PullStart(characterHit, victimAnimationID)
end

function Effect:PullEnd()
	local RootPart = self.Character.PrimaryPart
	_G.NewShake("DownSlam", RootPart.Position, 5)
	if self.victimAnim then
		self.victimAnim:Stop()
	end

	EffectFunctions.PullEnd(RootPart)
end

function Effect:OnStart(Character: Model)
	self.Character = Character
	local RootPart = Character.PrimaryPart

	local SpinVFX = Assets.Spin:Clone()
	SpinVFX.Parent = workspace.World.Debris
	self.SpinVFX = SpinVFX

	local UpdateConnection

	UpdateConnection = RunService.RenderStepped:Connect(function()
		if not Character or not Character.Parent then
			UpdateConnection:Disconnect()
			return
		end

		local BaseCFrame = RootPart.CFrame
		SpinVFX.CFrame = BaseCFrame
			* CFrame.new(-2.038, 0.476, 0.366)
			* CFrame.Angles(math.rad(0), math.rad(180), math.rad(-90))
	end)
end

return Effect
