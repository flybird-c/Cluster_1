local assets =
{
	Asset("ANIM", "anim/jellyfish.zip"),
	Asset("ANIM", "anim/meat_rack_food_sw.zip"),

	Asset("ANIM", "anim/scale_o_matic_jellyfish.zip"),
}

local function CalcNewSize()
	return math.random()
end

local function PlayShockAnim(inst)
    if inst.components.floater and inst.components.floater:IsFloating() then
        inst.AnimState:PlayAnimation("idle_water_shock")
        inst.AnimState:PushAnimation("idle_water", true)
        inst.SoundEmitter:PlaySound("ia/creatures/jellyfish/electric_water")
    else
        inst.AnimState:PlayAnimation("idle_ground_shock")
        inst.AnimState:PushAnimation("idle_ground", true)
        inst.SoundEmitter:PlaySound("ia/creatures/jellyfish/electric_water")
    end
end

local function PlayDeadAnim(inst)
    inst.AnimState:PlayAnimation("death_ground", true)
    inst.AnimState:PushAnimation("idle_ground", true)
end

local function OnDropped(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local onwater = TheWorld.Map:IsPassableAtPoint(x, y, z)
    local replacement = SpawnPrefab(onwater and "jellyfish_dead" or "jellyfish_planted")
    replacement.Transform:SetPosition(x, y, z)
    inst:Remove()
    if onwater then
        replacement.AnimState:PlayAnimation("stunned_loop", true)
        replacement:DoTaskInTime(2.5, PlayDeadAnim)
        replacement.shocktask = replacement:DoPeriodicTask(math.random() * 10 + 5, PlayShockAnim)
        replacement:AddTag("stinger")
    end
end

local function OnDroppedDead(inst)
    inst:AddTag("stinger")
    inst.shocktask = inst:DoPeriodicTask(math.random() * 10 + 5, PlayShockAnim)
    inst.AnimState:PlayAnimation("idle_ground", true)
end

local function OnPickup(inst, guy)
    if inst:HasTag("stinger") and guy.components.combat and guy.components.inventory and not guy:HasTag("shadowminion") then
        if not guy.components.inventory:IsInsulated() then
            guy.components.health:DoDelta(-TUNING.JELLYFISH_DAMAGE, nil, inst.prefab, nil, inst)
            guy.sg:GoToState("electrocute")
        end

        inst:RemoveTag("stinger")
    end

    if inst.shocktask then
        inst.shocktask:Cancel()
        inst.shocktask = nil
    end
end

local function commonfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("jellyfish")
    inst.AnimState:SetBuild("jellyfish")

    inst:AddTag("jellyfish")

    inst.AnimState:SetRayTestOnBB(true)

    MakeInventoryPhysics(inst)

    return inst
end

local function masterfn(inst)

    inst:AddComponent("inventoryitem")

    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD

    return inst
end

local function default()
    local inst = commonfn()

    inst.AnimState:PlayAnimation("idle_ground", true)

    inst:AddTag("show_spoilage")
    inst:AddTag("cookable")
    inst:AddTag("small_livestock") -- "hungry" instead of "stale"
    inst:AddTag("fish")
    inst:AddTag("smalloceancreature")

    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle_ground")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

	inst:AddComponent("edible") --mermking and merm code is stupid
    inst.components.edible.foodtype = nil

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_ONE_DAY * 1.5)
    inst.components.perishable.onperishreplacement = "jellyfish_dead"
    inst.components.perishable:StartPerishing()

	inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
	inst.components.inventoryitem:SetOnPickupFn(OnPickup)

    inst:ListenForEvent("on_landed", OnDropped)

	inst:AddComponent("cookable")
	inst.components.cookable.product = "jellyfish_cooked"

	inst:AddComponent("health")
	inst.components.health.murdersound = "ia/creatures/jellyfish/death_murder"

    inst:AddComponent("murderable")

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"jellyfish_dead"})

    MakeHauntableLaunchAndPerish(inst)

	inst:AddComponent("weighable")
	inst.components.weighable.type = TROPHYSCALE_TYPES.FISH
	inst.components.weighable:Initialize(TUNING.IA_WEIGHTS.JELLYFISH.min, TUNING.IA_WEIGHTS.JELLYFISH.max)
	inst.components.weighable:SetWeight(Lerp(TUNING.IA_WEIGHTS.JELLYFISH.min, TUNING.IA_WEIGHTS.JELLYFISH.max, CalcNewSize()))

    return inst
end

local function dead()
    local inst = commonfn()

    inst.AnimState:PlayAnimation("idle_ground")

    inst:AddTag("fishmeat")

    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle_ground")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.MEAT
    inst.components.edible.foodstate = "COOKED"

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable.onperishreplacement = "spoiled_food"
    inst.components.perishable:StartPerishing()

    inst.components.inventoryitem:SetOnDroppedFn(OnDroppedDead)
    inst.components.inventoryitem:SetOnPickupFn(OnPickup)

    inst:AddComponent("cookable")
    inst.components.cookable.product = "jellyfish_cooked"

    inst:AddComponent("dryable")
    inst.components.dryable:SetProduct("jellyjerky")
    inst.components.dryable:SetBuildFile("meat_rack_food_sw")
    inst.components.dryable:SetDryTime(TUNING.DRY_FAST)

	MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    return inst
end

local function cooked()
    local inst = commonfn()

    inst:AddTag("fishmeat")

    inst.AnimState:PlayAnimation("cooked")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.MEAT
    inst.components.edible.foodstate = "COOKED"
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable.onperishreplacement = "spoiled_food"
    inst.components.perishable:StartPerishing()

    MakeHauntableLaunchAndPerish(inst)

    inst.components.inventoryitem.sinks = true

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    return inst
end

local function dried()
    local inst = commonfn()
    inst:AddTag("show_spoilage")

    inst.AnimState:SetBank("meat_rack_food")
    inst.AnimState:SetBuild("meat_rack_food_sw")
    inst.AnimState:PlayAnimation("idle_dried_jellyjerky")

    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_dried_jellywater", "idle_dried_jellyjerky")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.MEAT
    inst.components.edible.foodstate = "DRIED"
    inst.components.edible.hungervalue = TUNING.CALORIES_MED
    inst.components.edible.sanityvalue = TUNING.SANITY_MEDLARGE

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
    inst.components.perishable.onperishreplacement = "spoiled_food"
    inst.components.perishable:StartPerishing()

	MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    return inst
end

return Prefab("jellyfish", default, assets),
    Prefab("jellyfish_dead", dead, assets),
    Prefab("jellyfish_cooked", cooked, assets),
    Prefab("jellyjerky", dried, assets)
