local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local REFX = require(ReplicatedStorage.Packages.Refx)
local Animation = require(ReplicatedStorage.Shared.Modules.Animation)

local Effect = REFX.CreateEffect(tostring(script.Name))

local Assets = ReplicatedStorage.Shared.Assets.Visuals.Movesets.BlackLeg["Projectile Kick"]

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

function Effect:FireTornado(Direction, duration)
	_G.NewShake("Radar", self.RootPart.Position, 5)

	DisableAll(self.flareVFX)

	local tornadoVFX = Assets.Tornado:Clone()
	tornadoVFX.Anchored = false
	tornadoVFX.Parent = workspace.World.Debris
	--	game.Debris:AddItem(tornadoVFX, 5 + duration)
	tornadoVFX.CFrame = CFrame.new(self.RootPart.Position + Vector3.new(0, 1, 0))
		* CFrame.Angles(math.rad(90), math.rad(0), math.rad(0))

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bv.Velocity = Direction
	bv.P = math.huge
	bv.Parent = tornadoVFX

	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	EmitAll(tornadoVFX)

	task.wait(duration)
	tornadoVFX.Anchored = true
	DisableAll(tornadoVFX)
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

function Effect:StarterWind()
	local offset = CFrame.new(0, -1.75, 0)
	local flareVFX = Assets.StarterWind:Clone()
	flareVFX.Anchored = false
	flareVFX.Parent = workspace.World.Debris
	game.Debris:AddItem(flareVFX, 8)

	-- create a weld to the character's root part
	local weld = Instance.new("ManualWeld")
	weld.Part0 = self.RootPart
	weld.Part1 = flareVFX
	weld.C0 = offset
	weld.Parent = flareVFX

	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	EmitAll(flareVFX)

	self.flareVFX = flareVFX
end

function Effect:End()
	task.wait(4)
	_G.NewShake("Stop", self.RootPart.Position, 5)
end

function Effect:_startEffects(character: Model)
	local HRP = character:FindFirstChild("HumanoidRootPart")
	self:StarterWind()
	_G.NewShake("Vibrate", HRP.Position, 5)
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
