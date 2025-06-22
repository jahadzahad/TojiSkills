--[[

-- FUNCTIONS --

DarwinBox.Setup = function(cacheName : Caches, template : BasePart, partAmount : number?) : PartCache
--this is to setup must setup before you can use any other function

--Constructors---

DarwinBox.TrackerBox = function(trackerBoxData : TrackerBoxData, func : (hitboxResult : {Instance}, startTime : number) -> ()) : RBXScriptConnection
--Creates a trackerhitbox this is to track a part

--Methods--

DarwinBox:Destroy(cacheName : Caches, part : BasePart)
--Destroy a hitbox that was made

DarwinBox:Direction(cframe1 : CFrame, cframe2 : CFrame, distance : number, axis : "X" | "Z") : Direction?
--Checks direction depending on 2 cframe positions you give depending on axis. It returns a string "Back" | "Front" | "Left" | "Right"

--INSTRUCTIONS--

--Setup--
To setup you muse use this constructor function,  the way to use it you must give a "cacheName", this can be any string really,
once you made the name the "template", is a basepart just create a basepart and send it through this,
"partAmount", this is how many copies you want, just make like 1000 or 10000,

DarwinBox.Setup = function(cacheName : Caches, template : BasePart, partAmount : number?) : PartCache
--this is to setup must setup before you can use any other function

--CONSTRUCTORS--

--TrackerBox--

create a data table based on "TrackerBoxData"

trackerBoxData : TrackerBoxData = {
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

The "func", this is just the function which will handle the callback for the hitbox, you can either create a lambda fucntion,
or a named function.

The callback arguments are "hitboxResult" which is the normal return data of "GetPartsInPart" which is a result of what it hit.
The "startTime" argument is based on when it first started based in the result of "workspace:GetServerTimeNow()"

the callback of the constructor function returns a connection,
meaning you can disconnect it if you want to whenever you want to stop the hitbox

local connection : RBXScriptConnection = DarwinBox.TrackerBox(trackerBoxData, function(hitboxResult, startTime)
--code here
end)


--]]


