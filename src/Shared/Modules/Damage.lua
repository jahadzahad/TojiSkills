local module = {}

local Visuals = require(game.ReplicatedStorage.Shared.Modules.Visuals)
local DamageEffect = require(game.ReplicatedStorage.Shared.Refx.Combat.Misc.Damage)

function module:TakeDamage(Character, Target, Damage)
	if Target.Humanoid.Health <= 0 then
		return
	end
	Target.Humanoid:TakeDamage(Damage)
	DamageEffect.new(Target,Damage):Start(Visuals:GetPlayers(Character,100))
end

return module
