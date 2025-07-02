local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Animations = ReplicatedStorage.Shared.Assets.Animations
 
local Animation = {}
Animation.Loaded = {}

local function getAnimator(character)
	if not character then return nil end

	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid and humanoid:FindFirstChild("Animator") then
		return humanoid.Animator
	end

	local animController = character:FindFirstChildOfClass("AnimationController")
	if animController and animController:FindFirstChild("Animator") then
		return animController.Animator
	end

	return nil
end

function Animation.LoadAnimations(Character: Model)
	local Animator = getAnimator(Character)
	
	Animation.Loaded[Character] = {}
	
	for _, Track in pairs(Animations:GetDescendants()) do
		if Track:IsA("Animation") then
			Animation.Loaded[Character][Track] = Animator:LoadAnimation(Track)
		end
	end
end

function Animation.GetAnimation(Character, Track)
	if not Animation.Loaded[Character] or not Animation.Loaded[Character][Track] then
		warn("Animation not found...")
		warn("For Character:", Character, "Track Requested:", Track)
	end
	return Animation.Loaded[Character][Track]
end

function Animation.IsLoaded(Character)
	if Animation.Loaded[Character] then
		return true
	else
		return false
	end
end

function Animation.Unload(Character)
	if Animation.Loaded[Character] then
		Animation.Loaded[Character] = {}
	end
end

function Animation.PlayAnimation(Character, Track)
	if not Animation.Loaded[Character] or not Animation.Loaded[Character][Track] then
		warn("Animation not found...")
		warn("For Character:", Character, "Track Requested:", Track)
	end
	Animation.Loaded[Character][Track]:Play(.1)
end

function Animation.StopAnimation(Character,Track)
	if not Animation.Loaded[Character] or not Animation.Loaded[Character][Track] then
		warn("Animation not found...")
		warn("For Character:", Character, "Track Requested:", Track)
	end
	Animation.Loaded[Character][Track]:Stop(.1)
end

function Animation.IsPlaying(Character, Track)
	if Animation.Loaded[Character][Track].IsPlaying then
		return true
	else
		return false
	end
end

function Animation.PlayCameraAnimation(CamAnim: Animation, CharacterFocus)
	local Player = game:GetService("Players").LocalPlayer
	local Character = Player.Character
	local CameraRig = CamAnim:GetAttribute("Marbles") and ReplicatedStorage.StoragePackage.Assets.Models.Misc.CutsceneCameraPart:Clone() or ReplicatedStorage.StoragePackage.Assets.Models.Misc.CamRigWithLetterBox:Clone()
	CameraRig.Parent = CamAnim:GetAttribute("Marbles") and (CharacterFocus and CharacterFocus or Character) or workspace
	local Weld = CameraRig:FindFirstChild("CutsceneCameraPart")
	if CamAnim:GetAttribute("Marbles") then
		Weld.Parent = CharacterFocus and CharacterFocus.PrimaryPart or Character.PrimaryPart
		Weld.Part0 = CharacterFocus and CharacterFocus.PrimaryPart or Character.PrimaryPart
	else
		CameraRig.RootPart.CFrame = CharacterFocus and CharacterFocus.PrimaryPart.CFrame * CFrame.fromOrientation(math.rad(0), math.rad(180), math.rad(0)) or Character.PrimaryPart.CFrame * CFrame.fromOrientation(math.rad(0), math.rad(180), math.rad(0))
	end
	
	local FOV = CamAnim:FindFirstChildOfClass("Folder")
	local FrameTime = 0
	
	if CamAnim:GetAttribute("Offset") then
		CameraRig.RootPart.CFrame = CameraRig.RootPart.CFrame * CamAnim:GetAttribute("Offset")
	end
	
	local Anim = nil
	
	if CamAnim:GetAttribute("Marbles") then
		Anim = Animation.Loaded[Character][CamAnim]
		Anim:Play()
	else
		Anim = CameraRig.AnimationController.Animator:LoadAnimation(CamAnim)	
		Anim:Play()
	end
	
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	
	local Connection; Connection = RunService.RenderStepped:Connect(function(DT)
		FrameTime += (DT * 60) 
		
		if FOV then
			workspace.CurrentCamera.FieldOfView = FOV:FindFirstChild(tonumber(math.ceil(FrameTime))).Value
		end
			
		workspace.CurrentCamera.CFrame = CamAnim:GetAttribute("Marbles") and CameraRig.CFrame or CameraRig.camera.CFrame
	end)
	
	local StopConnection; StopConnection = Anim.Stopped:Connect(function()
		Connection:Disconnect()
		StopConnection:Disconnect()
		
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
		workspace.CurrentCamera.FieldOfView = 75
		
		if Weld then
			Weld:Destroy()
		end
		
		CameraRig:Destroy()
	end)
	
	return Anim
end

return Animation