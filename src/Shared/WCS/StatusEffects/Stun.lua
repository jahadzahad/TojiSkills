local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WCS = require(ReplicatedStorage.Packages.WCS)

local Stun = WCS.RegisterStatusEffect("Stun")

function Stun:OnStartServer()
	self:SetHumanoidData({ WalkSpeed = { 0, "Set", 3 } })
end

return Stun
