local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local VFX = ReplicatedStorage.Shared.Assets.VFX

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Refx = require(ReplicatedStorage.Packages.Refx)
local KatanaCritical = Refx.CreateEffect("KatanaCritical")

function KatanaCritical:OnStart(Character)
	local Spawn = Visuals:Spawn(VFX.Combat.CriticalAttacks.Katana.Katana.slash)
	Spawn.CFrame = Character.HumanoidRootPart.CFrame
	Visuals:Emit(Spawn)
	Debris:AddItem(Spawn, 5)

	local GroundSpawn: Model = Visuals:Spawn(VFX.Combat.CriticalAttacks.Katana.Katana.funn)
	GroundSpawn.PrimaryPart.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0, -1.5, 0)
	Visuals:Emit(GroundSpawn)
	Debris:AddItem(GroundSpawn, 5)

	local BigSlash = Visuals:Spawn(VFX.Combat.CriticalAttacks.Katana.BigSlash)
	Visuals:Enabled(BigSlash, false)
	BigSlash.CFrame = Character.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(-90), math.rad(-50), math.rad(-90))
	Visuals:Enabled(BigSlash, true)
	Debris:AddItem(BigSlash,5)

	TweenService:Create(BigSlash, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		["CFrame"] = Character.HumanoidRootPart.CFrame
			* CFrame.new(0, 0, -50)
			* CFrame.Angles(math.rad(-90), math.rad(-70), math.rad(-90)),
	}):Play()

	task.delay(0.6, function()
		for _, v in pairs(BigSlash:GetDescendants()) do
			if v:IsA("Beam") then
				TweenService:Create(
					v,
					TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{ ["Width0"] = 0, ["Width1"] = 0 }
				):Play()
			end
		end
		Visuals:Enabled(BigSlash, false)
	end)
end

return KatanaCritical
