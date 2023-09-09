local assets =
{
    Asset("ANIM", "anim/tidal_pool.zip")
}

local prefabs =
{
    "tidal_plant",
    "pondfish_tropical",
}

local function SpawnPlants(inst, plantname, count, maxradius)

    if inst.decor then
        for i,item in ipairs(inst.decor) do
        item:Remove()
        end
    end
    inst.decor = {}

    local plant_offsets = {}

    for i=1,math.random(math.ceil(count/2),count) do
        local a = math.random()*math.pi*2
        local x = math.sin(a)*maxradius+math.random()*0.2
        local z = math.cos(a)*maxradius+math.random()*0.2
        table.insert(plant_offsets, {x,0,z})
    end

    for k, offset in pairs(plant_offsets) do
        local plant = SpawnPrefab(plantname)
        plant.entity:SetParent(inst.entity)
        plant.Transform:SetPosition(offset[1], offset[2], offset[3])
        table.insert(inst.decor, plant)
    end
end

local sizes =
{
    {anim="small_idle", rad=2.0, plantcount=2, plantrad=1.6},
    {anim="med_idle", rad=2.6, plantcount=3, plantrad=2.5},
    {anim="big_idle", rad=3.6, plantcount=4, plantrad=3.4},
}

local function SetSize(inst, size)
    inst.size = size or math.random(1, #sizes)
    inst.AnimState:PlayAnimation(sizes[inst.size].anim, true)
    inst.Physics:SetCapsule(sizes[inst.size].rad, 1.0)
    SpawnPlants(inst, "marsh_plant_tropical", sizes[inst.size].plantcount, sizes[inst.size].plantrad)
end

local function OnSave(inst, data)
    data.size = inst.size
end

local function OnLoad(inst, data, newents)
    if data and data.size then
        SetSize(inst, data.size)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics( inst, 3.5)

    inst.AnimState:SetBuild("tidal_pool")
    inst.AnimState:SetBank("tidal_pool")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.MiniMapEntity:SetIcon("pond_cave.png")

    -- From watersource component
    inst:AddTag("watersource")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("birdblocker")
    inst:AddTag("fishable")

    inst.no_wet_prefix = true

    inst:SetDeployExtraSpacing(2)
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("fishable")
    inst.components.fishable:AddFish("pondfish_tropical")
    inst.components.fishable:SetRespawnTime(TUNING.FISH_RESPAWN_TIME)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("watersource")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    SetSize(inst)

    return inst
end

return Prefab("tidalpool", fn, assets, prefabs)
