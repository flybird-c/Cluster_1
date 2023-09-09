local assets=
{
  Asset("ANIM", "anim/snakeoil.zip"),
}

local function fn()
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddSoundEmitter()
  inst.entity:AddNetwork()

  MakeInventoryPhysics(inst)

  inst.AnimState:SetBank("snakeoil")
  inst.AnimState:SetBuild("snakeoil")
  inst.AnimState:PlayAnimation("idle")
  
  -- for all-time quaffing
  inst:AddTag("poison_vaccine")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.HEAVY, TUNING.WINDBLOWN_SCALE_MAX.HEAVY)

  inst:AddComponent("inspectable")

  inst:AddComponent("inventoryitem")

  inst:AddComponent("fuel")
  inst.components.fuel.fuelvalue = 0

  inst:AddComponent("poisonhealer")
  inst.components.poisonhealer.enabled = false

  MakeHauntableLaunch(inst)

  return inst
end

return Prefab( "snakeoil", fn, assets)