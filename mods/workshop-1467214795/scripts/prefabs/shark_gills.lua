local assets=
{
  Asset("ANIM", "anim/shark_gills.zip"),
}

local function fn(Sim)
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddNetwork()

  inst.AnimState:SetBank("shark_gills")
  inst.AnimState:SetBuild("shark_gills")
  inst.AnimState:PlayAnimation("idle")
  MakeInventoryPhysics(inst)

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  inst:AddComponent("inspectable")

  MakeHauntableLaunch(inst)

  inst:AddComponent("inventoryitem")

  inst:AddComponent("appeasement")
  inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_LARGE

  inst:AddComponent("stackable")
  inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

  return inst
end

return Prefab( "shark_gills", fn, assets) 
