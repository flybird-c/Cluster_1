local WindProofer = Class(function(self, inst)
	self.inst = inst
	self.effectiveness = 1
    --Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("windproofer")
end)

function WindProofer:OnRemoveFromEntity()
    self.inst:RemoveTag("windproofer")
end

function WindProofer:GetEffectiveness()
	return self.effectiveness
end

function WindProofer:SetEffectiveness(val)
	self.effectiveness = val
end

return WindProofer