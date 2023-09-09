local function onupdatefueled(inst)
	if inst.components.burnable and inst.components.fueled then
		inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
	end
end

local function onfuelchange(section, oldsection, inst)
	if section <= 0 then
		inst.components.burnable:Extinguish() 
	else
		if not inst.components.burnable:IsBurning() then
			inst.components.burnable:Ignite()
		end
		inst.components.burnable:SetFXLevel(section, inst.components.fueled:GetSectionPercent())
	end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddLight()
	inst.entity:AddNetwork()

	inst:AddTag("fire")
	inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("propagator")

	inst:AddComponent("burnable")
	inst.components.burnable:AddBurnFX("campfirefire", Vector3(0,0,0))
	inst:ListenForEvent("onextinguish", inst.Remove)

	inst:AddComponent("fueled")
	inst.components.fueled.maxfuel = TUNING.DRAGOONFIRE_FUEL_MAX
	inst.components.fueled.accepting = false

	inst.components.fueled:SetSections(4)
	inst.components.fueled:SetUpdateFn(onupdatefueled)
	inst.components.fueled:SetSectionCallback(onfuelchange)
	inst.components.fueled:InitializeFuelLevel(TUNING.DRAGOONFIRE_FUEL)
	  
	inst.persists = false

	return inst
end

return Prefab("dragoonfire", fn)
