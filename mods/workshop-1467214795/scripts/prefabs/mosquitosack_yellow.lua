local assets =
{
    Asset("ANIM", "anim/bladder_yellow.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bladder")
    inst.AnimState:SetBuild("bladder_yellow")
    inst.AnimState:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndIgnite(inst)

    ---------------------       

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")

    inst:AddComponent("fillable")
    inst.components.fillable.filledprefab = "waterballoon"

    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(TUNING.HEALING_MED)

    return inst
end

return Prefab("mosquitosack_yellow", fn, assets)