local assets =
{
    Asset("ANIM", "anim/blubber.zip"),
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("blubber")
    inst.AnimState:SetBuild("blubber")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)

    inst:AddTag("fishmeat")

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

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.MEAT
    -- Does this thing just... not have any food values? -M

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    inst:AddComponent("waterproofer")
    inst.components.waterproofer.effectiveness = 0

    inst:AddComponent("tradable")
    inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL

    MakeHauntableLaunchAndPerish(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)

    return inst
end

return Prefab("blubber", fn, assets)
