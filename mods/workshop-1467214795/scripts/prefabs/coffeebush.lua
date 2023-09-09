require("prefabutil")

local assets = {
    Asset("ANIM", "anim/coffeebush.zip"),
}

local rawassets = {
    Asset("ANIM", "anim/coffeebeans.zip"),
}

local cookedassets = {
    Asset("ANIM", "anim/coffeebeans.zip"),
}

local prefabs = {
    "coffeebeans",
    "dug_coffeebush",
    "twigs",
}

local rawprefabs = {
    "coffeebeans_cooked",
    "spoiled_food",
}

local function makeemptyfn(inst)
    if POPULATING then
        inst.AnimState:PlayAnimation("empty", true)
        inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())
    elseif inst:HasTag("withered") or inst.AnimState:IsCurrentAnimation("idle_dead") then
        inst.AnimState:PlayAnimation("dead_to_empty")
        inst.AnimState:PushAnimation("empty")
    else
        inst.AnimState:PlayAnimation("empty", true)
    end
end

local function makebarrenfn(inst)
    if not POPULATING and (inst:HasTag("withered") or inst.AnimState:IsCurrentAnimation("idle")) then
        inst.AnimState:PlayAnimation("empty_to_dead")
        inst.AnimState:PushAnimation("idle_dead", false)
    else
        inst.AnimState:PlayAnimation("idle_dead")
    end
end

local function pickanim(inst)
    if inst.components.pickable then
        if inst.components.pickable:CanBePicked() then
            local percent = 0
            if inst.components.pickable then
                percent = inst.components.pickable.cycles_left / inst.components.pickable.max_cycles
            end
            if percent >= .9 then
                return "berriesmost"
            elseif percent >= .33 then
                return "berriesmore"
            else
                return "berries"
            end
        else
            if inst.components.pickable:IsBarren() then
                return "idle_dead"
            else
                return "idle"
            end
        end
    end

    return "idle"
end


local function shake(inst)
    if inst.components.pickable and inst.components.pickable:CanBePicked() then
        inst.AnimState:PlayAnimation("shake")
    else
        inst.AnimState:PlayAnimation("shake_empty")
    end
    inst.AnimState:PushAnimation(pickanim(inst), false)
end

local function onpickedfn(inst, picker)
    if inst.components.pickable ~= nil then
        local old_percent = (inst.components.pickable.cycles_left+1) / inst.components.pickable.max_cycles

        if old_percent >= .9 then
            inst.AnimState:PlayAnimation("berriesmost_picked")
        elseif old_percent >= .33 then
            inst.AnimState:PlayAnimation("berriesmore_picked")
        else
            inst.AnimState:PlayAnimation("berries_picked")
        end

        if inst.components.pickable:IsBarren() then
            inst.AnimState:PushAnimation("empty_to_dead")
            inst.AnimState:PushAnimation("idle_dead", false)
        else
            inst.AnimState:PushAnimation("idle")
        end
    end
end

local function ongustpickfn(inst)
    if inst.components.pickable and inst.components.pickable:CanBePicked() then
        inst.components.pickable:MakeEmpty()
        local pt = inst:GetPosition()
        pt.y = pt.y + (inst.components.pickable.dropheight or 0)
        inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product, pt)
    end
end

local function getregentimefn(inst)
    local num_cycles_passed = math.max(0, inst.components.pickable.max_cycles - (inst.components.pickable.cycles_left or inst.components.pickable.max_cycles))
    return TUNING.BERRY_REGROW_TIME
        + TUNING.BERRY_REGROW_INCREASE * num_cycles_passed
        + TUNING.BERRY_REGROW_VARIANCE * math.random()
end

local function makefullfn(inst)
    local anim = "idle"
    local berries = nil
    if inst.components.pickable ~= nil then
        if inst.components.pickable:CanBePicked() then
            local percent = inst.components.pickable.cycles_left ~= nil and inst.components.pickable.cycles_left / inst.components.pickable.max_cycles or 1
            if percent >= .9 then
                anim = "berriesmost"
            elseif percent >= .33 then
                anim = "berriesmore"
            else
                anim = "berries"
            end
        elseif inst.components.pickable:IsBarren() then
            anim = "idle_dead"
        end
    end
    if anim == "idle_dead" then
        inst.AnimState:PlayAnimation(anim)
    elseif POPULATING then
        inst.AnimState:PlayAnimation(anim, true)
        inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())
    else
        inst.AnimState:PushAnimation(anim, true)
    end
end

