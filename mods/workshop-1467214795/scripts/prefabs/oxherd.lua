local assets =
{
  --Asset("ANIM", "anim/arrow_indicator.zip"),
}

local prefabs = 
{
  "babyox",
  "ox",
}

local function InMood(inst)
  if inst.components.periodicspawner then
    inst.components.periodicspawner:Start()
  end
  if inst.components.herd then
    for k,v in pairs(inst.components.herd.members) do
      k:PushEvent("entermood")
    end
  end
end

local function LeaveMood(inst)
  if inst.components.periodicspawner then
    inst.components.periodicspawner:Stop()
  end
  if inst.components.herd then
    for k,v in pairs(inst.components.herd.members) do
      k:PushEvent("leavemood")
    end
  end
  inst.components.mood:CheckForMoodChange()
end

local function AddMember(inst, member)
	if inst.components.mood then
		member:PushEvent(inst.components.mood:IsInMood() and "entermood" or "leavemood")
	end
end

local function CanSpawn(inst)
  return inst.components.herd and not inst.components.herd:IsFull()
end

local function OnSpawned(inst, newent)
  if inst.components.herd then
    inst.components.herd:AddMember(newent)
  end
end

local function OnEmpty(inst)
  inst:Remove()
end

-- local function OnFull(inst)
  --TODO: mark some ox for death
-- end

local function OnInit(inst)
    inst.components.mood:ValidateMood()
end

local function fn(Sim)
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
    --[[Non-networked entity]]

	-- inst.entity:AddAnimState()
  --inst.AnimState:SetBank("arrow_indicator")
  --inst.AnimState:SetBuild("arrow_indicator")
  --inst.AnimState:PlayAnimation("arrow_loop", true)

	inst:AddTag("herd")
	--V2C: Don't use CLASSIFIED because herds use FindEntities on "herd" tag
	inst:AddTag("NOBLOCK")
	inst:AddTag("NOCLICK")

	inst:AddComponent("herd")
	if inst:HasTag("migratory") then
		inst.components.herd:SetMemberTag("ox_migratory") 
	else
		inst.components.herd:SetMemberTag("ox")
	end
	inst.components.herd:SetGatherRange(TUNING.OXHERD_RANGE)
  inst.components.herd:SetUpdateRange(20)
  inst.components.herd:SetOnEmptyFn(OnEmpty)
  -- inst.components.herd:SetOnFullFn(OnFull)
  inst.components.herd:SetAddMemberFn(AddMember)

  inst:AddComponent("mood")
  inst.components.mood:SetMoodTimeInDays(TUNING.OX_MATING_SEASON_LENGTH, TUNING.OX_MATING_SEASON_WAIT)
  inst.components.mood:SetMoodSeason(SEASONS.AUTUMN) --SEASONS.MILD
  inst.components.mood:SetInMoodFn(InMood)
  inst.components.mood:SetLeaveMoodFn(LeaveMood)
  inst.components.mood:CheckForMoodChange()
  inst:DoTaskInTime(0, OnInit)

  inst:AddComponent("periodicspawner")
  inst.components.periodicspawner:SetNotFloatsam(true)
  inst.components.periodicspawner:SetRandomTimes(TUNING.OX_MATING_SEASON_BABYDELAY, TUNING.OX_MATING_SEASON_BABYDELAY_VARIANCE)
  inst.components.periodicspawner:SetPrefab("babyox")
  inst.components.periodicspawner:SetOnSpawnFn(OnSpawned)
  inst.components.periodicspawner:SetSpawnTestFn(CanSpawn)
  inst.components.periodicspawner:SetDensityInRange(20, 6)
  inst.components.periodicspawner:SetOnlySpawnOffscreen(true)

  return inst
end

return Prefab( "oxherd", fn, assets, prefabs) 
