local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function onStartFlooded(inst)
	if inst.components.container then
		inst.components.container.canbeopened = false
		inst.components.container:Close()
	end
	if inst.components.stewer and inst.components.stewer:IsCooking() then
		inst.components.stewer.product = "wetgoop"
	end
end

local function onStopFlooded(inst)
	if inst.components.container then
		inst.components.container.canbeopened = true 
	end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("cookpot", function(inst)

	inst:AddComponent("floodable")

	if TheWorld.ismastersim then
		inst.components.floodable:SetFX("shock_machines_fx",5)
		inst.components.floodable.onStartFlooded = onStartFlooded
		inst.components.floodable.onStopFlooded = onStopFlooded
	end
end)
