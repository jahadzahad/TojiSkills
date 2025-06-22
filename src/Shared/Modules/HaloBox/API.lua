
--	EXAMPLE USAGE : 

local ReplicatedStorage = game:GetService( 'ReplicatedStorage' )
local UserInputService = game:GetService( 'UserInputService' )
local Players = game:GetService( 'Players' )

local Modules = ReplicatedStorage:WaitForChild( 'Modules' )
local Utility = Modules:WaitForChild( 'Utility' )
local Toolbox = require( Utility:WaitForChild( 'Toolbox' ) )

local Player = Players.LocalPlayer
local Module = {}
local ActiveHitbox = nil

local WallIgnore = {
	workspace.World.Alive:WaitForChild( 'xxUltimate_elitexx' ),
	workspace.World.Map:WaitForChild('Baseplate'),
	table.unpack( workspace.World.Map.Spawns:GetChildren() ),
}

function Module.InputBegan( Input, Processed )
	if Processed or Input.KeyCode ~= Enum.KeyCode.E then return end
	if ActiveHitbox then return end

	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Root = Character:WaitForChild( 'HumanoidRootPart' )

	ActiveHitbox = Toolbox.Hitbox.new({
		Character = Character,
		Size = Vector3.new( 4, 6, 10 ),
		Offset = CFrame.new( 0, 0, 0 ),
		RepeatDelay = 0.5,
		Count = 50,
		Interval = 0.05,
		Visualize = true,
		DeleteOnDetect = true,
		CheckForWall = true,
		Ignore = WallIgnore,

		OnHit = function( Target, Position )
			print( '✔️ Character Hit:', Target.Name, 'at', Position )
		end,

		OnWallHit = function( Part )
			if table.find( WallIgnore, Part ) then return end

			local HitPos = Part.Position
			local DirectionToHit = ( HitPos - Root.Position ).Unit
			local Facing = Root.CFrame.LookVector

			local Dot = Facing:Dot( DirectionToHit )
			if Dot > 0.5 then
				print( '🧱 Wall In Front Hit:', Part:GetFullName() )

				if ActiveHitbox and ActiveHitbox.VisualPart then
					ActiveHitbox.VisualPart.Color = Color3.new( 1, 0, 0 )
				end
			end
		end,
	})

	ActiveHitbox.Janitor:Add( function()
		ActiveHitbox = nil
	end )

	ActiveHitbox:Start()
end

function Module.InputEnded( Input, Processed ) end

function Module.Start()
	UserInputService.InputBegan:Connect( Module.InputBegan )
	UserInputService.InputEnded:Connect( Module.InputEnded )
end

return Module