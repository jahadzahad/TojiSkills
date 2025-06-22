local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WCS = require(ReplicatedStorage.Packages.WCS)

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Evade = WCS.RegisterStatusEffect("Evade")

function Evade:OnConstructServer()
	self.Effect = nil
end

function Evade:OnStartServer()
	self:SetHumanoidData({ WalkSpeed = { 30, "Set", 3 } })
	
	for i, v in pairs(self.Character.Instance:GetDescendants()) do
		if not v:IsA("Part") or v.Name == "HumanoidRootPart" then
			continue
		end
		
		v.Transparency = 1
	end
	
	self.Effect = Visuals:Spawn(
		ReplicatedStorage.Shared.Assets.VFX.Combat.Evade,
		self.Character.Instance.HumanoidRootPart.CFrame,
		workspace.Debris,
		false
	)
	
	self.Effect.Anchored = false
	
	Visuals:Enabled(self.Effect, false)
	Visuals:Weld(self.Effect, self.Character.Instance.HumanoidRootPart, CFrame.new(0, 0, 0), CFrame.new(0, 0, 0))
	Visuals:Enabled(self.Effect, true)
	
	self.Character.Instance:SetAttribute("IFrames", true)
end

function Evade:OnEndServer()
	for i, v in pairs(self.Character.Instance:GetDescendants()) do
		if not v:IsA("Part") or v.Name == "HumanoidRootPart" then
			continue
		end
		v.Transparency = 0
	end
	Visuals:Enabled(self.Effect, false)
	Debris:AddItem(self.Effect, 2)
	self.Character.Instance:SetAttribute("IFrames", false)
end

return Evade
