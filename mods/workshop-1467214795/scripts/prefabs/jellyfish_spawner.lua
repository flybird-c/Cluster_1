require("worldsettingsutil")

local prefabs = {
    "jellyfish_planted",
}

local function onspawned(inst, child)
    local pos = child:GetPosition()
    local offset = FindSwimmableOffset(pos, 2*math.pi*math.random(), 30*math.random(), 4)
    if offset then
        child.Transform:SetPosition((offset + pos):Get())
    end
    SpawnAt("splash_water_drop", child)
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "jellyfish_planted"
    inst.components.childspawner.spawnoffscreen = true
    inst.components.childspawner:SetRegenPeriod(TUNING.JELLYFISH_REGEN_PERIOD)
    inst.components.childspawner:SetSpawnPeriod(.1)
    inst.components.childspawner:SetMaxChildren(TUNING.JELLYFISH_SPAWNER_JELLYFISH)
    inst.components.childspawner:SetSpawnedFn(onspawned)
    inst.components.childspawner:StartSpawning()
    inst.components.childspawner.wateronly = true
    WorldSettings_ChildSpawner_SpawnPeriod(inst, .1, TUNING.JELLYFISH_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.JELLYFISH_REGEN_PERIOD, TUNING.JELLYFISH_ENABLED)
    if not TUNING.JELLYFISH_ENABLED then
        inst.components.childspawner.childreninside = 0
    end

    return inst
end

return Prefab("jellyfish_spawner", fn, nil, prefabs)
