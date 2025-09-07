local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WCS = require(ReplicatedStorage.Packages.WCS)
local Skills = ReplicatedStorage.Shared.WCS.Skills

local Fist = require(Skills.Combat.Attacks.Fists)
local Block = require(Skills.Combat.Block)
local BlockBreak = require(Skills.Combat.BlockBreak)
local Parry = require(Skills.Combat.Parry)
local SlideAttack = require(Skills.Combat.SlideAttack)
local DropKick = require(Skills.Combat.DropKick)
local Evade = require(Skills.Combat.Evade)

local Pludge = require(Skills.Combat.Pludge)
local CriticalAttack = require(Skills.Combat.CriticalAttacks.Fists)

local Uptilt = require(Skills.Combat.Uptilt)

local Slide = require(Skills.Movement.Slide)
local Dash = require(Skills.Movement.Dash)
local SlideJump = require(Skills.Movement.SlideJump)

local Party_Table = require(Skills.Moves.BlackLeg["Party Table"])
local Grill_Shot = require(Skills.Moves.BlackLeg["Grill Shot"])
local Concasser = require(Skills.Moves.BlackLeg["Concasser"])
local ProjectileKick = require(Skills.Moves.BlackLeg["Projectile Kick"])
local TripleKicks = require(Skills.Moves.BlackLeg["Triple Kicks"])

return WCS.CreateMoveset("BlackLeg", {
	Fist,
	Block,
	BlockBreak,
	Parry,
	Slide,
	SlideAttack,
	Dash,
	DropKick,
	SlideJump,
	Evade,
	Pludge,
	CriticalAttack,
	Uptilt,
	Party_Table,
	Grill_Shot,
	Concasser,
	ProjectileKick,
	TripleKicks,
})
