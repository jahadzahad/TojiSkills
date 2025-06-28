local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFX = ReplicatedStorage.Shared.Assets.VFX

local CameraShaker = require(ReplicatedStorage.Shared.Modules.CameraShaker)

local Camera = workspace.CurrentCamera

local Refx = require(ReplicatedStorage.Packages.Refx)
local CameraShake = Refx.CreateEffect("CameraShake")

function CameraShake:OnStart(Preset)
	local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCf)
        if shakeCf then
            Camera.CFrame *= shakeCf
        else
            warn("shakeCf is nil")
        end
    end)
    
    camShake:Start()
    camShake:Shake(CameraShaker.Presets[Preset])
end

return CameraShake
