local assets =
{
    Asset("ANIM", "anim/corallarve.zip"),
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("corallarve")
    inst.AnimState:SetBuild("corallarve")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("molebait")

    -- waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")

    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("waterproofer")
    inst.components.waterproofer.effectiveness = 0

    inst:AddComponent("bait")

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = "stone"
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_CUTSTONE_HEALTH

    MakeHauntableLaunch(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.HEAVY, TUNING.WINDBLOWN_SCALE_MAX.HEAVY)

    return inst
end

return Prefab("corallarve", fn, assets)
