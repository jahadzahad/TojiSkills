local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFX = ReplicatedStorage.Shared.Assets.VFX

local Visuals = require(ReplicatedStorage.Shared.Modules.Visuals)

local Refx = require(ReplicatedStorage.Packages.Refx)
local Footsteps = Refx.CreateEffect("Footsteps")

function Footsteps:OnStart(Character, Limb)
	local origin = Character[Limb].Position
	local direction = Vector3.new(0, -1, 0)
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = { Character }
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(origin, direction, rayParams)

	if result and result.Instance and result.Instance:IsA("BasePart") then
		local hitColor = result.Instance.Color

		local normal = result.Normal
		local up = normal
		local forward = -Character.HumanoidRootPart.CFrame.LookVector
		local right = forward:Cross(up).Unit
		forward = up:Cross(right).Unit

		local alignedCFrame = CFrame.fromMatrix(result.Position, right, up)

		local Spawn = Visuals:Spawn(VFX.Base.Footprint, alignedCFrame * CFrame.new(0, 0.01, 0))
		Spawn.Attachment2.Dust.Color = ColorSequence.new(hitColor)
		Visuals:Emit(Spawn)
		Debris:AddItem(Spawn, 5)
	end
end


return Footsteps
