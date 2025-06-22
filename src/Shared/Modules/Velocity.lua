local module = {}

function module:Velocity(part, direction, distance, time)
	if not part:IsA("BasePart") or direction.Magnitude == 0 then return end

	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.Position = part.Position + direction.Unit * distance
	bodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bodyPosition.P = 10000
	bodyPosition.D = 1000
	bodyPosition.Name = "TemporaryBodyPosition"
	bodyPosition.Parent = part

	task.delay(time, function()
		if bodyPosition and bodyPosition.Parent then
			bodyPosition:Destroy()
		end
	end)
end

function module:VelocityRelativeRoot(character, enemy, time, distance, upforce)
	local root = enemy:FindFirstChild("HumanoidRootPart")
	local charRoot = character:FindFirstChild("HumanoidRootPart")
	if not root or not charRoot then return end
	if not upforce then upforce = 0 end

	local direction = charRoot.CFrame.LookVector
	local targetPosition = root.Position + direction * distance + Vector3.new(0,upforce,0)

	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.Position = targetPosition
	bodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bodyPosition.P = 10000
	bodyPosition.D = 1000
	bodyPosition.Name = "TemporaryBodyPosition"
	bodyPosition.Parent = root

	task.delay(time, function()
		if bodyPosition and bodyPosition.Parent then
			bodyPosition:Destroy()
		end
	end)
end

function module:RemoveAllBodyMovers(part, completeCleaning)
	local removedBodyMovers = {}
	local success, result = pcall(function()
		for _, obj in (not completeCleaning and part:GetChildren() or part:GetDescendants()) do
			if obj:IsA("BodyPosition") or obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") or 
				obj:IsA("BodyThruster") or obj:IsA("BodyForce") or obj:IsA("BodyAngularVelocity") then
				table.insert(removedBodyMovers, obj)
			end
		end
	end)
	for _, mover in removedBodyMovers do
		mover:Destroy()
	end
end

function module:SlowDownVelocity(character, enemy, t, max_distance)
	
	local root = enemy:FindFirstChild("HumanoidRootPart")
	local charRoot = character:FindFirstChild("HumanoidRootPart")
	if not root or not charRoot then return end

	local direction = charRoot.CFrame.LookVector
	local targetPosition = root.Position + direction * max_distance

	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.Position = targetPosition
	bodyPosition.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bodyPosition.P = 10000
	bodyPosition.D = 1000
	bodyPosition.Name = "TemporaryBodyPosition"
	bodyPosition.Parent = root

	task.delay(t, function()
		if bodyPosition and bodyPosition.Parent then
			bodyPosition:Destroy()
		end
	end)
	
	game:GetService("TweenService"):Create(bodyPosition,TweenInfo.new(t),{["MaxForce"] = Vector3.zero}):Play()
	
	
end

return module
