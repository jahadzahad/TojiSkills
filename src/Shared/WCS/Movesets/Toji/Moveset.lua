local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Skills = ReplicatedStorage.Shared.WCS.Movesets.Toji.Skills

local WCS = require(ReplicatedStorage.Packages.WCS)

return WCS.CreateMoveset("Toji", {
	require(Skills["Chain Reel"]),
	require(Skills["Massacre Counter"]),
})
