local bluebrain = require("brains/bluewhalebrain")
local whitebrain = require("brains/whitewhalebrain")

local assets_blue =
{
    Asset("ANIM", "anim/whale.zip"),
    Asset("ANIM", "anim/whale_blue_build.zip"),
    -- Asset("SOUND", "sound/koalefant.fsb"),
}
local assets_white =
{
    Asset("ANIM", "anim/whale.zip"),
    Asset("ANIM", "anim/whale_moby_build.zip"),
    -- Asset("SOUND", "sound/koalefant.fsb"),
}

local prefabs =
{
    -- "fishmeat_cooked",
    "boneshard",
    "whale_carcass_blue",
    "whale_carcass_white",
    "whale_bubbles",
    "whale_track",
}

local bluesounds =
{
    death = "ia/creatures/blue_whale/death",
    hit = "ia/creatures/blue_whale/hit",
    idle = "ia/creatures/blue_whale/idle",
    breach_swim = "ia/creatures/blue_whale/breach_swim",
    sleep = "ia/creatures/blue_whale/sleep",
    rear_attack = "ia/creatures/blue_whale/rear_attack",
    mouth_open = "ia/creatures/blue_whale/mouth_open",
    bite_chomp = "ia/creatures/blue_whale/chomp",
    bite = "ia/creatures/blue_whale/bite",
}

local whitesounds =
{
    death = "ia/creatures/white_whale/death",
    hit = "ia/creatures/white_whale/hit",
    idle = "ia/creatures/white_whale/idle",
    breach_swim = "ia/creatures/white_whale/breach_swim",
    sleep = "ia/creatures/white_whale/sleep",
    rear_attack = "ia/creatures/white_whale/rear_attack",
    mouth_open = "ia/creatures/white_whale/mouth_open",
    bite_chomp = "ia/creatures/white_whale/chomp",
    bite = "ia/creatures/white_whale/bite",
}

--local loot_blue = {"fishmeat_cooked","fishmeat_cooked","fishmeat_cooked","fishmeat_cooked","fishmeat_cooked","fishmeat_cooked","boneshard","boneshard","boneshard","boneshard"}
--local loot_white = {"fishmeat_cooked","fishmeat_cooked","fishmeat_cooked","fishmeat_cooked","fishmeat_cooked","fishmeat_cooked","boneshard","boneshard","boneshard","boneshard"}


local WAKE_TO_RUN_DISTANCE = 10
local SLEEP_NEAR_ENEMY_DISTANCE = 14

local function ShouldWakeUp(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    return DefaultWakeTest(inst) or IsAnyPlayerInRange(x, y, z, WAKE_TO_RUN_DISTANCE)
end

local function ShouldSleep(inst)
    -- local x, y, z = inst.Transform:GetWorldPosition()
    -- return DefaultSleepTest(inst) and not IsAnyPlayerInRange(x, y, z, SLEEP_NEAR_ENEMY_DISTANCE)
    return false --only sleep from items
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30,function(dude)
        return dude:HasTag("whale") and not dude:HasTag("player") and not dude.components.health:IsDead()
    end, 5)
end

local function OnLoad(inst, data)
    if not data then
        return
    end

    inst.hitshallow = data.hitshallow
end

local function OnSave(inst, data)
    data.hitshallow = inst.hitshallow
end

local function fn_common()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 140, .75)

    inst.AnimState:SetBank("whale")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("whale")
    inst:AddTag("animal")
    inst:AddTag("largecreature")
    -- inst:AddTag("scarytoprey")

    return inst
end

local function fn_master(inst)
    inst:AddComponent("combat")

    inst:ListenForEvent("attacked", function(inst, data) OnAttacked(inst, data) end)

    inst:AddComponent("health")

    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")
    inst:AddComponent("locomotor")
    inst.components.locomotor.pathcaps = { allowocean = true, ignoreLand = true }

    inst:AddComponent("sleeper")
    inst.components.sleeper.onlysleepsfromitems = true
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    inst:SetStateGraph("SGwhale")

    inst:AddComponent("tiletracker")

    MakeHauntablePanic(inst)
    MakePoisonableCharacter(inst)
    MakeLargeFreezableCharacter(inst)

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave
end

local function KeepTargetBlue(inst, target)
    return inst:IsNear(target, TUNING.WHALE_BLUE_CHASE_DIST)
end

local function fn_blue(sim)
    local inst = fn_common(sim)

    inst.AnimState:SetBuild("whale_blue_build")
    inst.carcass = "whale_carcass_blue"

    inst.sounds = bluesounds

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    fn_master(inst)

    inst.components.combat:SetHurtSound(inst.sounds.hit)

    inst.components.locomotor.walkspeed = TUNING.WHALE_BLUE_SPEED * 0.5
    inst.components.locomotor.runspeed = TUNING.WHALE_BLUE_SPEED

    inst.components.combat:SetKeepTargetFunction(KeepTargetBlue)
    inst.components.combat:SetDefaultDamage(TUNING.WHALE_BLUE_DAMAGE)
    inst.components.combat:SetAttackPeriod(3.5)

    inst.components.health:SetMaxHealth(TUNING.WHALE_BLUE_HEALTH)

    inst.components.sleeper:SetResistance(3)

    inst:SetBrain(bluebrain)

    return inst
end

local function KeepTargetWhite(inst, target)
    return inst:IsNear(target, TUNING.WHALE_WHITE_CHASE_DIST) and not target:IsOnValidGround()
end

local function RetargetWhite(inst)
    -- White Whale is aggressive. Look for targets.
    -- They are so aggressive they attack other whales, this seems intentional -Half
    return FindEntity(inst, TUNING.WHALE_WHITE_TARGET_DIST, function(guy)
        return inst.components.combat:CanTarget(guy) and not guy:IsOnValidGround()
    end)
end

local function fn_white(sim)
    local inst = fn_common(sim)

    local s = 1.25
    inst.Transform:SetScale(s, s, s)

    inst.AnimState:SetBuild("whale_moby_build")
    inst.carcass = "whale_carcass_white"

    inst.sounds = whitesounds

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    fn_master(inst)

    inst.components.combat:SetHurtSound(inst.sounds.hit)

    inst.components.locomotor.walkspeed = TUNING.WHALE_WHITE_SPEED * 0.5
    inst.components.locomotor.runspeed = TUNING.WHALE_WHITE_SPEED

    inst.components.combat:SetKeepTargetFunction(KeepTargetWhite)
    inst.components.combat:SetDefaultDamage(TUNING.WHALE_WHITE_DAMAGE)
    inst.components.combat:SetRetargetFunction(1, RetargetWhite)
    inst.components.combat:SetAttackPeriod(3)

    inst.components.health:SetMaxHealth(TUNING.WHALE_WHITE_HEALTH)

    inst.components.sleeper:SetResistance(5)

    inst:SetBrain(whitebrain)

    return inst
end

return Prefab( "whale_blue", fn_blue, assets_blue, prefabs),
    Prefab( "whale_white", fn_white, assets_white, prefabs)
