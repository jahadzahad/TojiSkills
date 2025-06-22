local darwinBox = script.Parent

local darwinModules = darwinBox.Parent

local utils = darwinModules.Utilities

local Types = {}

export type Direction = "Back" | "Front" | "Right" | "Left"

export type Caches = "FollowBox" | "ProjectileMotion"

export type PartCache = typeof(require(utils.PartCache))

export type TrackerBoxData = {
	Base : BasePart, --- the base to use so like your character primarypart or the projectile or like sword
	CFrame : CFrame?, -- the cframe for the hitbox
	Size : Vector3, -- the size of the hitbox
	Visual : boolean?, -- whether you want to see the hitbox or not
	OverlapParams : OverlapParams?, -- the overlapParams
	Duration : number?, -- optional to put a duration  in for how long to make it last
	ModelParams : {
		Once : boolean?, -- checks if part of same model so it don't hit a character based on the limbs,
		Character : boolean? -- checks if it a character based on humanoid
	}?, 
}

export type ProjectileMotionData = {
	Origin : CFrame, 
	Velocity : Vector3?, 
	Gravity : number?, 
	AirResistance : number?,
	Duration : number,
	Mass : number?,
	PhysicalProperties : PhysicalProperties?,
	RaycastParams : RaycastParams?,
	Size : Vector3?,
	GroundThreshold : number?,
	RollingFriction : number?,
	MinimumSpeed : number?,
	EnergyPreservation : number?,
	VisualParams : {
		Enabled : boolean?,
		Path : boolean?,
	}?
}

return Types
