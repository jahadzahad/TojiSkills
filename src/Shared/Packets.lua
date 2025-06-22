local ReplicatedStorage = game:GetService( 'ReplicatedStorage' )
local Packet = require(ReplicatedStorage.Shared.Modules.Packet)

-->> EXAMPLE <<--

--local Packet = Packet("adjgh",{
--	Action = Packet.String,
--	Amount = Packet.NumberU16,
--	ItemName = Packet.String,
--	Extra = {
--		Stats = {Packet.String} or Packet.Nil
--	} or {}
--})
--Packet:Fire({
--	Action  = "String",
--	Amount = 12,
--	ItemName = "Something",
--	Extra = {}
--})
--Packet.OnServerEvent:Connect(function(Player)
	
--end)

return {
	--[ MISC ]--
	
	Ragdoll = Packet( 'Ragdoll', { Value = Packet.Any } ),
    Parry = Packet( 'Parry', { Caster = Packet.Any } )
}