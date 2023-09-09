require("worldsettingsutil")

local prefabs = {
    "stungray"
}

local function onsave(inst, data)
    data.start_day = inst.start_day
end

local function teststartspawning(inst)
    if inst.start_day then
        if TheWorld.state.cycles >= inst.start_day then
            inst.components.childspawner:StartSpawning()
            inst.start_day = nil
            inst.MiniMapEntity:SetEnabled(true)
        end
    end
end


local function onload(inst, data)
    if data and data.start_day then
        inst.start_day = data.start_day
        teststartspawning(inst)
    end
end

local function longupdate(inst, dt)
    teststartspawning(inst)
end

local function onwake(inst)
    teststartspawning(inst)
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("stinkray.tex")
    inst.MiniMapEntity:SetEnabled(false)

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst:AddTag("ignorewalkableplatforms")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent( "childspawner" )
    inst.components.childspawner:SetRegenPeriod(TUNING.STINKRAY_REGEN_PERIOD)
    inst.components.childspawner:SetSpawnPeriod(.1)
    inst.components.childspawner:SetMaxChildren(6)
    inst.components.childspawner.childname = "stungray"
    inst.components.childspawner.wateronly = true
    WorldSettings_ChildSpawner_SpawnPeriod(inst, .1, TUNING.STINKRAY_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.STINKRAY_REGEN_PERIOD, TUNING.STINKRAY_ENABLED)
    if not TUNING.STINKRAY_ENABLED then
        inst.components.childspawner.childreninside = 0
    end

    inst.start_day = 5 + math.random() * 5

    inst.OnLongUpdate = longupdate
    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnEntityWake = onwake

    return inst
end

return Prefab("stungray_spawner", fn, nil, prefabs)
