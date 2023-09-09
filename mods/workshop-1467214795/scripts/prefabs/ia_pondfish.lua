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
        "fishmeat_small",
        "fishmeat_small_cooked",
        --"spoiled_fish",
        --"fish_tropical",
    },
    purple_grouper = {
        --"spoiled_food",,
        "purple_grouper",
    },
    pierrot_fish = {
        --"spoiled_food",
        "pierrot_fish",
    },
    neon_quattro = {
        --"spoiled_food",
        "neon_quattro",
    },
}

local function CalcNewSize()
	local p = 2 * math.random() - 1
	return (p*p*p + 1) * 0.5
end

local function flop(inst)
	local num = math.random(2)
	for i = 1, num do
		inst.AnimState:PushAnimation("idle", false)
	end

	inst.flop_task = inst:DoTaskInTime(math.random() * 2 + num * 2, flop)
end

local function ondropped(inst)
    if inst.flop_task ~= nil then
        inst.flop_task:Cancel()
    end
	inst.AnimState:PlayAnimation("idle", false)
    inst.flop_task = inst:DoTaskInTime(math.random() * 3, flop)
end

local function ondroppedasloot(inst, data)
	if data ~= nil and data.dropper ~= nil then
		inst.components.weighable.prefab_override_owner = data.dropper.prefab
	end
end

local function onpickup(inst)
    if inst.flop_task ~= nil then
        inst.flop_task:Cancel()
        inst.flop_task = nil
    end
end

local function commonfn(bank, build, char_anim_build, data)
    local inst = CreateEntity()

	data = data or {}

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle", false)

	inst:AddTag("fish")
    inst:AddTag("pondfish")
    inst:AddTag("meat")
    inst:AddTag("catfood")
	inst:AddTag("smallcreature")
    inst:AddTag("packimfood")
    if not data.freshwater then --unused atm
        inst:AddTag("smalloceancreature") --unlike normal pondfish these are saltwater they should be able to go into fish bins
    end

	if data.weight_min ~= nil and data.weight_max ~= nil then
		--weighable_fish (from weighable component) added to pristine state for optimization
		inst:AddTag("weighable_fish")
	end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.build = char_anim_build --This is used within SGwilson, sent from an event in fishingrod.lua

    inst:AddComponent("bait")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(data.perish_time)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = data.perish_product
	inst.components.perishable.ignorewentness = true

    inst:AddComponent("cookable")
    inst.components.cookable.product = data.cookable_product

    if data.quote_name then
        inst:AddComponent("inspectable")
        inst.components.inspectable.nameoverride = data.quote_name
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(onpickup)
	inst.components.inventoryitem:SetSinks(true)

	inst:AddComponent("murderable")

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot(data.loot)

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
	inst.components.edible.healthvalue = data.healthvalue
	inst.components.edible.hungervalue = data.hungervalue
	inst.components.edible.sanityvalue = 0
    inst.components.edible.foodtype = FOODTYPE.MEAT

    if data.edible ~= nil and type(data.edible) == "table" then
        for name,value in pairs(data.edible) do
            inst.components.edible[name] = value
        end
    end

    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = data.goldvalue or TUNING.GOLD_VALUES.MEAT
    inst.data = {}--

    if data.dubloonvalue then
		inst.components.tradable.dubloonvalue = data.dubloonvalue
	end
		
	inst:AddComponent("appeasement")
    if data.appeasementvalue then
	    inst.components.appeasement.appeasementvalue = data.appeasementvalue
    end

	if data.weight_min ~= nil and data.weight_max ~= nil then
		inst:AddComponent("weighable")
		inst.components.weighable.type = TROPHYSCALE_TYPES.FISH
		inst.components.weighable:Initialize(data.weight_min, data.weight_max)
		inst.components.weighable:SetWeight(Lerp(data.weight_min, data.weight_max, CalcNewSize()))
	end

	inst:ListenForEvent("on_loot_dropped", ondroppedasloot)

	inst.flop_task = inst:DoTaskInTime(math.random() * 2 + 1, flop)

    return inst
end

local MakePreRotFish = not IA_CONFIG.pondfishable and function(fishprefab)
    local inst = Prefabs[fishprefab].fn()

    inst.realprefab = "pond"..fishprefab
    inst:SetPrefabName(fishprefab)

    return inst
