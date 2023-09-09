local ripple_assets =
{
    Asset("ANIM", "anim/coral_rock.zip"),
}

local lab_assets =
{
    Asset("ANIM", "anim/critterlab_water.zip"),
}

local prefabs = 
{
    "critterlab_water_ripple",
}

local function underwaterfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.persists = false

    inst:AddTag("NOBLOCK")
    inst:AddTag("FX")
    inst:AddTag("ignorewalkableplatforms")
    inst.AnimState:SetBank("coral_rock")
    inst.AnimState:SetBuild("coral_rock")
    inst.AnimState:PlayAnimation("full1", true)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)

    inst.AnimState:HideSymbol("coral_leaf")
    inst.AnimState:HideSymbol("wake")
    inst.AnimState:HideSymbol("coral_base")
    inst.AnimState:HideSymbol("ripple2")

    inst:AddComponent("highlightchild")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function ripplesfn()
    local inst = CreateEntity()

    inst:AddTag("can_offset_sort_pos")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.persists = false

    inst:AddTag("NOBLOCK")
    inst:AddTag("FX")
    inst:AddTag("ignorewalkableplatforms")
    inst.AnimState:SetBank("coral_rock")
    inst.AnimState:SetBuild("coral_rock")
    inst.AnimState:PlayAnimation("full1", true)
    inst.AnimState:SetSortWorldOffset(0, -0.5, 0)

    inst.AnimState:HideSymbol("coral_leaf")
    inst.AnimState:HideSymbol("wake")
    inst.AnimState:HideSymbol("coral_base")
    inst.AnimState:HideSymbol("coral_underwater")

    inst:AddComponent("highlightchild")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function fn()
    local inst = Prefabs["critterlab"].fn()

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("critterlab_water.tex")

    inst.AnimState:SetBank("critterlab_water")
    inst.AnimState:SetBuild("critterlab_water")

    inst.AnimState:HideSymbol("ripple2")
    inst.AnimState:HideSymbol("coral_underwater")

    inst:AddTag("blocker")
    inst:AddComponent("waterphysics")
    inst.components.waterphysics.restitution = 0.75

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.inspectable.nameoverride = "critterlab"

    local r = 0.8 + math.random() * 0.2
    local g = 0.8 + math.random() * 0.2
    local b = 0.8 + math.random() * 0.2
    -- inst.AnimState:SetMultColour(r, g, b, 1)
    -- No longer colours the wake like in sw
    inst.AnimState:SetSymbolMultColour("coral_base", r, g, b, 1)
    inst.AnimState:SetSymbolMultColour("coral_leaf", r, g, b, 1)

    ---------------------
	inst.underwater = SpawnPrefab("critterlab_water_underwater")
	inst.underwater.entity:SetParent(inst.entity)
	inst.underwater.Transform:SetPosition(0,0,0)
    inst.underwater.components.highlightchild:SetOwner(inst)
    ---------------------

    ---------------------
	inst.ripple = SpawnPrefab("critterlab_water_ripple")
	inst.ripple.entity:SetParent(inst.entity)
	inst.ripple.Transform:SetPosition(0,0,0)
    inst.ripple.components.highlightchild:SetOwner(inst)
    ---------------------

    return inst
end

return Prefab("critterlab_water_underwater", underwaterfn, ripple_assets),
Prefab("critterlab_water_ripple", ripplesfn, ripple_assets),
Prefab("critterlab_water", fn, lab_assets, prefabs)
