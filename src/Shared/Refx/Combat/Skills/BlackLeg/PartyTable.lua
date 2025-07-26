local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local REFX = require(ReplicatedStorage.Packages.Refx)
local Animation = require(ReplicatedStorage.Shared.Modules.Animation)

local Effect = REFX.CreateEffect(tostring(script.Name))

local Assets = ReplicatedStorage.Shared.Assets.Visuals.Movesets.BlackLeg["PartyTable"]

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

function Effect:Floor()
	local Floor = self.Scene:FindFirstChild("Floor")
	if Floor then
		EmitAll(Floor)
	else
		warn("No Floor found in the scene for Massacre Counter effect.")
	end
end
function Effect:Blood()
	local Blood = self.Scene:FindFirstChild("Blood")
	if Blood then
		EmitAll(Blood)
	else
		warn("No Blood found in the scene for Massacre Counter effect.")
	end
end
function Effect:Jump()
	local Jump = self.Scene:FindFirstChild("Jump")
	if Jump then
		EmitAll(Jump)
	else
		warn("No Jump found in the scene for Massacre Counter effect.")
	end
end
function Effect:Boom()
	local Boom = self.Scene:FindFirstChild("Boom")
	if Boom then
		EmitAll(Boom)
	else
		warn("No Boom found in the scene for Massacre Counter effect.")
	end
end

function Effect:Hit(characterHit, victimAnimationID)
	-- This function is called when the skill hits a character
	-- It will play the victim animation on the client
	local RootPart = characterHit.HumanoidRootPart
	local Humanoid = characterHit:FindFirstChildOfClass("Humanoid")
	local Animator = Humanoid and Humanoid:FindFirstChildOfClass("Animator")
	if not Animator then
		return
	end
	print(victimAnimationID)
	local victimAnim = Animator:LoadAnimation(victimAnimationID)

	victimAnim:Play()

	function playCamera()
		Animation.PlayCameraAnimation(self.CameraAnimation, self.Character)
	end
end

function Effect:End()
	DisableAll(self.flameWindVFX)
	DisableAll(self.windVFX)
	task.wait(4)
	_G.NewShake("Stop", self.RootPart.Position, 5)
end

function Effect:_startEffects(character: Model)
	local HRP = character:FindFirstChild("HumanoidRootPart")

	_G.NewShake("Bump2", HRP.Position, 5)
	--	_G.NewShake("Vibrate", HRP.Position, 5)

	local windVFX = Assets.Wind:Clone()
	windVFX.Parent = workspace.World.Debris
	Debris:AddItem(windVFX, 15)

	local flameWindVFX = Assets.FlameWind:Clone()
	flameWindVFX.Parent = workspace.World.Debris
	Debris:AddItem(flameWindVFX, 15)

	local weld1 = Instance.new("ManualWeld")
	weld1.Part0 = HRP
	weld1.Part1 = windVFX
	weld1.Parent = windVFX
	weld1.C0 = CFrame.new(0, 0, 0)

	local weld2 = Instance.new("ManualWeld")
	weld2.Part0 = HRP
	weld2.Part1 = flameWindVFX
	weld2.Parent = flameWindVFX
	weld2.C0 = CFrame.new(0, 0, 0)

	self.flameWindVFX = flameWindVFX
	self.windVFX = windVFX

	EmitAll(windVFX)
	EnableAll(windVFX)

	task.delay(0.1, function()
		EmitAll(flameWindVFX)
		EnableAll(flameWindVFX)
	end)
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
