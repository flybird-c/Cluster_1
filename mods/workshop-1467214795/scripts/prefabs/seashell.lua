local assets =
{
  Asset("ANIM", "anim/seashell.zip"),
}

local seashellloot = { "slurtle_shellpieces" }

local function onfinishwork(inst, worker)
    inst.components.lootdropper:DropLoot()
    if worker.SoundEmitter then
        worker.SoundEmitter:PlaySound("dontstarve/common/destroy_pot")
    end
    inst.components.stackable:Get(1):Remove()
end

local function stack_size_changed(inst, data)
  if data ~= nil and data.stacksize ~= nil and inst.components.workable ~= nil then
      inst.components.workable:SetWorkLeft(1)
  end
end

local function fn(Sim)
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddSoundEmitter()
  inst.entity:AddNetwork()

  MakeInventoryPhysics(inst)

  inst.AnimState:SetBank("seashell")
  inst.AnimState:SetBuild("seashell")
  inst.AnimState:PlayAnimation("idle")

  inst:AddTag("molebait")

    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle")

    inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

    inst:AddComponent("inventoryitem")

  inst:AddComponent("stackable")
  inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

  inst:AddComponent("tradable")

  inst:AddComponent("lootdropper")
  inst.components.lootdropper:SetLoot(seashellloot)

  inst:AddComponent("workable")
  inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
  inst.components.workable:SetWorkLeft(1) 
  inst.components.workable:SetOnFinishCallback(onfinishwork)
  inst.components.workable.savestate = false
  
  inst:AddComponent("inspectable")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ELEMENTAL
    inst.components.edible.healthvalue = 1

    inst:AddComponent("bait")

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.SHELL
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_SHELL_HEALTH

    -- The amount of work needs to be updated whenever the size of the stack changes
    inst:ListenForEvent("stacksizechange", stack_size_changed)

    MakeHauntableLaunch(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)

    return inst
end

return Prefab("seashell", fn, assets)
