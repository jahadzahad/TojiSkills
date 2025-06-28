local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WCS = require(ReplicatedStorage.Packages.WCS)

local NoJump = WCS.RegisterStatusEffect("NoJump")

function NoJump:OnStartServer()
	self:SetHumanoidData({ JumpPower = { 0, "Set", 3 } })
end

return NoJump
