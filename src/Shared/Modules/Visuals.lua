local module = {}

function module:Spawn(Part,Cframe,Parent,Anchore)
	if not Parent then
		Parent = workspace.Debris
	end
	if not Anchore then
		Anchore = true
	end
	local Clone:Part = Part:Clone()
	Clone.Parent = Parent
	
	if Cframe then
		Clone.CFrame = Cframe
	end
	if Clone:IsA("Part") then
		Clone.Anchored = Anchore
		Clone.CanCollide = false
	end
	
	return Clone
end

function module:Emit(Part)
	for _,v in pairs(Part:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v:Emit(v:GetAttribute("EmitCount"))
		end
	end
end

function module:Enabled(Part,Value)
	for _,v in pairs(Part:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Beam") then
			v.Enabled = Value
		end
	end
end

function module:Weld(Part0,Part1,C0,C1)
	if not C0 then C0 = CFrame.new(0,0,0) end
	if not C1 then C1 = CFrame.new(0,0,0) end
	local Weld = Instance.new("Motor6D")
	Weld.Part0 = Part0
	Weld.Part1 = Part1
	Weld.C0 = C0
	Weld.C1 = C1
	Weld.Parent = Part0
	return Weld
end

function module:GetPlayers(Character,Range)
	if not Range then
		Range = 10000
	end
	local Players = {}
	for _,v in pairs(game.Players:GetPlayers()) do
		if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			if (v.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude <= Range then
				table.insert(Players,v)
			end
		end
	end
	return Players
end

return module
