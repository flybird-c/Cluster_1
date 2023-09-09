local assets = {
    Asset("ANIM", "anim/bioluminescence.zip"),
}

--This has to be a multiple of 1/32 or else the float netvar loses precision and stays below INTENSITY
--Ideally, don't use a netvar for this at all. -M
local INTENSITY = .65625 --.65

local function randomizefadein()
    return math.random(1, 31)
end

local function randomizefadeout()
    return math.random(32, 63)
end

local function immediatefadeout()
    return 0
end

local function resolvefaderate(x)
    -- immediate fadeout -> 0
    -- randomize fadein -> INTENSITY * FRAMES / (1 + math.random())
    -- randomize fadeout -> -INTENSITY * FRAMES / (.5 + math.random())
    return (x == 0 and 0)
        or (x < 32 and INTENSITY * FRAMES / (x / 31 + 1))
        or INTENSITY * FRAMES / ((32 - x) / 31 - 0.5)
end

local function updatefade(inst, rate)
    inst._fadeval:set_local(math.clamp(inst._fadeval:value() + rate, 0, INTENSITY))

    --Client light modulation is enabled:
    inst.Light:SetIntensity(inst._fadeval:value())

    if rate == 0 or
        (rate < 0 and inst._fadeval:value() <= 0) or
        (rate > 0 and inst._fadeval:value() >= INTENSITY) then
        inst._fadetask:Cancel()
        inst._fadetask = nil
        if inst._fadeval:value() <= 0 and TheWorld.ismastersim then
            inst:AddTag("NOCLICK")
            inst.Light:Enable(false)
            inst:Hide()
        end
    end
end

local function fadein(inst)
    local ismastersim = TheWorld.ismastersim
    if not ismastersim or resolvefaderate(inst._faderate:value()) <= 0 then
        if ismastersim then
            inst:RemoveTag("NOCLICK")
            inst.Light:Enable(true)
            inst:Show()
            inst.AnimState:PlayAnimation("idle_pre")
            inst.AnimState:PushAnimation("idle_loop", true)
            inst._faderate:set(randomizefadein())
        end
        if inst._fadetask ~= nil then
            inst._fadetask:Cancel()
            inst._fadetask = nil
        end
        local rate = resolvefaderate(inst._faderate:value()) * math.clamp(1 - inst._fadeval:value() / INTENSITY, 0, 1)
        inst._fadetask = inst:DoPeriodicTask(FRAMES, updatefade, nil, rate)
        if not ismastersim then
            updatefade(inst, rate)
        end
    end
end

local function fadeout(inst)
    local ismastersim = TheWorld.ismastersim
    if not ismastersim or resolvefaderate(inst._faderate:value()) > 0 then
        if ismastersim then
            inst.AnimState:PlayAnimation("idle_pst")
            inst._faderate:set(randomizefadeout())
        end
        if inst._fadetask ~= nil then
            inst._fadetask:Cancel()
            inst._fadetask = nil
        end
        local rate = resolvefaderate(inst._faderate:value()) * math.clamp(inst._fadeval:value() / INTENSITY, 0, 1)
        inst._fadetask = inst:DoPeriodicTask(FRAMES, updatefade, nil, rate)
        if not ismastersim then
            updatefade(inst, rate)
        end
    end
end

local function OnFadeRateDirty(inst)
    local rate = resolvefaderate(inst._faderate:value())
    if rate > 0 then
        fadein(inst)
    elseif rate < 0 then
        fadeout(inst)
    elseif inst._fadetask ~= nil then
        inst._fadetask:Cancel()
        inst._fadetask = nil
        inst._fadeval:set_local(0)

        -- Client light modulation is enabled:
        inst.Light:SetIntensity(0)
    end
end

local function updatelight(inst)
    if TheWorld.state.phase ~= "day" and inst.components.inventoryitem.owner == nil then
        fadein(inst)
    elseif TheWorld.state.phase == "day" and inst.components.inventoryitem.owner == nil then
        fadeout(inst)
    end
end

local function ondropped(inst)
    inst.components.workable:SetWorkLeft(1)
    inst._fadeval:set(0)
    inst._faderate:set_local(immediatefadeout())
    fadein(inst)
    inst:DoTaskInTime(2 + math.random(), updatelight)
end

local function onpickup(inst)
    if inst._fadetask ~= nil then
        inst._fadetask:Cancel()
        inst._fadetask = nil
    end
    inst._fadeval:set_local(0)
    inst._faderate:set(immediatefadeout())
    inst.Light:SetIntensity(0)
    inst.Light:Enable(false)
end

local function onhitland(inst)
    -- When the game loads, these are temporarily not in an inventory.. so they were hitting the ground and being
    -- destroyed. Delaying a frame waits until they have a chance to be inventoried before being removed.
    -- Load post pass might also have worked
    inst:DoTaskInTime(0, function()
        if not inst.components.inventoryitem.owner then
            local x, y, z = inst.Transform:GetLocalPosition()
            local fx = SpawnPrefab("splash_water_drop")
            fx.Transform:SetPosition(x, y, z)
            inst:Remove()
        end
    end)
end

local function onlanded(inst)
	if GetTime() <= 1 or IsOnOcean(inst) then --Rot boats
		updatelight(inst)
	else
		onhitland(inst)
	end
end

local function onworked(inst, worker)
    if worker.components.inventory ~= nil then
        worker.components.inventory:GiveItem(inst, nil, inst:GetPosition())
    end
end

local function onphase(inst)
    inst:DoTaskInTime(2 + math.random(), updatelight)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.Light:SetFalloff(0.45)
    inst.Light:SetIntensity(INTENSITY)
    inst.Light:SetRadius(0.9)
    inst.Light:SetColour(0/255, 180/255, 255/255)
    inst.Light:SetIntensity(0)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    inst.AnimState:SetBank("bioluminessence")
    inst.AnimState:SetBuild("bioluminessence")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(-3)
    inst.AnimState:SetRayTestOnBB(true)

    MakeInventoryPhysics(inst)
    inst.Physics:ClearCollidesWith(COLLISION.BOAT_LIMITS)

    inst.no_wet_prefix = true

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst:AddTag("unramable")
    inst:AddTag("ignorewalkableplatforms")

    inst._fadeval = net_float(inst.GUID, "bioluminescence._fadeval")
    inst._faderate = net_smallbyte(inst.GUID, "bioluminescence._faderate", "onfaderatedirty")
    inst._fadetask = nil

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("onfaderatedirty", OnFadeRateDirty)

        return inst
    end

    inst:Hide()

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onworked)

    inst:AddComponent("stackable")
    inst.components.stackable.forcedropsingle = true

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPickupFn(onpickup)
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
	inst.components.inventoryitem.notboattossable = true

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
    inst.components.fuel.fueltype = "CAVE"

	inst:ListenForEvent("on_landed", onlanded)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:WatchWorldState("phase", onphase)

    updatelight(inst)

    return inst
end

return Prefab("bioluminescence", fn, assets)
