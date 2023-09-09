local assets=
{
    Asset("ANIM", "anim/crocodog_basic.zip"),
    Asset("ANIM", "anim/crocodog.zip"),
    Asset("ANIM", "anim/crocodog_poison.zip"),
    Asset("ANIM", "anim/crocodog_water.zip"),
    Asset("ANIM", "anim/crocodog_basic_water.zip"),
    Asset("ANIM", "anim/watercrocodog.zip"),
    Asset("ANIM", "anim/watercrocodog_poison.zip"),
    Asset("ANIM", "anim/watercrocodog_water.zip"),
}

local prefabs =
{
  "houndstooth",
  "monstermeat",
  "ice_puddle",
}

local brain = require("brains/crocodogbrain")

-- local sounds =
-- {
--     pant = "dontstarve/creatures/hound/pant",
--     attack = "dontstarve/creatures/hound/attack",
--     bite = "dontstarve/creatures/hound/bite",
--     bark = "dontstarve/creatures/hound/bark",
--     death = "dontstarve/creatures/hound/death",
--     sleep = "dontstarve/creatures/hound/sleep",
--     growl = "dontstarve/creatures/hound/growl",
--     howl = "dontstarve/creatures/together/clayhound/howl",
--     hurt = "dontstarve/creatures/hound/hurt",
-- }

SetSharedLootTable('crocodog',
{
    {'monstermeat', 1.000},
    {'houndstooth',  0.125},
    {'houndstooth',  0.125},
})

SetSharedLootTable('crocodog_poison',
{
    {'monstermeat', 1.0},
    {'houndstooth', 1.0},
    {'venomgland',      0.2},
})

SetSharedLootTable('crocodog_water',
{
    {'monstermeat', 1.0},
    {'houndstooth', 1.0},
    {'houndstooth', 1.0},
    {'seaweed',   0.2},
})

local WAKE_TO_FOLLOW_DISTANCE = 8
local SLEEP_NEAR_HOME_DISTANCE = 10
local SHARE_TARGET_DIST = 30
local HOME_TELEPORT_DIST = 30

local NO_TAGS = {"FX", "NOCLICK","DECOR","INLIMBO"}

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or (inst.components.follower and inst.components.follower.leader and not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE))
end

local function ShouldSleep(inst)
    return inst:HasTag("pet_hound")
        and not TheWorld.state.isday
        and not (inst.components.combat and inst.components.combat.target)
        and not (inst.components.burnable and inst.components.burnable:IsBurning())
        and (not inst.components.homeseeker or inst:IsNear(inst.components.homeseeker.home, SLEEP_NEAR_HOME_DISTANCE))
end

local function OnNewTarget(inst, data)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local RETARGET_CANT_TAGS = { "wall", "houndmound", "hound", "houndfriend" }
local function retargetfn(inst)
    if inst.sg:HasStateTag("statue") then
        return
    end
    local leader = inst.components.follower.leader
    if leader ~= nil and leader.sg ~= nil and leader.sg:HasStateTag("statue") then
        return
    end
    local playerleader = leader ~= nil and leader:HasTag("player")
    local ispet = inst:HasTag("pet_hound")
    return (leader == nil or
            (ispet and not playerleader) or
            inst:IsNear(leader, TUNING.HOUND_FOLLOWER_AGGRO_DIST))
        and FindEntity(
                inst,
                (ispet or leader ~= nil) and TUNING.HOUND_FOLLOWER_TARGET_DIST or TUNING.HOUND_TARGET_DIST,
                function(guy)
                    return guy ~= leader and inst.components.combat:CanTarget(guy)
                end,
                nil,
                RETARGET_CANT_TAGS
            )
        or nil
end

local function KeepTarget(inst, target)
    if inst.sg:HasStateTag("statue") then
        return false
    end
    local leader = inst.components.follower.leader
    local playerleader = leader ~= nil and leader:HasTag("player")
    local ispet = inst:HasTag("pet_hound")
    return (leader == nil or
            (ispet and not playerleader) or
            inst:IsNear(leader, TUNING.HOUND_FOLLOWER_RETURN_DIST))
        and inst.components.combat:CanTarget(target)
        and (not (ispet or leader ~= nil) or
            inst:IsNear(target, TUNING.HOUND_FOLLOWER_TARGET_KEEP))
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, SHARE_TARGET_DIST,
        function(dude)
            return not (dude.components.health ~= nil and dude.components.health:IsDead())
                and (dude:HasTag("hound") or dude:HasTag("houndfriend"))
                and data.attacker ~= (dude.components.follower ~= nil and dude.components.follower.leader or nil)
        end, 5)
