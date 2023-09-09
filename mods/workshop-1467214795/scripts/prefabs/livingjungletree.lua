local assets =
{
  Asset("ANIM", "anim/living_jungle_tree.zip"),
}

local prefabs =
{
  "livinglog",
}

local function chop_down_burnt_tree(inst, chopper)
  inst:RemoveComponent("workable")
  inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")          
  if not (chopper ~= nil and chopper:HasTag("playerghost")) then
    inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
  end      
  inst.AnimState:PlayAnimation("chop_burnt_tall")
  RemovePhysicsColliders(inst)
  inst:ListenForEvent("animover", function() inst:Remove() end)
  inst.components.lootdropper:SpawnLootPrefab("charcoal")
  inst.components.lootdropper:DropLoot()
end

local function Extinguish(inst)
	if inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst:RemoveComponent("burnable")
	inst:RemoveComponent("propagator")
	inst:RemoveComponent("hauntable")
	MakeHauntableWork(inst)

	inst.components.lootdropper:SetLoot({})

	if inst.components.workable then
		inst.components.workable:SetWorkLeft(1)
		inst.components.workable:SetOnWorkCallback(nil)
		inst.components.workable:SetOnFinishCallback(chop_down_burnt_tree)
	end
end

local function OnBurnt(inst)
	inst:DoTaskInTime(.5, Extinguish)

  inst.AnimState:PlayAnimation("burnt_tall", true)
  inst.MiniMapEntity:SetIcon("livingjungletree_burnt.tex")

  inst.SoundEmitter:PlaySound("ia/common/living_jungle_tree/burn")

  inst.AnimState:SetRayTestOnBB(true);
  inst:AddTag("burnt")
end

local function ondug(inst)
	inst.components.lootdropper:SpawnLootPrefab("livinglog")
	inst:Remove()
end

local function makestump(inst, instant)
  inst:RemoveComponent("workable")
  inst:RemoveComponent("hauntable")
  MakeHauntableWork(inst)
  RemovePhysicsColliders(inst)
  if instant then
    inst.AnimState:PlayAnimation("stump")
  else
    inst.AnimState:PushAnimation("stump")	
  end
  inst:AddComponent("workable")
  inst.components.workable:SetWorkAction(ACTIONS.DIG)
  inst.components.workable:SetOnFinishCallback(ondug)
  inst.components.workable:SetWorkLeft(1)    
  inst:AddTag("stump")

  inst.MiniMapEntity:SetIcon("livingjungletree_stump.tex")
end

local function onworked(inst, chopper, workleft)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound(
            chopper ~= nil and chopper:HasTag("beaver") and
            "dontstarve/characters/woodie/beaver_chop_tree" or
            "dontstarve/wilson/use_axe_tree"
        )
    end
	inst.SoundEmitter:PlaySound("ia/common/living_jungle_tree/hit")
	inst.AnimState:PlayAnimation("chop")
	inst.AnimState:PushAnimation("idle", true)
end

local function ShakeCamera(inst)
	ShakeAllCameras(CAMERASHAKE.FULL, .25, .03, 0.5, inst, 6)
end

local function onworkfinish(inst, chopper)
  inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")
  local pt = Vector3(inst.Transform:GetWorldPosition())
  local hispos = Vector3(chopper.Transform:GetWorldPosition())
  local he_right = (hispos - pt):Dot(TheCamera:GetRightVec()) > 0

  inst.SoundEmitter:PlaySound("ia/common/living_jungle_tree/death")

  if he_right then
    inst.AnimState:PlayAnimation("fallleft")
    inst.components.lootdropper:DropLoot(pt - TheCamera:GetRightVec())
  else
    inst.AnimState:PlayAnimation("fallright")
    inst.components.lootdropper:DropLoot(pt + TheCamera:GetRightVec())
  end

	inst:DoTaskInTime(.4, ShakeCamera)

  makestump(inst)
end

local function onsave(inst, data)
  if inst:HasTag("stump") then
    data.stump = true
  end

  if inst:HasTag("burnt") or inst:HasTag("fire") then
    data.burnt = true
  end
end

local function onload(inst, data)
  if data and data.stump then
    makestump(inst, true)
  end

  if data and data.burnt then
    OnBurnt(inst)
  end
end

local function fn()
  local inst = CreateEntity()
  local trans = inst.entity:AddTransform()
  inst.entity:AddAnimState()        
  local sound = inst.entity:AddSoundEmitter()
  inst.entity:AddNetwork()

  local minimap = inst.entity:AddMiniMapEntity()
  minimap:SetIcon("livingjungletree.tex")

  inst:AddTag("tree")
	inst:AddTag("plant")
  inst:AddTag("workable")

  MakeObstaclePhysics(inst, .66)

  inst.AnimState:SetBank("living_jungle_tree")
  inst.AnimState:SetBuild("living_jungle_tree")
  inst.AnimState:PlayAnimation("idle", true)
  
  MakeSnowCoveredPristine(inst)
  
  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  inst:AddComponent("inspectable")

  inst:AddComponent("lootdropper")
  inst.components.lootdropper:SetLoot({"livinglog", "livinglog"})
  if TheNet:IsOnlineMode() then
    inst.components.lootdropper:AddChanceLoot("reskin_tool", 0.25)
end

  inst:AddComponent("workable")
  inst.components.workable:SetWorkAction(ACTIONS.CHOP)
  inst.components.workable:SetWorkLeft(TUNING.LIVINGJUNGLETREE_WORK)
  inst.components.workable:SetOnWorkCallback(onworked)
  inst.components.workable:SetOnFinishCallback(onworkfinish)

  MakeLargeBurnable(inst)
  inst.components.burnable:SetFXLevel(5)
  inst.components.burnable:SetOnBurntFn(OnBurnt)
  MakeLargePropagator(inst)
  MakeHauntableWorkAndIgnite(inst)

  MakeSnowCovered(inst, .01)

  inst.OnSave = onsave
  inst.OnLoad = onload

  return inst
end

return Prefab("livingjungletree", fn, assets, prefabs)
