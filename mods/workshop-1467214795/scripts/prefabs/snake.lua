local brain = require("brains/snakebrain")

local assets =
{
    Asset("ANIM", "anim/snake_build.zip"),
    Asset("ANIM", "anim/snake_yellow_build.zip"),
    Asset("ANIM", "anim/snake_basic.zip"),
}

local prefabs =
{
    "monstermeat",
    "snakeskin",
    "venomgland",
    --"obsidian",
    --"ash",
    --"charcoal",
    --"vomitfire_fx",
    --"firesplash_fx",
    --"firering_fx",
    --"dragonfly_fx",
    --"lavaspit",
    "snakeoil",
}

local WAKE_TO_FOLLOW_DISTANCE = 8
local SLEEP_NEAR_HOME_DISTANCE = 10
local SHARE_TARGET_DIST = 30
local HOME_TELEPORT_DIST = 30

local NO_TAGS = {"FX", "NOCLICK","DECOR","INLIMBO"}

local function ShouldWakeUp(inst)
    return TheWorld.state.isnight
    or (inst.components.combat and inst.components.combat.target)
    or (inst.components.homeseeker and inst.components.homeseeker:HasHome())
    or (inst.components.burnable and inst.components.burnable:IsBurning())
    or (inst.components.follower and inst.components.follower.leader)
end

local function ShouldSleep(inst)
    return TheWorld.state.isday
    and not (inst.components.combat and inst.components.combat.target)
    and not (inst.components.homeseeker and inst.components.homeseeker:HasHome())
    and not (inst.components.burnable and inst.components.burnable:IsBurning())
    and not (inst.components.follower and inst.components.follower.leader)
end

local function OnNewTarget(inst, data)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local TARGET_DIST = TUNING.SNAKE_TARGET_DIST
local CANT_TAGS = {"wall", "snake", "structure", "snakefriend"}
local function retargetfn(inst)
    return FindEntity(inst, TARGET_DIST, function(guy)
            return  inst.components.combat:CanTarget(guy) and guy:IsOnPassablePoint()
        end, nil, CANT_TAGS)
end

local function KeepTarget(inst, target)
    return inst.components.combat:CanTarget(target) and target:IsOnPassablePoint()
end

local function OnAttacked(inst, data)
    if data.attacker == nil or data.attacker:HasTag("jungletree") then
        return
    end
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("snake") and not dude.components.health:IsDead() end, 5)
end

local function OnAttackOther(inst, data)
    if data.attacker == nil then
        return
    end
    inst.components.combat:ShareTarget(data.target, SHARE_TARGET_DIST, function(dude) return dude:HasTag("snake") and not dude.components.health:IsDead() end, 5)
end

local function DoReturn(inst)
    -- print("DoReturn", inst)
    if inst.components.homeseeker then
        inst.components.homeseeker:GoHome()
    end
end

local function OnDay(inst, isday)
    -- print("OnNight", inst)
    if isday and inst:IsAsleep() then
        DoReturn(inst)
    end
end


local function OnEntitySleep(inst)
    -- print("OnEntitySleep", inst)
    if TheWorld.state.isday then
        DoReturn(inst)
    end
end

local function SanityAura(inst, observer)
    if observer.prefab == "webber" then
        return 0
    end

    return -TUNING.SANITYAURA_SMALL
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    -- inst.entity:AddDynamicShadow()
    -- inst.DynamicShadow:SetSize( 2.5, 1.5 )

    MakeCharacterPhysics(inst, 10, .5)

    inst.AnimState:SetBank("snake")
    inst.AnimState:SetBuild("snake_build")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("scarytoprey")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("snake")
    inst:AddTag("canbetrapped")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("knownlocations")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.SNAKE_SPEED

    -- boat hopping enable.
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

    inst:SetBrain(brain)
    inst:SetStateGraph("SGsnake")

    inst:AddComponent("follower")

    inst:AddComponent("eater")
    inst.components.eater:SetCarnivore()
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater.strongstomach = true -- can eat monster meat!

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SNAKE_HEALTH)
    inst.components.health.poison_damage_scale = 0 -- immune to poison

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.SNAKE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SNAKE_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, retargetfn)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetHurtSound("ia/creatures/snake/hurt")
    inst.components.combat:SetRange(2,3)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddRandomLoot("monstermeat", 1.00)
    inst.components.lootdropper:AddRandomLoot("snakeskin", 0.50)
    inst.components.lootdropper:AddRandomLoot("snakeoil", 0.01)
    inst.components.lootdropper.numrandomloot = math.random(0, 1)

    inst:AddComponent("inspectable")

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = SanityAura

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetNocturnal(true)
    -- inst.components.sleeper:SetResistance(1)
    -- inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    -- inst.components.sleeper:SetSleepTest(ShouldSleep)
    -- inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    inst:WatchWorldState("isday", OnDay)
    inst:ListenForEvent("newcombattarget", OnNewTarget)

    inst.OnEntitySleep = OnEntitySleep

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onattackother", OnAttackOther)

    MakeHauntablePanic(inst)
    MakeMediumFreezableCharacter(inst, nil)

    return inst
end

local function commonfn()
    local inst = fn()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeMediumBurnableCharacter(inst, nil, Vector3(0, 0.1, 0))

    return inst
end

local function poisonfn()
    local inst = fn()

    inst.AnimState:SetBuild("snake_yellow_build")

    inst:AddTag("poisonous")
    inst:AddTag("poisonimmune")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.combat.poisonous = true
    inst.components.lootdropper:AddRandomLoot("venomgland", 1.00)

    MakeMediumBurnableCharacter(inst, nil, Vector3(0, 0.1, 0))

    return inst
end

--[[
local function firefn()
    local inst = fn()

    inst.AnimState:SetBuild("snake_yellow_build")
    inst:AddTag("lavaspitter")

    if not TheWorld.ismastersim then
        return
    end

    inst.last_spit_time = nil
    inst.last_target_spit_time = nil
    inst.spit_interval = math.random(20,30)
    inst.num_targets_vomited = 0

    inst.components.health.fire_damage_scale = 0

    -- inst:AddTag("poisonous")
    inst.components.lootdropper.numrandomloot = 3
    inst.components.lootdropper:AddRandomLoot("obsidian", .25)
    inst.components.lootdropper:AddRandomLoot("ash", .25)
    inst.components.lootdropper:AddRandomLoot("charcoal", .25)

    MakeLargePropagator(inst)
    inst.components.propagator.decayrate = 0

    return inst
end
--]]

return Prefab("snake", commonfn, assets, prefabs),
    Prefab("snake_poison", poisonfn, assets, prefabs)
    -- Prefab("snake_fire", firefn, assets, prefabs),
    -- Prefab("deadsnake", fndefault, assets, prefabs),
