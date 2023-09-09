local dogfish_assets=
{
  Asset("ANIM", "anim/fish_dogfish.zip"),
}

local swordfish_assets=
{
  Asset("ANIM", "anim/fish_swordfish.zip"), 	
}
--[[
local spoiledfish_assets = 
{
  Asset("ANIM", "anim/spoiled_fish.zip")
}

local cooked_assets = 
{
  Asset("ANIM", "anim/fish_med_cooked.zip")
}

local raw_assets = 
{
  Asset("ANIM", "anim/fish_raw.zip")
}

local small_assets =
{
  Asset("ANIM", "anim/fish_meat_small.zip")
}
--]]
local lobster_assets =
{
  Asset("ANIM", "anim/ia_lobster_build_color.zip"),
  Asset("ANIM", "anim/ia_lobster.zip"),
}

local prefabs =
{
  "fishmeat_cooked",
  "spoiled_fish_large",
  "spoiled_fish",
}
--[[
SetSharedLootTable( 'spoiledfish',
  {
    {'boneshard',    1.00},
    {'boneshard',    1.00},
  })
--]]

local function stopkicking(inst)
  inst.AnimState:PlayAnimation("dead")
end


local function makefish_med(bank, build, dryablesymbol)

  local function commonfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.entity:AddAnimState()
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("dead")
    inst.build = build --This is used within SGwilson, sent from an event in fishingrod.lua

    inst:AddTag("catfood")
    inst:AddTag("fishmeat")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "dead")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
      return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
    inst.components.edible.foodtype = "MEAT"
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_MED

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_fish_large"

    inst:AddComponent("inspectable")

    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("inventoryitem")

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
    inst.data = {}

    inst:AddComponent("cookable")
    inst.components.cookable.product = "fishmeat_cooked"

    inst:AddComponent("dryable")
    inst.components.dryable:SetProduct("meat_dried")
    inst.components.dryable:SetBuildFile("meat_rack_food_sw")
    inst.components.dryable:SetDryTime(TUNING.DRY_FAST)

    inst:AddTag("spoiledbypackim")
    inst:AddTag("meat")

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL

    return inst
  end

  return commonfn
end

local function onspoiledhammered(inst, worker)
  local to_hammer = (inst.components.stackable and inst.components.stackable:Get(1)) or inst
  if to_hammer == inst then
    to_hammer.components.inventoryitem:RemoveFromOwner(true)
  end
  if to_hammer:IsInLimbo() then
    to_hammer:ReturnToScene()
  end

  to_hammer.Transform:SetPosition(inst:GetPosition():Get())
  to_hammer.components.lootdropper:DropLoot()
  SpawnPrefab("collapse_small").Transform:SetPosition(to_hammer.Transform:GetWorldPosition())
  to_hammer.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")

  inst.components.workable:SetWorkLeft(1)

  to_hammer:Remove()
end
--[[
local function spoiledfn()

    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.entity:AddAnimState()
    inst.AnimState:SetBank("spoiled_fish")
    inst.AnimState:SetBuild("spoiled_fish")
    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:AddSoundEmitter()

    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle")

    inst:AddTag("spoiled_fish")
        
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onspoiledhammered)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"boneshard", "boneshard"})

    
    -- inst:RemoveComponent("appeasement")

    return inst

end 

local function cookedfn()
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddNetwork()

  MakeInventoryPhysics(inst)

  inst.entity:AddAnimState()
  inst.AnimState:SetBank("fish_med_cooked")
  inst.AnimState:SetBuild("fish_med_cooked")
  inst.AnimState:PlayAnimation("cooked", true)

  inst:AddTag("meat")
  inst:AddTag("fishmeat")
  inst:AddTag("catfood")
  inst:AddTag("packimfood")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_cooked_water", "cooked")
	
  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  inst:AddComponent("edible")
  inst.components.edible.ismeat = true
  inst.components.edible.foodtype = "MEAT"
  inst.components.edible.foodstate = "COOKED"
  inst.components.edible.healthvalue = TUNING.HEALING_MED
  inst.components.edible.hungervalue = TUNING.CALORIES_MED

  inst:AddComponent("stackable")
  inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

  inst:AddComponent("perishable")
  inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
  inst.components.perishable:StartPerishing()
  inst.components.perishable.onperishreplacement = "spoiled_food" 

  inst:AddComponent("inspectable")

  inst:AddComponent("inventoryitem")

  inst:AddComponent("tradable")
  inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
  inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
  inst.data = {}
  inst:AddComponent("bait")

  return inst