end

local function OnAttackOther(inst, data)
    inst.components.combat:ShareTarget(data.target, SHARE_TARGET_DIST,
        function(dude)
            return not (dude.components.health ~= nil and dude.components.health:IsDead())
                and (dude:HasTag("hound") or dude:HasTag("houndfriend"))
                and data.target ~= (dude.components.follower ~= nil and dude.components.follower.leader or nil)
        end, 5)
end

local function GetReturnPos(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local rad = 2
    local angle = math.random() * 2 * PI
    return x + rad * math.cos(angle), y, z - rad * math.sin(angle)
end

local function DoReturn(inst)
    --print("DoReturn", inst)
    if inst.components.homeseeker ~= nil and inst.components.homeseeker:HasHome() then
        if inst:HasTag("pet_hound") then
            if inst.components.homeseeker.home:IsAsleep() and not inst:IsNear(inst.components.homeseeker.home, HOME_TELEPORT_DIST) then
                inst.Physics:Teleport(GetReturnPos(inst.components.homeseeker.home))
            end
        elseif inst.components.homeseeker.home.components.childspawner ~= nil then
            inst.components.homeseeker.home.components.childspawner:GoHome(inst)
        end
    end
end

local function OnEntitySleep(inst)
    --print("OnEntitySleep", inst)
    if not TheWorld.state.isday then
        DoReturn(inst)
    end
end

local function OnStopDay(inst)
    --print("OnStopDay", inst)
    if inst:IsAsleep() then
        DoReturn(inst)
    end
end

local function OnSpawnedFromHaunt(inst)
    if inst.components.hauntable ~= nil then
        inst.components.hauntable:Panic()
    end
end

local function OnSave(inst, data)
    data.ispet = inst:HasTag("pet_hound") or nil
    --print("OnSave", inst, data.ispet)
end

local function OnLoad(inst, data)
    --print("OnLoad", inst, data.ispet)
    if data ~= nil and data.ispet then
        inst:AddTag("pet_hound")
        if inst.sg ~= nil then
            inst.sg:GoToState("idle")
        end
    end
end

local function OnStartFollowing(inst, data)
    if inst.leadertask ~= nil then
        inst.leadertask:Cancel()
        inst.leadertask = nil
    end
    if data == nil or data.leader == nil then
        inst.components.follower.maxfollowtime = nil
    elseif data.leader:HasTag("player") then
        inst.components.follower.maxfollowtime = TUNING.HOUNDWHISTLE_EFFECTIVE_TIME * 1.5
    else
        inst.components.follower.maxfollowtime = nil
        if inst.components.entitytracker:GetEntity("leader") == nil then
            inst.components.entitytracker:TrackEntity("leader", data.leader)
        end
    end
end

local function RestoreLeader(inst)
    inst.leadertask = nil
    local leader = inst.components.entitytracker:GetEntity("leader")
    if leader ~= nil and not leader.components.health:IsDead() then
        inst.components.follower:SetLeader(leader)
        leader:PushEvent("restoredfollower", { follower = inst })
    end
end

local function OnStopFollowing(inst)
    inst.leader_offset = nil
    if not inst.components.health:IsDead() then
        local leader = inst.components.entitytracker:GetEntity("leader")
        if leader ~= nil and not leader.components.health:IsDead() then
            inst.leadertask = inst:DoTaskInTime(.2, RestoreLeader)
        end
    end
end

local function OnWaterChangeCommon(inst)
    if inst:GetTimeAlive() > 1 then
        inst.SoundEmitter:PlaySound("ia/creatures/crocodog/emerge")
        local splash = SpawnPrefab("splash_water")
        local ent_pos = Vector3(inst.Transform:GetWorldPosition())
        splash.Transform:SetPosition(ent_pos.x, ent_pos.y, ent_pos.z)
    end

    if inst.sg then
        inst.sg:GoToState("idle")
    end
end

local function OnEnterWater(inst)
    inst.DynamicShadow:Enable(false)
    OnWaterChangeCommon(inst)
end

local function OnExitWater(inst)
    inst.DynamicShadow:Enable(true)
    OnWaterChangeCommon(inst)
end


local function fncommon(water_build, build, morphlist, custombrain, tag, data)
    local data = data or {}

    local inst = CreateEntity()

    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeAmphibiousCharacterPhysics(inst, 10, .5)

    inst.DynamicShadow:SetSize(3, 1.5)
    inst.Transform:SetFourFaced()

    inst:AddTag("scarytoprey")
    inst:AddTag("scarytooceanprey")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("hound")
    inst:AddTag("crocodog")
    inst:AddTag("canbestartled")
    inst:AddTag("poisonimmune") --fun fact all crocodogs are immune to poison not just the yellow ones
    inst:AddTag("breederpredator")

    if tag ~= nil then
        inst:AddTag(tag)
    end

    inst.AnimState:SetBank("crocodog") --("crocodog_water")
    inst.AnimState:SetBuild(build)--("watercrocodog")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("spawnfader")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.HOUND_SPEED

    inst:SetStateGraph("SGcrocodog")

    inst:AddComponent("amphibiouscreature")
    inst.components.amphibiouscreature:SetBanks("crocodog", "crocodog_water")
    inst.components.amphibiouscreature:SetBuilds(build, water_build)
    inst.components.amphibiouscreature:SetEnterWaterFn(OnEnterWater)
    inst.components.amphibiouscreature:SetExitWaterFn(OnExitWater)


    inst.components.locomotor.pathcaps = { allowocean = true }

    inst.wasintaunt = false

    inst:SetBrain(custombrain or brain)

    inst:AddComponent("follower")
    inst:AddComponent("entitytracker")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.HOUND_HEALTH)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.HOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.HOUND_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, retargetfn)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetHurtSound("ia/creatures/crocodog/hit")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('crocodog')

    inst:AddComponent("inspectable")
    --inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("eater")
    inst.components.eater:SetCarnivore()
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetStrongStomach(true) -- can eat monster meat!

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)
    inst:ListenForEvent("newcombattarget", OnNewTarget)

    if morphlist ~= nil then
        MakeHauntableChangePrefab(inst, morphlist)
        inst.components.hauntable.panicable = true
        inst:ListenForEvent("spawnedfromhaunt", OnSpawnedFromHaunt)
    else
        MakeHauntablePanic(inst)
    end

    inst:WatchWorldState("stopday", OnStopDay)
    inst.OnEntitySleep = OnEntitySleep

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("startfollowing", OnStartFollowing)
    inst:ListenForEvent("stopfollowing", OnStopFollowing)

    return inst
