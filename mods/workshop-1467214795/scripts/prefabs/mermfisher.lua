local assets = {
    Asset("ANIM", "anim/merm_fisherman_build.zip"),
    Asset("ANIM", "anim/ds_pig_basic.zip"),
    Asset("ANIM", "anim/ds_pig_actions.zip"),
    Asset("ANIM", "anim/ds_pig_attacks.zip"),
    Asset("ANIM", "anim/merm_fishing.zip"),
    Asset("SOUND", "sound/merm.fsb"),
}

local prefabs = {
    "pondfish_tropical",
}

local loot = {
    "pondfish_tropical",
}

local sounds = {
    attack = "dontstarve/creatures/merm/attack",
    hit = "dontstarve/creatures/merm/hurt",
    death = "dontstarve/creatures/merm/death",
    talk = "dontstarve/creatures/merm/idle",
    buff = "dontstarve/characters/wurt/merm/warrior/yell",
}

local merm_fisher_brain = require "brains/mermfisherbrain"

local SLIGHTDELAY = 1

local function ontalk(inst, script)
    inst.SoundEmitter:PlaySound(inst.sounds.talk)
end

local function FindInvaderFn(guy, inst)
    local leader = inst.components.follower and inst.components.follower.leader

    local leader_guy = guy.components.follower and guy.components.follower.leader
    if leader_guy and leader_guy.components.inventoryitem then
        leader_guy = leader_guy.components.inventoryitem:GetGrandOwner()
    end

    return not (TheWorld.components.mermkingmanager and TheWorld.components.mermkingmanager:HasKing()) and
           not (leader and leader:HasTag("player")) and
           not (leader_guy and leader_guy:HasTag("merm") and not guy:HasTag("pig"))
end

local RETARGET_CANT_TAGS = {"merm"}
local RETARGET_ONEOF_TAGS = {"player", "monster", "character"}
local function RetargetFn(inst)
    return FindEntity(inst, SpringCombatMod(TUNING.MERM_FISHER_TARGET_DIST), FindInvaderFn, nil, RETARGET_CANT_TAGS, RETARGET_ONEOF_TAGS)
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target) and target:GetPosition():DistSq(inst:GetPosition()) < TUNING.MERM_FISHER_FOLLOW_DIST * TUNING.MERM_FISHER_FOLLOW_DIST
end

local DECIDROOTTARGET_MUST_TAGS = { "_combat", "_health", "merm" }
local DECIDROOTTARGET_CANT_TAGS = { "INLIMBO" }

local function OnAttackedByDecidRoot(inst, attacker)
    local share_target_dist = TUNING.MERM_SHARE_TARGET_DIST
    local max_target_shares = TUNING.MERM_MAX_TARGET_SHARES

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, SpringCombatMod(share_target_dist) * .5, DECIDROOTTARGET_MUST_TAGS, DECIDROOTTARGET_CANT_TAGS)
    local num_helpers = 0

    for i, v in ipairs(ents) do
        if v ~= inst and not v.components.health:IsDead() then
            v:PushEvent("suggest_tree_target", { tree = attacker })
            num_helpers = num_helpers + 1
            if num_helpers >= max_target_shares then
                break
            end
        end
    end
end

local NO_TAGS = {"FX", "NOCLICK", "DECOR", "INLIMBO"}
local HOUSE_TAGS = {"mermhouse"}

local function OnAttacked(inst, data)

    local attacker = data and data.attacker
    if attacker and attacker.prefab == "deciduous_root" and attacker.owner ~= nil then
        OnAttackedByDecidRoot(inst, attacker.owner)

    elseif attacker and inst.components.combat:CanTarget(attacker) and attacker.prefab ~= "deciduous_root" then

        local share_target_dist = TUNING.MERM_SHARE_TARGET_DIST
        local max_target_shares = TUNING.MERM_MAX_TARGET_SHARES

        inst.components.combat:SetTarget(attacker)

        local pt = inst:GetPosition()
        local homes = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.MERM_FISHER_ATTACKED_ALERT_DIST, HOUSE_TAGS, NO_TAGS)

        for k,v in pairs(homes) do
            if v and v.components.childspawner then
                v.components.childspawner:ReleaseAllChildren(attacker)
            end
        end

        inst.components.combat:ShareTarget(attacker, share_target_dist, function(dude)
            return (dude:HasTag("mermfighter") and not
                (dude.components.follower and dude.components.follower.leader and dude.components.follower.leader:HasTag("player")))
        end, max_target_shares)
    end
