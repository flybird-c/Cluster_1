require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/lobster_home.zip"),
}

local prefabs =
{
    "lobster",
}

local function startspawning(inst)
    if inst.components.spawner and not TheWorld.state.isspring then
        if not inst.components.spawner:IsSpawnPending() then
            inst.components.spawner:SpawnWithDelay(10 + math.random(15))
        end
    end
end

local function stopspawning(inst)
    if inst.components.spawner then
        inst.components.spawner:CancelSpawning()
    end
end

local function onoccupied(inst)
    if not TheWorld.state.isday and not TheWorld.state.isspring then
        startspawning(inst)
    end
end

local function SetSpringMode(inst, force)
    if not inst.spring or force then
        stopspawning(inst)
        inst.springtask = nil
        inst.spring = true
    end
end

local function SetNormalMode(inst, force)
    if inst.spring or force then
        --inst.AnimState:PlayAnimation("idle")
        if not TheWorld.state.isday and inst.components.spawner and not inst.components.spawner:IsSpawnPending() then
            startspawning(inst)
        end
        inst.normaltask = nil
        inst.spring = false
    end
end

local function OnWake(inst)
    if inst.spring and inst.components.spawner and inst.components.spawner:IsOccupied() then
        if inst.components.spawner:IsSpawnPending() then
            stopspawning(inst)
        end
        if inst.springtask then
            inst.springtask:Cancel()
            inst.springtask = nil
        end
    end
end

local function OnPreLoad(inst, data)
    WorldSettings_Spawner_PreLoad(inst, data, TUNING.LOBSTER_RESPAWN_TIME)
end

local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()


    inst.AnimState:SetBank("lobster_home")
    inst.AnimState:SetBuild("lobster_home")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(-3)

    inst.MiniMapEntity:SetIcon("lobster.tex")

    inst:AddTag("ignorewalkableplatforms")

    inst.no_wet_prefix = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("spawner")
    inst.components.spawner:SetQueueSpawning(false)
    inst.components.spawner:SetWaterSpawning(true, false)
    WorldSettings_Spawner_SpawnDelay(inst, TUNING.LOBSTER_RESPAWN_TIME, TUNING.LOBSTER_ENABLED)
    inst.components.spawner:Configure("lobster", TUNING.LOBSTER_RESPAWN_TIME)
    inst.components.spawner:SetOnOccupiedFn(onoccupied)
    inst.components.spawner:SetOnVacateFn(stopspawning)

    inst:WatchWorldState("phase", function()
        if TheWorld.state.isday then
            stopspawning(inst)
        elseif TheWorld.state.isdusk then
            startspawning(inst)
        end
    end)

    inst.spring = TheWorld.state.isspring
    if inst.spring then
        inst:DoTaskInTime(.1, function(inst) SetSpringMode(inst, true) end)
    else
        inst:DoTaskInTime(.1, function(inst) SetNormalMode(inst, true) end)
    end

    inst:WatchWorldState("israining", function(world, data)
        if TheWorld.state.isspring and not inst.spring then
            inst.springtask = inst:DoTaskInTime(math.random(3, 20), SetSpringMode)
        end
    end)

    inst:WatchWorldState("season", function(world, data)
        if not TheWorld.state.isspring and inst.spring then
            inst.normaltask = inst:DoTaskInTime(math.random(TUNING.MIN_LOBSTER_HOME_TRANSITION_TIME, TUNING.MAX_LOBSTER_HOME_TRANSITION_TIME), SetNormalMode)
        end
    end)


    inst.OnEntityWake = OnWake

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        if TheWorld.state.isspring then
            return "SPRING"
        end
    end

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

return Prefab("lobsterhole", fn, assets, prefabs)
