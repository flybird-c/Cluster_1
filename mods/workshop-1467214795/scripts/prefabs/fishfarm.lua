require "prefabutil"

local assets = {
	Asset("ANIM", "anim/fish_farm.zip"),
}

local prefabs = {
   "fish_farm_sign"
}

local function OnRemove(inst)
    if inst.sign then
        inst.sign:Remove()
        inst.sign = nil
    end
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
	if inst.components.breeder then inst.components.breeder:Reset() end
	inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function ResetArt(inst)
    inst.AnimState:Hide("sign")
    inst.AnimState:Hide("fish_1")
    inst.AnimState:Hide("fish_2")
    inst.AnimState:Hide("fish_3")
    inst.AnimState:Hide("fish_4")
    inst.AnimState:Hide("fish_5")
    inst.AnimState:Hide("fish_6")
    inst.AnimState:Hide("fish_7")
    inst.AnimState:Hide("fish_8")
    inst.AnimState:Hide("fish_9")
end

local function SwitchTables(fromTable, toTable)
    local randNum = math.random(#fromTable)
    local fishLayer = fromTable[randNum]
    table.remove(fromTable, randNum)
    table.insert(toTable, fishLayer)

    return fishLayer
end

local function RefreshArt(inst)
    if inst.sign then
        inst.sign.ResetArt(inst.sign)
    end

    if inst.volume ~= inst.components.breeder.volume then
        local fishLayer = 0

        for i = 1, math.abs(inst.volume - inst.components.breeder.volume) do
            if inst.volume < inst.components.breeder.volume then
                if inst.volume == inst.components.breeder.max_volume -1 then
                    table.insert(inst.UsedFishStates, 9)
                    inst.AnimState:Show("fish_9")
                else
                    local loop = 1
                    if #inst.UsedFishStates > 0 then
                        loop = 2
                    end
                    for j = 1, loop do
                        inst.AnimState:Show("fish_"..tostring(SwitchTables(inst.UnusedFishStates, inst.UsedFishStates)))
                    end
                end
                inst.volume = inst.volume + 1
            else
                if inst.volume == inst.components.breeder.max_volume then
                    table.remove(inst.UsedFishStates, #inst.UsedFishStates)
                    inst.AnimState:Hide("fish_9")
                else
                    local loop = 1
                    if #inst.UsedFishStates > 1 then
                        loop = 2
                    end
                    for j = 1, loop do
                        inst.AnimState:Hide("fish_"..tostring(SwitchTables(inst.UsedFishStates, inst.UnusedFishStates)))
                    end
                end
                inst.volume = inst.volume -1
            end
        end
    end
    inst.current_volume:set(inst.components.breeder.volume)
end

local function OnSave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.burnt and inst.components.burnable ~= nil and inst.components.burnable.onburnt ~= nil then
        inst.components.burnable.onburnt(inst)
    end
    ResetArt(inst)
    RefreshArt(inst)
end

local function SpawnSign(inst)
    local pt = Vector3(inst.Transform:GetWorldPosition())
    inst.sign = SpawnPrefab("fish_farm_sign")
    inst.sign.Transform:SetPosition(pt.x, 0, pt.z)
    inst.sign.parent = inst
    inst.sign.ResetArt(inst.sign)
    inst.highlightchildren = {inst.sign}
end

local function onseed(inst, seed)
    inst.SoundEmitter:PlaySound("ia/creatures/seacreature_movement/splash_small")
    inst.SoundEmitter:PlaySound("ia/common/pickobject_water")
end

local function onharvest(inst, harvester)
    inst.SoundEmitter:PlaySound("ia/creatures/seacreature_movement/splash_small")
    inst.SoundEmitter:PlaySound("ia/common/fish_farm_harvest")
end

local function onbuilt(inst)
	inst.SoundEmitter:PlaySound("ia/creatures/seacreature_movement/water_submerge_med")
    inst.SoundEmitter:PlaySound("ia/creatures/seacreature_movement/splash_medium")
	RefreshArt(inst)
end

local VOLUME_STATUS = {
    [1] = "ONEFISH",
    [2] = "TWOFISH",
    [3] = "REDFISH",
    [4] = "BLUEFISH",
}

local function getstatus(inst)
    if inst.components.breeder.volume > 0 then
        return VOLUME_STATUS[inst.components.breeder.volume]
    else
        return inst.components.breeder.seeded and "STOCKED" or "EMPTY"
    end
end

local function placer_postinit(inst, pt)
    inst.AnimState:Hide("mouseover")
    inst.AnimState:Hide("sign")
    inst.AnimState:Hide("fish_1")
    inst.AnimState:Hide("fish_2")
    inst.AnimState:Hide("fish_3")
    inst.AnimState:Hide("fish_4")
    inst.AnimState:Hide("fish_5")
    inst.AnimState:Hide("fish_6")
    inst.AnimState:Hide("fish_7")
    inst.AnimState:Hide("fish_8")
    inst.AnimState:Hide("fish_9")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("fish_farm")
    inst.AnimState:SetBuild("fish_farm")
    inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)

    MakeWeakWaterObstaclePhysics(inst, 0, 1.5, 2, 0.75)

    inst.MiniMapEntity:SetIcon("fish_farm.tex")

    inst.entity:SetPristine()

    inst:AddTag("structure")
    inst:AddTag("fishfarm")

    --breeder (from breeder component) added to pristine state for optimization
    inst:AddTag("breeder")

    inst.current_volume = net_tinybyte(inst.GUID, "fish_farm.current_volume")  -- For ActionQueue

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "FISH_FARM"
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("breeder")
    inst.components.breeder.onseedfn = onseed
    inst.components.breeder.onharvestfn = onharvest
    inst.components.breeder.luretime = TUNING.FISH_FARM_LURE_TEST_TIME
    inst.components.breeder.cycle_min = TUNING.FISH_FARM_CYCLE_TIME_MIN
    inst.components.breeder.cycle_max = TUNING.FISH_FARM_CYCLE_TIME_MAX

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)

    inst.volume = 0
    inst.UsedFishStates = {}
    inst.UnusedFishStates={1,2,3,4,5,6,7,8}

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnRemoveEntity = OnRemove

	inst:ListenForEvent("onbuilt", onbuilt)

	inst:ListenForEvent("vischange", RefreshArt)

    inst:DoTaskInTime(0, SpawnSign)

    inst.AnimState:Hide("mouseover")

    ResetArt(inst)
	RefreshArt(inst)

    return inst
end

return Prefab("fish_farm", fn, assets, prefabs),
        MakePlacer("fish_farm_placer", "fish_farm", "fish_farm", "idle", nil, nil, nil, nil, nil, nil, placer_postinit)
