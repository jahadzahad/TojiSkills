local TweenService = game:GetService( 'TweenService' )
local ReplicatedStorage = game:GetService( 'ReplicatedStorage' )
local Lighting = game:GetService( 'Lighting' )
local Debris = game:GetService( 'Debris' )
local RunService = game:GetService( 'RunService' )

local REFX = require( ReplicatedStorage.Packages.Refx )

local Effect = REFX.CreateEffect( tostring( script.Name ) )

local Assets = ReplicatedStorage.Shared.Assets.Visuals.Movesets.Enel[ 'Celestial Blitz' ]

local Rocks = require( ReplicatedStorage.Shared.Modules.RockModule )

local function EmitAll( Parent : Instance, IgnoreNames : {}? )
	local IgnoreList = IgnoreNames or {}

	for _, Descendant in ipairs( Parent:GetDescendants() ) do
		if ( Descendant.ClassName == 'ParticleEmitter' and not IgnoreList[Descendant.Parent.Name] ) then
			local Count = Descendant:GetAttribute( 'EmitCount' )
			if ( Count ) then
				task.spawn( function()
					local Delay = Descendant:GetAttribute( 'EmitDelay' )

					if ( Delay ) then
						task.wait( Delay )
					end

					Descendant:Emit( Count )
				end )
			end
		end
	end

	return true
end

local function DisableAll( Parent : Instance )
	for _, Descendant in ipairs( Parent:GetDescendants() ) do
		if ( Descendant.ClassName == 'ParticleEmitter' or Descendant.ClassName == 'Trail' or Descendant.ClassName == 'PointLight' or Descendant.ClassName == 'Beam' ) then
			Descendant.Enabled = false
		end
	end
end

local function EnableAll( Parent : Instance )
	for _, Descendant in ipairs( Parent:GetDescendants() ) do
		if ( Descendant.ClassName == 'ParticleEmitter' or Descendant.ClassName == 'Trail' or Descendant.ClassName == 'Beam' ) then
			Descendant.Enabled = true
		end
	end
end

local DebrisFolder = workspace.World.Debris

