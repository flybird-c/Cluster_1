local assets =
{
	Asset("ANIM", "anim/doydoy_nest.zip"),
}

local prefabs =
{
	"doydoyegg",
	"doydoybaby",
}

local function TrackInSpawner(inst)
	if TheWorld.components.doydoyspawner then
		TheWorld.components.doydoyspawner:StartTracking(inst)
	end
end

local function StopTrackingInSpawner(inst)
	if TheWorld.components.doydoyspawner then
		TheWorld.components.doydoyspawner:StopTracking(inst)
	end
end

local function SpawnChild(inst)
    local child = SpawnAt("doydoybaby", inst)
	child.sg:GoToState("hatch")
	if inst.components.pickable then
		inst.components.pickable:MakeEmpty()
	end
	inst:Remove()
    return child
end

local function ScheduleSpawn(inst, dt)
	if inst.hatchtask then inst.hatchtask:Cancel() end

	dt = dt or TUNING.DOYDOY_EGG_HATCH_TIMER + math.random()*TUNING.DOYDOY_EGG_HATCH_VARIANCE
	inst.hatchtime = GetTime() + dt
	inst.hatchtask = inst:DoTaskInTime(dt, function()
		if inst:IsAsleep() then
			ScheduleSpawn(inst, TUNING.SEG_TIME)
		else
			SpawnChild(inst)
		end
	end)
end

local function onmakeempty(inst)
	inst.AnimState:PlayAnimation("idle_nest_empty")
	-- inst.components.childspawner.regening = false
	-- inst:RemoveTag('fullnest')
	inst.components.trader.enabled = true
	-- inst.components.childspawner:StopSpawning()
	if inst.hatchtask then
		inst.hatchtask:Cancel()
		inst.hatchtime = nil
	end
	 -- The doydoyspawner checks if this nest is registered before doing any math,
	 -- so putting StopTrackingInSpawner here is safe. -M
	StopTrackingInSpawner(inst)
end

local function onregrow(inst)
	inst.AnimState:PlayAnimation("idle_nest")
	-- inst.components.childspawner.regening = true
	-- inst:AddTag('fullnest')
	inst.components.trader.enabled = false
	-- inst.components.childspawner:StartSpawning(TUNING.DOYDOY_EGG_HATCH_TIMER)
	ScheduleSpawn(inst)
	TrackInSpawner(inst)
end

local function onhammered(inst)
	if inst.components.burnable and inst.components.burnable:IsBurning() then
		inst.components.burnable:Extinguish()
	end
	if inst.components.pickable:CanBePicked() then
        inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product)
    end
	inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("straw")
	inst:Remove()
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		if inst.components.pickable:CanBePicked() then
			inst.AnimState:PlayAnimation("hit_nest")
			inst.AnimState:PushAnimation("idle_nest")
		else
			inst.AnimState:PlayAnimation("hit_nest_empty")
			inst.AnimState:PushAnimation("idle_nest_empty")
		end
	end
end

local function itemtest(inst, item)
	return not inst.components.pickable:CanBePicked() and item.prefab == "doydoyegg"
end

local function itemget(inst, giver, item)
	inst.components.pickable:Regen()
	item:Remove()
end

local function OnSave(inst, data)
	if inst.hatchtask and inst.hatchtime then
		data.timetohatch = inst.hatchtime - GetTime()
	end
end

local function OnLoad(inst, data)
	if data.timetohatch and inst.components.pickable:CanBePicked() then
		ScheduleSpawn(inst, data.timetohatch)
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	inst.MiniMapEntity:SetIcon("doydoynest.tex")

	inst.AnimState:SetBuild("doydoy_nest")
	inst.AnimState:SetBank("doydoy_nest")
	inst.AnimState:PlayAnimation("idle_nest", false)

	MakeObstaclePhysics(inst, 0.25)

	inst:AddTag("doydoy")
	inst:AddTag("doydoynest")
	inst:AddTag("donotautopick")
	-- inst:AddTag('fullnest')

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("pickable")
	--inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
	inst.components.pickable:SetUp("doydoyegg", nil)
	inst.components.pickable:SetOnPickedFn(onmakeempty)
	inst.components.pickable:SetOnRegenFn(onregrow)
	inst.components.pickable:SetMakeEmptyFn(onmakeempty)

	MakeMediumBurnable(inst)
	MakeSmallPropagator(inst)

	-------------------

	-- why do we even use childspawner when we could just make a task? -M
	-- inst:AddComponent("childspawner")
	-- inst.components.childspawner.childname = "doydoybaby"
	-- inst.components.childspawner.spawnoffscreen = false
	-- inst.components.childspawner:SetRegenPeriod(65000)
	-- inst.components.childspawner:StopRegen()
	-- inst.components.childspawner:SetSpawnPeriod(0)
	-- inst.components.childspawner:SetSpawnedFn(onvacate)
	-- inst.components.childspawner:SetMaxChildren(1)
	-- inst.components.childspawner:StartSpawning(TUNING.DOYDOY_EGG_HATCH_TIMER)
	-- -- inst.components.childspawner.nooffset = true
	-- inst.components.childspawner.spawnradius = 0

	ScheduleSpawn(inst)
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

	inst:AddComponent("inspectable")

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"cutgrass", "twigs", "twigs", "doydoyfeather"})

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(3)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	TrackInSpawner(inst)
	inst:ListenForEvent("onremove", StopTrackingInSpawner)

	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(itemtest)
	inst.components.trader.onaccept = itemget
	inst.components.trader.enabled = false

	inst:ListenForEvent("onbuilt", function (inst)
		inst.components.pickable:MakeEmpty()
	end)

	return inst
end

return Prefab("doydoynest", fn, assets, prefabs),
	MakePlacer("doydoynest_placer", "doydoy_nest", "doydoy_nest", "idle_nest_empty")
