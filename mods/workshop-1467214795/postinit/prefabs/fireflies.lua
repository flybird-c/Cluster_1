local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
-- TheWorld:PushEvent("ms_setphase","night")

local needtoupvaluehack = true

local updatelight_old
local fadeout

local function updatelight( inst, ... )
	if TheWorld.state.iswinter and IsInIAClimate(inst) then
		if fadeout then
			return fadeout( inst, ... )
		end
	else
		return updatelight_old( inst, ... )
	end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("fireflies", function(inst)
	if TheWorld.ismastersim then
		if inst.components.inventoryitem then
			inst.components.inventoryitem.notboattossable = true
		end
		if needtoupvaluehack then
			updatelight_old = UpvalueHacker.GetUpvalue(inst.components.inventoryitem.ondropfn, "updatelight")
			if updatelight_old then
				fadeout = UpvalueHacker.GetUpvalue(updatelight_old, "fadeout") or fadeout
				UpvalueHacker.SetUpvalue(inst.components.inventoryitem.ondropfn, updatelight, "updatelight")

				needtoupvaluehack = fadeout == nil
			end
		end
	end
end)
