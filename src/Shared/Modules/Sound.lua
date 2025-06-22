local module = {}

function module:Play(SFX, Part)
	if Part then
		local Clone = SFX:Clone()
		Clone.Parent = Part
		Clone:Play()
		game.Debris:AddItem(Clone,5)
	else
		SFX:Play()
	end
end

return module
