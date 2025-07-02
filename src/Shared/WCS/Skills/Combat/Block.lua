local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WCS = require(ReplicatedStorage.Packages.WCS)

-- < Modules > --
local Animation = require(ReplicatedStorage.Shared.Modules.Animation)
local Block = WCS.RegisterHoldableSkill("Block")
local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Animations = ReplicatedStorage.Shared.Assets.Animations

--local BlockAnimation = Animations.Combats.Fists.Block
local BlockVFX = require(ReplicatedStorage.Shared.Refx.Combat.Block)

local BlockSE = require(ReplicatedStorage.Shared.WCS.StatusEffects.Block)

function Block:OnConstructServer()
	self:SetMaxHoldTime(nil)
	self.BlockVFX = nil
	self.BlockEffect = nil
end

function Block:OnStartServer()
	self.Character.Instance:SetAttribute("Blocking", false)
	self.Character.Instance:SetAttribute("Parry", true)

	--Animation.PlayAnimation(self.Character.Instance, BlockAnimation)
	self.BlockVFX = BlockVFX.new(self.Character.Instance)
	self.BlockVFX:Start(Visuals:GetPlayers(self.Character.Instance))

	self.BlockEffect = BlockSE.new(self.Character)
	self.BlockEffect:Start()

	task.delay(0.5, function()
		self.Character.Instance:SetAttribute("Parry", false)
		self.Character.Instance:SetAttribute("Blocking", true)
	end)
end

function Block:OnEndServer()
	self.Character.Instance:SetAttribute("Blocking", false)
	self.Character.Instance:SetAttribute("Parry", false)
	--Animation.StopAnimation(self.Character.Instance, BlockAnimation)

	if self.BlockEffect then
		self.BlockEffect:Stop()
		self.BlockEffect = nil
	end
	if self.BlockVFX then
		self.BlockVFX:Destroy()
	end
end

return Block
