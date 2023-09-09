require "brains/babyoxbrain"
require "stategraphs/SGox"
    
local assets=
{
    Asset("ANIM", "anim/ox_baby_build.zip"),
    Asset("ANIM", "anim/ox_basic.zip"),
    Asset("ANIM", "anim/ox_actions.zip"),
    Asset("ANIM", "anim/ox_basic_water.zip"),
    Asset("ANIM", "anim/ox_actions_water.zip"),
    Asset("SOUND", "sound/beefalo.fsb"),
}

local prefabs =
{
    "smallmeat",
    "meat",
    "poop",
    "ox",
}

local babyloot = {"smallmeat","smallmeat","smallmeat"}
local toddlerloot = {"smallmeat","smallmeat","smallmeat","smallmeat"}
local teenloot = {"meat","meat","meat"}

local sounds = {
    angry = "ia/creatures/ox/baby/angry",
    curious = "ia/creatures/ox/baby/curious",

    attack_whoosh = "ia/creatures/ox/baby/attack_whoosh",
    chew = "ia/creatures/ox/baby/chew",
    grunt = "ia/creatures/ox/baby/bellow",
    hairgrow_pop = "ia/creatures/ox/baby/hairgrow_pop",
    hairgrow_vocal = "ia/creatures/ox/baby/hairgrow_vocal",
    sleep = "ia/creatures/ox/baby/sleep",
    tail_swish = "ia/creatures/ox/baby/tail_swish",
    walk_land = "ia/creatures/ox/baby/walk_land",
    walk_water = "ia/creatures/ox/baby/walk_water",

    death = "ia/creatures/ox/baby/death",
    mating_call = "ia/creatures/ox/baby/mating_call",

    emerge = "ia/creatures/seacreature_movement/water_emerge_med",
    submerge = "ia/creatures/seacreature_movement/water_submerge_med",
}

local brain = require "brains/babyoxbrain"

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
        return dude:HasTag("ox") and not dude:HasTag("player") and not dude.components.health:IsDead()
    end, 5)
end

local FOLLOW_MUST_TAGS = {"ox", "herdmember"}
local FOLLOW_CANT_TAGS = {"baby"}

local function FollowGrownOx(inst)
    local nearest = FindEntity(inst, 30, function(guy)
        return guy.components.leader and guy.components.leader:CountFollowers() < 1
    end, FOLLOW_MUST_TAGS, FOLLOW_CANT_TAGS)
    if nearest and nearest.components.leader then
        nearest.components.leader:AddFollower(inst)
    end
end

local function Grow(inst)
    if inst.components.sleeper:IsAsleep() then
        inst.growUpPending = true
        inst.sg:GoToState("wake")
    else
        inst.sg:GoToState("grow_up")
    end
end

local function GetGrowTime()
    return GetRandomWithVariance(TUNING.BABYOX_GROW_TIME.base, TUNING.BABYOX_GROW_TIME.random)
end

local function SetBaby(inst)
    local scale = 0.5
    inst.Transform:SetScale(scale, scale, scale)
    inst.components.lootdropper:SetLoot(babyloot)
    inst.components.sleeper:SetResistance(1)
end

local function SetToddler(inst)
    local scale = 0.7
    inst.Transform:SetScale(scale, scale, scale)
    inst.components.lootdropper:SetLoot(toddlerloot)
    inst.components.sleeper:SetResistance(2)
end

local function SetTeen(inst)
    local scale = 0.9
    inst.Transform:SetScale(scale, scale, scale)
    inst.components.lootdropper:SetLoot(teenloot)
    inst.components.sleeper:SetResistance(2)
end

local function SetFullyGrown(inst)
    local herd = inst.components.herdmember ~= nil and inst.components.herdmember:GetHerd() or nil
    local grown = SpawnPrefab("ox")
    grown.Transform:SetPosition(inst.Transform:GetWorldPosition())
    grown.Transform:SetRotation(inst.Transform:GetRotation())
    grown.sg:GoToState("grow_up_adult_pop")
    inst:Remove()
    if herd ~= nil and herd.components.herd ~= nil and herd:IsValid() then
        herd.components.herd:AddMember(grown)
    end
end

