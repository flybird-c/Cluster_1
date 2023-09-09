local assets = {
    fish_tropical = {
        Asset("ANIM", "anim/fish2.zip"),
        Asset("ANIM", "anim/fish02.zip"),
    },
    purple_grouper = {
        Asset("ANIM", "anim/fish3.zip"),
    },
    pierrot_fish = {
        Asset("ANIM", "anim/fish4.zip"),
    },
    neon_quattro = {
        Asset("ANIM", "anim/fish5.zip"),
    },
}

local prefabs = {
    fish_tropical = {
        --"fish_cooked",
        --"spoiled_food",
       "fishmeat_small_cooked",
        "spoiled_fish_small",
    },
    purple_grouper = {
        --"spoiled_food",
        "spoiled_fish",
    },
    pierrot_fish = {
        --"spoiled_food",
        "spoiled_fish",
    },
    neon_quattro = {
        --"spoiled_food",
        "spoiled_fish",
    },
}

local function stopkicking(inst)
	if inst.components.floater then
		inst.components.floater:UpdateAnimations("idle_water", "dead")
	end
end

local function pristinefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("meat")
    inst:AddTag("catfood")
	inst:AddTag("packimfood")
    if IA_CONFIG.pondfishable then
        inst:AddTag("fishmeat")
    end

	return inst
end

local function masterfn(inst, bank_and_build)
    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
    inst.components.edible.foodtype = FOODTYPE.MEAT

--Not using the prefab name, or bools? -M
    if bank_and_build == "fish3" then
        inst.components.edible.surferdelta = TUNING.HYDRO_FOOD_BONUS_SURF
        inst.components.edible.surferduration = TUNING.FOOD_SPEED_AVERAGE
    end

    if bank_and_build == "fish4" then
        inst.components.edible.autodrydelta = TUNING.HYDRO_FOOD_BONUS_DRY
        inst.components.edible.autodryduration = TUNING.FOOD_SPEED_AVERAGE
    end

    if bank_and_build == "fish5" then
        inst.components.edible.autocooldelta = TUNING.HYDRO_FOOD_BONUS_COOL_RATE
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("bait")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()

    if bank_and_build == "fish2" then --i hate this but im too lazy to rewrite all this code -Half
        inst.components.perishable.onperishreplacement = "spoiled_fish_small"
    else
        inst.components.perishable.onperishreplacement = "spoiled_fish"
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
    inst.data = {}

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_TINY
end

local function rawfn(name, bank_and_build, rod, dryable, cookable)
    local inst = pristinefn()

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "dead")

    inst.AnimState:SetBank(bank_and_build)
    inst.AnimState:SetBuild(bank_and_build)
    inst.AnimState:PlayAnimation(name == "fish_tropical" and "idle" or "dead", true)

    if dryable then
        --dryable (from dryable component) added to pristine state for optimization
        inst:AddTag("dryable")
        inst:AddTag("lureplant_bait")
    end

    if not IA_CONFIG.pondfishable then
        inst:AddTag("fish")
        inst:AddTag("smalloceancreature")
    end

    if cookable ~= false then
        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
    end

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
	masterfn(inst, bank_and_build)

    if dryable then
        inst:AddComponent("dryable")
        inst.components.dryable:SetProduct(dryable)
        inst.components.dryable:SetBuildFile("meat_rack_food_sw")
        inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
    end

    if cookable ~= false then
        inst:AddComponent("cookable")
        inst.components.cookable.product = cookable or name .."_cooked"
    end
	
    inst.build = rod --This is used within SGwilson, sent from an event in fishingrod.lua

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    if name == "fish_tropical" then --fish_tropical is unused now, except for that pre rot pondfish config
        inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
    else
        inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    end

    if name == "fish_tropical" then --fish_tropical is unused now, except for that pre rot pondfish config
        inst:DoTaskInTime(5, stopkicking)
        inst.components.inventoryitem:SetOnPickupFn(stopkicking)
        inst.OnLoad = stopkicking
    end


    return inst
end

local function cookedfn(bank_and_build, rod)
    local inst = pristinefn()

    inst.AnimState:SetBank(bank_and_build)
    inst.AnimState:SetBuild(bank_and_build)
    inst.AnimState:PlayAnimation("cooked")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("cooked_water", "cooked")

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	masterfn(inst, bank_and_build)

    inst.build = rod --This is used within SGwilson, sent from an event in fishingrod.lua

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)


    return inst
end

local function makefish(name, bank_and_build, rod, dryable, cookable)
    local function makerawfn()
        return rawfn(name, bank_and_build, rod, dryable, cookable)
    end

    local function makecookedfn()
        return cookedfn(bank_and_build, rod)
    end

    return makerawfn, makecookedfn
end

local prefabs = {}

local function fish(name, bank_and_build, rod, dryable, cookable)
    local raw, cooked = makefish(name, bank_and_build, rod, dryable, cookable)

    table.insert(prefabs, Prefab(name, raw, assets[name], prefabs[name]))
    if cookable == nil then
        table.insert(prefabs, Prefab(name.."_cooked", cooked, assets[name], prefabs[name]))
    end
end

fish("fish_tropical", "fish2", "fish02", "smallmeat_dried", "fishmeat_small_cooked")
fish("purple_grouper", "fish3")
fish("pierrot_fish", "fish4")
fish("neon_quattro", "fish5")

return unpack(prefabs)
