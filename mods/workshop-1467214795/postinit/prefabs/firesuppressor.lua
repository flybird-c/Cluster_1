local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

-- local CanInteract_old
-- local function CanInteract(inst)
	-- return CanInteract_old(inst) and not inst:HasTag("flooded")
-- end

local function onStartFlooded(inst)
	--trick the machine into thinking it's out of juice
	local lying = not inst:HasTag("fueldepleted")
	if lying then inst:AddTag("fueldepleted") end
	
	inst.components.machine:TurnOff()
	inst:AddTag("alwayson") --seems unused, so hopefully this won't clash with anything
	
	if lying then inst:RemoveTag("fueldepleted") end
end

local function onStopFlooded(inst)
	inst:RemoveTag("alwayson")
	if inst.components.firedetector then
		inst.components.firedetector:ActivateEmergencyMode()
	end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("firesuppressor", function(inst)


inst:AddComponent("floodable")

if TheWorld.ismastersim then

	inst.components.floodable:SetFX("shock_machines_fx",5)
	inst.components.floodable.onStartFlooded = onStartFlooded
	inst.components.floodable.onStopFlooded = onStopFlooded
	
	-- CanInteract_old = inst.components.machine.caninteractfn
	-- inst.components.machine.caninteractfn = CanInteract

end


end)
