local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WCS = require(ReplicatedStorage.Packages.WCS)

local Cast = WCS.RegisterStatusEffect("Cast")

function Cast:OnStartServer()
	self:SetHumanoidData({ WalkSpeed = { 0, "Set", 2 } })
end

return Cast
