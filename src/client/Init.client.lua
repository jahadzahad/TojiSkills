local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages

local REFX = require(Packages.Refx)
local WCS = require(Packages.WCS)

local WCSClient = WCS.CreateClient()
WCSClient:RegisterDirectory(ReplicatedStorage.Shared.WCS.Movesets)
WCSClient:RegisterDirectory(ReplicatedStorage.Shared.WCS.StatusEffects)

WCSClient:Start()

REFX.Register(ReplicatedStorage.Shared.Refx.Movesets.Enel)
REFX.Register(ReplicatedStorage.Shared.Refx.Movesets.Gojo)
REFX.Register(ReplicatedStorage)
REFX.Start()

require(ReplicatedStorage.Shared.Modules.Darwin.DarwinUtilities).AnimationHandler:PreloadAnimations(
	ReplicatedStorage.Shared.Assets.Animations:GetDescendants(),
	function()
		print("LOADED ANIMATION")
	end
)

require(ReplicatedStorage.Shared.Modules.Darwin.DarwinBox).Setup("FollowBox", nil, 1000)

local Player = Players.LocalPlayer

local function GetCharacterClass()
	return WCS.Character.GetLocalCharacter()
end

UserInputService.InputBegan:Connect(function(Input, Processed)
	if Processed then
		return
	end

	local Character = Player.Character

	if not Character then
		return
	end

	local Class = GetCharacterClass()

	if Input.KeyCode == Enum.KeyCode.Z then
		Class:GetSkillFromString("Chain Reel"):Start()
	elseif Input.KeyCode == Enum.KeyCode.X then
		Class:GetSkillFromString("Massacre Counter"):Start()
	elseif Input.KeyCode == Enum.KeyCode.C then
		Class:GetSkillFromString("El Thor"):Start()
	end
end)

local Camera = workspace.CurrentCamera
local CameraShake = require(ReplicatedStorage.Shared.Modules:WaitForChild("CameraShaker"))

local Shake = CameraShake.new(Enum.RenderPriority.Last.Value, function(ShakeCFrame)
	Camera.CFrame = Camera.CFrame * ShakeCFrame
end)

Shake:Start()

_G.NewShake = function(Preset: string, Position: Vector3?, MaxDistance: number?)
	if Preset == "Stop" then
		CameraShake:Stop()
		return
	end

	CameraShake:Stop()

	local CanShake = true

	if MaxDistance then
		local Character = Player.Character
		if not Character then
			return
		end

		local RootPart = Character:FindFirstChild("HumanoidRootPart")
		if not RootPart then
			return
		end

		local Distance = (RootPart.Position - Position).Magnitude
		if Distance > MaxDistance then
			CanShake = false
		end
	end

	if CanShake then
		Shake:Start()
		Shake:Shake(CameraShake.Presets[Preset])

		return true
	end
end

require(ReplicatedStorage.Shared.Modules.Darwin.DarwinUtilities).CameraService:HeadTrack(999999999)
