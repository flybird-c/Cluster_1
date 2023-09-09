local prefabs = {
    "lava_erupt",
    "lava_bubbling"
}

local function GetPrefab()
    local vm = TheWorld.components.volcanomanager
    if vm and vm:IsErupting() and math.random() < 0.5 then
        return "lava_erupt"
    end
    return "lava_bubbling"
end

local function CanSpawn(inst, ground, x, y, z)
    return IsSurroundedByTile(x, y, z, 6, WORLD_TILES.VOLCANO_LAVA)
end

local function SetRadius(inst, radius)
    inst.radius = radius
    inst.Light:SetRadius(inst.radius)
    inst.components.areaspawner:SetDensityInRange(inst.radius)
end

local function OnEntitySleep(inst)
    inst.components.areaspawner:Stop()
end

local function OnEntityWake(inst)
    inst.components.areaspawner:Start()
end

local function OnSave(inst, data)
    if data then
        data.radius = inst.radius
    end
end

local function OnLoad(inst, data)
    if data and data.radius then
        SetRadius(inst, data.radius)
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.Light:SetIntensity(0.2)
    inst.Light:SetFalloff(2.5)
    inst.Light:SetColour(255/255,84/255,61/255)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.SetRadius = SetRadius

    inst:AddComponent("areaspawner")
    inst.components.areaspawner:SetPrefabFn(GetPrefab)
    inst.components.areaspawner:SetSpawnTestFn(CanSpawn)
    inst.components.areaspawner:SetRandomTimes(0.5, 0.25)
    inst.components.areaspawner:SetValidTileType(WORLD_TILES.VOLCANO_LAVA)

    return inst
end

return Prefab("volcanolavafx", fn, nil, prefabs)