local function digupcoffeebush(inst, chopper)
    if inst.components.pickable and inst.components.lootdropper then
        local withered = inst.components.witherable ~= nil and inst.components.witherable:IsWithered()

        if withered or inst.components.pickable:IsBarren() then
            inst.components.lootdropper:SpawnLootPrefab("twigs")
            inst.components.lootdropper:SpawnLootPrefab("twigs")
        else
            if inst.components.pickable and inst.components.pickable:CanBePicked() then
                local pt = inst:GetPosition()
                pt.y = pt.y + (inst.components.pickable.dropheight or 0)
                inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product, pt)
            end

            inst.components.lootdropper:SpawnLootPrefab("dug_"..inst.prefab)
        end
    end
    inst:Remove()
end

local function ontransplantfn(inst)
    inst.AnimState:PlayAnimation("idle_dead")
    inst.components.pickable:MakeBarren()
end

local function OnLoad(inst, data)
    -- just from world gen really
    if data and data.makebarren then
        makebarrenfn(inst)
        inst.components.pickable:MakeBarren()
    end
end

local function OnHaunt(inst)
    if math.random() <= TUNING.HAUNT_CHANCE_ALWAYS and not inst.AnimState:IsCurrentAnimation("idle_dead") then
        shake(inst)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_COOLDOWN_TINY
        return true
    else
        return false
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeSmallObstaclePhysics(inst, .1)

    inst.MiniMapEntity:SetIcon("coffeebush.tex")

    inst.AnimState:SetBank("coffeebush")
    inst.AnimState:SetBuild("coffeebush")
    inst.AnimState:PlayAnimation("berriesmost", false)

    inst:AddTag("plant")
    inst:AddTag("renewable")
    inst:AddTag("fire_proof")

    --witherable (from witherable component) added to pristine state for optimization
    inst:AddTag("witherable")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn
    inst.components.pickable.makebarrenfn = makebarrenfn
    inst.components.pickable.makefullfn = makefullfn
    inst.components.pickable.ontransplantfn = ontransplantfn

    inst.components.pickable:SetUp("coffeebeans", TUNING.BERRY_REGROW_TIME)
    inst.components.pickable.getregentimefn = getregentimefn
    inst.components.pickable.max_cycles = TUNING.BERRYBUSH_CYCLES + math.random(2)
    inst.components.pickable.cycles_left = inst.components.pickable.max_cycles

    inst:AddComponent("witherable")
    inst.components.witherable.volcanic = true

    AddHauntableCustomReaction(inst, OnHaunt, false, false, true)

    inst:AddComponent("lootdropper")

    if not GetGameModeProperty("disable_transplanting") then
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetOnFinishCallback(digupcoffeebush)
        inst.components.workable:SetWorkLeft(1)
    end

    inst:AddComponent("inspectable")

    inst:ListenForEvent("onwenthome", shake)
    MakeSnowCovered(inst)
    MakeNoGrowInWinter(inst)

    --[[
    inst:AddComponent("blowinwindgust")
    inst.components.blowinwindgust:SetWindSpeedThreshold(TUNING.BERRYBUSH_WINDBLOWN_SPEED)
    inst.components.blowinwindgust:SetDestroyChance(TUNING.BERRYBUSH_WINDBLOWN_FALL_CHANCE)
    inst.components.blowinwindgust:SetDestroyFn(ongustpickfn)
    inst.components.blowinwindgust:Start()
    --]]

    inst.OnLoad = OnLoad

    return inst
end

local function rawfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("coffeebeans")
    inst.AnimState:SetBuild("coffeebeans")
    inst.AnimState:PlayAnimation("idle")

    inst.pickupsound = "vegetation_firm"

    --cookable (from cookable component) added to pristine state for optimization
    inst:AddTag("cookable")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.edible.sanityvalue = 0
    inst.components.edible.foodtype = FOODTYPE.VEGGIE

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    ---------------------

    inst:AddComponent("bait")

    ------------------------------------------------
    inst:AddComponent("tradable")

    ------------------------------------------------

    inst:AddComponent("cookable")
    inst.components.cookable.product = "coffeebeans_cooked"

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

local function cookedfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("coffeebeans")
    inst.AnimState:SetBuild("coffeebeans")
    inst.AnimState:PlayAnimation("cooked")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("cooked_water", "cooked")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.edible.sanityvalue = -TUNING.SANITY_TINY
    inst.components.edible.foodtype = FOODTYPE.VEGGIE

    inst.components.edible.caffeinedelta = TUNING.CAFFEINE_FOOD_BONUS_SPEED
    inst.components.edible.caffeineduration = TUNING.FOOD_SPEED_AVERAGE

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    ---------------------

    inst:AddComponent("bait")

    ------------------------------------------------
    inst:AddComponent("tradable")

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

return Prefab("coffeebush", fn, assets, prefabs),
    Prefab("coffeebeans", rawfn, rawassets, rawprefabs),
    Prefab("coffeebeans_cooked", cookedfn, cookedassets)
