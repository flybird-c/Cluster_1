local assets = {
    Asset("ANIM", "anim/researchlab5.zip"),
}

local prefabs = {
    "collapse_small",
    "sea_lab_underwater_fx",
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")
    inst:Remove()
end

local function onhit(inst)
    inst.AnimState:PlayAnimation("hit")
    inst.underwater.AnimState:PlayAnimation("hit")
    if inst.components.prototyper.on then
        inst.AnimState:PushAnimation("proximity_loop", true)
        inst.underwater.AnimState:PushAnimation("proximity_loop", true)
    else
        inst.AnimState:PushAnimation("idle", true)
        inst.underwater.AnimState:PushAnimation("idle", true)
    end
end

local function doonact(inst)
    if inst._activecount > 1 then
        inst._activecount = inst._activecount - 1
    else
        inst._activecount = 0
        inst.SoundEmitter:KillSound("sound")
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_lvl2_ding")
end

local function onturnon(inst)
    if inst._activetask == nil then
        if inst.AnimState:IsCurrentAnimation("place") then
            inst.AnimState:PushAnimation("proximity_loop", true)
            inst.underwater.AnimState:PushAnimation("proximity_loop", true)
        else
            inst.AnimState:PlayAnimation("proximity_loop", true)
            inst.underwater.AnimState:PlayAnimation("proximity_loop", true)
        end
        inst.SoundEmitter:KillSound("idlesound")

    end
end

local function onturnoff(inst)
    if inst._activetask == nil then
        inst.AnimState:PlayAnimation("idle", true)
        inst.underwater.AnimState:PlayAnimation("idle", true)
        inst.SoundEmitter:KillSound("proximity_loop")
    end
end

local function doneact(inst)
    inst._activetask = nil
    if inst.components.prototyper.on then
        onturnon(inst)
    else
        onturnoff(inst)
    end
end

local function onactivate(inst)
    inst.AnimState:PlayAnimation("use")
    inst.AnimState:PushAnimation("idle", true)
    inst.underwater.AnimState:PlayAnimation("use")
    inst.underwater.AnimState:PushAnimation("idle", true)
    if not inst.SoundEmitter:PlayingSound("sound") then
        inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_lvl2_run", "sound")
    end
    inst._activecount = inst._activecount + 1
    inst:DoTaskInTime(1.5, doonact)
    if inst._activetask ~= nil then
        inst._activetask:Cancel()
    end
    inst._activetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, doneact)
end

local function onbuilt(inst, data)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.underwater.AnimState:PlayAnimation("place")
    inst.underwater.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_lvl2_place")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeWaterObstaclePhysics(inst, .4, nil, 0.80)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("sea_lab.tex")

    inst.AnimState:SetBank("researchlab5")
    inst.AnimState:SetBuild("researchlab5")
    inst.AnimState:PlayAnimation("idle", true)

    inst.AnimState:HideSymbol("ripple2")
    inst.AnimState:HideSymbol("underwater_shadow")

    inst:AddTag("giftmachine")
    inst:AddTag("structure")

    -- prototyper (from prototyper component) added to pristine state for optimization
    inst:AddTag("prototyper")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.underwater = SpawnPrefab("sea_lab_underwater_fx")
    inst.underwater.entity:SetParent(inst.entity)
    inst.underwater.Transform:SetPosition(0,0,0)

    inst._activecount = 0
    inst._activetask = nil

    inst:AddComponent("inspectable")
    inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.SEALAB
    inst.components.prototyper.onactivate = onactivate

    inst:AddComponent("wardrobe")
    inst.components.wardrobe:SetCanUseAction(false)  -- also means NO wardrobe tag!
    inst.components.wardrobe:SetCanBeShared(true)
    inst.components.wardrobe:SetRange(TUNING.RESEARCH_MACHINE_DIST + .1)

    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    MakeSnowCovered(inst)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:ListenForEvent("ms_giftopened", onactivate)

    return inst
end

local function underwaterfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("researchlab5")
    inst.AnimState:SetBuild("researchlab5")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)

    inst.AnimState:HideSymbol("bamboo")
    inst.AnimState:HideSymbol("body")
    inst.AnimState:HideSymbol("bubbles")
    inst.AnimState:HideSymbol("corks")
    inst.AnimState:HideSymbol("droplet")
    inst.AnimState:HideSymbol("lid")
    inst.AnimState:HideSymbol("pipes")
    inst.AnimState:HideSymbol("ripple2")
    inst.AnimState:HideSymbol("tube")
    inst.AnimState:HideSymbol("wake")

    inst:AddTag("DECOR")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("sea_lab", fn, assets, prefabs),
    Prefab("sea_lab_underwater_fx", underwaterfxfn, assets, prefabs),
    MakePlacer("sea_lab_placer", "researchlab5", "researchlab5", "placer")
