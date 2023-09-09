local assets=
{
  	Asset("ANIM", "anim/rainbowjellyfish.zip"),
  	Asset("ANIM", "anim/meat_rack_food.zip"),
	
	Asset("ANIM", "anim/scale_o_matic_rainbowjellyfish.zip"),
}

local function CalcNewSize()
	return math.random()
end

local function PlayDeadAnim(inst)
  	inst.AnimState:PlayAnimation("death_ground", true)
  	inst.AnimState:PushAnimation("idle_ground", true)
end

local function OnDropped(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
    local onwater = TheWorld.Map:IsPassableAtPoint(x, y, z)
    local replacement = SpawnPrefab(onwater and "rainbowjellyfish_dead" or "rainbowjellyfish_planted")
    replacement.Transform:SetPosition(x, y, z)
    inst:Remove()
    if onwater then
        replacement.AnimState:PlayAnimation("stunned_loop", true)
        replacement:DoTaskInTime(2.5, PlayDeadAnim)
    end
end

local function oneaten_light(inst, eater)
    if eater.rainbowjellylight and eater.rainbowjellylight:IsValid() then
        eater.rainbowjellylight.components.spell.lifetime = 0
        eater.rainbowjellylight.components.spell:ResumeSpell()
    else
        local light = SpawnPrefab("rainbowjellylight")

        light.components.spell:SetTarget(eater)
		if light:IsValid() then
			if not light.components.spell.target then
				light:Remove()
			else
				light.components.spell:StartSpell()
			end
		end
    end
end

local function commonfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.Transform:SetScale(0.8, 0.8, 0.8)

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("rainbowjellyfish")
	inst.AnimState:SetBuild("rainbowjellyfish")

	inst:AddTag("jellyfish")

	inst.AnimState:SetRayTestOnBB(true)

	inst._startspell = net_event(inst.GUID, "rainbowjellyfish._startspell")

	return inst
end

local function masterfn(inst)
    inst:AddComponent("inventoryitem")

    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
	inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
end

local function defaultfn()

	local inst = commonfn()

    inst.AnimState:PlayAnimation("idle_ground", true)

    inst:AddTag("show_spoilage")
	inst:AddTag("cookable")
    inst:AddTag("small_livestock") -- "hungry" instead of "stale"
    inst:AddTag("fish")
    inst:AddTag("smalloceancreature")
	inst:AddTag("lightbattery")

	MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle_ground")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

    masterfn(inst)

	inst:AddComponent("edible") --mermking and merm code is stupid
    inst.components.edible.foodtype = "NONE"

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_ONE_DAY * 1.5)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "rainbowjellyfish_dead"

	inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

	inst:ListenForEvent("on_landed", OnDropped)

	inst:AddComponent("cookable")
	inst.components.cookable.product = "rainbowjellyfish_cooked"

	inst:AddComponent("health")
	inst.components.health.murdersound = "ia/creatures/jellyfish/death_murder"

	inst:AddComponent("murderable")
	
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"rainbowjellyfish_dead"})
	
	MakeHauntableLaunchAndPerish(inst)
	
	inst:AddComponent("weighable")
	inst.components.weighable.type = TROPHYSCALE_TYPES.FISH
	inst.components.weighable:Initialize(TUNING.IA_WEIGHTS.RAINBOWJELLYFISH.min, TUNING.IA_WEIGHTS.RAINBOWJELLYFISH.max)
	inst.components.weighable:SetWeight(Lerp(TUNING.IA_WEIGHTS.RAINBOWJELLYFISH.min, TUNING.IA_WEIGHTS.RAINBOWJELLYFISH.max, CalcNewSize()))

	return inst

end

local function deadfn()
	local inst = commonfn()

	inst:AddTag("fishmeat")

	inst.Transform:SetScale(0.7, 0.7, 0.7)

	--TODO this looks very nonsensical, besides serving no clear purpose (never triggers) -M
	inst:ListenForEvent("rainbowjellyfish._startspell", function(inst)
		oneaten_light(nil, inst)
	end)

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle_ground")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	masterfn(inst)

	inst:AddComponent("edible")
	inst.components.edible.foodtype = "MEAT"
	inst.components.edible:SetOnEatenFn(oneaten_light)

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst.AnimState:PlayAnimation("idle_ground", true)

	inst:AddComponent("cookable")
	inst.components.cookable.product = "rainbowjellyfish_cooked"

	inst:AddComponent("dryable")
	inst.components.dryable:SetProduct("jellyjerky")
	inst.components.dryable:SetBuildFile("meat_rack_food_sw")
	inst.components.dryable:SetDryTime(TUNING.DRY_FAST)

	MakeHauntableLaunchAndPerish(inst)

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

	return inst
end


local function cookedfn()
	local inst = commonfn()

	inst:AddTag("fishmeat")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	masterfn(inst)

	inst:AddComponent("edible")
	inst.components.edible.foodtype = "MEAT"
	inst.components.edible.foodstate = "COOKED"
	inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
	inst.components.edible.sanityvalue = 0

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst.components.inventoryitem.sinks = true --I checked sw they sink -Half

	MakeHauntableLaunchAndPerish(inst)

	inst.AnimState:PlayAnimation("cooked", true)
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM
	return inst
end

return Prefab( "rainbowjellyfish", defaultfn, assets),
Prefab( "rainbowjellyfish_dead", deadfn, assets),
Prefab( "rainbowjellyfish_cooked", cookedfn, assets)
