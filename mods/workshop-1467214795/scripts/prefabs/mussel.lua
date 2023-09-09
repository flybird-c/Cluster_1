local assets=
{
  Asset("ANIM", "anim/mussel.zip"),
}

local prefabs =
{
  "mussel_cooked",
  "spoiled_food",
}


local function commonclient()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mussel")
    inst.AnimState:SetBuild("mussel")
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("packimfood")

    -- MakeInventoryFloatable(inst)

    return inst
end

local function commonmaster(inst)
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "MEAT"

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD

    inst:AddComponent("inspectable")

    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"
end

local function raw()
    local inst = commonclient()
    inst.no_wet_prefix = true
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    commonmaster(inst)

    inst.components.inventoryitem.imagename = "mussel"

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL

    inst:AddComponent("cookable")
    inst.components.cookable.product = "mussel_cooked"

    inst:AddComponent("bait")

    return inst
end

local function cooked()
    local inst = commonclient()
    inst.AnimState:PlayAnimation("cooked")

        inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    commonmaster(inst)

    inst.components.inventoryitem.imagename = "mussel_cooked"

    inst.components.edible.foodstate = "COOKED"
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    return inst
end

return Prefab( "mussel", raw, assets, prefabs),
Prefab("mussel_cooked", cooked, assets)
