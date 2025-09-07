local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local REFX = require(ReplicatedStorage.Packages.Refx)
local Animation = require(ReplicatedStorage.Shared.Modules.Animation)

local Effect = REFX.CreateEffect(tostring(script.Name))

local Assets = ReplicatedStorage.Shared.Assets.Visuals.Movesets.BlackLeg["Concasser"]

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

function Effect:Leap()
	_G.NewShake("Radar", self.RootPart.Position, 5)

	local leapVFX = Assets.LeapUp:Clone()
	leapVFX.Anchored = true
	leapVFX.Parent = workspace.World.Debris
	game.Debris:AddItem(leapVFX, 5)
	leapVFX.Position = self.RootPart.Position + Vector3.new(0, -1.4, 0)

	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	EmitAll(leapVFX)
end

function Effect:LandImpact()
	task.wait(0.075)

	_G.NewShake("Explosion", self.RootPart.Position, 5)
	local impactPosition = self.RootPart.Position + Vector3.new(0, -3, -0.5)
	local impactExplosion = Assets.Impact:Clone()
	impactExplosion.CanCollide = false
	impactExplosion.Anchored = true
	impactExplosion.Parent = workspace.World.Debris
	impactExplosion.Position = impactPosition
	game.Debris:AddItem(impactExplosion, 5)

	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	EmitAll(impactExplosion)
end

function Effect:FlareNotify()
	_G.NewShake("Bump2", self.RootPart.Position, 5)

	local offset = CFrame.new(0, -0.75, -3.75)
	local flareVFX = Assets.Notify:Clone()
	flareVFX.Anchored = false
	flareVFX.Parent = workspace.World.Debris
	game.Debris:AddItem(flareVFX, 5)

	-- create a weld to the character's root part
	local weld = Instance.new("ManualWeld")
	weld.Part0 = self.RootPart
	weld.Part1 = flareVFX
	weld.C0 = CFrame.new(0, 0, 0)
	weld.Parent = flareVFX

	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	EmitAll(flareVFX)
end

function Effect:End()
	task.wait(4)
	_G.NewShake("Stop", self.RootPart.Position, 5)
end

function Effect:_startEffects(character: Model)
	local HRP = character:FindFirstChild("HumanoidRootPart")

	--_G.NewShake("Bump2", HRP.Position, 5)
end

function Effect:OnStart(Character: Model)
	self.Character = Character
	self.DestroyOnEnd = false
	self.MaxLifetime = 40

	print("[Effect Start]", script.Name)
	local RootPart = Character.PrimaryPart
	self.Character = Character
	self.RootPart = RootPart

	self:_startEffects(Character)

	print("SKILL VFX: " .. script.Name)
end

return Effect
