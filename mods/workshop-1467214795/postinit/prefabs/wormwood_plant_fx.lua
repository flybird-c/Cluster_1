local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local SetVariation_old
local function SetVariation(inst, variation, ...)
	if IsOnOcean(inst) then return inst:Remove() end
	return SetVariation_old(inst, variation, ...)
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------


IAENV.AddPrefabPostInit("wormwood_plant_fx", function(inst)
	if inst.SetVariation then
		SetVariation_old = inst.SetVariation
		inst.SetVariation = SetVariation
	end
end)
