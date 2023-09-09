local assets =
{
  Asset("ANIM", "anim/poison_hole.zip"),
}

local prefabs = 
{
  -- "collapse_small",
  -- "poisonbubble_short",
  "venomgland",
  "spoiled_food"
}

local function fartover(inst)
  -- print('fartover')
  if not inst.SoundEmitter:PlayingSound("poisonswamp_lp") then
    inst.SoundEmitter:PlaySound("ia/common/poisonswamp_lp", "poisonswamp_lp")
  end

  inst.AnimState:PlayAnimation("boil_start", false)
  inst.AnimState:PushAnimation("boil_loop", true)
  inst.farting = false
end

local function fart(inst, victim)
  if not inst.farting then
    inst.farting = true


    inst.AnimState:PlayAnimation("pop_pre", false)
    inst.AnimState:PushAnimation("pop", false)

    inst:DoTaskInTime(15*FRAMES, function (inst)
        inst.SoundEmitter:KillSound("poisonswamp_lp")
      end)

    inst:DoTaskInTime(20*FRAMES, function()
        inst.SoundEmitter:PlaySound("ia/common/poisonswamp_attack")
        if victim and victim:IsValid() then 
          if inst:GetDistanceSqToInst(victim) <= inst.components.areapoisoner.poisonrange*inst.components.areapoisoner.poisonrange then
            if victim.components.poisonable then
              victim.components.poisonable:Poison(true)
            end
          end
        end 
      end)


    inst:ListenForEvent("animqueueover", fartover)
  end
end

local function steam(inst)
  -- local prefab = SpawnPrefab("poisonbubble_short")
  -- prefab.Transform:SetPosition(inst:GetPosition():Get())
  if not inst.farting then
    inst.farting = true
    inst.AnimState:PlayAnimation("pop_pre", false)
    inst.AnimState:PushAnimation("pop", false)
  end
end

local function dig_up(inst, chopper)
  chopper.SoundEmitter:PlaySound("ia/common/poisonswamp_hole_dig")
  if inst.steamtask then
    inst.steamtask:Cancel()
    inst.steamtask = nil
  end
  inst.components.lootdropper:DropLoot()
  inst:Remove()
end

local function OnWake(inst)
  if inst.steamtask then
    inst.steamtask:Cancel()
    inst.steamtask = nil
  end

  inst.SoundEmitter:PlaySound("ia/common/poisonswamp_lp", "poisonswamp_lp")

  inst.steamtask = inst:DoPeriodicTask(3+(math.random()*2), fart)
end

local function OnSleep(inst)
  if inst.steamtask then
    inst.steamtask:Cancel()
    inst.steamtask = nil
  end

  inst.SoundEmitter:KillSound("poisonswamp_lp")

end

local function OnPoisonAttackFn(inst, victim)
  fart(inst, victim)
end


local function fn()
  local inst = CreateEntity()
  local trans = inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddSoundEmitter()
  inst.entity:AddNetwork()

  inst.AnimState:SetBank("poison_hole")
  inst.AnimState:SetBuild("poison_hole")
  inst.AnimState:PlayAnimation("boil_loop", true)
  inst.AnimState:SetLayer( LAYER_BACKGROUND )
  inst.AnimState:SetSortOrder( -3 )

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  MakeAreaPoisoner(inst, 3)
  inst.components.areapoisoner:SetOnPoisonAttackFn(OnPoisonAttackFn)
  inst.components.areapoisoner:StartSpreading()

  -- inst.steamtask = inst:DoPeriodicTask(3+(math.random()*2), fart)

  inst:AddComponent("lootdropper")
  inst.components.lootdropper:AddRandomLoot("venomgland" , 1)
  inst.components.lootdropper:AddRandomLoot("spoiled_food" , 1)
  inst.components.lootdropper.numrandomloot = 1
  --inst.components.lootdropper:AddChanceLoot("venomgland" , 0.5)
  inst:AddComponent("workable")
  inst.components.workable:SetWorkAction(ACTIONS.DIG)
  inst.components.workable:SetOnFinishCallback(dig_up)
  inst.components.workable:SetWorkLeft(1)

  inst.OnEntityWake = OnWake
  inst.OnEntitySleep = OnSleep

  inst:AddComponent("inspectable")

  inst:AddComponent("hauntable")
  inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)  
  
  return inst
end

return Prefab( "poisonhole", fn, assets, prefabs ) 
