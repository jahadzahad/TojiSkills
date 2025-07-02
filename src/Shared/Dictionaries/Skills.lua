local module = {
	["Enel"] = {
		["Move1"] = {
			Name = "El Thor",
			WCS = require(game.ReplicatedStorage.Shared.WCS.Skills.Moves.Enel["El Thor"]),
			Refx = require(game.ReplicatedStorage.Shared.Refx.Combat.Skills.Enel["El Thor"]),
			Cooldown = 40,
		},
		["Move2"] = {
			Name = "Celestial Blitz",
			WCS = require(game.ReplicatedStorage.Shared.WCS.Skills.Moves.Enel["Celestial Blitz"]),
			Refx = require(game.ReplicatedStorage.Shared.Refx.Combat.Skills.Enel["Celestial Blitz"]),
			Cooldown = 20,
		},
	}
}

return module
