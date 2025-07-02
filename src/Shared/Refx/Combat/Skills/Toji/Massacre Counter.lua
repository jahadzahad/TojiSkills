local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local REFX = require(ReplicatedStorage.Packages.Refx)

local Effect = REFX.CreateEffect(tostring(script.Name))

local Assets = ReplicatedStorage.Shared.Assets.Visuals.Movesets.Toji["Massacre Counter"]

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

local EffectFunctions = {
	ImpactFrames = function()
		local Camera = workspace.CurrentCamera

		TweenService:Create(Camera, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			FieldOfView = 25,
		}):Play()

		task.delay(0.15, function()
			TweenService:Create(Camera, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				FieldOfView = 70,
			}):Play()
		end)

		local Steps = {
			[1] = { Brightness = 0, Contrast = 10, Saturation = -1, TintColor = Color3.fromRGB(4, 0, 255) },
			[2] = { Brightness = 0, Contrast = -10, Saturation = -1, TintColor = Color3.fromRGB(0, 83, 255) },
			[3] = { Brightness = -0.2, Contrast = -0.5, Saturation = 0, TintColor = Color3.fromRGB(0, 0, 0) },
			[4] = { Brightness = 0, Contrast = 10, Saturation = -1, TintColor = Color3.fromRGB(255, 255, 255) },
			[5] = { Brightness = 0.1, Contrast = 1, Saturation = 0, TintColor = Color3.fromRGB(4, 0, 255) },
		}

		local Effect = Instance.new("ColorCorrectionEffect")
		Effect.Parent = Lighting

		task.spawn(function()
			for i = 1, #Steps do
				for Property, Value in next, Steps[i] do
					Effect[Property] = Value
				end
				task.wait(0.025)
			end
			Effect:Destroy()
		end)
	end,

	Hand = function(Character: Model)
		local HandPart = Assets:FindFirstChild("Hand"):Clone()
		local Arm = Character:FindFirstChild("Left Arm")
		local Grip = Arm and Arm:FindFirstChild("LeftGripAttachment")

		if not Grip then
			return
		end

		HandPart.CFrame = Grip.WorldCFrame
		HandPart.Parent = workspace.World.Debris

		local Weld = Instance.new("WeldConstraint")
		Weld.Part0 = HandPart
		Weld.Part1 = Arm
		Weld.Parent = HandPart

		return HandPart
	end,
}

function Effect:OnStart(Character: Model)
	self.Character = Character
	--self.DestroyOnEnd = true
	--self.MaxLifetime = 3
	--self.DestroyOnLifecycleEnd = true

	local RootPart = Character.PrimaryPart

	local HandAttachment = EffectFunctions.Hand(Character)

	task.delay(0.5, function()
		_G.NewShake("Vibration", RootPart.Position, 20)
	end)

	task.delay(0.92, function()
		_G.NewShake("BigBump", RootPart.Position, 5)

		EffectFunctions.ImpactFrames()

		_G.NewShake("Vibration", RootPart.Position, 5)

		local Emit = Assets.ElThorEndEmit:Clone()
		local Beam = Assets.FF:Clone()

		Emit.Parent = workspace.World.Debris
		Beam.Parent = workspace.World.Debris

		EmitAll(Emit)
		EmitAll(Beam)

		local UpdateConnection

		UpdateConnection = RunService.RenderStepped:Connect(function()
			if not Character or not Character.Parent then
				UpdateConnection:Disconnect()
				return
			end

			local BaseCFrame = RootPart.CFrame
			Emit.CFrame = BaseCFrame * CFrame.new(0, 0, -46)
			Beam.CFrame = Emit.CFrame * CFrame.new(0, 0, -5)
		end)

		task.delay(1, function()
			if UpdateConnection then
				UpdateConnection:Disconnect()
			end

			DisableAll(Beam)

			Debris:AddItem(Emit, 4)
			Debris:AddItem(Beam, 1)
		end)

		if HandAttachment then
			DisableAll(HandAttachment)

			task.delay(1, function()
				HandAttachment:Destroy()
			end)
		end

		task.delay(1, function()
			_G.NewShake("Shake", RootPart.Position, 20)
		end)
	end)

	print("SKILL VFX: " .. script.Name)
end

return Effect
