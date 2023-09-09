local assets =
{
    Asset("ANIM", "anim/blueprint_sketch.zip"),
}

local SKETCHES =
{
    { item = "chesspiece_kraken",				recipe = "chesspiece_kraken_builder" },
    { item = "chesspiece_tigershark",			recipe = "chesspiece_tigershark_builder" },
    { item = "chesspiece_twister",				recipe = "chesspiece_twister_builder" },
    { item = "chesspiece_seal",			        recipe = "chesspiece_seal_builder" },
}

local function GetSketchID(item)
    for i, v in ipairs(SKETCHES) do
        if v.item == item then
            return i
        end
    end
end

local function GetSketchIDFromName(name)
    for i, v in ipairs(SKETCHES) do
        if name == subfmt(STRINGS.NAMES.SKETCH, { item = STRINGS.NAMES[string.upper(SKETCHES[i].recipe)] }) then
            return i
        end
    end
end

local function onload(inst, data)
    if not data then
        inst.sketchid = GetSketchIDFromName(inst.components.named.name) or 1
    else
        if data.sketchid then
            inst.sketchid = data.sketchid or 1
        elseif data.sketchitem then
            inst.sketchid = GetSketchID(data.sketchitem) or 1
        end
    end

    inst.components.named:SetName(subfmt(STRINGS.NAMES.SKETCH, { item = STRINGS.NAMES[string.upper(SKETCHES[inst.sketchid].recipe)] }))
    if SKETCHES[inst.sketchid].image ~= nil then
        inst.components.inventoryitem:ChangeImageName(SKETCHES[inst.sketchid].image)
    end
end

local function onsave(inst, data)
    data.sketchitem = SKETCHES[inst.sketchid].item
end

local function GetRecipeName(inst)
    return SKETCHES[inst.sketchid].recipe
end

local function GetSpecificSketchPrefab(inst)
    return SKETCHES[inst.sketchid].item.."_sketch"
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blueprint_sketch")
    inst.AnimState:SetBuild("blueprint_sketch")
    inst.AnimState:PlayAnimation("idle")

    --Sneak these into pristine state for optimization
    inst:AddTag("_named")
    inst:AddTag("sketch")

    inst:SetPrefabName("ia_sketch")

    MakeInventoryFloatable(inst, "med", nil, 0.75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("_named")

    inst:AddComponent("named")
    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "sketch"

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("sketch")

	inst:AddComponent("erasablepaper")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeHauntableLaunch(inst)

    inst.OnLoad = onload
    inst.OnSave = onsave

    inst.sketchid = 1

    inst.GetRecipeName = GetRecipeName
    inst.GetSpecificSketchPrefab = GetSpecificSketchPrefab

    return inst
end

local function MakeSketchPrefab(sketchid)
    return function()
        local inst = fn()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.sketchid = sketchid

        inst.components.named:SetName(subfmt(STRINGS.NAMES.SKETCH, { item = STRINGS.NAMES[string.upper(SKETCHES[sketchid].recipe)] }))

        if SKETCHES[sketchid].image ~= nil then
            inst.components.inventoryitem:ChangeImageName(SKETCHES[sketchid].image)
        end

        return inst
    end
end

local ret = {}
table.insert(ret, Prefab("ia_sketch", fn, assets))
for i, v in ipairs(SKETCHES) do
    local temp_assets = assets
    if v.image ~= nil then
        temp_assets = { Asset("INV_IMAGE", v.image) }
        for _, asset in ipairs(assets) do
            table.insert(temp_assets, asset)
        end
    end
    table.insert(ret, Prefab(v.item.."_sketch", MakeSketchPrefab(i), temp_assets))
end

return unpack(ret)
