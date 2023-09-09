require "prefabutil"

local LARGE_APPEASEMENT = TUNING.APPEASEMENT_LARGE
local LARGE_WRATH = TUNING.WRATH_LARGE

local prefabs = {
    "obsidian",
    "volcano_altar_tower",
    "volcano_altar_meter",
    "volcano_altar_pillar"
}

local baseassets = {
    Asset("ANIM", "anim/volcano_altar_fx.zip"),
}

local towerassets = {
    Asset("ANIM", "anim/volcano_altar.zip"),
}

local meterassets = {
    Asset("ANIM", "anim/volcano_altar.zip"),
}

local pillarassets = {
    Asset("ANIM", "anim/altar_pillar.zip"),
}

local function UpdateMeter(inst)
    local vm = TheWorld.components.volcanomanager
    if not vm then return end
    if vm:IsFireRaining() then
        inst.components.volcanometer.targetseg = 0
    elseif TheWorld.state.issummer then
        inst.components.volcanometer.maxseg = vm:GetNumSegmentsOfEruption() or 67
        inst.components.volcanometer.targetseg = vm:GetNumSegmentsUntilEruption() or inst.components.volcanometer.maxseg
    else
        inst.components.volcanometer.maxseg = 10
        inst.components.volcanometer.targetseg = 10
    end
    inst.components.volcanometer:Start()

end

local function OnGetItemFromPlayer(inst, giver, item)
    local appeasesegs = TUNING.WRATH_SMALL  --8
    if item.components.appeasement then
        appeasesegs = item.components.appeasement.appeasementvalue
    end

    local vm = TheWorld.components.volcanomanager
    vm:Appease(appeasesegs)
    for id in pairs(Shard_GetConnectedShards()) do
        SendModRPCToShard(SHARD_MOD_RPC["Island Adventure"]["AppeaseVolcano"], id, appeasesegs)
    end

    inst.appeasements = inst.appeasements + 1

    if inst.meterprefab then
        UpdateMeter(inst.meterprefab)
    end

    inst.fullappeased = inst.meterprefab.components.volcanometer.targetseg >= inst.meterprefab.components.volcanometer.maxseg

    if appeasesegs > 0 then
        inst.sg:GoToState("appeased")
    else
        if giver and giver.components.health then
            giver.components.health:DoFireDamage(TUNING.VOLCANO_ALTAR_DAMAGE, inst, true)
        end
        inst.sg:GoToState("unappeased")
    end
    print(string.format("Volcano Altar takes your %d seg appeasement from %s\n", appeasesegs, tostring(item.prefab)))
end

local function AcceptTest(inst, item, giver)
    return inst.sg.currentstate.name == "opened"
end

local function SetIsOpen(inst)
    local vm = TheWorld.components.volcanomanager
    if not inst:FullAppeased() and TheWorld.state.issummer and not vm:IsFireRaining() then
        if inst.sg.currentstate.name ~= "opened" then
            inst.sg:GoToState("open")
        end
        inst.components.appeasable:Enable()
    else
        if inst.sg.currentstate.name ~= "closed" then
            inst.sg:GoToState("close")
        end
        inst.components.appeasable:Disable()
    end
end

local function getstatus(inst)
    if inst.components.appeasable.enabled then
        return "OPEN"
    else
        return "CLOSED"
    end
end

local function onsave(inst, data)
    data.fullappeased = inst.fullappeased
    data.appeasements = inst.appeasements
end

local function onload(inst, data)
    inst.fullappeased = data and data.fullappeased and data.fullappeased == true
    inst.appeasements = (data and data.appeasements) or 0
end

local function onloadpostpass(inst, ents, data)
    SetIsOpen(inst)
end

local function fullappeased(inst)
    return inst.meterprefab and inst.meterprefab.components.volcanometer.targetseg >= inst.meterprefab.components.volcanometer.maxseg
end

local function OnHaunt(inst, haunter)
	if math.random() <= TUNING.HAUNT_CHANCE_RARE and inst.components.appeasable.enabled then
		local item = {}
		item.components = {} -- simulating an item to not spawn a real one
		OnGetItemFromPlayer(inst, haunter, item)
	end
end

local toweroff = 0
local meteroff = 1
local altaroff = 2

