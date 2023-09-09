require "brains/doydoybrain"
require "stategraphs/SGdoydoy"

local assets_baby =
{
	Asset("ANIM", "anim/doydoy.zip"),
	Asset("ANIM", "anim/doydoy_baby.zip"),
	Asset("ANIM", "anim/doydoy_baby_build.zip"),
	Asset("ANIM", "anim/doydoy_teen_build.zip"),
}

local assets =
{
	Asset("ANIM", "anim/doydoy.zip"),
	Asset("ANIM", "anim/doydoy_adult_build.zip"),
}

local prefabs_baby =
{
	"doydoyfeather",
	"drumstick",
}

local prefabs =
{
	"doydoyfeather",
	"drumstick",
	"doydoy_mate_fx",
}

local babyloot = {"smallmeat","doydoyfeather"}
local teenloot = {"drumstick","doydoyfeather","doydoyfeather"}
local adultloot = {'meat', 'drumstick', 'drumstick', 'doydoyfeather', 'doydoyfeather'}

local babyfoodprefs = {FOODTYPE.SEEDS}
local teenfoodprefs = {FOODTYPE.SEEDS, FOODTYPE.VEGGIE}
local adultfoodprefs = {FOODTYPE.MEAT, FOODTYPE.VEGGIE, FOODTYPE.SEEDS, FOODTYPE.ELEMENTAL, FOODTYPE.WOOD, FOODTYPE.ROUGHAGE}

local babysounds = 
{
	eat_pre = "ia/creatures/doydoy/baby/eat_pre",
	swallow = "ia/creatures/doydoy/teen/swallow", --SW bug: baby has no swallow sound
	hatch = "ia/creatures/doydoy/baby/hatch",
	death = "ia/creatures/doydoy/baby/death",
	jump = "ia/creatures/doydoy/baby/jump",
	peck = "ia/creatures/doydoy/teen/peck",
}

local teensounds = 
{
	idle = "ia/creatures/doydoy/teen/idle",
	eat_pre = "ia/creatures/doydoy/teen/eat_pre",
	swallow = "ia/creatures/doydoy/teen/swallow",
	hatch = "ia/creatures/doydoy/teen/hatch",
	death = "ia/creatures/doydoy/teen/death",
	jump = "ia/creatures/doydoy/baby/jump",
	peck = "ia/creatures/doydoy/teen/peck",
}

local function TrackInSpawner(inst)
	if TheWorld.components.doydoyspawner then
		TheWorld.components.doydoyspawner:StartTracking(inst)
	end
end

local function StopTrackingInSpawner(inst)
	if TheWorld.components.doydoyspawner then
		TheWorld.components.doydoyspawner:StopTracking(inst)
	end
end

local function SetBaby(inst)
	inst:AddTag("baby")
	inst:RemoveTag("teen")

	inst.AnimState:SetBank("doydoy_baby")
	inst.AnimState:SetBuild("doydoy_baby_build")
	inst.AnimState:PlayAnimation("idle", true)

	inst.sounds = babysounds
	inst.components.combat:SetHurtSound("ia/creatures/doydoy/baby/hit")

	inst.Transform:SetScale(1, 1, 1)

	inst.components.health:SetMaxHealth(TUNING.DOYDOY_BABY_HEALTH)
	inst.components.locomotor.walkspeed = TUNING.DOYDOY_BABY_WALK_SPEED
	inst.components.locomotor.runspeed = TUNING.DOYDOY_BABY_WALK_SPEED
	inst.components.lootdropper:SetLoot(babyloot)
	inst.components.eater:SetDiet(babyfoodprefs)

	inst.components.inventoryitem:ChangeImageName("doydoybaby")

	inst.components.named:SetName(STRINGS.NAMES.DOYDOYBABY)
end

