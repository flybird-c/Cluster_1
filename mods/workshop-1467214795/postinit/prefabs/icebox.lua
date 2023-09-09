local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function onStartFlooded(inst)
	inst:RemoveTag("fridge")
end

local function onStopFlooded(inst)
	inst:AddTag("fridge")
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("icebox", function(inst)

	inst:AddComponent("floodable")

	if TheWorld.ismastersim then
		inst.components.floodable:SetFX("shock_machines_fx",5)
		inst.components.floodable.onStartFlooded = onStartFlooded
		inst.components.floodable.onStopFlooded = onStopFlooded
	end
end)
