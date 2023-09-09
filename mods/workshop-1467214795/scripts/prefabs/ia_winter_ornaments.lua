local BLINK_PERIOD = 1.2

local LIGHT_DATA =
{
    {colour = Vector3(1, 0.1, 0.1)},
}

function GetAllShipwreckedWinterOrnamentPrefabs()
    local decor =
    {
        "winter_ornament_boss_tigershark",
        "winter_ornament_boss_kraken",
        "winter_ornament_boss_kraken_tentacle",
        "winter_ornament_boss_twister",
        "winter_ornament_boss_doydoy",
    }

    return decor
end

local function updatelight(inst, data)
    if data ~= nil and data.name == "blink" then
        inst.ornamentlighton = not inst.ornamentlighton
        local owner = inst.components.inventoryitem:GetGrandOwner()
        if owner ~= nil then
            owner:PushEvent("updatelight", inst)
        else
            inst.Light:Enable(inst.ornamentlighton)
            inst.AnimState:PlayAnimation(inst.winter_ornamentid .. (inst.ornamentlighton and "_on" or "_off"))
        end
        if not inst.components.timer:TimerExists("blink") then
            inst.components.timer:StartTimer("blink", BLINK_PERIOD)
        end
    end
end

local function ondropped(inst)
    inst.ornamentlighton = false
    updatelight(inst, {name = "blink"})
    inst.components.fueled:StartConsuming()
end

local function onpickup(inst, by)
    if by ~= nil and by:HasTag("winter_tree") then
        if not inst.components.timer:TimerExists("blink") then
            inst.ornamentlighton = false
            updatelight(inst, {name = "blink"})
        end
        inst.components.fueled:StartConsuming()
    else
        inst.ornamentlighton = false
        inst.Light:Enable(false)
        inst.components.timer:StopTimer("blink")
        if by ~= nil and by:HasTag("lamp") then
            inst.components.fueled:StartConsuming()
        else
            inst.components.fueled:StopConsuming()
        end
    end
end

local function onentitywake(inst)
    if inst.components.timer:IsPaused("blink") then
        inst.components.timer:ResumeTimer("blink")
    elseif inst.components.fueled.consuming then
        updatelight(inst, {name = "blink"})
    end
end

local function onentitysleep(inst)
    inst.components.timer:PauseTimer("blink")
end

local function ondepleted(inst)
    inst.ornamentlighton = false
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner ~= nil then
        owner:PushEvent("updatelight", inst)
    end
    inst.Light:Enable(false)
    inst.AnimState:PlayAnimation(inst.winter_ornamentid .. "_off")
    inst.components.timer:StopTimer("blink")
    inst.components.fueled:StopConsuming()
    inst.components.inventoryitem:SetOnDroppedFn(nil)
    inst.components.inventoryitem:SetOnPutInInventoryFn(nil)
    inst.OnEntitySleep = nil
    inst.OnEntityWake = nil
    inst.OnSave = nil
    if inst.components.fuel ~= nil then
        inst:RemoveComponent("fuel")
    end
end

local function onsave(inst, data)
    data.ornamentlighton = inst.ornamentlighton
end

local function onload(inst, data)
    if inst.components.fueled:IsEmpty() then
        ondepleted(inst)
    elseif data ~= nil then
        inst.ornamentlighton = data.ornamentlighton
    end
end

local function MakeOrnament(ornamentid, overridename, lightdata, float_scale)
    local build = "winter_ornaments_ia"

    local assets =
    {
        Asset("ANIM", "anim/" .. build .. ".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst, 0.1)

        inst.AnimState:SetBank(build)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(tostring(ornamentid))

        inst:AddTag("winter_ornament")
        inst:AddTag("molebait")
        inst:AddTag("cattoy")

        inst.winter_ornamentid = ornamentid
        inst.winter_ornament_build = build

        inst:SetPrefabNameOverride(overridename)

        if lightdata then
            inst.entity:AddLight()
            inst.Light:SetFalloff(0.7)
            inst.Light:SetIntensity(0.5)
            inst.Light:SetRadius(0.5)
            inst.Light:SetColour(lightdata.colour.x, lightdata.colour.y, lightdata.colour.z)
            inst.Light:Enable(false)

            inst:AddTag("lightbattery")

            inst.AnimState:PlayAnimation(tostring(ornamentid) .. "_on")
        else
            inst.AnimState:PlayAnimation(tostring(ornamentid))
        end

        MakeInventoryFloatable(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")

        if float_scale ~= nil then
            inst.components.floater:SetScale(float_scale)
        end

        inst:AddComponent("tradable")
        inst.components.tradable.goldvalue = 1

        if lightdata then
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = FUELTYPE.USAGE
            inst.components.fueled.no_sewing = true
            inst.components.fueled:InitializeFuelLevel(160 * TUNING.TOTAL_DAY_TIME)
            inst.components.fueled:SetDepletedFn(ondepleted)
            inst.components.fueled:StartConsuming()

            inst:AddComponent("timer")
            inst:ListenForEvent("timerdone", updatelight)

            inst:AddComponent("fuel")
            inst.components.fuel.fuelvalue = TUNING.MED_LARGE_FUEL
            inst.components.fuel.fueltype = FUELTYPE.CAVE

            inst.components.inventoryitem:SetOnDroppedFn(ondropped)
            inst.components.inventoryitem:SetOnPutInInventoryFn(onpickup)

            inst.OnEntitySleep = onentitysleep
            inst.OnEntityWake = onentitywake
            inst.OnSave = onsave
            inst.OnLoad = onload

            inst.ornamentlighton = math.random() < 0.5
            inst.components.timer:StartTimer("blink", math.random() * BLINK_PERIOD)
        else
            inst:AddComponent("stackable")
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
        end

        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab("winter_ornament_" .. tostring(ornamentid), fn, assets)
end

local ornament = {
    MakeOrnament("boss_tigershark", "winter_ornamentboss", nil),
    MakeOrnament("boss_kraken", "winter_ornamentboss", nil),
    MakeOrnament("boss_kraken_tentacle", "winter_ornamentboss", nil),
    MakeOrnament("boss_twister", "winter_ornamentboss", nil),
    MakeOrnament("boss_doydoy", "winter_ornamentboss", nil)
}

return unpack(ornament)
