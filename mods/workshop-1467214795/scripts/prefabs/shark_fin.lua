local assets=
{
  Asset("ANIM", "anim/shark_fin.zip"),
}

local function fn(Sim)
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddNetwork()

  inst.AnimState:SetBank("shark_fin")
  inst.AnimState:SetBuild("shark_fin")
  inst.AnimState:PlayAnimation("idle")
  MakeInventoryPhysics(inst)

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

	inst:AddTag("spawnnosharx")

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  inst:AddComponent("inspectable")

  MakeHauntableLaunchAndPerish(inst)

  inst:AddComponent("inventoryitem")

  inst:AddComponent("edible")
  inst.components.edible.foodtype = "MEAT"
  inst.components.edible.healthvalue = TUNING.HEALING_MED
  inst.components.edible.hungervalue = TUNING.CALORIES_MED
  inst.components.edible.sanityvalue = -TUNING.SANITY_MED

  inst:AddComponent("perishable")
  inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
  inst.components.perishable:StartPerishing()
  inst.components.perishable.onperishreplacement = "spoiled_food"

  inst:AddComponent("appeasement")
  inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL

  inst:AddComponent("stackable")
  inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM



  return inst
end

return Prefab( "shark_fin", fn, assets) 
