-- Camera Shake Presets
-- Stephen Leitnick
-- February 26, 2018

--[[
	
	CameraShakePresets.Bump
	CameraShakePresets.Explosion
	CameraShakePresets.Earthquake
	CameraShakePresets.BadTrip
	CameraShakePresets.HandheldCamera
	CameraShakePresets.Vibration
	CameraShakePresets.RoughDriving
	
--]]



local CameraShakeInstance = require(script.Parent.CameraShakeInstance)

local CameraShakePresets = {
	EXplosion = function()
		local c = CameraShakeInstance.new(5, 10, 0, 1.5)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(4, 1, 1)
		return c
	end;
	EXplosion2 = function()
		local c = CameraShakeInstance.new(3.5, 10, 0, 1.5)
		c.PositionInfluence = Vector3.new(0.2, 0.2, 0.2)
		c.RotationInfluence = Vector3.new(3, 1, 1)
		return c
	end;
	SmallExplosion = function()
		local c = CameraShakeInstance.new(2, 10, 0, 1.5)
		c.PositionInfluence = Vector3.new(0.15, 0.15, 0.15)
		c.RotationInfluence = Vector3.new(1, 1, 1)

		return c
	end;	
	BigBump = function()
		local c = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		c.PositionInfluence = Vector3.new(0.8, 0.8, 0.8)
		c.RotationInfluence = Vector3.new(1, 1, 1)
		return c
	end;

	SmallBump = function()
		local c = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		c.PositionInfluence = Vector3.new(0.01, 0.01, 0.01)
		c.RotationInfluence = Vector3.new(.5, .5, .5)
		return c
	end;
	-- A high-magnitude, short, yet smooth shake.
	-- Should happen once.
	Bump = function()
		local c = CameraShakeInstance.new(2.5, 4, 0.1, 0.75)
		c.PositionInfluence = Vector3.new(0.15, 0.15, 0.15)
		c.RotationInfluence = Vector3.new(.5, .5, .5)
		return c
	end;
	Bump3 = function()
		local c = CameraShakeInstance.new(1.25/2, 3/2, 0.2, .2)
		c.PositionInfluence = Vector3.new(0.75, 0.75, 0.75)
		c.RotationInfluence = Vector3.new(.25, .25, .25)
		return c
	end;
	Bump4 = function()
		local c = CameraShakeInstance.new(1.25/4, 3/4, 0.1, .1)
		c.PositionInfluence = Vector3.new(0.3, 0.3, 0.3)
		c.RotationInfluence = Vector3.new(.15, .15, .15)
		return c
	end;
	-- An intense and rough shake.
	-- Should happen once.
	Explosion = function()
		local c = CameraShakeInstance.new(10, 13, 0, 1)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(2.5, 1, 1)
		return c
	end;

	Explosion2 = function()
		local c = CameraShakeInstance.new(8, 12, 0, 2.5)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(2.5, 1, 1.5)
		return c
	end;
	Shake = function()
		local c = CameraShakeInstance.new(6, 13, 0, 1)
		c.PositionInfluence = Vector3.new(0.5, 0.1, 0.1)
		c.RotationInfluence = Vector3.new(1.5, 1, 1)
		return c
	end;
	Radar = function()
		local c = CameraShakeInstance.new(4, 13, 0, .5)
		c.PositionInfluence = Vector3.new(0.25, 0.25, 0.25)
		c.RotationInfluence = Vector3.new(1, 1, 1)
		return c
	end;
	-- A continuous, rough shake
	-- Sustained.
	Earthquake = function()
		local c = CameraShakeInstance.new(0.6, 7, 1, 3)
		c.PositionInfluence = Vector3.new(2, 4, 2)
		c.RotationInfluence = Vector3.new(6, 6, 16)
		return c
	end;


	-- A bizarre shake with a very high magnitude and low roughness.
	-- Sustained.
	BadTrip = function()
		local c = CameraShakeInstance.new(10, 0.15, 5, 10)
		c.PositionInfluence = Vector3.new(0, 0, 0.15)
		c.RotationInfluence = Vector3.new(2, 1, 4)
		return c
	end;


	-- A subtle, slow shake.
	-- Sustained.
	Bump2 = function()
		local c = CameraShakeInstance.new(5, 8, 0.2, 1)
		c.PositionInfluence = Vector3.new(0.3, 0.3, 0.3)
		c.RotationInfluence = Vector3.new(1, 1, 1)
		return c
	end;
	Bumpx = function()
		local r = .6
		local c = CameraShakeInstance.new(5*r, 8*r, 0.2*r, 1*r)
		c.PositionInfluence = Vector3.new(0.3, 0.3, 0.3)
		c.RotationInfluence = Vector3.new(1, 1, 1)
		return c
	end;

	-- A very rough, yet low magnitude shake.
	-- Sustained.
	Vibration = function()
		local c = CameraShakeInstance.new(1, 30, .5, .5)
		c.PositionInfluence = Vector3.new(0, 0.3, 0)
		c.RotationInfluence = Vector3.new(4, 0, 4)
		return c
	end;


	-- A slightly rough, medium magnitude shake.
	-- Sustained.
	RoughDriving = function()
		local c = CameraShakeInstance.new(1, 2, 1, 1)
		c.PositionInfluence = Vector3.new(0, .2, 0)
		c.RotationInfluence = Vector3.new(2, 1, 1)
		return c
	end;


}


return setmetatable({}, {
	__index = function(t, i)
		local f = CameraShakePresets[i]
		if (type(f) == "function") then
			return f()
		end
		error("No preset found with index \"" .. i .. "\"")
	end;
})