local function baseFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("volcano_altar.tex")
    inst.Transform:SetScale(1,1,1)

    MakeObstaclePhysics(inst, 2.0, 1.2)

    inst.AnimState:SetBank("volcano_altar_fx")
    inst.AnimState:SetBuild("volcano_altar_fx")
    inst.AnimState:PlayAnimation("idle_close")
    inst.AnimState:SetFinalOffset(altaroff)

    inst.Light:Enable(true)
    inst.Light:SetIntensity(0.75)
    inst.Light:SetColour(197/255, 197/255, 50/255)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetRadius(2)

    inst:AddTag("altar")
    inst:AddTag("structure")
    inst:AddTag("stone")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("hauntable")
    inst.components.hauntable.onhaunt = OnHaunt
	inst.components.hauntable.hauntvalue = TUNING.HAUNT_LARGE

    inst:SetStateGraph("SGvolcanoaltar")

    inst:AddComponent("appeasable")
    inst.components.appeasable.onaccept = OnGetItemFromPlayer
    inst.components.appeasable:SetAcceptTest(AcceptTest)
    inst.components.appeasable:Disable()


    inst:SetPrefabName("volcano_altar")
    local function createExtras(inst)
        local x, y, z = inst.Transform:GetWorldPosition()
        inst.meterprefab =  SpawnPrefab("volcano_altar_meter")
        inst.meterprefab.Transform:SetPosition( x, y, z )
        inst.towerprefab =  SpawnPrefab("volcano_altar_tower")
        inst.towerprefab.Transform:SetPosition( x, y, z )
        UpdateMeter(inst.meterprefab)
        print("createExtras", inst.meterprefab.components.volcanometer:GetDebugString())
        inst.meterprefab.components.volcanometer.curseg = inst.meterprefab.components.volcanometer.targetseg
        inst.meterprefab.components.volcanometer:UpdateMeter()
    end

    inst.fullappeased = false
    inst.appeasements = 0

    inst:DoPeriodicTask(10, SetIsOpen)

	inst:WatchWorldState("season", function(inst)
        if  TheWorld.state.season ~= "summer" then
            inst.appeasements = 0
        end
        SetIsOpen(inst)
    end)

    inst:ListenForEvent("OnVolcanoEruptionBegin", function(it, data)
        SetIsOpen(inst)
    end, TheWorld)

    inst:ListenForEvent("OnVolcanoFireRainEnd", function(it, data)
        inst.fullappeased = false
        SetIsOpen(inst)
    end, TheWorld)

   inst:DoTaskInTime(FRAMES * 1, createExtras)

    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnLoadPostPass = onloadpostpass
    inst.FullAppeased = fullappeased

    SetIsOpen(inst)

    return inst
end


local function meterFn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetScale(1,1,1)

    inst.AnimState:SetBank("volcano_altar")
    inst.AnimState:SetBuild("volcano_altar")
    inst.AnimState:PlayAnimation("meter")
    inst.AnimState:SetFinalOffset(meteroff)
    inst.AnimState:SetPercent("meter", 0)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("volcanometer")
    inst.components.volcanometer.targetseg = 66 --66 seems to the longest time between eruptions but this number really shouldn't be hardcoded.
    inst.components.volcanometer.curseg = 66
    inst.components.volcanometer.maxseg = 66
    inst.components.volcanometer.updatemeterfn = function(inst, perc)
        inst.AnimState:SetPercent("meter", perc)
    end
    inst.components.volcanometer.updatedonefn = function(inst)
        inst:PushEvent("MeterDone")
    end

    UpdateMeter(inst)

    inst:DoPeriodicTask(10, UpdateMeter)

    inst:WatchWorldState("season", function(inst)
        UpdateMeter(inst)
        if TheWorld.state.season == "summer" then
            inst.components.volcanometer.curseg = inst.components.volcanometer.targetseg
        end
    end, TheWorld)

    inst:ListenForEvent("OnVolcanoEruptionBegin", function(it, data)
        UpdateMeter(inst)
    end, TheWorld)

    inst:ListenForEvent("OnVolcanoFireRainEnd", function(it, data)
        UpdateMeter(inst)
    end, TheWorld)

    return inst
end

local function towerFn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetScale(1,1,1)

    inst.AnimState:SetBank("volcano_altar")
    inst.AnimState:SetBuild("volcano_altar")
    inst.AnimState:PlayAnimation("idle_close")
    inst.AnimState:SetFinalOffset(toweroff)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function pillarFn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .25)

    inst.Transform:SetScale(1,1,1)

    inst.AnimState:SetBank("altar_pillar")
    inst.AnimState:SetBuild("altar_pillar")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end



return Prefab("volcano_altar", baseFn, baseassets, prefabs),
    Prefab("volcano_altar_tower", towerFn, towerassets),
    Prefab("volcano_altar_meter", meterFn, meterassets),
    Prefab("volcano_altar_pillar", pillarFn, pillarassets)
