local RunService = game:GetService( 'RunService' )
local Debris = game:GetService( 'Debris' )
local ReplicatedStorage = game:GetService( 'ReplicatedStorage' )

local Janitor = require( script:WaitForChild( 'Janitor' ) )

local Hitbox = {}
Hitbox.__index = Hitbox

function Hitbox.new( Config : {
	Character : Model,
	Size : Vector3,
	Offset : CFrame?,
	Ignore : { Instance }?,
	OnHit : ( ( Target : Model, Position : Vector3 ) -> () )?,
	OnWallHit : ( ( Part : BasePart ) -> () )?,
	RepeatDelay : number?,
	Count : number?,
	Interval : number?,
	Visualize : boolean?,
	DeleteOnDetect : boolean?,
	CheckForWall : boolean?
	} )
	local self = setmetatable( {}, Hitbox )

	self.Character = Config.Character
	self.Root = self.Character and self.Character:FindFirstChild( 'HumanoidRootPart' )
	if not self.Root then warn( '[Hitbox] HumanoidRootPart missing' ) end

	self.Size = Config.Size
	self.Offset = Config.Offset or CFrame.new()
	self.Ignore = Config.Ignore or {}
	self.OnHit = Config.OnHit
	self.OnWallHit = Config.OnWallHit
	self.RepeatDelay = Config.RepeatDelay or 0.2
	self.Count = Config.Count or 1
	self.Interval = Config.Interval or 0.05
	self.Visualize = Config.Visualize or false
	self.DeleteOnDetect = Config.DeleteOnDetect or false
	self.CheckForWall = Config.CheckForWall or false

	self.HitMap = {}
	self.DetectionCount = {}
	self.DetectionLimit = {}
	self.VisualPart = nil
	self.HasHit = false
	self.Janitor = Janitor.new()

	return self
end

function Hitbox:SetDetectionLimit( Target : Model, MaxHits : number )
	self.DetectionLimit[ Target ] = MaxHits
end

function Hitbox:CheckWallFromPart( FromPart : BasePart )
	local Frame = self.Root.CFrame * self.Offset
	local StartPos = FromPart.Position
	local EndPos = Frame.Position
	local Direction = ( EndPos - StartPos ).Unit * self.Size.Magnitude / 2

	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = { self.Character, unpack( self.Ignore ) }

	local Result = workspace:Raycast( StartPos, Direction, Params )

	if Result and Result.Normal then
		local Dot = math.abs( Result.Normal:Dot( Vector3.yAxis ) )
		local Angle = math.deg( math.acos( Dot ) )

		if Angle >= 65 and self.OnWallHit then
			print( '[Hitbox] Wall ray hit:', Result.Instance:GetFullName(), 'Angle:', Angle )
			self.OnWallHit( Result.Instance )

			if self.DeleteOnDetect then
				self:Destroy()
			end
		end
	end
end

function Hitbox:Spawn()
	if not self.Root then return end

	local Now = os.clock()
	local Frame = self.Root.CFrame * self.Offset

	local Params = OverlapParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = { self.Character, unpack( self.Ignore ) }

	local Parts = workspace:GetPartBoundsInBox( Frame, self.Size, Params )

	for _, Part in Parts do
		local Model = Part:FindFirstAncestorOfClass( 'Model' )
		if Model == self.Character then continue end

		local Humanoid = Model and Model:FindFirstChildOfClass( 'Humanoid' )
		if Humanoid then
			local Last = self.HitMap[ Model ]
			if not Last or Now - Last >= self.RepeatDelay then
				self.HitMap[ Model ] = Now
				self.DetectionCount[ Model ] = ( self.DetectionCount[ Model ] or 0 ) + 1

				print( '[Hitbox] Character touched:', Model.Name )
				if self.OnHit then
					self.OnHit( Model, Part.Position )
				end

				if self.VisualPart then
					self.VisualPart.Color = Color3.new( 1, 0, 0 )
				end

				local MaxHits = self.DetectionLimit[ Model ]
				if MaxHits and self.DetectionCount[ Model ] >= MaxHits then
					self:Destroy()
					break
				end

				self.HasHit = true

				if self.DeleteOnDetect then
					self:Destroy()
					break
				end
			end
		elseif self.OnWallHit then
			self.OnWallHit( Part )

			if self.DeleteOnDetect then
				self:Destroy()
				break
			end
		end
	end

	if self.CheckForWall and self.Root then
		self:CheckWallFromPart( self.Root )
	end

	if self.Visualize and not self.VisualPart then
		local Box = Instance.new( 'Part' )
		Box.Anchored = true
		Box.CanCollide = false
		Box.CanQuery = false
		Box.CastShadow = false
		Box.Size = self.Size
		Box.CFrame = Frame
		Box.Transparency = 0.5
		Box.Material = Enum.Material.ForceField
		Box.Color = Color3.new( 0, 1, 0 )
		Box.Name = 'HitboxPreview'

		local DebrisFolder = workspace:FindFirstChild( 'World' ) and workspace.World:FindFirstChild( 'Debris' )
		Box.Parent = DebrisFolder or workspace

		self.VisualPart = Box
	end

	if self.VisualPart then
		self.VisualPart.CFrame = Frame
	end
end

function Hitbox:Start()
	local Index = 0
	local LastTick = 0

	local Connection
	Connection = RunService.Heartbeat:Connect( function( Step )
		if not self.Root then
			Connection:Disconnect()
			return
		end

		if Index >= self.Count then
			Connection:Disconnect()
			self:Destroy()
			return
		end

		local Now = os.clock()
		if Now - LastTick >= self.Interval then
			self:Spawn()
			Index += 1
			LastTick = Now
		end
	end )

	self.Janitor:Add( Connection, 'Disconnect' )
end

function Hitbox:ClearHits()
	table.clear( self.HitMap )
	table.clear( self.DetectionCount )
	table.clear( self.DetectionLimit )
end

function Hitbox:Destroy()
	self:ClearHits()

	if self.VisualPart then
		Debris:AddItem( self.VisualPart, 0.1 )
		self.VisualPart = nil
	end

	if self.Janitor then
		self.Janitor:Destroy()
		self.Janitor = nil
	end

	table.clear( self )
end

return Hitbox