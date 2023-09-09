local assets =
{
  Asset("ANIM", "anim/bambootree.zip"),
  Asset("ANIM", "anim/bambootree_build.zip"),
}


local prefabs =
{
  "bamboo",
  "dug_bambootree",
  "hacking_bamboo_fx",
}

local function ontransplantfn(inst)
  if inst.components.hackable then
    inst.components.hackable:MakeBarren()
  end
end

local function dig_up(inst, chopper)
	if inst.components.hackable and inst.components.hackable:CanBeHacked() then
		inst.components.lootdropper:SpawnLootPrefab(inst.components.hackable.product)
	end
	if inst.components.witherable and inst.components.witherable:IsWithered() then
		inst.components.lootdropper:SpawnLootPrefab("bamboo")
	else
		inst.components.lootdropper:SpawnLootPrefab("dug_bambootree")
	end
	inst:Remove()
end

local function onregenfn(inst)
  inst.AnimState:PlayAnimation("grow")
  inst.AnimState:PushAnimation("idle", true)
  inst.Physics:SetCollides(true)
end

local function makeemptyfn(inst)
  if not POPULATING and inst.components.witherable and inst.components.witherable:IsWithered() then
    inst.AnimState:PlayAnimation("dead_to_empty")
    inst.AnimState:PushAnimation("picked")
  else
    inst.AnimState:PlayAnimation("picked")
  end
  inst.Physics:SetCollides(false)
end

local function makebarrenfn(inst)
  if inst.components.witherable and inst.components.witherable:IsWithered() then
	if POPULATING then
		inst.AnimState:PlayAnimation("idle_dead")
	else
		if not inst.components.hackable.hasbeenhacked then
			inst.AnimState:PlayAnimation("full_to_dead")
		else
			inst.AnimState:PlayAnimation("empty_to_dead")
		end
		inst.AnimState:PushAnimation("idle_dead")
	end
  else
    inst.AnimState:PlayAnimation("idle_dead")
  end
  inst.Physics:SetCollides(true)
end

local function onhackedfn(inst, hacker, hacksleft)
	local fx = SpawnPrefab("hacking_bamboo_fx")
    local x, y, z= inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x,y + math.random()*2,z)

	if(hacksleft <= 0) then

		inst.AnimState:PlayAnimation("picking")
			
		if inst.components.hackable and inst.components.hackable:IsBarren() then
			inst.AnimState:PushAnimation("idle_dead")
			inst.Physics:SetCollides(true)
		else
			inst.Physics:SetCollides(false)
			inst.SoundEmitter:PlaySound("ia/common/bamboo_drop")
			inst.AnimState:PushAnimation("picked")
		end
	else
		inst.AnimState:PlayAnimation("chop")
		inst.AnimState:PushAnimation("idle")
	end
	
	inst.SoundEmitter:PlaySound("ia/common/bamboo_hack")
end

local function inspect_bambootree(inst)
  if inst:HasTag("burnt") then
    return "BURNT"
  elseif inst:HasTag("stump") then
    return "CHOPPED"
  end
end

local function OnSave(inst, data)
  data.was_herd = inst.components.herdmember and true or nil
end

local function OnPreLoad(inst, data)
  if data and data.was_herd then
      if TheWorld.components.lunarthrall_plantspawner then
          TheWorld.components.lunarthrall_plantspawner:setHerdsOnPlantable(inst)
      end
  end    
end

local function makefn(stage)
  local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    local minimap = inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .35)

    minimap:SetIcon( "bambootree.tex" )

    inst.AnimState:SetBank("bambootree")
    inst.AnimState:SetBuild("bambootree_build")
    inst.AnimState:PlayAnimation("idle",true)
    inst.AnimState:SetTime(math.random()*2)
    local color = 0.75 + math.random() * 0.25
    inst.AnimState:SetMultColour(color, color, color, 1)

	  inst:AddTag("witherable") -- added to pristine state for optimization
    inst:AddTag("gustable")
	  inst:AddTag("plant")
    inst:AddTag("silviculture") -- for silviculture book
    inst:AddTag("lunarplant_target")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
      return inst
    end

    inst:AddComponent("hackable")
    inst.components.hackable:SetUp("bamboo", TUNING.BAMBOO_REGROW_TIME)
    inst.components.hackable.onregenfn = onregenfn
    inst.components.hackable.onhackedfn = onhackedfn
    inst.components.hackable.makeemptyfn = makeemptyfn
    inst.components.hackable.makebarrenfn = makebarrenfn
    inst.components.hackable.max_cycles = 20
    inst.components.hackable.cycles_left = 20
    inst.components.hackable.ontransplantfn = ontransplantfn
    inst.components.hackable.hacksleft = TUNING.BAMBOO_HACKS
    inst.components.hackable.maxhacks = TUNING.BAMBOO_HACKS

	  inst:AddComponent("witherable")
	
    if stage == 1 then
      inst.components.hackable:MakeBarren()
    end

    inst:AddComponent("lootdropper")
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = inspect_bambootree

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up)
    inst.components.workable:SetWorkLeft(1)

	  MakeHackableBlowInWindGust(inst, TUNING.BAMBOO_WINDBLOWN_SPEED, TUNING.BAMBOO_WINDBLOWN_FALL_CHANCE)
    MakeMediumBurnable(inst)
    MakeSmallPropagator(inst)
    MakeHauntableIgnite(inst)

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad

    return inst
  end

  return fn
end

local function bamboo(name, stage)
  return Prefab(name, makefn(stage), assets, prefabs)
end

return bamboo("bambootree", 0),
bamboo("depleted_bambootree", 1)
