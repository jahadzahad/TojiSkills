local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WCS = require(ReplicatedStorage.Packages.WCS)

local Block = WCS.RegisterStatusEffect("Block")

function Block:OnStartServer()
	self:SetHumanoidData({ WalkSpeed = { 8, "Set", 2 } })
end

return Block
