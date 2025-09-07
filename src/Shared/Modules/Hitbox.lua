local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local HitboxModule = {}
HitboxModule.HitboxClass = {}
HitboxModule.HitboxClass.__index = HitboxModule.HitboxClass

local WCS = require(ReplicatedStorage.Packages.WCS)
local Animation = require(ReplicatedStorage.Shared.Modules.Animation)

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Parry = require(ReplicatedStorage.Shared.WCS.Skills.Combat.Parry)
local Block = require(ReplicatedStorage.Shared.WCS.Skills.Combat.Block)
local BlockBreakM = require(ReplicatedStorage.Shared.WCS.Skills.Combat.BlockBreak)
local Evade = require(ReplicatedStorage.Shared.WCS.Skills.Combat.Evade)
local Dash = require(ReplicatedStorage.Shared.WCS.Skills.Movement.Dash)
local BlockHit = require(ReplicatedStorage.Shared.Refx.Combat.BlockHit)

local Pakets = require(ReplicatedStorage.Shared.Packets)

local Character = WCS.Character

local ParryCD = {}

function getCurrentWCS_Character(characterModel)
	if not characterModel then
		return
	end
	return Character.GetCharacterFromInstance(characterModel)
end

function HitboxModule:createHitbox(data, onHit)
	local self = setmetatable({}, HitboxModule.HitboxClass)

	local caster = data.Caster
	if not caster then
		return self
	end

	local rootPart = caster:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return self
	end
	print("Creating hitbox for:", caster.Name)

	self.Destroyed = false
	self.Visualize = nil
	self.Connection = nil
	self.DestroyedCallback = nil
	self.MoveTween = nil
	self.MoveOffset = data.Offset or CFrame.new(0, 0, 0)
	self.BaseOffset = data.Offset or CFrame.new(0, 0, 0)
	self.RootPart = rootPart
	self.Direction = nil

	local size = data.Size or Vector3.new(5, 5, 5)
	local offset = data.Offset or CFrame.new(0, 0, 0)
	local hitboxType = data.HitboxType or "Box"
	local ignoresBlock = data.IgnoresBlock or false
	local ignoresRagdoll = data.IgnoresRagdoll or false
	local ignoresIFrames = data.IgnoresIFrames or false
	local ignoresParry = data.ignoresParry or false
	local BlockBreak = data.BlockBreak or false
	local hitType = data.HitType or "OneHit"
	local tickInterval = data.TickInterval or 0.5
	local destructionDamage = data.DDamage or 0
	local debrisTime = data.Debris

	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = data.FilterList or { Workspace.Entities, workspace.Map, workspace }

	local AlreadyChecked = {}
	local hitList = {}
	local hitTimestamps = {}
	local houseTimestamps = {}

	local function shouldHit(character)
		print("Checking hit for character:", character)
		if character:GetAttribute("IFrames") and not ignoresIFrames then
			return false
		end
		if character:GetAttribute("Parry") and not ignoresParry then
			print("Parried")
			if Players:GetPlayerFromCharacter(character) then
				Pakets.Parry:FireClient(Players:GetPlayerFromCharacter(character), { Caster = caster })
			else
				getCurrentWCS_Character(character):GetSkillFromConstructor(Block):End(caster)
				getCurrentWCS_Character(character):GetSkillFromConstructor(Parry):Start(caster)
				AlreadyChecked[character] = true
			end

			return false
		end
		if character:GetAttribute("Evade") and not ignoresParry then
			getCurrentWCS_Character(character):GetSkillFromConstructor(Block):End(caster)
			getCurrentWCS_Character(character):GetSkillFromConstructor(Dash):End(caster)
			getCurrentWCS_Character(character):GetSkillFromConstructor(Evade):Start(caster)
			return false
		end
		if character:GetAttribute("Blocking") and not character:GetAttribute("Parry") and not ignoresBlock then
			if BlockBreak then
				getCurrentWCS_Character(character):GetSkillFromConstructor(Block):End(caster)
				getCurrentWCS_Character(character):GetSkillFromConstructor(BlockBreakM):Start(caster)
				return false
			else
				BlockHit.new(character):Start(Visuals:GetPlayers(character))
				return false
			end
		end
		if character:GetAttribute("Ragdoll") and not ignoresRagdoll then
			return false
		end
		return true
	end

	task.delay(data.DelayTime or 0, function()
		if self.Destroyed or not rootPart or not rootPart.Parent then
			self:Destroy()
			return
		end

		if data.Visualize or Workspace:GetAttribute("Debugging") then
			local visual = Instance.new("Part")
			visual.Anchored = true
			visual.CanCollide = false
			visual.Color = Color3.fromRGB(85, 0, 0)
			visual.Transparency = 0.8
			visual.Size = size
			visual.Parent = Workspace:FindFirstChild("Debris") or Workspace
			self.Visualize = visual

			if debrisTime then
				Debris:AddItem(visual, debrisTime)
			end
		end

		if debrisTime then
			self:AddFor(debrisTime)
		end

		self.Connection = RunService.Heartbeat:Connect(function()
			if not rootPart or not rootPart.Parent then
				self:Destroy()
				return
			end

			if hitboxType == "Box" then
				local cframe = (self.Direction or rootPart.CFrame) * self.MoveOffset
				if self.Visualize then
					self.Visualize.CFrame = cframe
				end

				local results = Workspace:GetPartBoundsInBox(cframe, size, params)
				local currentTime = tick()
				for _, part in pairs(results) do
					if part.Parent:IsA("Model") and destructionDamage > 0 then
						local House = part.Parent
						if House:GetAttribute("CanDestroy") == true then
							if hitType == "OneHit" then
								if not table.find(hitList, House) then
									House:SetAttribute("Health", House:GetAttribute("Health") - destructionDamage)
									table.insert(hitList, House)
								end
							elseif hitType == "Tick" then
								local lastHitTime = houseTimestamps[House]
								if not lastHitTime or (currentTime - lastHitTime) >= tickInterval then
									House:SetAttribute("Health", House:GetAttribute("Health") - destructionDamage)
									houseTimestamps[House] = currentTime
								end
							elseif hitType == "SingleTarget" then
								House:SetAttribute("Health", House:GetAttribute("Health") - destructionDamage)
							end
						end
					end

					local character = part:FindFirstAncestorOfClass("Model")
					if not character then
						continue
					end
					if character == caster then
						continue
					end
					if not character:FindFirstChildOfClass("Humanoid") then
						continue
					end
					print("Checking character:", character)

					if hitType == "OneHit" then
						if table.find(hitList, character) then
							continue
						end
					elseif hitType == "Tick" then
						local lastHitTime = hitTimestamps[character]
						if lastHitTime and (currentTime - lastHitTime) < tickInterval then
							continue
						end
					elseif hitType == "SingleTarget" then
					end

					if not shouldHit(character) then
						self:Destroy()
						break
					end

					if hitType == "OneHit" then
						table.insert(hitList, character)
					elseif hitType == "Tick" then
						hitTimestamps[character] = currentTime
					end

					onHit(character, getCurrentWCS_Character(character))

					if hitType == "SingleTarget" then
						self:Destroy()
						break
					end
				end
			end
		end)
		print("Hitbox started for:", caster.Name)
	end)

	return self