local function OnPooped(inst, poop)
    local heading_angle = -(inst.Transform:GetRotation()) + 180

    local x, y, z = inst.Transform:GetWorldPosition()
    x = x + (math.cos(heading_angle*DEGREES))
    y = y + 0.9
    z = z + (math.sin(heading_angle*DEGREES))
    poop.Transform:SetPosition(x, y, z)

    if poop.components.inventoryitem then 
        poop.components.inventoryitem:SetLanded(false, true)
    end
end

local function UpdateTile(inst, tile, tileinfo)
    if GetTileDepth(tile) >= OCEAN_DEPTH.DEEP then
        -- local splash = SpawnPrefab("splash_water")
        -- local ent_pos = Vector3(self.inst.Transform:GetWorldPosition())
        -- splash.Transform:SetPosition(ent_pos.x, ent_pos.y, ent_pos.z)
        -- self.inst:Remove()
        SinkEntity(inst) -- This looks so much nicer... -Half
    end   
end

local growth_stages =
{
    {name="baby", time = GetGrowTime, fn = SetBaby},
    {name="toddler", time = GetGrowTime, fn = SetToddler, growfn = Grow},
    {name="teen", time = GetGrowTime, fn = SetTeen, growfn = Grow},
    {name="grown", time = GetGrowTime, fn = SetFullyGrown, growfn = Grow},
}

local function OnEnterWater(inst)
    if inst:GetTimeAlive() > 1 then
        inst.sg:GoToState("submerge")
    else
        inst.AnimState:SetBank("ox_water")
    end
end

local function OnExitWater(inst)
    inst.sg:GoToState("emerge")
end

local function fn()
    local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.Transform:SetSixFaced()
    inst.Transform:SetScale(0.5, 0.5, 0.5)

    inst.DynamicShadow:SetSize(2.5, 1.25)
    
    inst.AnimState:SetBank("ox")
    inst.AnimState:SetBuild("ox_baby_build")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:AddTag("ox")
    inst:AddTag("baby")
    inst:AddTag("animal")

    --herdmember (from herdmember component) added to pristine state for optimization
    inst:AddTag("herdmember")

    MakeAmphibiousCharacterPhysics(inst, 50, .5)

    inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		return inst
	end

    inst.sounds = sounds
    inst.walksound = sounds.walk_land

    inst:AddComponent("eater")
    inst.components.eater:SetVegetarian()
    
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "beefalo_body"
     
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BABYOX_HEALTH)

    inst:AddComponent("lootdropper")
    
    inst:AddComponent("inspectable")
    inst:AddComponent("sleeper")
    
    inst:AddComponent("knownlocations")
    inst:AddComponent("herdmember")
    inst.components.herdmember.herdprefab = "oxherd"
    inst:AddComponent("follower")
    inst.components.follower.canaccepttarget = true

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("poop")
    inst.components.periodicspawner:SetRandomTimes(TUNING.OX_POOP_PERIOD_MIN, TUNING.OX_POOP_PERIOD_MAX)
    inst.components.periodicspawner:SetDensityInRange(20, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
    inst.components.periodicspawner:SetOnSpawnFn(OnPooped)
    inst.components.periodicspawner:Start()
    
    inst:AddComponent("growable")
    inst.components.growable.stages = growth_stages
    inst.components.growable.growonly = true
    inst.components.growable:SetStage(1)
    inst.components.growable:StartGrowing()

    MakeLargeBurnableCharacter(inst, "swap_fire")
    MakeLargeFreezableCharacter(inst, "beefalo_body")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 2
    inst.components.locomotor.runspeed = 9

    MakeHauntablePanic(inst)
    
    inst:DoTaskInTime(1, FollowGrownOx)
    
    --Note: we set the land bank in the state for seamless transition
    inst:AddComponent("amphibiouscreature")
    inst.components.amphibiouscreature:SetBanks("ox_water", "ox_water")
    inst.components.amphibiouscreature:SetEnterWaterFn(OnEnterWater)
    inst.components.amphibiouscreature:SetExitWaterFn(OnExitWater)
    inst.components.locomotor.pathcaps = { allowocean = true }

    inst:AddComponent("tiletracker")
    inst.components.tiletracker:SetOnTileChangeFn(UpdateTile)

    inst:SetBrain(brain)
    
    inst:SetStateGraph("SGox")

    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end

return Prefab("babyox", fn, assets, prefabs) 