end

local function fish_raw_fn()
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddNetwork()

  MakeInventoryPhysics(inst)

  inst.entity:AddAnimState()
  inst.AnimState:SetBank("fish_raw")
  inst.AnimState:SetBuild("fish_raw")
  inst.AnimState:PlayAnimation("idle")

  inst:AddTag("meat")
  inst:AddTag("fishmeat")
  inst:AddTag("catfood")
  inst:AddTag("packimfood")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")
	
  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  inst:AddComponent("edible")
  inst.components.edible.ismeat = true
  inst.components.edible.foodtype = "MEAT"

  inst:AddComponent("stackable")
  inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

  inst:AddComponent("perishable")
  inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
  inst.components.perishable:StartPerishing()
  inst.components.perishable.onperishreplacement = "spoiled_food"

  inst:AddComponent("inspectable")

  inst:AddComponent("inventoryitem")

  inst:AddComponent("tradable")
  inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
  inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
  inst.data = {}

  inst:AddComponent("appeasement")
  inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL

  inst.components.edible.healthvalue = TUNING.HEALING_TINY
  inst.components.edible.hungervalue = TUNING.CALORIES_MED

  inst:AddComponent("cookable")
  inst.components.cookable.product = "fishmeat_cooked"
  inst:AddComponent("dryable")
  inst.components.dryable:SetProduct("meat_dried")
  inst.components.dryable:SetBuildFile("meat_rack_food_sw")
  inst.components.dryable:SetDryTime(TUNING.DRY_FAST)

  inst:AddComponent("bait")

  return inst
end

local function fish_raw_small_fn()
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddNetwork()

  MakeInventoryPhysics(inst)

  inst.entity:AddAnimState()
  inst.AnimState:SetBank("fish_meat_small")
  inst.AnimState:SetBuild("fish_meat_small")
  inst.AnimState:PlayAnimation("raw")

  inst:AddTag("meat")
  inst:AddTag("fishmeat")
  inst:AddTag("catfood")
  inst:AddTag("packimfood")
  inst:AddTag("smalloceancreature")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("raw_water", "raw")
	
  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  inst:AddComponent("edible")
  inst.components.edible.ismeat = true
  inst.components.edible.foodtype = "MEAT"

  inst:AddComponent("stackable")
  inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

  inst:AddComponent("perishable")
  inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
  inst.components.perishable:StartPerishing()
  inst.components.perishable.onperishreplacement = "spoiled_food"

  inst:AddComponent("inspectable")

  inst:AddComponent("inventoryitem")

  inst:AddComponent("tradable")
  inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
  inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
  inst.data = {}

  inst:AddComponent("appeasement")
  inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL

  inst.components.edible.healthvalue = TUNING.HEALING_TINY
  inst.components.edible.hungervalue = TUNING.CALORIES_SMALL

  inst:AddComponent("cookable")
  inst.components.cookable.product = "fish_small_cooked"

  inst:AddComponent("dryable")
  inst.components.dryable:SetProduct("smallmeat_dried")
  inst.components.dryable:SetBuildFile("meat_rack_food_sw")
  inst.components.dryable:SetDryTime(TUNING.DRY_FAST)

  inst:AddComponent("bait")

  return inst
end

