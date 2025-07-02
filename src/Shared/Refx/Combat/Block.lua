local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFX = ReplicatedStorage.Shared.Assets.VFX

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Refx = require(ReplicatedStorage.Packages.Refx)
local Block = Refx.CreateEffect("Block")

function Block:OnConstruct()
	self.Spawn = nil
	self.DestroyOnEnd = false
	self.DestroyOnLifecycleEnd = false
end

function Block:OnStart(Character)
	print("Triggered")
	self.Spawn = Visuals:Spawn(VFX.Combat.Block, Character.HumanoidRootPart.CFrame, Character.HumanoidRootPart, false)
	self.Spawn.Anchored = false
	self.Spawn.Weld.Part1 = Character.HumanoidRootPart
	Visuals:Enabled(self.Spawn,true)
	print(self.Spawn)
end

function Block:OnDestroy()
	if self.Spawn then
		Debris:AddItem(self.Spawn,0)
	end
end

return Block
