local Debris = game:GetService("Debris")

local components = script.Parent

local darwinUtils = components.Parent

local types = require(darwinUtils.Types)

export type VisualParams = types.VisualParams
export type IgnoreListVFX = types.IgnoreListVFX

local VFXService = {}

function VFXService:EnableVisuals(base : Instance | {instance}, condition : boolean, visualParams : VisualParams)
	if typeof(base) == "Instance" then
		for _, visual : ParticleEmitter | Beam in base:GetDescendants() do
			if visualParams ~= nil then
				if visualParams.IgnoreList ~= nil then 
					if visualParams.IgnoreList.Class ~= nil then
						if visualParams.IgnoreList.Class.Parent ~= nil then
							if table.find(visualParams.IgnoreList.Class.Parent, base.ClassName) then continue end
							if table.find(visualParams.IgnoreList.Class.Parent, visual.Parent.Name) then continue end
							if table.find(visualParams.IgnoreList.Class.Parent, visual.Parent.Parent.Name) then continue end
							if table.find(visualParams.IgnoreList.Class.Parent, base.Parent.ClassName) then continue end
						end
						
						if visualParams.IgnoreList.Class.Child ~= nil then
							if table.find(visualParams.IgnoreList.Class.Child, visual.ClassName) then continue end
						end
					end
					
					if visualParams.IgnoreList.Name ~= nil then
						if visualParams.IgnoreList.Name.Parent ~= nil then
							if table.find(visualParams.IgnoreList.Name.Parent, base.Name) then continue end
							if table.find(visualParams.IgnoreList.Name.Parent, visual.Parent.Name) then continue end
							if table.find(visualParams.IgnoreList.Name.Parent, visual.Parent.Parent.Name) then continue end
							if table.find(visualParams.IgnoreList.Name.Parent, base.Parent.Name) then continue end
						end
						
						if visualParams.IgnoreList.Name.Child ~= nil then
							if table.find(visualParams.IgnoreList.Name.Child, visual.Name) then continue end
						end
					end
				end
			end
			
			if (
				visual:IsA("ParticleEmitter") == false and 
					visual:IsA("Beam") == false and 
					visual:IsA("Trail") == false and
					visual:IsA("Light") == false
				)then continue end

			visual.Enabled = condition
		end

		if visualParams == nil then return end
		if not visualParams.Destroy then return end

		Debris:AddItem(base, 1)
		return
	end

	if typeof(base) ~= "table" then return end
	if #base == 0 then return end

	for _, part in base do
		for _, visual : ParticleEmitter | Beam in part:GetDescendants() do
			if visualParams ~= nil then
				if visualParams.IgnoreList ~= nil then 
					if table.find(visualParams.IgnoreList, visual.ClassName) then continue end
				end
			end

			if (
				visual:IsA("ParticleEmitter") == false and 
					visual:IsA("Beam") == false and 
					visual:IsA("Trail") == false and
					visual:IsA("Light") == false
				)then continue end

			visual.Enabled = condition
		end

		if visualParams == nil then continue end
		if not visualParams.Destroy then continue end

		Debris:AddItem(part, 1)
	end
end

function VFXService:EmitAll(base : Instance)
	for _, visual : ParticleEmitter in base:GetDescendants() do
		if visual:IsA("ParticleEmitter") == false and visual:IsA("Beam") == false then continue end

		local emitDelay : number = visual:GetAttribute("EmitDelay") or 0

		task.delay(emitDelay, function()
			local duration : number = visual:GetAttribute("Duration") or 0
			
			if duration > 0 then
				if visual:IsA("ParticleEmitter") then
					local emitCount : number = visual:GetAttribute("EmitCount") or 0
					visual:Emit(emitCount)
				end
				
				visual.Enabled = true
				
				task.wait(duration)
				
				visual.Enabled = false
				return
			end
			
			if visual:IsA("ParticleEmitter") then
				local emitCount : number = visual:GetAttribute("EmitCount") or 1
				visual:Emit(emitCount)
			end
		end)
	end
end

return VFXService
