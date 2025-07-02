--[[
	#Writer: TheBlackwave;
	@class 'debris';
]]

--[[
	//// Misc \\\\
	"Reworked" module from that guy who open sourced it. I just managed to organize it.
	
	//// Debris Module Application \\\\
	Ex. of Use.:
	
	local Crater = require(CraterModule)
	
	//// Ground Rocks \\\\
	local Position = RootPart.Position
	
	Crater:Spawn({
		Position = Position, --> Position
		
		AmountPerUnit = 2, --> Amount of Rocks Per Unit (1 would appear a single rock per angle step.)
		
		Amount = 14, --> Amount of rocks that will exist in the circle. (360 / Amount)
		
		Angle = {10, 30}, --> Random Angles (Y) axis.
		Radius = {4, 6}, --> Random Radius;
		Size = {2.5, 3}, --> Random Size (number only);
		
		Offset = {
			X = 0,
			Y = 0.5,
			Z = 0,
		}, --> Random offset (Y);

		DespawnTime = 5, --> Despawn Time
	})
	
	//// Rocks Trail \\\\
	local TrailData = {
		Size = {
			Vector3.one * 0.8,
			Vector3.one * 1.2,
		}, --> Sizes [Random]
		Offset = {
			X = 0,
			Y = 0.1,
			Z = 0,
		}, --> Offsets (Y)

		AmountPerUnit = 2, --> Per Unit
		Distance = 40, --> Max Distance
		
		Increment = 0.05, --> Size increment;
		ReachTime = {3, 10^-4}, --> Each [3] rock groups waits [0.0001].
		
		Spread = Vector3.new(1, 2, 1), --> Spread Vector (You can play with the values, but isn't that usefull.)
		
		Spacing = 3, --> Spacing number;
		DespawnTime = 5, --> Despawn Time.
	}
	
	This part, you can make a summary, but, y'know, when we can't think on a better idea, let's just stay like this.
	
	local RightVector = RootCFrame.RightVector.Unit
	local LookVector = RootCFrame.LookVector.Unit
	local UpVector = RootCFrame.UpVector.Unit
	
	Crater:Trail(
		RootCFrame.Position + (LookVector * 5) + (RightVector * 2), --> That's the space between you and the rocks.
		LookVector + (RightVector * 0.25), --> 0 to 1 just manages to change the (X) known as side axis, so, get your perfect value.
		
		TrailData,
		Folder --> In case you want to have a specific folder existing.
	)
	
	Crater:Trail(
		RootCFrame.Position + (LookVector * 5) - (RightVector * 2),
		LookVector - (RightVector * 0.25),
	
		TrailData,
		Folder --> In case you want to have a specific folder existing.
	)
	
	
	//// Explosion Rocks \\\\
	local RootCFrame = RootPart.CFrame
	
	Crater:ExplosionRocks({
		Position = RootCFrame.Position, --> Position;
		
		Amount = 15, --> Amount of Rocks;
		
		Radius = {
			X = 2,
			Y = -2,
			Z = 2,
		}, --> Radius (Y);
		
		Size = {Vector3.one, Vector3.one * 1.45}, --> Random Sizes between '1' and '2';
		
		Force = {
			X = {-10, 10},
			Y = {10, 30},
			Z = {40, 80},
		}, --> Forces (X, Y, Z) [Random]
		
		Trail = false, --> Enable / Disable
		
		Direction = RootCFrame, --> Direction (Gets 'LookVector', 'UpVector' and 'RightVector' automatically)
		
		DespawnTime = 4, --> Despawn Time.
	})
	
	
]]

--/ @services \--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--/ @defined \--
local Map = workspace.World.Map
local Effects = workspace.World.Debris

--/ @modules 'services' \--
local SpawnService = {}
local MaidService = {}

function MaidService:Task(func: (...any) -> (), ...): ()
	task.defer(function(...)
		func(...)
	end, ...)
end

function SpawnService:Wait(waitTime: number, func: (...any) -> (), ...): ()
	MaidService:Task(function(waitTime, ...)
		task.wait(waitTime)
		if func then
			func(...)
		end
	end, waitTime, ...)
end

function SpawnService:AddItem(object: Instance, lifeTime: number): ()
	SpawnService:Wait(lifeTime, function()
		if object and object.Parent then
			object:Destroy()
		end
	end)
end

--/ @modules 'shared' \--
local Auxiliary = {}
Auxiliary.RaycastParams = {}

Auxiliary.RaycastParams.Map = RaycastParams.new()
Auxiliary.RaycastParams.Map.FilterType = Enum.RaycastFilterType.Include
Auxiliary.RaycastParams.Map.FilterDescendantsInstances = { Map }

function Auxiliary:Raycast(Origin: Vector3, Direction: Vector3): RaycastResult
	return workspace:Raycast(Origin, Direction, Auxiliary.RaycastParams.Map)
end

--/ @functions \--
function Create_Tween(object: Instance, tweenInfo: TweenInfo, goal: { [string]: any }): Tween
	local TweenInstance = TweenService:Create(object, tweenInfo, goal)
	TweenInstance:Play()
	TweenInstance:Destroy()
	return TweenInstance
end

--/ @types \--
export type GroundData = {
	Amount: number?,
	AmountPerUnit: number?,

	Radius: { number }?,
	Angle: { number }?,
	Offset: {
		X: number?,
		Y: number?,
		Z: number?,
	}?,
	Size: { number }?,

	Position: Vector3,

	DespawnTime: number?,
}

export type RockData = {
	Amount: number?,
	Radius: { number }?,
	Force: { X: { number }, Y: { number }, Z: { number } }?,

	Trail: boolean?,

	Direction: Vector3?,
	Position: Vector3,

	Size: { Vector3 }?,

	DespawnTime: number?,
}

export type TrailData = {
	Size: { Vector3 }?,
	Offset: { X: number, Y: number, Z: number }?,

	ReachTime: { number }?,

	AmountPerUnit: number?,
	Distance: number?,

	Increment: number?,

	Spread: Vector3?,

	Spacing: number?,
	DespawnTime: number?,
}

--/ @constants \--
local Seed = Random.new()

--/ @class 'debris' \--
local Crater = {}

--/ @functions \--
function RandomVector3(VectorA: Vector3, VectorB: Vector3): Vector3
	return Vector3.new(
		Seed:NextNumber(VectorA.X, VectorB.X),
		Seed:NextNumber(VectorA.Y, VectorB.Y),
		Seed:NextNumber(VectorA.Z, VectorB.Z)
	)
end

--/ @debris 'rocks' \--
function Crater:ExplosionRocks(Data: RockData)
	--/ @variables \--
	local Amount = Data.Amount or 10
	local Radius = Data.Radius or { X = 0, Y = 0, Z = 0 }
	local Force = Data.Force or { X = { 0, 0 }, Y = { 0, 0 }, Z = { 0, 0 } }
	local Size = Data.Size or { Vector3.one, Vector3.one }

	local Trail = Data.Trail or false
	local DespawnTime = Data.DespawnTime or 3

	local Position = Data.Position or nil
	local Direction = Data.Direction or nil

	--/ @return \--
	if not Position then
		return
	end

	--/ @folder \--
	local Folder = Instance.new("Folder")
	Folder.Name = "RockFolder"
	Folder.Parent = Effects

	--/ @loop \--
	MaidService:Task(function()
		for i = 1, Amount do
			if not Folder.Parent then
				break
			end

			local function FixNumber(Axis): number
				return if Axis < 0 then math.abs(Axis) else Axis
			end

			local Radius = {
				X = math.random(-FixNumber(Radius.X), FixNumber(Radius.X)),
				Y = math.random(-FixNumber(Radius.Y), FixNumber(Radius.Y)),
				Z = math.random(-FixNumber(Radius.Z), FixNumber(Radius.Z)),
			}

			local Size = RandomVector3(Size[1], Size[2])

			local Part = Instance.new("Part")
			Part.Massless = true
			Part.CanTouch = true
			Part.CanCollide = true

			Part.Size = Size

			Part.Anchored = false
			Part.CastShadow = false
			Part.CanQuery = false

			Part.CollisionGroup = "RockDebris"

			Part.CFrame = CFrame.new(Position) * CFrame.new(Radius.X, Radius.Y, Radius.Z)
			Part.Parent = Folder

			if Trail then
				local Attachment0 = Instance.new("Attachment")
				Attachment0.Name = "Attachment0"
				Attachment0.CFrame = CFrame.new(0, Part.Size.Y / 5, 0)
				Attachment0.Parent = Part

				local Attachment1 = Instance.new("Attachment")
				Attachment1.Name = "Attachment1"
				Attachment1.CFrame = CFrame.new(0, -Part.Size.Y / 5, 0)
				Attachment1.Parent = Part

				local Trail = script.Trail:Clone()
				Trail.Attachment0 = Attachment0
				Trail.Attachment1 = Attachment1
				Trail.Parent = Part
			end

			local Raycast = Auxiliary:Raycast(Part.Position, -Vector3.yAxis * 30)

			if Raycast then
				local Velocity = Vector3.new(
					math.random(Force.X[1], Force.X[2]),
					math.random(Force.Y[1], Force.Y[2]),
					math.random(Force.Z[1], Force.Z[2])
				)

				local Object = Raycast.Instance

				Part.Position = Raycast.Position + (Vector3.yAxis * math.random(1, 3))

				Part.Material = Object.Material or Enum.Material.Plastic
				Part.Color = Object.Color
				Part.Transparency = Object.Transparency

				Part.CFrame = CFrame.new(Part.Position)
					* CFrame.Angles(math.random(0, 360), math.random(0, 360), math.random(0, 360))

				local BodyVelocity = Instance.new("BodyVelocity")
				BodyVelocity.MaxForce = Vector3.one * 125000
				BodyVelocity.P = 820

				if Direction then
					local lookForce = math.random(Force.Z[1], Force.Z[2])
					local rightForce = math.random(Force.X[1], Force.X[2])
					local upForce = math.random(Force.Y[1], Force.Y[2])

					local lookVector = Direction.LookVector.Unit * lookForce
					local rightVector = Direction.RightVector.Unit * rightForce
					local upVector = Direction.UpVector.Unit * upForce

					BodyVelocity.Velocity = lookVector + upVector + rightVector
				else
					BodyVelocity.Velocity = Velocity
				end

				BodyVelocity.Parent = Part
				SpawnService:AddItem(BodyVelocity, 0.15)

				--/ @wait \--
				SpawnService:Wait(DespawnTime, function()
					if i % 2 == 0 then
						task.wait(0.1 + (math.random(-1, 1) / 20))
					end

					Create_Tween(Part, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
						Transparency = 1,
					})

					SpawnService:AddItem(Part, 0.5)
				end)
			else
				Part:Destroy()
			end
		end
	end)

	SpawnService:AddItem(Folder, DespawnTime + 2)