local function SetTeen(inst)
	inst:AddTag("teen")
	inst:RemoveTag("baby")

	inst.AnimState:SetBank("doydoy")
	inst.AnimState:SetBuild("doydoy_teen_build")
	inst.AnimState:PlayAnimation("idle", true)

	inst.sounds = teensounds
	inst.components.combat:SetHurtSound("ia/creatures/doydoy/hit")

	local scale = TUNING.DOYDOY_TEEN_SCALE
	inst.Transform:SetScale(scale, scale, scale)

	inst.components.health:SetMaxHealth(TUNING.DOYDOY_TEEN_HEALTH)
	inst.components.locomotor.walkspeed = TUNING.DOYDOY_TEEN_WALK_SPEED
	inst.components.locomotor.runspeed = TUNING.DOYDOY_TEEN_WALK_SPEED
	inst.components.lootdropper:SetLoot(teenloot)
	inst.components.eater:SetDiet(teenfoodprefs)

	if inst.components.burnable then
		inst:RemoveComponent("burnable")
	end
	if inst.components.propagator then
		inst:RemoveComponent("propagator")
	end

	MakeSmallBurnableCharacter(inst, "doydoy_body")

	inst.components.inventoryitem:ChangeImageName("doydoyteen")

	inst.components.named:SetName(STRINGS.NAMES.DOYDOYTEEN)
end

local function SetFullyGrown(inst)
	inst.needtogrowup = true
end

local function GetBabyGrowTime()
	return TUNING.DOYDOY_BABY_GROW_TIME
end

local function GetTeenGrowTime()
	return TUNING.DOYDOY_TEEN_GROW_TIME
end

local growth_stages =
{
	{name="baby", time = GetBabyGrowTime, fn = SetBaby},
	{name="teen", time = GetTeenGrowTime, fn = SetTeen},
	{name="grown", time = GetTeenGrowTime, fn = SetFullyGrown},
}

local function OnEntitySleep(inst)
	if inst.shouldGoAway then
		inst:Remove()
	end
end

local function OnGrowUp(inst)
	if not inst:IsValid() then return end
	
	local grown = SpawnPrefab("doydoy")

	-- Taken from scripts/components/perishable.lua:269@Perish()
	local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
	local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
	if holder ~= nil then
		local slot = holder:GetItemSlot(inst)
		inst:Remove()
		holder:GiveItem(grown, slot)
	else
		local x, y, z = inst.Transform:GetWorldPosition()
		local rot = inst.Transform:GetRotation()
		inst:Remove()
		grown.Transform:SetPosition(x, y, z)
		grown.Transform:SetRotation(rot)
	end
end

local function OnEntityWake(inst)
	inst:ClearBufferedAction()
	--TODO this massive hack is done very improperly
	-- what about the inventory?
	if inst.needtogrowup then
		-- DoTaskInTime to fix stupid brain issues on the stupid brainless bird
		inst:DoTaskInTime(0, OnGrowUp)
	end
end

local function OnInventory(inst)
	inst:ClearBufferedAction()
	inst:AddTag("mating")
end

local function OnDropped(inst)
	inst.components.sleeper:GoToSleep()
	inst:AddTag("mating")
end

local function OnDeath(inst, data) 
	--If the doydoy is held drop items.
	local owner = inst.components.inventoryitem:GetGrandOwner()

	if inst.components.lootdropper and owner then
		local loots = inst.components.lootdropper:GenerateLoot()
		inst:Remove()
		for k, v in pairs(loots) do
			local loot = SpawnPrefab(v)
			owner.components.inventory:GiveItem(loot)
		end
	end
end

local function OnSleep(inst)
	inst.components.inventoryitem.canbepickedup = true
end

local function OnWakeUp(inst) 
	inst.components.inventoryitem.canbepickedup = false
	inst:RemoveTag("mating")
end

local function OnMate(inst, partner)
	
end

local function commonpristinefn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddLightWatcher() --solely for cave sleeping
	inst.entity:AddNetwork()
	inst.entity:AddDynamicShadow()
    
	inst.DynamicShadow:SetSize(1.5, 0.8)
	
	inst.Transform:SetFourFaced()
	
	MakeCharacterPhysics(inst, 50, .5)

	inst.AnimState:SetBank("doydoy")
	inst.AnimState:SetBuild("doydoy_adult_build")
	inst.AnimState:PlayAnimation("idle", true)
	
	inst:AddTag("doydoy")
	inst:AddTag("companion")
	inst:AddTag("scannable")
	inst:AddTag("nosteal")--nosteal is not exactly SW-accurate, but I don't *want* to find out why SW Primeapes do not steal Doydoys. -M
	inst:AddTag("donotautopick")
	inst:AddTag("noepicmusic")
	
	MakeFeedableSmallLivestockPristine(inst)
	
	return inst
