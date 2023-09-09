local assets =
{
  -- Asset("ANIM", "anim/blow_dart_sw.zip"),
  Asset("ANIM", "anim/blow_dart_ia.zip"),
  Asset("ANIM", "anim/swap_blowdart_flup.zip"),
}

local prefabs =
{
  "impact",
}

local function onequip(inst, owner)
  owner.AnimState:OverrideSymbol("swap_object", "swap_blowdart", "swap_blowdart")
  owner.AnimState:Show("ARM_carry")
  owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
  owner.AnimState:ClearOverrideSymbol("swap_object")
  owner.AnimState:Hide("ARM_carry")
  owner.AnimState:Show("ARM_normal")
end

local function onhit(inst, attacker, target)
    local impactfx = SpawnPrefab("impact")
    if impactfx ~= nil then
        local follower = impactfx.entity:AddFollower()
        follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
        if attacker ~= nil then
        impactfx:FacePoint(attacker.Transform:GetWorldPosition())
        end
    end
    inst:Remove()
end

local function onthrown(inst, data)
  inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
end

local function pristinefn(anim, tags, removephysicscolliders)
  local inst = CreateEntity()

  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddNetwork()

  MakeInventoryPhysics(inst)

  inst.AnimState:SetBank("blow_dart_ia")
  inst.AnimState:SetBuild("blow_dart_ia")

  if anim ~= nil then
    inst.AnimState:PlayAnimation(anim)
  end

  inst:AddTag("blowdart")
  inst:AddTag("sharp")
  --projectile (from projectile component) added to pristine state for optimization
  inst:AddTag("projectile")
  -- weapon (from weapon component) added to pristine state for optimization
  inst:AddTag("weapon")

  if tags ~= nil then
    for i, v in ipairs(tags) do
      inst:AddTag(v)
    end
  end

  if removephysicscolliders then
    RemovePhysicsColliders(inst)
  end

    return inst
end

local function masterfn(inst)
  inst:AddComponent("weapon")
  inst.components.weapon:SetDamage(0)
  inst.components.weapon:SetRange(8, 10)

  inst:AddComponent("projectile")
  inst.components.projectile:SetSpeed(60)
  inst.components.projectile:SetOnHitFn(onhit)
  inst:ListenForEvent("onthrown", onthrown)
  -------

  inst:AddComponent("inspectable")

  inst:AddComponent("inventoryitem")
  
  inst:AddComponent("stackable")

  inst:AddComponent("equippable")
  inst.components.equippable:SetOnEquip(onequip)
  inst.components.equippable:SetOnUnequip(onunequip)
  inst.components.equippable.equipstack = true

  MakeHauntableLaunch(inst)
end

local function poisonthrown(inst)
  inst.AnimState:PlayAnimation("dart_poison")
end

local function poisonattack(inst, attacker, target)
  target.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_impact_sleep")
  if target.components.poisonable then
    target.components.poisonable:Poison()
  end
  if target.components.combat then
    target.components.combat:SuggestTarget(attacker)
  end
  target:PushEvent("attacked", {attacker = attacker, damage = 0, weapon = inst})
end

local function poison()
  local inst = pristinefn("idle_poison", {"poisondart"})

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_poison_water", "idle_poison")

	inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

	masterfn(inst)
  
  inst.components.weapon:SetOnAttack(poisonattack)
  inst.components.projectile:SetOnThrownFn(poisonthrown)

  return inst
end

local function flupequip(inst, owner)
  owner.AnimState:OverrideSymbol("swap_object", "swap_blowdart_flup", "swap_blowdart_flup")
  owner.AnimState:Show("ARM_carry")
  owner.AnimState:Hide("ARM_normal")
end

local function flupthrown(inst)
  inst.AnimState:PlayAnimation("dart_flup")
end

local function SetStunState(target)
	if target and target:IsValid() and target.sg then -- and not target.sg:HasStateTag("busy") --He's always too "busy" to spend time with me
		target.sg:GoToState("stunned")
	end
end

local function flupattack(inst, attacker, target)
	if target and target:HasTag("bird") and target.sg and target.sg:HasState("stunned") then
		target:DoTaskInTime(.4, SetStunState)
	end
end

local function flup()
  local inst = pristinefn("idle_flup", {"flupdart"})

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_flup_water", "idle_flup")
	
	inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

	masterfn(inst)
  
  inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
  inst.components.equippable:SetOnEquip(flupequip)
  inst.components.weapon:SetDamage(TUNING.FLUP_DART_DAMAGE)
  inst.components.projectile:SetOnThrownFn(flupthrown)
	inst.components.weapon:SetOnAttack(flupattack)
 
  return inst
end

return Prefab("blowdart_poison", poison, assets, prefabs),
Prefab("blowdart_flup", flup, assets, prefabs)
