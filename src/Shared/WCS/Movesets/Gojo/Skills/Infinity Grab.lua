local ReplicatedStorage = game:GetService( 'ReplicatedStorage' )
local Workspace = game:GetService( 'Workspace' )

local WCS = require( ReplicatedStorage.Packages.WCS )
local Maid = require( ReplicatedStorage.Packages.Maid )

local Ragdoll = require( ReplicatedStorage.Shared.Modules.Ragdoll )
local Velocity = require( ReplicatedStorage.Shared.Modules.Velocity )
local Hitboxes = require( ReplicatedStorage.Shared.Modules.HaloBox )

local Sound = require( ReplicatedStorage.Shared.Modules.Sound )
local Visuals = require( ReplicatedStorage.Shared.Modules.Visuals )
local DarwinUtil = require( ReplicatedStorage.Shared.Modules.Darwin.DarwinUtilities )

local NegativeEffects = {
	Stun = require( ReplicatedStorage.Shared.WCS.StatusEffects.Stun ),
	Cast = require( ReplicatedStorage.Shared.WCS.StatusEffects.Cast ),
}

local Animations = ReplicatedStorage.Shared.Assets.Animations.Movesets.Gojo[ 'Infinity Grab' ]

local Skill = WCS.RegisterSkill( tostring( script.Name ) )
local WallIgnore = { Workspace.World.Map:WaitForChild( 'Baseplate' ) }

local ActiveHitbox = nil
local ActiveHitbox2 = nil

function Skill:OnStartServer()
	local Character = self.Character.Instance
	local Humanoid = self.Character.Humanoid
	if not ( Character and Humanoid ) then return end

	self.Maid = Maid.new()
	self:ApplyCooldown( 6 )

	local Stun = NegativeEffects.Stun.new( self.Character )
	Stun:Start( 6 )
	self.Maid:GiveTask( function() Stun:End() end )

	self.Ended:Once( function()
		self.Maid:Destroy()
	end )
end

function Skill:OnStartClient()
	local Character = self.Character.Instance
	local Humanoid = Character and Character:FindFirstChildOfClass( 'Humanoid' )
	local RootPart = Character and Character.PrimaryPart
	if not ( Character and Humanoid and RootPart ) then return end

	Humanoid.WalkSpeed = 0
	Humanoid.JumpPower = 0
	Humanoid.AutoRotate = false

	local CastAnim = DarwinUtil.AnimationHandler:PlayAnimation( Character, Animations.User.Cast )

	CastAnim:GetMarkerReachedSignal( 'Hit Indicator' ):Once( function()
		ActiveHitbox = Hitboxes.new( {
			Character = Character,
			Size = Vector3.new( 4, 6, 4 ),
			Offset = CFrame.new( 0, 0, -3 ),
			RepeatDelay = 0.5,
			Count = 5,
			Interval = 0.05,
			DeleteOnDetect = true,
			CheckForWall = false,
			Visualize = true,
			Ignore = WallIgnore,

			OnHit = function( Target )
				CastAnim:Stop()
				local StartAnim = DarwinUtil.AnimationHandler:PlayAnimation( Character, Animations.User.Start )

				task.delay( 0.74, function()
					local RunAnim = DarwinUtil.AnimationHandler:PlayAnimation( Character, Animations.User.Run )
					local HitWall = false

					ActiveHitbox2 = Hitboxes.new( {
						Character = Character,
						Size = Vector3.new( 4, 6, 4 ),
						Offset = CFrame.new( 0, 0, -3 ),
						RepeatDelay = 0.5,
						Count = 50,
						Interval = 0.05,
						DeleteOnDetect = true,
						CheckForWall = true,
						Visualize = true,
						Ignore = WallIgnore,

						OnWallHit = function( Part )
							if table.find( WallIgnore, Part ) then return end

							local HitPos = Part.Position
							local Direction = ( HitPos - RootPart.Position ).Unit
							local Facing = RootPart.CFrame.LookVector
							local Dot = Facing:Dot( Direction )

							if Dot > 0.5 then
								HitWall = true
								RunAnim:Stop()
								DarwinUtil.AnimationHandler:PlayAnimation( Character, Animations.User.Wall )
							end
						end,
					} )

					ActiveHitbox2.Janitor:Add( function()
						ActiveHitbox2 = nil
					end )

					ActiveHitbox2:Start()

					task.delay( 2.5, function()
						if not HitWall then
							local EndAnim = DarwinUtil.AnimationHandler:PlayAnimation( Character, Animations.User.End )
							RunAnim:Stop()

							EndAnim.Ended:Once( function()
								Humanoid.WalkSpeed = 16
								Humanoid.JumpPower = 50
								Humanoid.AutoRotate = true
							end )
						end
					end )
				end )
			end,
		} )

		ActiveHitbox.Janitor:Add( function()
			ActiveHitbox = nil
		end )

		ActiveHitbox:Start()
	end )

	self.Ended:Once( function()
		Humanoid.WalkSpeed = 16
		Humanoid.JumpPower = 50
		Humanoid.AutoRotate = true
	end )
end

return Skill