end

local function commonmasterfn(inst)
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.nobounce = true
	inst.components.inventoryitem.canbepickedup = false
	inst.components.inventoryitem.longpickup = true
	--inst.components.inventoryitem:SetSinks(true) --Let drownable handle this (less doydoy death yay!)

	inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_LARGE
	
	inst:AddComponent("health")
	-- inst:AddComponent("sizetweener")
	inst:AddComponent("sleeper")

	inst:AddComponent("lootdropper")
	
	inst:AddComponent("inspectable")

	--Doy Doys are so stupid or "brave" one can say, that they aren't even scared when being haunted
	inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)  

	inst:AddComponent("inventory")
	-- inst:AddComponent("entitytracker")
	
	inst:AddComponent("eater")
	-- inst.components.eater:SetCanEatTestFn(CanEatFn)

	inst:ListenForEvent("entitysleep", OnEntitySleep)
	inst:ListenForEvent("entitywake", OnEntityWake)

    MakePoisonableCharacter(inst)
	MakeSmallFreezableCharacter(inst, "mossling_body")

	inst:AddComponent("locomotor")
	
    -- boat hopping enable.
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

	inst:AddComponent("combat")
	
	TrackInSpawner(inst)
	inst:ListenForEvent("onremove", StopTrackingInSpawner)

	inst:ListenForEvent("gotosleep", OnSleep)
    inst:ListenForEvent("onwakeup", OnWakeUp)

	inst:ListenForEvent("death", OnDeath)
	
	MakeFeedableSmallLivestock(inst, TUNING.TOTAL_DAY_TIME, OnInventory, OnDropped)

	return inst
end

local function babyfn()
	local inst = commonpristinefn()

	inst.AnimState:SetBank("doydoy_baby")
	inst.AnimState:SetBuild("doydoy_baby_build")
	inst.AnimState:PlayAnimation("idle", true)

	inst:AddTag("baby")

	inst.sounds = babysounds
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		return inst
	end
	
	commonmasterfn(inst)
	
	inst.components.combat:SetHurtSound("ia/creatures/doydoy/baby/hit")
	inst:AddComponent("named")
	
	inst.components.health:SetMaxHealth(TUNING.DOYDOY_BABY_HEALTH)
	inst.components.locomotor.walkspeed = TUNING.DOYDOY_BABY_WALK_SPEED
	inst.components.locomotor.runspeed = TUNING.DOYDOY_BABY_WALK_SPEED
	inst.components.lootdropper:SetLoot(babyloot)

	MakeSmallBurnableCharacter(inst, "head")

	inst.components.inventoryitem:ChangeImageName("doydoybaby")

	inst.components.eater:SetDiet(babyfoodprefs)

	inst:SetStateGraph("SGdoydoybaby")
	local brain = require("brains/doydoybrain")
	inst:SetBrain(brain)

	inst:AddComponent("growable")
	inst.components.growable.stages = growth_stages
	-- inst.components.growable.growonly = true
	inst.components.growable:SetStage(1)
	inst.components.growable.growoffscreen = true
	inst.components.growable:StartGrowing()

	return inst
end

local function adultfn()
	local inst = commonpristinefn()

	inst.AnimState:SetBank("doydoy")
	inst.AnimState:SetBuild("doydoy_adult_build")
	inst.AnimState:PlayAnimation("idle", true)

	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		return inst
	end
	
	commonmasterfn(inst)
	
	inst:AddComponent("mateable")
	inst.components.mateable:SetOnMateCallback(OnMate)
	
	inst.components.combat:SetHurtSound("ia/creatures/doydoy/hit")

	inst.components.health:SetMaxHealth(TUNING.DOYDOY_HEALTH)
	inst.components.locomotor.walkspeed = TUNING.DOYDOY_WALK_SPEED
	inst.components.lootdropper:SetLoot(adultloot)

	inst.components.eater:SetDiet(adultfoodprefs)

	MakeSmallBurnableCharacter(inst, "doydoy_body")
	
	inst:SetStateGraph("SGdoydoy")
	local brain = require("brains/doydoybrain")
	inst:SetBrain(brain)

	return inst
end

return  Prefab("doydoybaby", babyfn, assets_baby, prefabs_baby),
		Prefab("doydoy", adultfn, assets, prefabs)
