local brain = require("brains/ballphinbrain")

local SCREENSIZE = 40

local assets =
{
    Asset("ANIM", "anim/ballphin.zip"),
}

local prefabs =
{
    "fishmeat",
    "fishmeat_small",
    "ia_messagebottleempty",
    "splash_water_drop",
    "ballphinpod",
    "dorsalfin",
}

local function ontalk(inst, script)
    inst.SoundEmitter:PlaySound("ia/creatures/balphin/taunt")
end

local SHARE_TARGET_DIST = 30

local function OnNewTarget(inst, data)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local MUSTTAGS = {"monster"}
local CANTTAGS = {"abigail"}
local function RetargetFn(inst)
    return FindEntity(inst, TUNING.BALLPHIN_TARGET_DIST, function(guy)
        --return not guy:HasTag("wall") and not (guy:HasTag("ballphin") ) and inst.components.combat:CanTarget(guy)
		return guy.components.health and not guy.components.health:IsDead()
			and inst.components.combat:CanTarget(guy)
        end, MUSTTAGS, CANTTAGS)
end

local function KeepTarget(inst, target)
    local dist = inst:HasTag('ballphinfriend') and TUNING.BALLPHIN_FRIEND_KEEP_TARGET_DIST or TUNING.BALLPHIN_KEEP_TARGET_DIST
    return inst.components.combat:CanTarget(target) and inst:GetDistanceSqToInst(target) <= (dist*dist)
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("ballphin")and not dude.components.health:IsDead() end, 5)
end

local function OnAttackOther(inst, data)
    inst.components.combat:ShareTarget(data.target, SHARE_TARGET_DIST, function(dude) return dude:HasTag("ballphin") and not dude.components.health:IsDead() end, 5)
    -- local splash = SpawnPrefab("splash_water_drop")
    -- local pos = inst:GetPosition()
    -- splash.Transform:SetPosition(pos.x, pos.y, pos.z)
end

local function CalcSanityAura(inst, observer)

    if inst.components.follower and inst.components.follower.leader == observer and inst.entity:IsVisible() then
        return TUNING.SANITYAURA_MED
    end

    return 0
end

local function ShouldAcceptItem(inst, item)
    if inst.components.sleeper:IsAsleep() then
        return false
    end

    if inst.components.eater:CanEat(item) then
        if item.components.edible.foodtype == "MEAT" then
            if not (item:HasTag("fishmeat") or item:HasTag("fish")) then
                return false
            end
            if inst.components.follower.leader and inst.components.follower:GetLoyaltyPercent() > 0.9 then
                return false
            end
        end
        if item.components.edible.foodtype == "VEGGIE" then
            -- print("being given food veggie")
            if not item:HasTag("hydrofarm") then
                return false
            end

            local last_eat_time = inst.components.eater:TimeSinceLastEating()
            if last_eat_time and last_eat_time < TUNING.BALLPHIN_MIN_POOP_PERIOD then
                return false
            end
        end
        return true
    end
end