end

function HitboxModule.HitboxClass:Move(targetCFrame, duration, easingStyle, easingDirection, onComplete)
	if self.Destroyed then
		return
	end

	if not self.Direction then
		self.Direction = self.RootPart.CFrame
	end

	duration = duration or 1
	easingStyle = easingStyle or Enum.EasingStyle.Linear
	easingDirection = easingDirection or Enum.EasingDirection.InOut

	if self.MoveTween then
		self.MoveTween:Cancel()
		self.MoveTween = nil
	end

	local startOffset = self.MoveOffset
	local startTime = tick()

	local connection
	connection = RunService.Heartbeat:Connect(function()
		if self.Destroyed then
			connection:Disconnect()
			return
		end

		local elapsed = tick() - startTime
		local alpha = math.min(elapsed / duration, 1)

		if easingStyle == Enum.EasingStyle.Sine then
			if easingDirection == Enum.EasingDirection.In then
				alpha = 1 - math.cos(alpha * math.pi / 2)
			elseif easingDirection == Enum.EasingDirection.Out then
				alpha = math.sin(alpha * math.pi / 2)
			else
				alpha = 0.5 * (1 - math.cos(alpha * math.pi))
			end
		elseif easingStyle == Enum.EasingStyle.Quad then
			if easingDirection == Enum.EasingDirection.In then
				alpha = alpha * alpha
			elseif easingDirection == Enum.EasingDirection.Out then
				alpha = 1 - (1 - alpha) * (1 - alpha)
			else
				alpha = alpha < 0.5 and 2 * alpha * alpha or 1 - 2 * (1 - alpha) * (1 - alpha)
			end
		elseif easingStyle == Enum.EasingStyle.Bounce then
			if easingDirection == Enum.EasingDirection.Out then
				if alpha < 1 / 2.75 then
					alpha = 7.5625 * alpha * alpha
				elseif alpha < 2 / 2.75 then
					alpha = 7.5625 * (alpha - 1.5 / 2.75) * (alpha - 1.5 / 2.75) + 0.75
				elseif alpha < 2.5 / 2.75 then
					alpha = 7.5625 * (alpha - 2.25 / 2.75) * (alpha - 2.25 / 2.75) + 0.9375
				else
					alpha = 7.5625 * (alpha - 2.625 / 2.75) * (alpha - 2.625 / 2.75) + 0.984375
				end
			end
		end

		self.MoveOffset = startOffset:Lerp(targetCFrame, alpha)

		if alpha >= 1 then
			connection:Disconnect()
			self.MoveOffset = targetCFrame
			if onComplete then
				onComplete()
			end
		end
	end)

	self.MoveTween = connection
end

function HitboxModule.HitboxClass:StopMove()
	if self.MoveTween then
		self.MoveTween:Disconnect()
		self.MoveTween = nil
	end
end

function HitboxModule.HitboxClass:ResetPosition()
	self:StopMove()
	self.MoveOffset = self.BaseOffset
end

function HitboxModule.HitboxClass:AddFor(length)
	task.delay(length, function()
		self:Destroy()
	end)
end

function HitboxModule.HitboxClass:Destroy()
	if self.Destroyed then
		return
	end
	self.Destroyed = true

	self:StopMove()

	if self.Visualize then
		self.Visualize:Destroy()
	end

	if self.Connection then
		self.Connection:Disconnect()
	end

	if self.DestroyedCallback then
		self.DestroyedCallback()
	end
end

return HitboxModule
