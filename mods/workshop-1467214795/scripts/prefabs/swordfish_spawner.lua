require("worldsettingsutil")

local prefabs =
{
    "swordfish",
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst:AddTag("ignorewalkableplatforms")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent( "childspawner" )
    inst.components.childspawner:SetRegenPeriod(TUNING.SWORDFISH_REGEN_PERIOD)
    inst.components.childspawner:SetSpawnPeriod(TUNING.SWORDFISH_SPAWN_PERIOD)
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner.childname = "swordfish"
    inst.components.childspawner.spawnoffscreen = true
    inst.components.childspawner.wateronly = true
    inst.components.childspawner:StartSpawning()
    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.SWORDFISH_SPAWN_PERIOD, TUNING.SWORDFISH_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.SWORDFISH_REGEN_PERIOD, TUNING.SWORDFISH_ENABLED)
    if not TUNING.SWORDFISH_ENABLED then
        inst.components.childspawner.childreninside = 0
    end

    return inst
end

return Prefab("swordfish_spawner", fn, nil, prefabs)