local EffectFunctions = {
	ImpactFrames = function()
		local Camera = workspace.CurrentCamera

		TweenService:Create( Camera, TweenInfo.new( 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out ), {
			FieldOfView = 20
		} ):Play()

		task.delay( 0.1, function()
			TweenService:Create( Camera, TweenInfo.new( 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out ), {
				FieldOfView = 70
			} ):Play()
		end )

		local Steps = {
			[1] = { Brightness = 0.1,  Contrast = 2,   Saturation = -0.2, TintColor = Color3.fromRGB( 255, 0, 0 ) },
			[2] = { Brightness = 0.05, Contrast = 4,   Saturation = -0.5, TintColor = Color3.fromRGB( 255, 64, 64 ) },
			[3] = { Brightness = 0,    Contrast = 6,   Saturation = -1,   TintColor = Color3.fromRGB( 255, 255, 255 ) },
			[4] = { Brightness = -0.1, Contrast = 8,   Saturation = -1,   TintColor = Color3.fromRGB( 0, 64, 255 ) },
			[5] = { Brightness = -0.2, Contrast = -5,  Saturation = 0,    TintColor = Color3.fromRGB( 0, 0, 0 ) },
			[6] = { Brightness = 0.2,  Contrast = 6,   Saturation = -1,   TintColor = Color3.fromRGB( 255, 0, 255 ) },
			[7] = { Brightness = 0,    Contrast = 2,   Saturation = 0,    TintColor = Color3.fromRGB( 255, 255, 255 ) },
			[8] = { Brightness = 0.05, Contrast = 1,   Saturation = 0,    TintColor = Color3.fromRGB( 4, 0, 255 ) },
			[9] = { Brightness = 0,    Contrast = 0,   Saturation = 0,    TintColor = Color3.fromRGB( 255, 255, 255 ) },
		}

		local ColorEffect = Instance.new( 'ColorCorrectionEffect' )
		local BlurEffect = Instance.new( 'BlurEffect' )
		local DepthEffect = Instance.new( 'DepthOfFieldEffect' )

		ColorEffect.Parent = Lighting
		BlurEffect.Parent = Lighting
		DepthEffect.Parent = Lighting

		DepthEffect.Enabled = true
		DepthEffect.FarIntensity = 1
		DepthEffect.NearIntensity = 1
		DepthEffect.FocusDistance = 0

		task.spawn( function()
			for i = 1, #Steps do
				for Property, Value in next, Steps[i] do
					ColorEffect[Property] = Value
				end

				BlurEffect.Size = math.random( 2, 6 )
				DepthEffect.InFocusRadius = 15 + i * 2

				task.wait( 0.025 )
			end

			ColorEffect:Destroy()
			BlurEffect:Destroy()
			DepthEffect:Destroy()
		end )
	end,


	Throw = function( RootPart : BasePart )
		local Throw = Assets.Throw:Clone()
		Throw.CFrame = RootPart.CFrame * CFrame.Angles( math.rad(-90), 0, 0 )
		Throw.Parent = DebrisFolder

		EmitAll( Throw, {} )
		Debris:AddItem( Throw, 3 )
	end,

	Jump = function( RootPart : BasePart )
		local Jump = Assets.Jump:Clone()
		Jump.CFrame = RootPart.CFrame * CFrame.new( 0, -2.5, 0 )
		Jump.Parent = DebrisFolder

		EmitAll( Jump, {} )
		Debris:AddItem( Jump, 3 )
		
		Rocks:Spawn({
			Position = RootPart.Position,
			AmountPerUnit = 2,
			Amount = 8,
			Angle = {16, 23},
			Radius = {3, 10},
			Size = {2, 4},
			Offset = {
				X = 0,
				Y = 0.5,
				Z = 0,
			},
			DespawnTime = 3,
		})

		Rocks:ExplosionRocks({
			Position = RootPart.Position,
			Amount = 8,
			Radius = {
				X = 7,
				Y = -2,
				Z = 7,
			},
			Size = {Vector3.one, Vector3.one},
			Force = {
				X = {-25, 25},
				Y = {30, 60},
				Z = {-25, 25},
			},
			Trail = false,
			Direction = nil,
			DespawnTime = 3,
		})
	end,

	Slam = function( RootPart : BasePart )
		local Slam = Assets.Slam:Clone()
		Slam.CFrame = RootPart.CFrame * CFrame.new( 0, -2.5, 0 )
		Slam.Parent = DebrisFolder
		
		Rocks:Spawn({
			Position = RootPart.Position,
			AmountPerUnit = 2,
			Amount = 16,
			Angle = {16, 23},
			Radius = {6, 17},
			Size = {4, 6},
			Offset = {
				X = 0,
				Y = 0.5,
				Z = 0,
			},
			DespawnTime = 5,
		})

		Rocks:ExplosionRocks({
			Position = RootPart.Position,
			Amount = 16,
			Radius = {
				X = 15,
				Y = -2,
				Z = 15,
			},
			Size = {Vector3.one, Vector3.one * 2},
			Force = {
				X = {-45, 45},
				Y = {30, 60},
				Z = {-45, 45},
			},
			Trail = false,
			Direction = nil,
			DespawnTime = 5,
		})

		EmitAll( Slam, {} )
		Debris:AddItem( Slam, 5 )
	end,

	Teleport = function( RootPart : BasePart )
		local Teleport = Assets.Teleport:Clone()
		Teleport.CFrame = RootPart.CFrame * CFrame.new( 0, 0, 0 )
		Teleport.Parent = DebrisFolder

		EmitAll( Teleport, {} )
		Debris:AddItem( Teleport, 5 )
	end,

	Hit = function( Character : Model )
		local Hit = Assets.Hit:Clone()
		Hit.CFrame = Character[ 'Right Arm' ].RightGripAttachment.WorldCFrame
		Hit.Parent = DebrisFolder

		EmitAll( Hit, {} )
		Debris:AddItem( Hit, 3 )
	end,

	Grab = function( Character : Model )
		local Grab = Assets.Hit:Clone()
		Grab.CFrame = Character[ 'Right Arm' ].RightGripAttachment.WorldCFrame
		Grab.Parent = DebrisFolder

		EmitAll( Grab, {} )
		Debris:AddItem( Grab, 3 )
	end,
}

function Effect:OnConstruct( Character : Model, Animation : AnimationTrack )
	
	self.Character = Character
	self.DestroyOnEnd = false
	self.MaxLifetime = 5
	
	print("[Constructed] ".. tostring(script.Name))
	
end

function Effect:Hit()
	local RootPart = self.Character.PrimaryPart
	
	print( 'TELEPORT EFFECT' )
	EffectFunctions.Hit( self.Character )
end

function Effect:Grab()
	local RootPart = self.Character.PrimaryPart
	_G.NewShake( 'Radar', RootPart.Position, 5 )
	
	EffectFunctions.Grab( self.Character )
end

function Effect:Throw()
	local RootPart = self.Character.PrimaryPart
	_G.NewShake( 'Shake', RootPart.Position, 5 )
	
	EffectFunctions.Throw( RootPart )
end

function Effect:Teleport()
	local RootPart = self.Character.PrimaryPart
	_G.NewShake( 'Radar', RootPart.Position, 5 )
	
	EffectFunctions.Teleport( RootPart )
end

function Effect:Jump()
	local RootPart = self.Character.PrimaryPart
	_G.NewShake( 'Shake', RootPart.Position, 5 )
	
	EffectFunctions.Jump( RootPart )  
end

function Effect:Slam()
	local RootPart = self.Character.PrimaryPart
	_G.NewShake( 'Explosion', RootPart.Position, 30 )
	
	EffectFunctions.ImpactFrames()
	EffectFunctions.Slam( RootPart )
end

return Effect