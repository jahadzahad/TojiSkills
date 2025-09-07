local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local REFX = require(ReplicatedStorage.Packages.Refx)
local Animation = require(ReplicatedStorage.Shared.Modules.Animation)

local Effect = REFX.CreateEffect(tostring(script.Name))

local Assets = ReplicatedStorage.Shared.Assets.Visuals.Movesets.BlackLeg["Triple Kicks"]

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

local EffectFunctions = {}

function Effect:Kick1()
	_G.NewShake("Bump2", self.RootPart.Position, 5)

	EmitAll(self.Assets.Kick1)
end

function Effect:Kick2()
	_G.NewShake("Bump2", self.RootPart.Position, 5)

	EmitAll(self.Assets.Kick2)
end

function Effect:Kick3()
	_G.NewShake("Bump2", self.RootPart.Position, 5)

	EmitAll(self.Assets.Kick3)
end

function Effect:End()
	task.wait(4)
	_G.NewShake("Stop", self.RootPart.Position, 5)
end

function Effect:_startEffects(character: Model)
	local HRP = character:FindFirstChild("HumanoidRootPart")

	self.Assets = Assets.TripleKickEffects:Clone()
	self.Assets.Parent = workspace.World.Debris
	game.Debris:AddItem(self.Assets, 15)
	local weld1 = Instance.new("ManualWeld")
	weld1.Part0 = HRP
	weld1.Part1 = self.Assets.Root
	weld1.Parent = self.Assets.Root
	weld1.C0 = CFrame.new(0, 0, 0)

	_G.NewShake("Bump", HRP.Position, 5)
end

function Effect:OnStart(Character: Model)
	self.Character = Character
	self.DestroyOnEnd = false
	self.MaxLifetime = 40

	print("[Effect Start]", script.Name)
	local RootPart = Character.HumanoidRootPart
	self.Character = Character
	self.RootPart = RootPart

	self:_startEffects(Character)

	print("SKILL VFX: " .. script.Name)
end

return Effect
