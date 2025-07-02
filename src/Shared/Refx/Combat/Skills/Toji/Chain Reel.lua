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

	Throw = function(RootPart: BasePart, SpinVFX)
		DisableAll(SpinVFX)

		--EmitAll(Throw, {})
		--Debris:AddItem(Throw, 3)
	end,

	PullEnd = function(RootPart: BasePart) end,

	PullStart = function(RootPart: BasePart)
		local Teleport = Assets.Teleport:Clone()
		Teleport.CFrame = RootPart.CFrame * CFrame.new(0, 0, 0)
		Teleport.Parent = DebrisFolder

		EmitAll(Teleport, {})
		Debris:AddItem(Teleport, 5)
	end,

	Hit = function(Character: Model)
		local Hit = Assets.Hit:Clone()
		Hit.CFrame = Character["Right Arm"].RightGripAttachment.WorldCFrame
		Hit.Parent = DebrisFolder

		EmitAll(Hit, {})
		Debris:AddItem(Hit, 3)
	end,
}

function Effect:OnConstruct(Character: Model, Animation: AnimationTrack)
	self.Character = Character
	self.DestroyOnEnd = false
	self.MaxLifetime = 15

	print("[Constructed] " .. tostring(script.Name))
end

function Effect:Hit()
	local RootPart = self.Character.PrimaryPart

	print("TELEPORT EFFECT")
	EffectFunctions.Hit(self.Character)
end

function Effect:Throw()
	local RootPart = self.Character.PrimaryPart
	_G.NewShake("Shake", RootPart.Position, 5)

	EffectFunctions.Throw(RootPart, self.SpinVFX)
end

function Effect:PullStart()
	local RootPart = self.Character.PrimaryPart
	_G.NewShake("Radar", RootPart.Position, 5)

	EffectFunctions.Teleport(RootPart)
end

function Effect:PullEnd()
	local RootPart = self.Character.PrimaryPart
	_G.NewShake("Shake", RootPart.Position, 5)

	EffectFunctions.Jump(RootPart)
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
