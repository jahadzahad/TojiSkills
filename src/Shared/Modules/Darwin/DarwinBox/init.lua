local RunService = game:GetService("RunService")

local darwinModules = script.Parent

local utils = darwinModules.Utilities

local types = require(script.Types)
local partCacheModule = require(utils.PartCache)
local threadHandler = require(utils.ThreadHandler)

export type PartCache = types.PartCache
export type TrackerBoxData = types.TrackerBoxData
export type Caches = types.Caches
export type Direction = types.Direction
export type ProjectileMotionData = types.ProjectileMotionData

local storedCaches = {}
local storedProjectiles : {BasePart} = {}

workspace:SetAttribute("HITBOX_DEBUG", false)

local DarwinBox = {}

DarwinBox.Setup = function(cacheName : Caches, template : BasePart, partAmount : number?) : PartCache
	if cacheName == nil then
		warn(`cacheName is {cacheName}`)
	end

	local world : Folder = workspace:FindFirstChild("World")

	if world == nil then
		world = Instance.new("Folder")
		world.Name = "World"
		world.Parent = workspace
	end

	local debrisFolder : Folder = world:FindFirstChild("Debris")

	if debrisFolder == nil then
		debrisFolder = Instance.new("Folder")
		debrisFolder.Name = "Debris"
		debrisFolder.Parent = world
	end

	local partsFolder : Folder

	if cacheName == "ProjectileMotion" then
		partsFolder = debrisFolder:FindFirstChild("Debug")

		if partsFolder == nil then
			partsFolder = Instance.new("Folder")
			partsFolder.Name = "Debug"
			partsFolder.Parent = debrisFolder
		end
	else
		partsFolder = debrisFolder:FindFirstChild("Hitboxes")

		if partsFolder == nil then
			partsFolder = Instance.new("Folder")
			partsFolder.Name = "Hitboxes"
			partsFolder.Parent = debrisFolder
		end
	end

	if template == nil then
		template = Instance.new("Part")
	end

	if partAmount == nil or 0 then
		partAmount = 10000
	end

	if storedCaches[cacheName] == nil then
		storedCaches[cacheName] = partCacheModule.new(template, partAmount, partsFolder)
	end

	return storedCaches[cacheName]
end

DarwinBox.TrackerBox = function(trackerBoxData : TrackerBoxData, func : (hitboxResult : {Instance}, startTime : number, objectHitbox : BasePart) -> ()) : RBXScriptConnection
	local provider : PartCache = storedCaches["FollowBox"]

	if provider == nil then
		warn("Did not setup")

		provider = DarwinBox.Setup("FollowBox")
	end

	local debugAttribute : boolean = workspace:GetAttribute("HITBOX_DEBUG")

	local visual : boolean = trackerBoxData.Visual or debugAttribute

	local objectHitbox : BasePart = provider:GetPart()
	objectHitbox.CFrame = trackerBoxData.CFrame
	objectHitbox.Anchored = false
	objectHitbox.Size = trackerBoxData.Size
	objectHitbox.CanCollide = false
	objectHitbox.CanTouch = false
	objectHitbox.CastShadow = false
	objectHitbox.Massless = true
	objectHitbox.Color = Color3.fromRGB(255, 31, 11)
	objectHitbox.Transparency = visual and 0.5 or 1

	local weld : WeldConstraint = objectHitbox:FindFirstChildOfClass("WeldConstraint")

	if weld == nil then
		weld = Instance.new("WeldConstraint")
		weld.Parent = objectHitbox
		weld.Part1 = objectHitbox
	end

	weld.Part0 = trackerBoxData.Base

	local startTime : number = workspace:GetServerTimeNow()

	local hasHit : {BasePart} = {}

	local connection : RBXScriptConnection
	connection = RunService.Heartbeat:Connect(function()
		if trackerBoxData.Duration ~= nil then
			if workspace:GetServerTimeNow() - startTime > trackerBoxData.Duration then
				connection:Disconnect()
			end
		end

		local hitBoxResult : {Instance} = workspace:GetPartsInPart(objectHitbox, trackerBoxData.OverlapParams)

		if typeof(func) ~= "function" then 
			warn("Must provide a callback function")
			return connection:Disconnect()
		end

		local modelParams = trackerBoxData.ModelParams
		if modelParams ~= nil then
			if modelParams.Once == true then
				local newResult : {Instance} = {}

				if #hitBoxResult ~= 0 then
					for _, partOfModel in hitBoxResult do
						if partOfModel.Parent == nil then continue end

						local modelParent : Model = partOfModel.Parent
						local anscestor : Model = partOfModel:FindFirstAncestorWhichIsA("Model")
						if modelParent:IsA("Model") == false and anscestor == nil then continue end

						local store : Model = anscestor
						if store == nil then
							store= modelParent
						end

						if modelParams.Character == true then
							if store:FindFirstChildOfClass("Humanoid") == nil then continue end
						end

						if table.find(hasHit, store) then continue end

						table.insert(hasHit, store)
						table.insert(newResult, store)
					end
				end
				hitBoxResult = newResult
			end
		end 

		func(hitBoxResult, workspace:GetServerTimeNow() - startTime, objectHitbox)
	end)

	threadHandler.Spawn(function()
		repeat task.wait()	
		until not connection.Connected or trackerBoxData.Base.Parent == nil

		connection:Disconnect()

		DarwinBox:Destroy("FollowBox", objectHitbox)
	end)

	return connection
end


function DarwinBox:Destroy(cacheName : Caches, part : BasePart)
	local provider : PartCache = storedCaches["FollowBox"]

	if provider == nil then
		warn("Cache does not exist")
		return
	end 

	local weld : WeldConstraint = part:FindFirstChildOfClass("WeldConstraint")

	if weld ~= nil then
		weld.Part0 = nil
	end

	provider:ReturnPart(part)
end

function DarwinBox:Direction(cframe1 : CFrame, cframe2 : CFrame, distance : number, axis : "X" | "Z") : Direction?
	local dot : (Vector3) -> (Vector3) = Vector3.one.Dot
	local objectSpace : CFrame = cframe2:Inverse() * cframe1
	local object1Position : Vector3 = cframe1.Position
	local object2Position : Vector3 = cframe2.Position

	if dot(object1Position, object2Position) >= dot(distance, distance) then return end

	local direction : string = axisCalculate(objectSpace, axis)
	return direction
end

function axisCalculate(objectSpace : CFrame, axis : string) : string
	local direction : string = ""
	local axisSpace = objectSpace[axis] :: number
	if axisSpace > 0 then
		direction = if axis == "Z" then "Back" else "Left"
	elseif axisSpace <= 0 then
		direction = if axis == "Z" then "Front" else "Right"
	end
	return direction
end

return DarwinBox