local function fish_raw_small_cooked_fn()
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddNetwork()

  MakeInventoryPhysics(inst)

  inst.entity:AddAnimState()
  inst.AnimState:SetBank("fish_meat_small")
  inst.AnimState:SetBuild("fish_meat_small")
  inst.AnimState:PlayAnimation("cooked", true)

  inst:AddTag("meat")
  inst:AddTag("fishmeat")
  inst:AddTag("catfood")
  inst:AddTag("packimfood")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_cooked_water", "cooked")
	
  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  inst:AddComponent("edible")
  inst.components.edible.ismeat = true
  inst.components.edible.foodtype = "MEAT"
  inst.components.edible.foodstate = "COOKED"
  inst.components.edible.healthvalue = TUNING.HEALING_TINY
  inst.components.edible.hungervalue = TUNING.CALORIES_SMALL

  inst:AddComponent("stackable")
  inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

  inst:AddComponent("perishable")
  inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
  inst.components.perishable:StartPerishing()
  inst.components.perishable.onperishreplacement = "spoiled_food" 

  inst:AddComponent("inspectable")

  inst:AddComponent("inventoryitem")

  inst:AddComponent("tradable")
  inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
  inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
  inst.data = {}
  inst:AddComponent("bait")

  return inst
end
--]]
local function lobster_dead_fn()
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddNetwork()

  inst.AnimState:SetBank("ia_lobster")
  inst.AnimState:SetBuild("lobster_build_color")
  inst.AnimState:PlayAnimation("idle_dead")

  MakeInventoryPhysics(inst)

  inst:AddTag("meat")
  inst:AddTag("fishmeat")
  inst:AddTag("catfood")
  inst:AddTag("packimfood")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_dead_water", "idle_dead")
	
  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  inst:AddComponent("inspectable")

  MakeHauntableLaunchAndPerish(inst)

  inst:AddComponent("perishable")
  inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
  inst.components.perishable:StartPerishing()
  inst.components.perishable.onperishreplacement = "spoiled_fish"

  inst:AddComponent("inventoryitem")

  inst:AddComponent("stackable")
  inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

  inst:AddComponent("edible")
  inst.components.edible.ismeat = true
  inst.components.edible.foodtype = "MEAT"
  inst.components.edible.healthvalue = TUNING.HEALING_TINY
  inst.components.edible.hungervalue = TUNING.CALORIES_SMALL

  inst:AddComponent("cookable")
  inst.components.cookable.product = "lobster_dead_cooked"

  inst:AddComponent("tradable")
  inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
  inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD

  return inst
end

local function lobster_dead_cooked_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("ia_lobster")
    inst.AnimState:SetBuild("lobster_build_color")
    inst.AnimState:PlayAnimation("idle_cooked")

    MakeInventoryPhysics(inst)

    inst:AddTag("meat")
    inst:AddTag("fishmeat")
    inst:AddTag("catfood")
    inst:AddTag("packimfood")

    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_cooked", "idle_cooked")
        
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_fish"

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
    inst.components.edible.foodtype = "MEAT"
    inst.components.edible.foodstate = "COOKED"
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD

    return inst
end

local rawmed = makefish_med("dogfish", "fish_dogfish", "dogfish")
local rawsword = makefish_med("swordfish", "fish_swordfish", "swordfish")

return Prefab( "solofish_dead", rawmed, dogfish_assets, prefabs),
Prefab( "swordfish_dead", rawsword, swordfish_assets, prefabs),
--Prefab( "spoiled_fish", spoiledfn, spoiledfish_assets), 
--Prefab( "fish_med", fish_raw_fn, raw_assets),
--Prefab( "fish_med_cooked", cookedfn, cooked_assets),
--Prefab( "fish_small", fish_raw_small_fn, small_assets),
--Prefab( "fish_small_cooked", fish_raw_small_cooked_fn, small_assets),
Prefab( "lobster_dead", lobster_dead_fn, lobster_assets),
Prefab( "lobster_dead_cooked", lobster_dead_cooked_fn, lobster_assets)
