local module = {}

function module:Play(SFX,Part)
	if Part then
		local RealPart = Part
		if Part:IsA("Model") then
			RealPart = Part.HumanoidRootPart
		end
		local Clone = SFX:Clone()
		Clone.Parent = RealPart
		Clone:Play()
		game.Debris:AddItem(Clone,5)
	else
		SFX:Play()
	end
end

return module
