local RagdollHandler = {}

local Packets = require(game.ReplicatedStorage.Shared.Packets) 

local function createweld(character)
	if not character then return end

	local Root = character:FindFirstChild("HumanoidRootPart")
	if not Root or not Root:IsA("BasePart") then return end

	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if not torso or not torso:IsA("BasePart") then return end

	local weldfound = Root:FindFirstChild("RootWeld")
	if weldfound and weldfound:IsA("Weld") then
		return weldfound
	else
		if weldfound then
			weldfound:Destroy()
		end

		local weld = Instance.new("Weld")
		weld.Name = "RootWeld"
		weld.Part0 = Root
		weld.Part1 = torso
		weld.Enabled = false
		weld.Parent = Root
		return weld
	end
end

function RagdollHandler:rig(character, constraintData)
	if character:FindFirstChild("RagdollConstraints") then return end

	local weld = createweld(character)
	if weld then
		weld.Enabled = false
	end

	local constraints = Instance.new("Folder")
	constraints.Name = "RagdollConstraints"
	constraints.Parent = character

	local Hum = character:FindFirstChildWhichIsA("Humanoid")

	if Hum then
		Hum.BreakJointsOnDeath = false
		Hum.Died:Once(function()
			self:ragdoll(true, character)
		end)
	end

	for _, motor in pairs(character:GetDescendants()) do
		if motor:IsA("Motor6D") and motor.Name ~= "RootJoint" then
			local part0, part1 = motor.Part0, motor.Part1
			if part0 and part1 then
				local attachment0 = part0:FindFirstChild(("%*RigAttachment"):format(motor.Name))
				local attachment1 = part1:FindFirstChild(("%*RigAttachment"):format(motor.Name))
				if not attachment0 or not attachment1 then
					if attachment0 then
						attachment0:Destroy()
					end
					if attachment1 then
						attachment1:Destroy()
					end
					attachment0 = Instance.new("Attachment")
					attachment1 = Instance.new("Attachment")
					attachment0.Name = ("%*RigAttachment"):format(motor.Name)
					attachment1.Name = ("%*RigAttachment"):format(motor.Name)
					attachment0.Parent = part0
					attachment1.Parent = part1
					attachment1.Position = motor.C1.Position
					attachment0.WorldPosition = attachment1.WorldPosition
				end
				if attachment0 and attachment1 then
					local jointName = motor.Name:match("[A-Z]?%l*$")
					if jointName and constraintData and constraintData[jointName] then
						for constraintType, properties in pairs(constraintData[jointName]) do
							local success, constraintInstance = pcall(function()
								return Instance.new(constraintType)
							end)
							if not success or not constraintInstance then
								if typeof(constraintInstance) == "Instance" 
									and not constraintInstance:IsA("Constraint") 
									and not constraintInstance:IsA("NoCollisionConstraint") 
									and not constraintInstance:IsA("WeldConstraint") then
									constraintInstance:Destroy()
								end
							else
								if constraintInstance:IsA("NoCollisionConstraint") 
									or constraintInstance:IsA("WeldConstraint") then
									constraintInstance.Part0 = part0
									constraintInstance.Part1 = part1
								else
									constraintInstance.Attachment0 = attachment0
									constraintInstance.Attachment1 = attachment1
								end
								constraintInstance.Name = part1.Name .. constraintType
								for property, value in pairs(properties) do
									if properties and typeof(constraintInstance[property]) ~= "Instance" then
										constraintInstance[property] = value
									end
								end
								local jointFolder = constraints:FindFirstChild(jointName)
								if not jointFolder then
									if not jointName then
										jointFolder = constraints
									else
										jointFolder = Instance.new("Folder")
										jointFolder.Name = jointName
										jointFolder.Parent = constraints
									end
								end
								constraintInstance.Enabled = false
								constraintInstance.Parent = jointFolder
							end
						end
					elseif not constraintData then
						local ballSocket = Instance.new("BallSocketConstraint")
						ballSocket.Name = part1.Name .. ballSocket.Name
						ballSocket.LimitsEnabled = true
						ballSocket.TwistLimitsEnabled = true
						ballSocket.Attachment0 = attachment0
						ballSocket.Attachment1 = attachment1
						local defaultFolder = constraints:FindFirstChild(jointName)
						if not defaultFolder then
							if not jointName then
								defaultFolder = constraints
							else
								defaultFolder = Instance.new("Folder")
								defaultFolder.Name = jointName
								defaultFolder.Parent = constraints
							end
						end
						ballSocket.Enabled = false
						ballSocket.Parent = defaultFolder
					end
				end
			end
		end
	end

	character:SetAttribute("Ragdoll", false)
	
end

function RagdollHandler:SetNetworkOwner(character,ToPlayer)
	if ToPlayer then
		local Player = game.Players:GetPlayerFromCharacter(character)
		if Player then
			for i,v in pairs(character:GetChildren()) do
				if not v:IsA("Part") then continue end
				v:SetNetworkOwner(Player)
			end
		end
	else
		for i,v in pairs(character:GetChildren()) do
			if not v:IsA("Part") then continue end
			v:SetNetworkOwner(nil)
		end
	end
end

function RagdollHandler:ragdoll(val, character)
	if not character:FindFirstChild("RagdollConstraints") then
		self:rig(character)
	end

	local Hum = character:FindFirstChildWhichIsA("Humanoid")
	local Head = character:FindFirstChild("Head")
	local Torso = character:FindFirstChild("Torso")
	local Root = character:FindFirstChild("HumanoidRootPart")
	local Player = game.Players:GetPlayerFromCharacter(character)
	
	if not val and Hum.Health <= 0 then
		return
	else
		if Head and Head:IsA("BasePart") then
			Head.CanCollide = val
		end

		if Hum then
			Hum.AutoRotate = not val
			if Player == nil then
				self:SetNetworkOwner(character, false)
				if val then
					Hum:ChangeState(Enum.HumanoidStateType.Physics)
				else
					Hum:ChangeState(Enum.HumanoidStateType.GettingUp)
				end
			else
				Packets.Ragdoll:FireClient(Player,{Value = val})
			end
			
			for i,v in pairs(Hum:GetPlayingAnimationTracks()) do
				v:Stop()
			end
		end

		if Root then
			local Weld = Root:FindFirstChild("RootWeld")
			if Weld then
				Weld.Enabled = val
			end
		end

		for _, v in pairs(character:GetDescendants()) do
			if v:IsA("Constraint") or v:IsA("NoCollisionConstraint") or v:IsA("WeldConstraint") then
				v.Enabled = val
			elseif v:IsA("Motor6D") then
				v.Enabled = not val
			end
		end
		
		character:SetAttribute("Ragdoll", val)
		
		return
	end
end


return RagdollHandler