end

local function fndefault()
    local inst = fncommon("watercrocodog", "crocodog", { "poisoncrocodog", "watercrocodog" })

    if not TheWorld.ismastersim then
        return inst
    end

    MakeMediumFreezableCharacter(inst, "Crocodog_Body") 
    MakeMediumBurnableCharacter(inst, "Crocodog_Body") 
    
    return inst
end

local function PlayPoisonExplosionSound(inst) --Neat it rymes
    inst.SoundEmitter:PlaySound("ia/creatures/crocodog/death", "explosion")
end

local function fnpoison()
    local inst = fncommon("watercrocodog_poison", "crocodog_poison", { "crocodog", "watercrocodog" })

    inst:AddTag("poisonous")
    
    if not TheWorld.ismastersim then
        return inst
    end

    MakeMediumFreezableCharacter(inst, "Crocodog_Body") 
    inst.components.health.poison_damage_scale = 0 -- immune to poison

    inst.components.combat.poisonous = true
    inst.components.lootdropper:AddRandomLoot("venomgland", 1.00)

    inst.components.combat:SetDefaultDamage(TUNING.FIREHOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.FIREHOUND_ATTACK_PERIOD)
    inst.components.locomotor.runspeed = TUNING.FIREHOUND_SPEED
    inst.components.health:SetMaxHealth(TUNING.FIREHOUND_HEALTH)
    inst.components.lootdropper:SetChanceLootTable('crocodog_poison')

    inst:ListenForEvent("death", PlayPoisonExplosionSound)

    return inst
end

local function fnwater()
    local inst = fncommon("watercrocodog_water", "crocodog_water", { "poisoncrocodog", "crocodog" })

    inst:AddTag("waterous")

    if not TheWorld.ismastersim then
        return inst
    end

    MakeMediumBurnableCharacter(inst, "Crocodog_Body") 

    inst.components.combat:SetDefaultDamage(TUNING.ICEHOUND_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.ICEHOUND_ATTACK_PERIOD)
    inst.components.locomotor.runspeed = TUNING.ICEHOUND_SPEED
    inst.components.health:SetMaxHealth(TUNING.ICEHOUND_HEALTH)
    inst.components.lootdropper:SetChanceLootTable('crocodog_water')

    return inst
end


return Prefab("crocodog", fndefault, assets, prefabs),
Prefab("poisoncrocodog", fnpoison, assets, prefabs),
Prefab("watercrocodog", fnwater, assets, prefabs)
