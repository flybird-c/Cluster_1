local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function CanDismantle(inst)
	return not inst:HasTag("flooded")
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("portableblender", function(inst)
	inst:AddComponent("floodable")

	inst.candismantle = CanDismantle

	if TheWorld.ismastersim then
		inst.components.floodable:SetFX("shock_machines_fx",5)
	end
end)
