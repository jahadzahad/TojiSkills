export type RagdollParams = {
	PlatformStand : boolean?, 
	Recover : boolean?, 
	DelayTime : number?,
	Override : boolean?,
}

local attachmentCFrames = {
	["Neck"] = {CFrame.new(0, 1, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1), CFrame.new(0, -0.5, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1)},
	["Left Shoulder"] = {CFrame.new(-1.3, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1), CFrame.new(0.2, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1)},
	["Right Shoulder"] = {CFrame.new(1.3, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), CFrame.new(-0.2, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
	["Left Hip"] = {CFrame.new(-0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)},
	["Right Hip"] = {CFrame.new(0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)},
}

local ragdollInstanceNames = {
	["RagdollAttachment"] = true,
	["RagdollConstraint"] = true,
	["ColliderPart"] = true,
}

local storedCharacters : {
	[Model] : {
		Thread : thread,
		EndTime : number
	}
} = {}


local Handler = {}

local function createColliderPart(part: BasePart)
	if part == nil then return end
	local ragdollPart : Part = Instance.new("Part")
	ragdollPart.Name = "ColliderPart"
	ragdollPart.Size = part.Size/1.7
	ragdollPart.Massless = true			
	ragdollPart.CFrame = part.CFrame
	ragdollPart.Transparency = 1
	ragdollPart.CanCollide = false

	local weld : WeldConstraint = Instance.new("WeldConstraint")
	weld.Part0 = ragdollPart
	weld.Part1 = part

	weld.Parent = ragdollPart
	ragdollPart.Parent = part
end

function Handler:SetRagdoll(character : Model, duration : number?, params : RagdollParams?)
	local humanoid : Humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid == nil then
		humanoid = character:WaitForChild("Humanoid")
	end
	humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
	humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	if params ~= nil then
		if params.PlatformStand == true then
			humanoid.PlatformStand = true
		end
	end

	for _, motor: Motor6D in character:GetDescendants() do
		if motor:IsA("Motor6D") then
			if attachmentCFrames[motor.Name] == nil then continue end
			motor.Enabled = false

			local attachment0 : Attachment, attachment1 : Attachment = Instance.new("Attachment"), Instance.new("Attachment")
			attachment0.CFrame = attachmentCFrames[motor.Name][1]
			attachment1.CFrame = attachmentCFrames[motor.Name][2]

			attachment0.Name = "RagdollAttachment"
			attachment1.Name = "RagdollAttachment"

			createColliderPart(motor.Part1)

			local ballSocketConstraint : BallSocketConstraint = Instance.new("BallSocketConstraint")
			ballSocketConstraint.Attachment0 = attachment0
			ballSocketConstraint.Attachment1 = attachment1
			ballSocketConstraint.Name = "RagdollConstraint"

			ballSocketConstraint.Radius = 0.15
			ballSocketConstraint.LimitsEnabled = true
			ballSocketConstraint.TwistLimitsEnabled = false
			ballSocketConstraint.MaxFrictionTorque = 0
			ballSocketConstraint.Restitution = 0
			ballSocketConstraint.UpperAngle = 90
			ballSocketConstraint.TwistLowerAngle = -45
			ballSocketConstraint.TwistUpperAngle = 45

			if motor.Name == "Neck" then
				ballSocketConstraint.TwistLimitsEnabled = true
				ballSocketConstraint.UpperAngle = 45
				ballSocketConstraint.TwistLowerAngle = -70
				ballSocketConstraint.TwistUpperAngle = 70
			end

			attachment0.Parent = motor.Part0
			attachment1.Parent = motor.Part1
			ballSocketConstraint.Parent = motor.Parent
		end
	end

	if duration == nil then return end

	if storedCharacters[character] == nil then
		storedCharacters[character] = {}
	end

	local endTime : number = workspace:GetServerTimeNow() + duration

	local override : boolean = false
	local recover : boolean = nil
	local raycastParams : RaycastParams = nil

	if params~= nil then
		recover = params.Recover
		duration =  params.DelayTime
		override = params.Override
	end

	if storedCharacters[character].EndTime ~= nil then
		if storedCharacters[character].EndTime > endTime and not override then return end
	end

	if storedCharacters[character].Thread ~= nil then
		task.cancel(storedCharacters[character].Thread)
		storedCharacters[character].Thread = nil
	end

	storedCharacters[character].EndTime = endTime

	storedCharacters[character].Thread = task.delay(duration, function()
		if storedCharacters[character].EndTime ~= endTime then return end

		Handler:Reset(character, recover, duration)
	end)
end

function Handler:Reset(character : Model, recover : boolean, duration : number?)
	local humanoid : Humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid == nil then
		humanoid = character:WaitForChild("Humanoid")
	end

	if recover == true then
		if duration ~= nil then
			task.wait(duration)
		end

		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end

	for _, instance in character:GetDescendants() do
		if ragdollInstanceNames[instance.Name] then
			instance:Destroy()
		end

		if instance:IsA("Motor6D") == false then continue end
		instance.Enabled = true
	end

	humanoid.PlatformStand = false
	humanoid.AutoRotate = true
end

return Handler
