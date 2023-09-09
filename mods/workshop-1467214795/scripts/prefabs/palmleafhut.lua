require "prefabutil"

local assets =
{
  Asset("ANIM", "anim/palmleaf_hut.zip"),
  Asset("ANIM", "anim/palmleaf_hut_shdw.zip"),
}

local prefabs =
{
  "palmleaf_hut_shadow",
}

local function onhammered(inst, worker)
    if inst:HasTag("fire") and inst.components.burnable then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", true)

        if inst.shadow then
        inst.shadow.AnimState:PlayAnimation("hit")
        inst.shadow.AnimState:PushAnimation("idle", true)
        end
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", true)

    if inst.shadow then
        inst.shadow.AnimState:PlayAnimation("place")
        inst.shadow.AnimState:PushAnimation("idle", true)
    end

    inst.SoundEmitter:PlaySound("ia/common/palmleafhut_jumpup")
    inst:DoTaskInTime(23*FRAMES, function() inst.SoundEmitter:PlaySound("ia/common/palmleafhut_land") end)
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function onremove(inst)
    if inst.shadow then
        inst.shadow:Remove()
    end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst:AddTag("shelter")
    inst:AddTag("dryshelter")

    inst:AddTag("structure")
    inst.AnimState:SetBank("hut")
    inst.AnimState:SetBuild("palmleaf_hut")
    inst.AnimState:PlayAnimation("idle", true)

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "palmleaf_hut.tex" )

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    ---------------------
	inst.shadow = SpawnPrefab("palmleaf_hut_shadow")
	inst.shadow.entity:SetParent(inst.entity)
	inst.shadow.Transform:SetPosition(0,0,0)
    ---------------------

    MakeSnowCovered(inst, .01)
    inst:ListenForEvent( "onbuilt", onbuilt)

    MakeLargeBurnable(inst, nil, nil, true)
    MakeLargePropagator(inst)

    inst.OnSave = onsave 
    inst.OnLoad = onload

    inst.OnRemoveEntity = onremove

    return inst
end

local function shadowfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("palmleaf_hut_shdw")
    inst.AnimState:SetBuild("palmleaf_hut_shdw")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst.persists = false

    return inst
end

return Prefab( "palmleaf_hut", fn, assets, prefabs),
MakePlacer( "palmleaf_hut_placer", "hut", "palmleaf_hut", "idle"),
Prefab("palmleaf_hut_shadow", shadowfn, assets)
