local assets = {
	Asset("ANIM", "anim/roe.zip"),
}

local function pickproduct(inst)
	local total_w = 0

	for k, v in pairs(FISH_FARM.SEEDWEIGHT) do
		total_w = total_w + v
	end

	local rnd = math.random(total_w)
	for k, v in pairs(FISH_FARM.SEEDWEIGHT) do        
		rnd = rnd - v
        if rnd <= 0 then
            return k
        end                
	end
	
	return "pondfish_tropical"
end


local function common()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    
    MakeInventoryPhysics(inst)
    
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)
    
    inst.AnimState:SetBank("roe")
    inst.AnimState:SetBuild("roe")
    inst.AnimState:SetRayTestOnBB(true)

	MakeInventoryFloatable(inst)

	return inst
end
local function masterfn(inst)
	
    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.MEAT
    inst:AddTag("spawnnosharx")

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
	inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD

    inst:AddComponent("inspectable")

	MakeHauntableLaunchAndPerish(inst)
    
    inst:AddComponent("inventoryitem")
    
	inst:AddComponent("perishable")
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
    
    return inst
end

local function raw()
    local inst = common()
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("roe")

	inst.components.floater:UpdateAnimations("idle_water", "idle")

	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	
	masterfn(inst)
	

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/2
    
    inst:AddComponent("cookable")
    inst.components.cookable.product = "roe_cooked"

	inst:AddComponent("bait")
	
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
	
    inst:AddComponent("seedable")
    inst.components.seedable.growtime = TUNING.SEEDS_GROW_TIME
    inst.components.seedable.product = pickproduct
    
    return inst
end

local function cooked()
    local inst = common()
    inst.AnimState:PlayAnimation("cooked")

	inst.components.floater:UpdateAnimations("cooked_water", "cooked")

	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end
	
	masterfn(inst)

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/2
    inst.components.edible.foodstate = FOODSTATE.COOKED
	
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    
    return inst
end

return Prefab("roe", raw, assets),
	Prefab("roe_cooked", cooked, assets)              
