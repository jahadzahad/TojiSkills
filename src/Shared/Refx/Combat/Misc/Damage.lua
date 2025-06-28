local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local VFX = ReplicatedStorage.Shared.Assets.VFX

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Refx = require(ReplicatedStorage.Packages.Refx)
local Damage = Refx.CreateEffect("Damage")

function Damage:OnStart(Character, Damage)
	local Spawn = Visuals:Spawn(
		VFX.Combat.DamageText,
		Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
	)

	Spawn.BillboardGui.Damage.Text = Damage
	Debris:AddItem(Spawn, 3)
	Spawn.BillboardGui.Damage.Size = UDim2.new(0, 0, 0, 0)
	Spawn.BillboardGui.Damage.TextColor3 = Color3.new(1, 0.925490, 0.498039)

	TweenService:Create(
		Spawn.BillboardGui.Damage,
		TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
		{ ["Size"] = UDim2.new(1, 0, 1, 0),}
	):Play()
	TweenService:Create(
		Spawn.BillboardGui.Damage,
		TweenInfo.new(2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
		{["TextColor3"] = Color3.new(1, 0.447058, 0.447058) }
	):Play()

	task.delay(2.5, function()
		TweenService:Create(
			Spawn.BillboardGui.Damage,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{ ["Size"] = UDim2.new(0, 0, 0, 0) }
		):Play()
	end)
end

return Damage