local function OnGetItemFromPlayer(inst, giver, item)
    --I eat food
    if item.components.edible then
        --meat makes us friends (unless I'm a guard)
        if item:HasTag("fishmeat") or item:HasTag("fish") then
            if inst.components.combat.target and inst.components.combat.target == giver then
                inst.components.combat:SetTarget(nil)
            elseif giver ~= nil and giver.components.leader and not inst:HasTag("guard") then
                inst.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
                giver.components.leader:AddFollower(inst)
                local loyaltytime = math.min(TUNING.BALLPHIN_LOYALTY_MAX_TIME, item.components.edible:GetHunger() * TUNING.BALLPHIN_LOYALTY_PER_HUNGER)
                inst.components.follower:AddLoyaltyTime(loyaltytime)
                inst.components.follower.maxfollowtime =
                            giver:HasTag("polite") --followers get a bonus from woodie
                            and TUNING.BALLPHIN_LOYALTY_MAX_TIME + TUNING.BALLPHIN_LOYALTY_POLITENESS_MAXTIME_BONUS
                            or TUNING.BALLPHIN_LOYALTY_MAX_TIME
            end
        end
        if inst.components.sleeper:IsAsleep() then
            inst.components.sleeper:WakeUp()
        end
    end
end

--local function OnEat(inst, food)
--
--end

local function OnRefuseItem(inst, item)
    --inst.sg:GoToState("refuse")
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

--instead of all ballphins merging into one pod and sharing the same house like in sw, at dusk if a ballphin has no house give it a random one nearby
local function OnStartNight(inst)
    inst.mood_override = nil
end

local function OnStartDusk(inst)
    if not (inst.components.homeseeker and inst.components.homeseeker:HasHome() and inst.components.homeseeker.home.components.childspawner) then
        local newhome = GetRandomInstWithTag("ballphin_palace", inst, 15)
        if newhome then
        newhome.components.childspawner:TakeOwnership(inst)
        end
    end
end

local function GetLeader(inst)
    return inst.components.follower.leader
end

local function FloatationTest(inst)
    local leader = GetLeader(inst)
    return leader and inst:IsNear(leader, 32)
    and math.random() < TUNING.BALLPHIN_DROWN_RESCUE_CHANCE
end

local SEPARATION_AMOUNT = 15.0
local SEPARATION_MUST_NOT_TAGS = {"FX", "DECOR", "INLIMBO"}
local SEPARATION_MUST_ONE_TAGS = {"blocker", "ballphin"}
local MAX_STEER_FORCE = 2.0
local MAX_STEER_FORCE_SQ = MAX_STEER_FORCE*MAX_STEER_FORCE
local DESIRED_BOAT_DISTANCE = TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 4
local function GetFormationOffsetNormal(inst, leader, leader_platform, leader_velocity)
    if leader == nil or leader_platform == nil or leader.components.leader == nil then
        return Vector3(1, 0, 0)
    end

    local my_location = inst:GetPosition()

    -- calculate desired position
    local leader_p_position = leader_platform:GetPosition()
    local mtlp_normal, mtlp_length = (leader_p_position - my_location):GetNormalizedAndLength()

    local leader_direction, leader_speed = leader_velocity:GetNormalizedAndLength()
    local my_locomotor = inst.components.locomotor
    local inst_move_speed = (my_locomotor.isrunning and my_locomotor:GetRunSpeed()) or my_locomotor:GetWalkSpeed()
    local speed = math.min(leader_speed, inst_move_speed)

    -- separation steering --
    local separation_steering = Vector3(0, 0, 0)
    local mx, my, mz = inst.Transform:GetWorldPosition()
    local separation_entities = TheSim:FindEntities(mx, my, mz, SEPARATION_AMOUNT, nil, SEPARATION_MUST_NOT_TAGS, SEPARATION_MUST_ONE_TAGS)
    local separation_affecting_ents_count = 0
    for _, se in ipairs(separation_entities) do
        if se ~= inst then
            -- Generate a vector pointing directly away from this entity, length inversely proportional to its distance away
            local se_to_me_normal, se_to_me_length = (my_location - se:GetPosition()):GetNormalizedAndLength()
            separation_steering = separation_steering + (se_to_me_normal * speed / se_to_me_length)
            separation_affecting_ents_count = separation_affecting_ents_count + 1
        end
    end
    if separation_affecting_ents_count > 0 then
        separation_steering = separation_steering / separation_affecting_ents_count
    end
    if separation_steering:LengthSq() > 0 then
        local recalculated_separation_steering = (separation_steering:Normalize() * speed) - (mtlp_normal * speed)
        if recalculated_separation_steering:LengthSq() > MAX_STEER_FORCE_SQ then
            recalculated_separation_steering = recalculated_separation_steering:GetNormalized() * MAX_STEER_FORCE
        end
        separation_steering = recalculated_separation_steering
    end
    -- separation steering --

    local desired_position_offset = mtlp_normal * (mtlp_length - DESIRED_BOAT_DISTANCE)
    return desired_position_offset + separation_steering
end

local function CancelPanicTask(inst)
    if inst.ballphin_panic_task ~= nil then
        inst.ballphin_panic_task:Cancel()
        inst.ballphin_panic_task = nil
    end
end

local function TriggerPanicTask(inst, pos)
    if pos ~= nil and math.sqrt(inst:GetDistanceSqToPoint(pos.x, 0 , pos.z)) < SCREENSIZE then
        CancelPanicTask(inst)
        inst.ballphin_panic_task = inst:DoTaskInTime(TUNING.SEG_TIME, CancelPanicTask)
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 1, 0.5)
    -- inst.Physics:ClearCollisionMask()
    -- inst.Physics:CollidesWith(COLLISION.WORLD)

    inst.AnimState:SetBank("ballphin")
    inst.AnimState:SetBuild("ballphin")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetRayTestOnBB(true)

    inst.entity:AddLightWatcher()

    inst:AddTag("ballphin")
    inst:AddTag("animal")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.no_wet_prefix = true

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.BALLPHIN_WALK_SPEED  -- 2 --3.0
    inst.components.locomotor.runspeed = TUNING.BALLPHIN_RUN_SPEED  -- 5 --6.0
    inst.components.locomotor.pathcaps = {allowocean = true, ignoreLand = true}

    inst:SetStateGraph("SGballphin")
    inst:SetBrain(brain)

    inst:AddComponent("drydrownable")
    inst.components.drydrownable.break_period = 3

    inst:AddComponent("eater")
    inst.components.eater:SetOmnivore()
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater:SetDiet({FOODGROUP.OMNI, FOODTYPE.RAW})
    inst.components.eater.strongstomach = true -- can eat monster meat!
    -- inst.components.eater:SetOnEatFn(OnEat)

    inst:AddComponent("inspectable")

    inst:AddComponent("herdmember")
    inst.components.herdmember.herdprefab = "ballphinpod"
    inst.components.herdmember.createherdfn = function(inst,herd)
        -- if inst.components.homeseeker and inst.components.homeseeker.home then     -- this was a really bad way to set the home...
        --     herd.home = inst.components.homeseeker.home
        --     -- print("##---->> SETTING THE POD's HOME AS THE BALLPHIN'S HOME",herd.GUID, herd.home.GUID, inst.GUID)
        -- end
        if herd.components.mood and inst.mood_override then
            herd.components.mood:OnLoad(inst.mood_override)
            herd.components.mood:CheckForMoodChange()
        end
    end

    inst:AddComponent("teamattacker")
    inst.components.teamattacker.team_type = "ballphin"
    inst.components.teamattacker.leashdistance = 99999

    inst:AddComponent("knownlocations")

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.BALLPHIN_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.BALLPHIN_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetHurtSound("ia/creatures/balphin/hit")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BALLPHIN_HEALTH)

    inst:AddComponent("inventory")

    inst:AddComponent("named")
    inst.components.named.possiblenames = STRINGS.BALLPHINNAMES
    inst.components.named:PickNewName()

    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = TUNING.BALLPHIN_LOYALTY_MAX_TIME
    inst.components.follower:SetFollowExitDestinations({EXIT_DESTINATION.WATER})

    inst:AddComponent("flotationdevice")
    inst.components.flotationdevice:SetTest(FloatationTest)

    inst:AddComponent("talker")
    inst.components.talker.ontalk = ontalk
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0,-400,0)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    inst:AddComponent("sleeper")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"fishmeat_small", "fishmeat_small", "dorsalfin"})
    inst.components.lootdropper:AddChanceLoot("ia_messagebottleempty", TUNING.SNAKE_JUNGLETREE_CHANCE)

    inst:ListenForEvent("startnight", OnStartNight)
    inst:ListenForEvent("startdusk", OnStartDusk)
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("explosion_heard", function(_world, pos)
        TriggerPanicTask(inst, pos)
    end, TheWorld)

    inst:ListenForEvent("ms_sendlightningstrike", function(_world, pos)
        TriggerPanicTask(inst, pos)
    end, TheWorld)

    inst.GetFormationOffsetNormal = GetFormationOffsetNormal

    MakeHauntablePanic(inst)
    MakeMediumFreezableCharacter(inst, "ballphin_body")

    return inst
end

return Prefab("ballphin", fn, assets, prefabs)
