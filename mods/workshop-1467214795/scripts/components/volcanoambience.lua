local VolcanoAmbience = Class(function(self, inst)
	self.inst = inst

	self.inst:StartUpdatingComponent(self)
end)

local ambience = ""
function VolcanoAmbience:OnUpdate(dt)
	local vm = TheWorld.components.volcanomanager

	if vm then
		if vm:IsActive() then
			ambience = "active"
		elseif vm:IsDormant() then
			ambience = "Dormant"
		else
			ambience = ""
		end
		self.inst.replica.volcanoambience:SetVolcanoAmbience(ambience)
	end
end

return VolcanoAmbience
