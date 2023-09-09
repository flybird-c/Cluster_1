local assets=
{
	Asset("ANIM", "anim/doydoy_nest.zip"),
}

local prefabs = 
{
	"spoiled_food",
}

local function commonfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddAnimState()
    -- inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst.AnimState:SetBank("doydoy_nest")
	inst.AnimState:SetBuild("doydoy_nest")

	MakeInventoryPhysics(inst)

    inst:AddTag("cattoy")
    inst:AddTag("doydoyegg")
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	MakeHauntableLaunchAndPerish(inst)
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetSinks(true)
	
	inst:AddComponent("edible")
	inst.components.edible.foodtype = FOODTYPE.MEAT

	inst:AddComponent("perishable")
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
	
	return inst
end


local function defaultfn()
	local inst = commonfn()

	inst.AnimState:PlayAnimation("idle_egg")

	if not TheWorld.ismastersim then
		return inst
	end
	
	inst.components.inventoryitem.imagename = "doydoyegg"

	inst.components.edible.healthvalue = TUNING.HEALING_SMALL
	inst.components.edible.hungervalue = TUNING.CALORIES_MED

	inst:AddComponent("cookable")
	inst.components.cookable.product = "doydoyegg_cooked"

	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	inst.components.perishable:StartPerishing()

	inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_MEDIUM

	return inst
end

local function cookedfn()
	local inst = commonfn()
	
	inst.AnimState:PlayAnimation("cooked")
	
	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("stackable")

	inst.components.edible.foodstate = "COOKED"
	inst.components.edible.healthvalue = 0
	inst.components.edible.hungervalue = TUNING.CALORIES_LARGE

	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	
	return inst
end

return Prefab( "doydoyegg", defaultfn, assets, prefabs),
	Prefab( "doydoyegg_cooked", cookedfn, assets, prefabs) 
