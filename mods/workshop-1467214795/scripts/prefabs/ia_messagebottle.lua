local assets =
{
    Asset("ANIM", "anim/messagebottle.zip"),
}

local function commonfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    -- waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)

    inst.AnimState:SetBank("messagebottle")
    inst.AnimState:SetBuild("messagebottle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    MakeHauntableLaunch(inst)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)

    return inst
end

local function onreadmap(inst, doer)
    local buriedtreasuremanager = TheWorld.components.buriedtreasuremanager
    if not TheWorld.components.buriedtreasuremanager or not IsInClimate(doer, "island") then  -- or (not inst.treasure and inst.treasureguid)
        doer.components.talker:Say(GetString(doer, "ANNOUNCE_OTHER_WORLD_TREASURE"))
        return
    end

    local buriedtreasure = buriedtreasuremanager:GetBuriedTreasure()
    if not buriedtreasure then
        buriedtreasure = buriedtreasuremanager:SpawnNewTreasure()
    elseif not buriedtreasure.revealed then
        buriedtreasure:SetRandomNewTreasure()
    end

    TheWorld:PushEvent("read_ia_messagebottle", inst.GUID) -- new bottle

    doer:DoTaskInTime(3 * FRAMES, function()
        doer.components.inventory:GiveItem(SpawnPrefab("ia_messagebottleempty"))
    end)

    inst:Remove()

    return buriedtreasure:GetPosition()
end


local function messagebottlefn()
    local inst = commonfn()
    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("ia_messagebottle.tex")

    inst:AddTag("ia_messagebottle")
    inst:AddTag("nosteal")
    inst:AddTag("scroll")

    inst.components.floater:UpdateAnimations("idle_water", "idle")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("mapspotrevealer")
    inst.components.mapspotrevealer:SetGetTargetFn(onreadmap)

    return inst
end

local function emptybottlefn()
    local inst = commonfn()

    inst.components.floater:UpdateAnimations("idle_water_empty", "idle_empty")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    return inst
end

return Prefab("ia_messagebottle", messagebottlefn, assets),
    Prefab("ia_messagebottleempty", emptybottlefn, assets)
