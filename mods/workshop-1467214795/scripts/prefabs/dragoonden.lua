require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/dragoon_den.zip"),
}

local prefabs =
{
    "dragoon",
}

local function ongohome(inst, child)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle")
end

local function StartSpawningFn(inst)
    inst.components.childspawner:StartSpawning()
end

local function StopSpawningFn(inst)
    inst.components.childspawner:StopSpawning()
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_stone")
    inst:Remove()
end

local function onhit(inst, worker)
	local do_work = worker:HasTag("toughworker") or worker:HasTag("explosive")
	if not do_work then
		local tool = worker.components.inventory ~= nil and worker.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
		do_work = tool ~= nil and tool.components.tool ~= nil and tool.components.tool:CanDoToughWork()
	end
	if do_work then
        if inst.components.childspawner ~= nil then
            inst.components.childspawner:ReleaseAllChildren()
        end
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle")
	end
end

local function ShouldRecoil(inst, worker, tool)
	if not (worker ~= nil and (worker:HasTag("toughworker") or worker:HasTag("explosive") or
        worker:HasTag("epic") or worker:HasTag("shadowrift_portal") or worker.prefab == "rift_terraformer" or worker.prefab == "tornado")) and
		not (tool ~= nil and tool.components.tool ~= nil and tool.components.tool:CanDoToughWork()) then
		return true
	end
	return false
end

local function spawncheckday(inst)
    inst.inittask = nil
    inst:WatchWorldState("isdusk", StopSpawningFn)
    inst:WatchWorldState("isday", StartSpawningFn)
    if inst.components.childspawner and inst.components.childspawner.childreninside > 0 then
        if TheWorld.state.isday then
            StartSpawningFn(inst)
        else
            StopSpawningFn(inst)
        end
    end
end

local function oninit(inst)
    inst.inittask = inst:DoTaskInTime(math.random(), spawncheckday)
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")
    inst.SoundEmitter:PlaySound("ia/common/dragoon_den_place")
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.DRAGOON_SPAWN_PERIOD, TUNING.DRAGOON_REGEN_PERIOD)
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1.5)

    inst.MiniMapEntity:SetIcon("dragoonden.tex")

    inst.AnimState:SetBank("dragoon_den")
    inst.AnimState:SetBuild("dragoon_den")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("structure")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
    inst.components.workable:SetShouldRecoilFn(ShouldRecoil)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("childspawner")
    inst.components.childspawner:SetRegenPeriod(TUNING.DRAGOON_REGEN_PERIOD)
    inst.components.childspawner:SetSpawnPeriod(TUNING.DRAGOON_SPAWN_PERIOD)
    if TUNING.DRAGOON_CHILDREN.max == 0 then
        inst.components.childspawner:SetMaxChildren(0)
    else
        inst.components.childspawner:SetMaxChildren(math.random(TUNING.DRAGOON_CHILDREN.min, TUNING.DRAGOON_CHILDREN.max))
    end

    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.DRAGOON_SPAWN_PERIOD, TUNING.DRAGOON_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.DRAGOON_REGEN_PERIOD, TUNING.DRAGOON_ENABLED)
    if not TUNING.DRAGOON_ENABLED then
        inst.components.childspawner.childreninside = 0
    end
    inst.components.childspawner:StartRegen()
    inst.components.childspawner.childname = "dragoon"
    -- inst.components.childspawner:StartSpawning()
    inst.components.childspawner.ongohome = ongohome
    inst.components.childspawner.allowboats = true

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("lootdropper")

    inst:ListenForEvent("onbuilt", onbuilt)
    inst.inittask = inst:DoTaskInTime(0, oninit)

    inst.OnPreLoad = OnPreLoad

    return inst
end

return Prefab("dragoonden", fn, assets, prefabs),
    MakePlacer("dragoonden_placer", "dragoon_den", "dragoon_den", "idle")
