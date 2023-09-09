local assets = {
  Asset("ANIM", "anim/snakeskin.zip"),
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("snakeskin")
    inst.AnimState:SetBuild("snakeskin")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)

        MakeInventoryFloatable(inst)
        inst.components.floater:UpdateAnimations("idle_water", "idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

        MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("selfstacker")

    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)

    ---------------------       

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_TINY

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("snakeskin", fn, assets) 