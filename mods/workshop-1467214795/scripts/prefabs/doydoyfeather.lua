local assets = {
	Asset("ANIM", "anim/feather_doydoy.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	
	inst.AnimState:SetBank("feather_doydoy")
	inst.AnimState:SetBuild("feather_doydoy")
	inst.AnimState:PlayAnimation("idle")

	inst.pickupsound = "cloth"
	
	MakeInventoryPhysics(inst)

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")
	
	inst:AddTag("cattoy")
    inst:AddTag("birdfeather")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

	inst:AddComponent("appeasement")
	inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_LARGE

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.TINY_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunch(inst)

	inst:AddComponent("inventoryitem")

	MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)

	return inst
end

return Prefab("doydoyfeather", fn, assets)
