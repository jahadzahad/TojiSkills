local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local VFX = ReplicatedStorage.Shared.Assets.VFX

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)
local Maid = require(ReplicatedStorage.Packages.Maid)

local Refx = require(ReplicatedStorage.Packages.Refx)
local DaggerCritical = Refx.CreateEffect("DaggerCritical")

function DaggerCritical:OnStart(Character)
	self.Maid = Maid.new()

	local Spawn = Visuals:Spawn(VFX.Combat.CriticalAttacks.Dagger.Slashes)
	Spawn.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-8)
	Visuals:Enabled(Spawn, true)

	self.Maid:GiveTask(RunService.Heartbeat:Connect(function()
		Spawn.CFrame = Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-8)
	end))

	task.delay(.7,function()
		Visuals:Enabled(Spawn, false)
		self.Maid:Destroy()
	end)
	Debris:AddItem(Spawn, 5)
end

return DaggerCritical
