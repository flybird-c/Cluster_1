local assets =
{
    Asset("ANIM", "anim/limestone.zip")
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    
    inst.AnimState:SetBank("limestone")
    inst.AnimState:SetBuild("limestone")
    inst.AnimState:PlayAnimation("idle")

    inst.pickupsound = "rock"

    MakeInventoryPhysics(inst)

    inst:AddTag("molebait")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ELEMENTAL
    inst.components.edible.hungervalue = 1
    inst:AddComponent("tradable")
    inst:AddComponent("bait")

	if IA_CONFIG.limestonerepair then
		inst:AddComponent("repairer")
		inst.components.repairer.repairmaterial = MATERIALS.LIMESTONE
		inst.components.repairer.workrepairvalue = TUNING.REPAIR_LIMESTONE_WORK
		inst.components.repairer.healthrepairvalue = TUNING.REPAIR_LIMESTONE_HEALTH
	end
	
	MakeHauntableLaunch(inst)

    return inst
end

return Prefab("limestonenugget", fn, assets)