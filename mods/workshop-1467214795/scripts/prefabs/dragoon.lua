local brain = require("brains/dragoonbrain")

local assets =
{
    Asset("ANIM", "anim/dragoon_build.zip"),
    Asset("ANIM", "anim/dragoon_basic.zip"),
    Asset("ANIM", "anim/dragoon_actions.zip"),
}

local prefabs =
{
    "monstermeat",
    "firesplash_fx",
    "firering_fx",
    "dragoonfire",
    -- "dragonfly_fx",
    "dragoonspit",
    "dragoonheart",
    "dragoon_charge_fx",
}

SetSharedLootTable('dragoon',
{
    {'monstermeat',  1.0},
    {'monstermeat',  1.0},
    {'dragoonheart', .25},
})

local RETARGET_CANT_TAGS = {"wall", "dragoon", "elephantcactus", "FX", "NOCLICK"}
local function RetargetFn(inst)
    return FindEntity(inst, TUNING.DRAGOON_TARGET_DIST,
        function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        nil, RETARGET_CANT_TAGS)
end

local function KeepTarget(inst, target)
    return inst.components.combat:CanTarget(target) and inst:GetDistanceSqToInst(target) <= (TUNING.DRAGOON_KEEP_TARGET_DIST * TUNING.DRAGOON_KEEP_TARGET_DIST)
end

local function ShouldSleep(inst)
    return DefaultSleepTest(inst)
end

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst)
end

local function OnNewTarget(inst, data)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, TUNING.DRAGOON_KEEP_TARGET_DIST, function(dude) return dude:HasTag("dragoon") and not dude.components.health:IsDead() end, 5)
end

local function OnAttackOther(inst, data)
    inst.components.combat:ShareTarget(data.target, TUNING.DRAGOON_KEEP_TARGET_DIST, function(dude) return dude:HasTag("dragoon") and not dude.components.health:IsDead() end, 5)
end

local function DoReturn(inst)
    -- print("DoReturn", inst)
    if inst.components.homeseeker and inst.components.homeseeker:HasHome() then
        inst.components.homeseeker.home.components.childspawner:GoHome(inst)
    end
end

local function OnNight(inst)
    -- print("OnNight", inst)
    if inst:IsAsleep() then
        DoReturn(inst)
    end
end

local function OnEntitySleep(inst)
    -- print("OnEntitySleep", inst)
    if not TheWorld.isday then
        DoReturn(inst)
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local s = 1.3
    inst.Transform:SetScale(s,s,s)
    inst.Transform:SetFourFaced()

    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(3, 1.25)

    inst.AnimState:SetBank("dragoon")
    inst.AnimState:SetBuild("dragoon_build")
    inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("scarytoprey")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("lavaspitter")
    inst:AddTag("dragoon")

    -- MakePoisonableCharacter(inst)
    MakeCharacterPhysics(inst, 10, .5)

    inst.last_spit_time = nil
    inst.last_target_spit_time = nil
    inst.spit_interval = math.random(20, 30)
    inst.num_targets_vomited = 0

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.DRAGOON_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.DRAGOON_RUN_SPEED

    -- boat hopping enable.
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

    inst:SetStateGraph("SGdragoon")

    inst:SetBrain(brain)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.DRAGOON_HEALTH)
    inst.components.health.fire_damage_scale = 0

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body"
    inst.components.combat:SetDefaultDamage(TUNING.DRAGOON_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.DRAGOON_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetHurtSound("ia/creatures/dragoon/hit")
    inst.components.combat:SetRange(2, 2)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('dragoon')

    inst:AddComponent("inspectable")

    inst:AddComponent("sleeper")
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)
    inst:ListenForEvent("newcombattarget", OnNewTarget)

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onattackother", OnAttackOther)

    inst:WatchWorldState("isdusk", OnNight)
    inst:WatchWorldState("isnight", OnNight)

    inst.OnEntitySleep = OnEntitySleep

    MakeHauntablePanic(inst)
    MakeMediumFreezableCharacter(inst, "hound_body")
    MakeLargePropagator(inst)
    inst.components.propagator.decayrate = 0

    return inst
end

return Prefab("dragoon", fn, assets, prefabs)
