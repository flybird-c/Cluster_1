local assets=
{
  Asset("ANIM", "anim/limpets.zip"),
}


local prefabs =
{
  "limpets_cooked",
}    

local function pristinefn()
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.AnimState:SetBank("limpets")
  inst.AnimState:SetBuild("limpets")
  inst.entity:AddNetwork()

  MakeInventoryPhysics(inst)

  inst:AddTag("smallmeat")
  inst:AddTag("packimfood")
  inst:AddComponent("edible")
  inst.components.edible.foodtype = "MEAT"
  inst.components.edible.forcequickeat = true

    return inst
end

local function masterfn(inst)
  MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)

  inst:AddComponent("appeasement")
  inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_TINY

  inst:AddComponent("perishable")
  inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
  inst.components.perishable:StartPerishing()
  inst.components.perishable.onperishreplacement = "spoiled_food"

  inst:AddComponent("stackable")
  inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

  inst:AddComponent("bait")

  inst:AddComponent("inspectable")

  inst:AddComponent("inventoryitem")

  MakeHauntableLaunchAndPerish(inst)

  inst:AddComponent("tradable")
  inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
end

local function defaultfn()
  local inst = pristinefn()
  inst.AnimState:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

	inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

	masterfn(inst)

  inst.components.edible.healthvalue = 0
  inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
  inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
  inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL


  inst:AddComponent("cookable")
  inst.components.cookable.product = "limpets_cooked"
  --inst:AddComponent("dryable")
  --inst.components.dryable:SetProduct("smallmeat_dried")
  --inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
  return inst
end

local function cookedfn()
  local inst = pristinefn()
  inst.AnimState:PlayAnimation("cooked")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("cooked_water", "cooked")

	inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

	masterfn(inst)

  inst.components.inventoryitem.imagename = "limpets_cooked"
  
  inst.components.edible.foodstate = "COOKED"
  inst.components.edible.healthvalue = TUNING.HEALING_TINY
  inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
  inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

  return inst
end

return Prefab("limpets", defaultfn, assets, prefabs),
Prefab("limpets_cooked", cookedfn, assets) 