end

local pond = {
    fish_tropical_data =
    {
        weight_min = 38.37,
        weight_max = 52.64,
        perish_product = "fishmeat_small",
        loot = { "fishmeat_small" },
        cookable_product = "fishmeat_small_cooked",
        healthvalue = TUNING.HEALING_TINY,
        hungervalue = TUNING.CALORIES_SMALL,
        perish_time = TUNING.PERISH_SUPERFAST,
        goldvalue = TUNING.GOLD_VALUES.MEAT,
        dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD,
        appeasementvalue = TUNING.APPEASEMENT_TINY,
        quote_name = "fish_tropical",
    },

    purple_grouper_data =
    {
        weight_min = 57.34,
        weight_max = 70.78,
        perish_product = "purple_grouper",
        loot = { "purple_grouper" },
        cookable_product = "purple_grouper_cooked",
        healthvalue = TUNING.HEALING_TINY,
        hungervalue = TUNING.CALORIES_SMALL,
        perish_time = TUNING.PERISH_MED,
        goldvalue = TUNING.GOLD_VALUES.MEAT,
        dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD,
        appeasementvalue = TUNING.APPEASEMENT_TINY,
        quote_name = "purple_grouper",
        edible = {
            surferdelta = TUNING.HYDRO_FOOD_BONUS_SURF,
            surferduration  = TUNING.FOOD_SPEED_AVERAGE,
        },
    },

    pierrot_fish_data =
    {
        weight_min = 34.42,
        weight_max = 53.80,
        perish_product = "pierrot_fish",
        loot = { "pierrot_fish" },
        cookable_product = "pierrot_fish_cooked",
        healthvalue = TUNING.HEALING_TINY,
        hungervalue = TUNING.CALORIES_SMALL,
        perish_time = TUNING.PERISH_MED,
        goldvalue = TUNING.GOLD_VALUES.MEAT,
        dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD,
        appeasementvalue = TUNING.APPEASEMENT_TINY,
        quote_name = "pierrot_fish",
        edible = {
            autodrydelta = TUNING.HYDRO_FOOD_BONUS_DRY,
            autodryduration = TUNING.FOOD_SPEED_AVERAGE,
        },
    },

    neon_quattro_data =
    {
        weight_min = 40.65,
        weight_max = 55.14,
        perish_product = "neon_quattro",
        loot = { "neon_quattro" },
        cookable_product = "neon_quattro_cooked",
        healthvalue = TUNING.HEALING_TINY,
        hungervalue = TUNING.CALORIES_SMALL,
        perish_time = TUNING.PERISH_MED,
        goldvalue = TUNING.GOLD_VALUES.MEAT,
        dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD,
        appeasementvalue = TUNING.APPEASEMENT_TINY,
        quote_name = "neon_quattro",
        edible = {
            autocooldelta = TUNING.HYDRO_FOOD_BONUS_COOL_RATE,
        },
    },
}

local function pondfish_tropicalfn()
    if MakePreRotFish then return MakePreRotFish("fish_tropical") end
	return commonfn("fish2", "fish2", "fish02", pond.fish_tropical_data)
end

local function pondpurple_grouperfn()
    if MakePreRotFish then return MakePreRotFish("purple_grouper") end
	return commonfn("fish3", "fish3", nil, pond.purple_grouper_data)
end

local function pondpierrot_fishfn()
    if MakePreRotFish then return MakePreRotFish("pierrot_fish") end
	return commonfn("fish4", "fish4", nil, pond.pierrot_fish_data)
end

local function pondneon_quattrofn()
    if MakePreRotFish then return MakePreRotFish("neon_quattro") end
	return commonfn("fish5", "fish5", nil, pond.neon_quattro_data)
end


return Prefab("pondfish_tropical", pondfish_tropicalfn, assets.fish_tropical, prefabs.fish_tropical),
	Prefab("pondpurple_grouper", pondpurple_grouperfn, assets.purple_grouper, prefabs.purple_grouper),
    Prefab("pondpierrot_fish", pondpierrot_fishfn, assets.pierrot_fish, prefabs.pierrot_fish),
    Prefab("pondneon_quattro", pondneon_quattrofn, assets.neon_quattro, prefabs.neon_quattro)
