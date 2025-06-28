local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WCS = require(ReplicatedStorage.Packages.WCS)
local Skills = ReplicatedStorage.Shared.WCS.Skills

local Dagger = require(Skills.Combat.Attacks.Dagger)
local Block = require(Skills.Combat.Block)
local BlockBreak = require(Skills.Combat.BlockBreak)
local Parry = require(Skills.Combat.Parry)
local SlideAttack = require(Skills.Combat.SlideAttack)
local DropKick = require(Skills.Combat.DropKick)
local Evade = require(Skills.Combat.Evade)

local Pludge = require(Skills.Combat.Pludge)
local CriticalAttack = require(Skills.Combat.CriticalAttacks.Dagger)

local Uptilt = require(Skills.Combat.Uptilt)

local Slide = require(Skills.Movement.Slide)
local Dash = require(Skills.Movement.Dash)
local SlideJump = require(Skills.Movement.SlideJump)

return WCS.CreateMoveset("Dagger", { Dagger, Block, BlockBreak, Parry, Slide, SlideAttack, Dash, DropKick, SlideJump, Evade, Pludge, CriticalAttack, Uptilt })
