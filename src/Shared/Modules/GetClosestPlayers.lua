return function (Character, Range)
	if Range == nil then
		Range = 300
	end

	local Players = {}

	for _, Player in pairs(game.Players:GetPlayers()) do
		if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and (Player.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).magnitude <= Range then
			table.insert(Players,Player)
		end
	end

	return Players
end