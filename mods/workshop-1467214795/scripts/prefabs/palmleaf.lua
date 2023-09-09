local assets = {
  Asset("ANIM", "anim/palmleaf.zip"),
}

local function fn()
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddNetwork()
  MakeInventoryPhysics(inst)

  inst.AnimState:SetBank("palmleaf")
  inst.AnimState:SetBuild("palmleaf")
  inst.AnimState:PlayAnimation("idle")

  inst.pickupsound = "vegetation_grassy"

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

  inst:AddTag("cattoy")

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)

  inst:AddComponent("stackable")
  inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

  inst:AddComponent("edible")
  inst.components.edible.foodtype = FOODTYPE.ROUGHAGE
  inst.components.edible.healthvalue = TUNING.HEALING_TINY
  inst.components.edible.hungervalue = TUNING.CALORIES_TINY/2

  inst:AddComponent("tradable")

  inst:AddComponent("inspectable")

  MakeHauntableLaunch(inst)

  inst:AddComponent("fuel")
  inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

  inst:AddComponent("appeasement")
  inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL

  MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
  MakeSmallPropagator(inst)

  inst:AddComponent("inventoryitem")

  return inst
end

return Prefab("palmleaf", fn, assets) 

