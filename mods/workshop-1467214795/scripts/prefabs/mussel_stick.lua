local assets =
{
  Asset("ANIM", "anim/musselfarm_stick.zip"),
}

local prefabs =
{
}

local function fn()
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddSoundEmitter()
  inst.entity:AddNetwork()

  MakeInventoryPhysics(inst)

  inst.no_wet_prefix = true

  inst.AnimState:SetBuild("musselFarm_stick")
  inst.AnimState:SetBank("musselFarm_stick")
  inst.AnimState:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end
  
  inst:AddComponent("sticker")
  inst:AddComponent("inspectable")

  inst:AddComponent("stackable")

  inst:AddComponent("inventoryitem")

  MakeHauntableLaunch(inst)
  
  return inst
end

return Prefab( "mussel_stick", fn, assets, prefabs) 

