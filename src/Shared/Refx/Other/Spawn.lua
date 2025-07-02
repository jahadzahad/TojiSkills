local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local VFX = ReplicatedStorage.Shared.Assets.VFX

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Refx = require(ReplicatedStorage.Packages.Refx)
local SpawnVFX = Refx.CreateEffect("Spawn")

function SpawnVFX:OnStart(Character)
	local Highlight = Instance.new("Highlight")
	Highlight.Adornee = Character
	Highlight.Parent = Character
	Highlight.FillColor = Color3.new(0.607843, 0.890196, 1)
	Highlight.FillTransparency = 1
	Highlight.OutlineTransparency = 1
	Highlight.DepthMode = Enum.HighlightDepthMode.Occluded

	TweenService:Create(
		Highlight,
		TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),
		{ ["FillTransparency"] = 0.2 }
	):Play()

	local Spawn = Visuals:Spawn(VFX.Base.Spawn, Character.HumanoidRootPart.CFrame)
	Visuals:Emit(Spawn)
	Debris:AddItem(Spawn,5)
end

return SpawnVFX