end

--/ @debris 'trail' \--
function Crater:Trail(Position: Vector3, Direction: Vector3, Data: TrailData, ExistingFolder: Folder?)
	--/ @variables \--
	local AmountPerUnit = Data.AmountPerUnit or 10
	local Distance = Data.Distance or 10

	local Size = Data.Size or { Vector3.one, Vector3.one }
	local Offset = Data.Offset or { X = 0, Y = 0, Z = 0 }

	local Spread = Data.Spread or Vector3.one
	local Spacing = Data.Spacing or 1
	local DespawnTime = Data.DespawnTime or 4

	local ReachTime = Data.ReachTime or nil

	local Increment = Data.Increment or 0.1

	MaidService:Task(function()
		local Extra = 0

		if ReachTime and type(ReachTime) == "table" and ReachTime[2] then
			Extra = ReachTime[2] or 0
		end

		local MaxRocks = Distance - (Spacing * AmountPerUnit)

		local Folder = ExistingFolder
			or (function()
				local Folder = Instance.new("Folder")
				Folder.Name = "RockTrail"
				Folder.Parent = Effects
				SpawnService:AddItem(Folder, DespawnTime + (Extra * AmountPerUnit) + 2)
				return Folder
			end)()

		local Rocks = {}

		local Counting = 1

		for x = 1, Distance, Spacing do
			Counting += 1

			if not Folder.Parent then
				break
			end

			local Line = Position + (Direction * x)

			for Index = 1, AmountPerUnit do
				local Factor = Vector3.one * (Increment * x)
				local NewPosition = Line
					+ Vector3.new(
						Seed:NextNumber(-Spread.X, Spread.X),
						Seed:NextNumber(-Spread.Y, Spread.Y),
						Seed:NextNumber(-Spread.Z, Spread.Z)
					)

				local Part = Instance.new("Part")

				Part.Size = RandomVector3(Size[1] + Factor, Size[2] + Factor)

				Part.Orientation = Vector3.one * math.random(0, 360)

				Part.Anchored = true
				Part.CanCollide = true
				Part.Massless = true

				Part.CanTouch = false
				Part.CastShadow = false
				Part.CanQuery = false

				Part.CollisionGroup = "RockDebris"

				local Raycast = Auxiliary:Raycast(NewPosition, -Vector3.yAxis * 20)

				if Raycast then
					local ResultPosition = Raycast.Position
					local Object = Raycast.Instance

					Part.Material = Object.Material or Enum.Material.Plastic
					Part.Color = Object.Color
					Part.Transparency = Object.Transparency

					Part.Position =
						Vector3.new(NewPosition.X, ResultPosition.Y - Offset.Y - Part.Size.Y / 2, NewPosition.Z)

					Create_Tween(Part, TweenInfo.new(0.125, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
						Position = Part.Position + (Vector3.yAxis * ((Part.Size.Y / 2) - Offset.Y)),
					})

					Part.Parent = Folder
				else
					Part:Destroy()
				end

				Rocks[#Rocks + 1] = Part
			end

			if ReachTime and type(ReachTime) == "table" and Counting % ReachTime[1] then
				task.wait(Extra)
			end
		end

		SpawnService:Wait(DespawnTime, function()
			for Index, Part in Rocks do
				local Time = (Index / MaxRocks) * 0.2

				if Index % AmountPerUnit == 0 then
					Time = 0
				end

				SpawnService:Wait(Time, function()
					local Tween =
						Create_Tween(Part, TweenInfo.new(0.85, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
							Position = Part.Position - Vector3.yAxis * (Part.Size.Y / 2 + Offset.Y + 3),
						})

					Create_Tween(
						Part,
						TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{ Transparency = 1 }
					)
					Create_Tween(
						Part,
						TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
						{ Size = Vector3.zero }
					)

					SpawnService:AddItem(Part, 0.6)
				end)
			end
		end)
	end)
end

function Crater:Spawn(Data: GroundData)
	--/ @variables \--
	local AmountPerUnit = Data.AmountPerUnit or 1
	local Amount = Data.Amount or 10
	local Radius = Data.Radius or { 5, 5 }
	local Size = Data.Size or { 3, 4 }
	local Offset = Data.Offset or { X = 0, Y = 0, Z = 0 }
	local Angle = Data.Angle or { 30, 30 }
	local DespawnTime = Data.DespawnTime or 3
	local Position = Data.Position or nil

	--/ @return \--
	if not Position then
		return
	end

	--/ @dependency \--
	local Orientation = 0

	--/ @loop \--
	MaidService:Task(function()
		local Folder = Instance.new("Folder")
		Folder.Name = "RockFolder"
		Folder.Parent = Effects
		SpawnService:AddItem(Folder, DespawnTime + 3)

		for x = 1, Amount do
			if not Folder.Parent then
				break
			end
			for i = 1, AmountPerUnit do
				local Radius = Seed:NextNumber(Radius[1], Radius[2])
				local NewCFrame = CFrame.new(Position)
					* CFrame.fromEulerAnglesXYZ(0, math.rad(Orientation), 0)
					* CFrame.new(Radius, 0, Radius)

				local Part = Instance.new("Part")
				Part.Anchored = true
				Part.CanCollide = true
				Part.Massless = true
				Part.CanTouch = false
				Part.CastShadow = false
				Part.CanQuery = false
				Part.CollisionGroup = "RockDebris"
				Part.CFrame = NewCFrame
				Part.Parent = Folder

				local Success, Error = pcall(function()
					local Raycast = Auxiliary:Raycast(Part.Position, -Vector3.yAxis * 13)

					local ResultPosition = Raycast.Position
					local Object = Raycast.Instance

					local EndFrame = CFrame.lookAt(
						Vector3.new(NewCFrame.Position.X, ResultPosition.Y - Offset.Y, NewCFrame.Position.Z),
						Vector3.new(Position.X, ResultPosition.Y, Position.Z)
					)

					Part.CFrame = EndFrame * CFrame.new(0, -4, 0)

					Part.Material = Object.Material or Enum.Material.Plastic
					Part.Color = Object.Color
					Part.Transparency = Object.Transparency

					Part.Size = Vector3.zero

					Part.CFrame *= CFrame.fromEulerAnglesXYZ(
						math.rad(math.random(-10, 10) / 20),
						math.rad(Orientation + (math.random(-200, 200) / 20)),
						math.rad(math.random(-10, 10) / 20)
					)

					--/ @tween \--
					Create_Tween(Part, TweenInfo.new(0.1), {
						Size = Vector3.one * math.random(Size[1], Size[2]),
						CFrame = EndFrame * CFrame.Angles(math.rad(-math.random(Angle[1], Angle[2])), 0, 0),
					})

					--/ @wait \--
					SpawnService:Wait(DespawnTime, function()
						task.wait((i / Amount) / 25)

						Create_Tween(Part, TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
							Size = Part.Size * 0.2,
						})

						Create_Tween(Part, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {
							Transparency = 1,
						})

						local Tween =
							Create_Tween(Part, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
								CFrame = EndFrame * CFrame.new(0, -4, 0),
							})

						SpawnService:AddItem(Part, 1)
					end)
				end)

				if Success then
					print("Ray successfully casted!")
				else
					warn(Error)
				end
			end

			Orientation += 360 / Amount
		end
	end)
end

--/ @return 'debris' \--
return Crater
