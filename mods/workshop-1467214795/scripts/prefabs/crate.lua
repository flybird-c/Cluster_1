local assets =
{
    Asset("ANIM", "anim/crates.zip"),
    Asset("MINIMAP_IMAGE", "crate")
}

local prefabs =
{
    "collapse_small",
    "boards",
    "rope",
    "tunacan",
    "ia_messagebottleempty",
    "fabric",
    "dubloon"
}

local function setanim(inst, anim)
    inst.anim = anim
    inst.AnimState:PlayAnimation("idle" .. anim)
end

local function onsave(inst, data)
    data.anim = inst.anim
end

local function onload(inst, data)
    if data and data.anim then
        setanim(inst, data.anim)
    end
end

local function onhammered(inst)
    if inst:HasTag("fire") and inst.components.burnable then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    local minimap = inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.1)

    inst.AnimState:SetBank("crates")
    inst.AnimState:SetBuild("crates")
    setanim(inst, math.random(1, 10))

    minimap:SetIcon("crate.tex")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddChanceLoot("boards", 1)
    inst.components.lootdropper:AddRandomLoot("boards", 10)
    inst.components.lootdropper:AddRandomLoot("rope", 10)
    inst.components.lootdropper:AddRandomLoot("tunacan", 5)
    inst.components.lootdropper:AddRandomLoot("ia_messagebottleempty", 10)
    inst.components.lootdropper:AddRandomLoot("fabric", 10)
    inst.components.lootdropper:AddRandomLoot("dubloon", 1)
    inst.components.lootdropper.numrandomloot = 1

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("crate", fn, assets, prefabs)
