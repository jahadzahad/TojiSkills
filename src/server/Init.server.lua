local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage.Packages

local REFX = require(Packages.Refx)
local WCS = require(Packages.WCS)

local WCSServer = WCS.CreateServer()

WCSServer:RegisterDirectory(ReplicatedStorage.Shared.WCS.Movesets)
WCSServer:RegisterDirectory(ReplicatedStorage.Shared.WCS.StatusEffects)

WCSServer:Start()

local WCSCharacter = WCS.Character

local EnelMoveset = require(ReplicatedStorage.Shared.WCS.Movesets.Enel.Moveset)
local GojoMoveset = require(ReplicatedStorage.Shared.WCS.Movesets.Gojo.Moveset)
local TojiMoveset = require(ReplicatedStorage.Shared.WCS.Movesets.Toji.Moveset)

local function PlayerAdded(Player: Player)
	local function CharacterAdded(Character: Model)
		local Humanoid = Character:WaitForChild("Humanoid")
		Humanoid.UseJumpPower = true

		Character.Parent = workspace.World.Alive

		local CharacterClass = WCSCharacter.new(Character)
		CharacterClass:ApplySkillsFromMoveset(EnelMoveset)
		CharacterClass:ApplySkillsFromMoveset(GojoMoveset)
		CharacterClass:ApplySkillsFromMoveset(TojiMoveset)

		Humanoid.Died:Once(function()
			CharacterClass:Destroy()
		end)

		Character.AncestryChanged:Connect(function(_, Parent)
			if Parent == nil then
				CharacterClass:Destroy()
			end
		end)
	end

	if Player.Character then
		task.spawn(CharacterAdded, Player.Character)
	end

	Player.CharacterAdded:Connect(CharacterAdded)
end

local function PlayerRemoving(Player: Player) end

for _, Player in pairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, Player)
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)

local PhysicsService = game:GetService("PhysicsService")
local WorldPlayers = workspace.World.Alive
local CollisionGroupName = "WorldPlayers"

local GroupExists = false
for _, Group in PhysicsService:GetRegisteredCollisionGroups() do
	if Group.name == CollisionGroupName then
		GroupExists = true
		break
	end
end
if not GroupExists then
	PhysicsService:RegisterCollisionGroup(CollisionGroupName)
end

PhysicsService:CollisionGroupSetCollidable(CollisionGroupName, CollisionGroupName, false)

local function SetCollisionGroup(Instance)
	if Instance:IsA("BasePart") then
		Instance.CollisionGroup = CollisionGroupName
	end
	for _, Child in Instance:GetChildren() do
		SetCollisionGroup(Child)
	end
end

local function OnCharacterAdded(Character)
	SetCollisionGroup(Character)
	Character.DescendantAdded:Connect(function(Descendant)
		if Descendant:IsA("BasePart") then
			Descendant.CollisionGroup = CollisionGroupName
		end
	end)
end

for _, Character in WorldPlayers:GetChildren() do
	OnCharacterAdded(Character)
end

WorldPlayers.ChildAdded:Connect(OnCharacterAdded)
