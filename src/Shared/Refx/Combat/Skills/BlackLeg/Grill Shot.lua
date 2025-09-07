local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local REFX = require(ReplicatedStorage.Packages.Refx)
local Animation = require(ReplicatedStorage.Shared.Modules.Animation)

local Effect = REFX.CreateEffect(tostring(script.Name))

local Assets = ReplicatedStorage.Shared.Assets.Visuals.Movesets.BlackLeg["Grill Shot"]

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

function Effect:CastKick()
	_G.NewShake("Slam", self.RootPart.Position, 5)

	local offset = CFrame.new(0, -0.75, -3.75)
	local vfx = Assets.Effects:Clone()
	vfx.Anchored = false
	vfx.Parent = workspace.World.Debris
	game.Debris:AddItem(vfx, 5)

	-- creat a weld to the character's root part
	local weld = Instance.new("ManualWeld")
	weld.Part0 = self.RootPart
	weld.Part1 = vfx
	weld.C0 = offset
	weld.Parent = vfx

	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	EmitAll(vfx.NormalTag)
end

function Effect:KickHit()
	_G.NewShake("Bump2", self.RootPart.Position, 5)

	local offset = CFrame.new(0, -0.75, -3.75)
	local vfx = Assets.Effects:Clone()
	vfx.Anchored = false
	vfx.Parent = workspace.World.Debris
	game.Debris:AddItem(vfx, 5)

	-- create a weld to the character's root part
	local weld = Instance.new("ManualWeld")
	weld.Part0 = self.RootPart
	weld.Part1 = vfx
	weld.C0 = offset
	weld.Parent = vfx

	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	EmitAll(vfx.FireTag)
end

function Effect:KickEnd(TargetRootPart)
	_G.NewShake("SmallExplosion", self.RootPart.Position, 5)

	local offset = CFrame.new(0, -0.75, -3.75)
	local vfx1 = Assets.Effects:Clone()
	vfx1.Anchored = false
	vfx1.Parent = workspace.World.Debris
	game.Debris:AddItem(vfx1, 5)

	-- create a weld to the character's root part
	local weld = Instance.new("ManualWeld")
	weld.Part0 = self.RootPart
	weld.Part1 = vfx1
	weld.C0 = offset
	weld.Parent = vfx1

	local vfx2 = Assets.Effects:Clone()
	vfx2.Anchored = false
	vfx2.Parent = workspace.World.Debris
	game.Debris:AddItem(vfx2, 5)

	-- create a weld to the character's root part
	local weld2 = Instance.new("ManualWeld")
	weld2.Part0 = TargetRootPart
	weld2.Part1 = vfx2
	weld2.C0 = CFrame.new(0, 0, 0)
	weld2.Parent = vfx2

	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	EmitAll(vfx1.Attachment)
	EmitAll(vfx2.BigFireTag)
end

function Effect:End()
	task.wait(4)
	_G.NewShake("Stop", self.RootPart.Position, 5)
end

function Effect:_startEffects(character: Model)
	local HRP = character:FindFirstChild("HumanoidRootPart")

	_G.NewShake("Bump2", HRP.Position, 5)
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