end

local function RoyalUpgrade(inst)
    if inst.components.health:IsDead() then
        return
    end

    inst.fishtimer_mult = 0.75

    if inst.components.timer:TimerExists("fish") then
        inst.components.timer:SetTimeLeft("fish", inst.components.timer:GetTimeLeft("fish") * 0.75)
    end

    inst.Transform:SetScale(1.05, 1.05, 1.05)
end

local function RoyalDowngrade(inst)
    if inst.components.health:IsDead() then
        return
    end

    inst.fishtimer_mult = 1

    if inst.components.timer:TimerExists("fish") then
        inst.components.timer:SetTimeLeft("fish", inst.components.timer:GetTimeLeft("fish") / 0.75)
    end

    inst.Transform:SetScale(1, 1, 1)
end

local function ResolveMermChatter(inst, strid, strtbl)
    local stringtable = STRINGS[strtbl:value()]
    if stringtable then
        if stringtable[strid:value()] ~= nil then
            if ThePlayer and ThePlayer:HasTag("mermfluent") then
                return stringtable[strid:value()][1] -- First value is always the translated one
            else
                return stringtable[strid:value()][2]
            end
        end
    end
end

local function ShouldSleep(inst)
    return NocturnalSleepTest(inst)
end

local function ShouldWake(inst)
    return NocturnalWakeTest(inst)
end

local function OnTimerDone(inst, data)
    if data.name == "fish" then
        inst.CanFish = true
    end
end

local function OnCollect(inst)
    inst.CanFish = false

    if inst.components.timer:TimerExists("fish") then
        inst.components.timer:StopTimer("fish")
    end

    inst.components.timer:StartTimer("fish", TUNING.MERM_FISHER_FISH_TIMER * inst.fishtimer_mult)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("pigman")
    inst.AnimState:SetBuild("merm_fisherman_build")

    inst.sounds = sounds

    inst:AddTag("character")
    inst:AddTag("merm")
    inst:AddTag("mermfisher")
    inst:AddTag("wet")

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker.resolvechatterfn = ResolveMermChatter
    inst.components.talker:MakeChatter()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.talker.ontalk = ontalk

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.MERM_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.MERM_WALK_SPEED

    -- boat hopping enable.
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

    inst:SetStateGraph("SGmerm")
    inst:SetBrain(merm_fisher_brain)
    inst.AnimState:Hide("hat")

    inst:AddComponent("eater")
    inst.components.eater:SetVegetarian()

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MERM_FISHER_HEALTH)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)


    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetNocturnal(true)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)


    MakeHauntablePanic(inst)
    MakeMediumBurnableCharacter(inst, "pig_torso")
    MakeMediumFreezableCharacter(inst, "pig_torso")

    inst:AddComponent("fishingrod")
    inst.components.fishingrod:SetWaitTimes(TUNING.BIG_FISHING_ROD_MIN_WAIT_TIME, TUNING.BIG_FISHING_ROD_MAX_WAIT_TIME)
    inst.components.fishingrod:SetStrainTimes(0, 5)
    inst.components.fishingrod.basenibbletime = TUNING.BIG_FISHING_ROD_BASE_NIBBLE_TIME
    inst.components.fishingrod.nibbletimevariance = TUNING.BIG_FISHING_ROD_NIBBLE_TIME_VARIANCE
    inst.components.fishingrod.nibblestealchance = 0

    inst:AddComponent("timer")

    inst:AddComponent("named")
    inst.components.named.possiblenames = STRINGS.MERMNAMES
    inst.components.named:PickNewName()

    inst.CanFish = true
    inst.fishtimer_mult = 1

    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("fishingcollect", OnCollect)

    inst:ListenForEvent("onmermkingcreated", function()
        inst:DoTaskInTime(math.random()*SLIGHTDELAY,function()
            RoyalUpgrade(inst)
            inst:PushEvent("onmermkingcreated")
        end)
    end, TheWorld)
    inst:ListenForEvent("onmermkingdestroyed", function()
        inst:DoTaskInTime(math.random()*SLIGHTDELAY,function()
            RoyalDowngrade(inst)
            inst:PushEvent("onmermkingdestroyed")
        end)
    end, TheWorld)

    if TheWorld.components.mermkingmanager and TheWorld.components.mermkingmanager:HasKing() then
        RoyalUpgrade(inst)
    end

    return inst
end

return Prefab("mermfisher", fn, assets, prefabs)