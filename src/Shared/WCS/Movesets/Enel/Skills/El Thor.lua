local ReplicatedStorage = game:GetService( 'ReplicatedStorage' )

local WCS = require( ReplicatedStorage.Packages.WCS )
local Maid = require( ReplicatedStorage.Packages.Maid )

local Skill = WCS.RegisterSkill( tostring( script.Name ) )

local Animation = require(ReplicatedStorage.Shared.Modules.Animation)
local Maid = require(ReplicatedStorage.Packages.Maid)
local Sound = require(ReplicatedStorage.Shared.Modules.Sound)
local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)
local Ragdoll = require(ReplicatedStorage.Shared.Modules.Ragdoll)
local Velocity = require(ReplicatedStorage.Shared.Modules.Velocity)
--local Hitbox = require(ReplicatedStorage.Shared.Modules.Hitbox)
--local Damage = require(ReplicatedStorage.Shared.Modules.Damage)

local NegativeEffects = {
	Stun = require(ReplicatedStorage.Shared.WCS.StatusEffects.Stun),
	Cast = require(ReplicatedStorage.Shared.WCS.StatusEffects.Cast),
}

local GetClosestPlayers = require( ReplicatedStorage.Shared.Modules.GetClosestPlayers )

function Skill:OnStartServer()
	self.Maid = Maid.new()
	
	local Effect = require( ReplicatedStorage.Shared.Refx.Movesets.Enel[ tostring( script.Name ) ] )
	local VFX = Effect.new( self.Character.Instance )
	
	local StunVal = NegativeEffects.Stun.new(self.Character)
	StunVal:Start(3)
	
	self:ApplyCooldown( 4 )
	
	local Animation = self.Character.Humanoid.Animator:LoadAnimation( ReplicatedStorage.Shared.Assets.Animations.Movesets.Enel[ 'El Thor' ].User_Cast )
	Animation:Play(); VFX:Start( GetClosestPlayers( self.Character.Instance ) )
	
	self.Maid:GiveTask( Animation.Stopped:Once( function()
		local Animation2 = self.Character.Humanoid.Animator:LoadAnimation( ReplicatedStorage.Shared.Assets.Animations.Movesets.Enel[ 'El Thor' ].User_Linger )
		Animation2:Play()
		
		--local HITBOX = Hitbox:createHitbox( {
		--	Caster = self.Character.Instance,
		--	Size = Vector3.new(15, 15, 15),
		--	Offset = CFrame.new(0, 0, -4),
		--	HitType = 'Tick',
		--	tickInterval = 0.1,
		--	Debris = .7,
		--	Visualize = true,
		--}, function( Target, WCSTarget )
		--	local StunVal2 = NegativeEffects.Stun.new( WCSTarget )
		--	StunVal2:Start(1)
			
		--	Damage:TakeDamage( self.Character.Instance, Target, 7 )
		--end )
		
		task.delay( 2, function()
			Animation2:Stop()
		end )
	end ) )
	
	print( script.Name )
end

function Skill:OnStartClient()
	print( script.Name )
end

return Skill