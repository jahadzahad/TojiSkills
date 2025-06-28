local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local VFX = ReplicatedStorage.Shared.Assets.VFX

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Refx = require(ReplicatedStorage.Packages.Refx)
local Dash = Refx.CreateEffect("Dash")

function Dash:OnStart(Character,Direction)
	local Spawn = Visuals:Spawn(VFX.Movement.Dash, Character.HumanoidRootPart.CFrame)
	for _,v in pairs(Spawn:GetChildren()) do
		if Direction == "Front" then
			v.EmissionDirection = Enum.NormalId.Front
		elseif Direction == "Back" then
			v.EmissionDirection = Enum.NormalId.Back
		elseif Direction == "Right" then
			v.EmissionDirection = Enum.NormalId.Right
		elseif Direction == "Left" then
			v.EmissionDirection = Enum.NormalId.Left
		end
	end
	Visuals:Emit(Spawn)
	Debris:AddItem(Spawn,5)

	local Highlight = Instance.new("Highlight")
	Highlight.Adornee = Character
	Highlight.Parent = Character
	Highlight.FillColor = Color3.new(1, 1, 1)
	Highlight.FillTransparency = 1
	Highlight.OutlineTransparency = 1
	Highlight.DepthMode = Enum.HighlightDepthMode.Occluded

	TweenService:Create(
		Highlight,
		TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),
		{ ["FillTransparency"] = 0.5 }
	):Play()
end

return Dash
