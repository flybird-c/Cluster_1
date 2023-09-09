--Need to make this enemy much less player focused.
--Doesn"t target player by default.
--Only if hit or if sharkittens threatened.

local assets =
{
    Asset("ANIM", "anim/tigershark_build.zip"),
    Asset("ANIM", "anim/tigershark_ground_build.zip"),
    Asset("ANIM", "anim/tigershark_ground.zip"),
    Asset("ANIM", "anim/tigershark_water_build.zip"),
    Asset("ANIM", "anim/tigershark_water.zip"),
    Asset("ANIM", "anim/tigershark_water_ripples_build.zip"),
}

local prefabs =
{
    "tigersharkshadow",
    "splash_water_big",
    "groundpound_fx",
    "groundpoundring_fx",
    "mysterymeat",
    "fishmeat",
    "tigereye",
    "shark_gills",
    "chesspiece_tigershark_sketch",
}

SetSharedLootTable("tigershark",
{
    {"fishmeat", 1.00},
    {"fishmeat", 1.00},
    {"fishmeat", 1.00},
    {"fishmeat", 1.00},
    {"fishmeat", 1.00},
    {"fishmeat", 1.00},
    {"fishmeat", 1.00},
    {"fishmeat", 1.00},

    {"tigereye", 1.00},
    {"tigereye", 0.50},

    {"shark_gills", 1.00},
    {"shark_gills", 1.00},
    {"shark_gills", 0.33},
    {"shark_gills", 0.10},

    {"chesspiece_tigershark_sketch", 1.00},
})

local TARGET_DIST = 20
local HEALTH_THRESHOLD = 0.1
local HOME_PROTECTION_DISTANCE = 60

local brain = require "brains/tigersharkbrain"

local function ShouldSleep(inst)
    return false
end

local function ShouldWake(inst)
    return true
end

local function GetTarget(inst)
    --Used for logic of moving between land and water states
    local target = inst.components.combat.target and inst.components.combat.target:GetPosition()

    if not target and inst:GetBufferedAction() then
        --in dst the pos from buffered action is a DynamicPosition and works differently -Half
        target = (inst:GetBufferedAction().target and inst:GetBufferedAction().target:GetPosition()) or (inst:GetBufferedAction().pos and inst:GetBufferedAction().pos:GetPosition())
    end

    --Returns a position
    return target
end

local function GroundTypesMatch(inst, target)
    local target = target and ((target.prefab and target:GetPosition()) or (target:IsVector3() and target)) or GetTarget(inst)

    if target and target.x and target.y and target.z then
        local targettile = TheWorld.Map:GetVisualTileAtPoint(target:Get())
        return (not inst:HasTag("swimming") and IsLandTile(targettile)) or
            (inst:HasTag("swimming") and IsOceanTile(targettile))
    end

    return true
end

local function FindSharkHome(inst)
    local tigersharker = TheWorld.components.tigersharker
    if tigersharker ~= nil then return tigersharker.shark_home end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
end

local RETARGET_HOME_CANT_TAGS = {"prey", "smallcreature", "bird", "butterfly", "sharkitten"}
local RETARGET_CANT_TAGS = {"prey", "smallcreature", "bird", "butterfly", "sharkitten", "player", "companion"}

local function RetargetFn(inst)
    local home = FindSharkHome(inst)

    if home and home:GetPosition():Dist(inst:GetPosition()) < HOME_PROTECTION_DISTANCE then
        --Aggressive to the player if close to home
        return FindEntity(inst, TARGET_DIST,
            function(tar) return inst.components.combat:CanTarget(tar) end, nil,
            RETARGET_HOME_CANT_TAGS)
    elseif inst.components.health:GetPercent() > HEALTH_THRESHOLD then
        --Not aggressive to the player if far from home
        return FindEntity(inst, TARGET_DIST,
            function(tar) return inst.components.combat:CanTarget(tar) end, nil,
            RETARGET_CANT_TAGS)
    end
end

local function KeepTargetFn(inst, target)
    --If this thing is close to my kittens keep target no matter what.
    local home = FindSharkHome(inst)
    if inst.components.health:GetPercent() < HEALTH_THRESHOLD and home and home:GetPosition():Dist(inst:GetPosition()) > HOME_PROTECTION_DISTANCE then
        --If I'm low health & not protecting my home, flee.
        return false
    else
        return inst.components.combat:CanTarget(target)
    end
end

local function ontimerdone(inst, data)
    if data.name == "Run" then
        inst.CanRun = true
    end
end

local function MakeWater(inst)
    inst:ClearStateGraph()
    if inst.components.combat then
        inst.components.combat:SetRange(TUNING.TIGERSHARK_ATTACK_SEA_RANGE)
    end
    inst:SetStateGraph("SGtigershark_water")
    inst.AnimState:SetBuild("tigershark_water_build")
    inst.AnimState:AddOverrideBuild("tigershark_water_ripples_build")
    inst.components.locomotor.pathcaps.allowocean = true
    inst.components.locomotor.pathcaps.ignoreLand = true
    inst:AddTag("swimming")
    inst.DynamicShadow:Enable(false)
end

local function MakeGround(inst)
    inst:ClearStateGraph()
    if inst.components.combat then
        inst.components.combat:SetRange(TUNING.TIGERSHARK_ATTACK_RANGE)
    end
    inst:SetStateGraph("SGtigershark_ground")
    inst.AnimState:SetBuild("tigershark_ground_build")
    inst.components.locomotor.pathcaps.allowocean = false
    inst.components.locomotor.pathcaps.ignoreLand = false
    inst:RemoveTag("swimming")
    inst.DynamicShadow:Enable(true)
end

local function oncollapse(inst, other)
    if other:IsValid() and other.components.workable ~= nil and other.components.workable:CanBeWorked() then
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        other.components.workable:Destroy(inst)
    end
end

local function oncollide(inst, other)
    if other ~= nil and
        (other:HasTag("tree") or other:HasTag("boulder")) and --HasTag implies IsValid
        Vector3(inst.Physics:GetVelocity()):LengthSq() >= 1 then
        inst:DoTaskInTime(2 * FRAMES, oncollapse, other)
    end
end

local function OnSave(inst, data)
    data.CanRun = inst.CanRun
    data.NextFeedTime = GetTime() - inst.NextFeedTime
end

local function OnLoad(inst, data)
    if data then
        inst.CanRun = data.CanRun or true
        inst.NextFeedTime = data.NextFeedTime or 0
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()
    inst.DynamicShadow:SetSize(6, 3)
    inst.DynamicShadow:Enable(false)

    inst:AddTag("scarytoprey")
    inst:AddTag("tigershark")
    inst:AddTag("monster") --for "mine" components, can be "animal" instead if "monster" is problematic -M
    inst:AddTag("largecreature")
    inst:AddTag("epic")
    inst:AddTag("ignorewalkableplatformdrowning")

    MakeCharacterPhysics(inst, 1000, 1.33)

    inst.AnimState:SetBank("tigershark")
    inst.AnimState:SetBuild("tigershark_water_build")
    inst.AnimState:PlayAnimation("water_run", true)
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:AddOverrideBuild("tigershark_water_ripples_build")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Physics:SetCollisionCallback(oncollide)

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.TIGERSHARK_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.TIGERSHARK_RUN_SPEED
    inst.components.locomotor.pathcaps = { allowocean = true, ignoreLand = true }

    inst:AddComponent("rowboatwakespawner")

    inst:AddComponent("inspectable")
    inst.no_wet_prefix = true

    inst:AddComponent("knownlocations")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.TIGERSHARK_HEALTH)

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({FOODGROUP.TIGERSHARK}, {FOODGROUP.TIGERSHARK})--{FOODTYPE.MEAT})

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("tigershark")

    inst:AddComponent("groundpounder")
    inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.damageRings = 3
    inst.components.groundpounder.destructionRings = 1
    inst.components.groundpounder.numRings = 3
    inst.components.groundpounder.noTags = {"FX", "NOCLICK", "DECOR", "INLIMBO", "sharkitten"}

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.TIGERSHARK_DAMAGE)
    inst.components.combat.playerdamagepercent = TUNING.TIGERSHARK_DAMAGE_PLAYER_PERCENT
    inst.components.combat:SetRange(TUNING.TIGERSHARK_ATTACK_RANGE)
    inst.components.combat:SetAreaDamage(TUNING.TIGERSHARK_SPLASH_RADIUS, TUNING.TIGERSHARK_SPLASH_DAMAGE/TUNING.TIGERSHARK_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.TIGERSHARK_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/bearger/hurt")
    inst.components.combat.notags = {"sharkitten"}

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)

    inst:ListenForEvent("killed", function(inst, data)
        if inst.components.combat and data and data.victim == inst.components.combat.target then
            inst.components.combat.target = nil
        end
    end)

    inst.CanRun = true --Can do charge attack

    inst.CanFly = false --Can do leap attack

    --[[
    - While in water, tigershark jumps every third attack.
    - While on ground, tigershark *can* jump after every third attack, but will
    only jump to close distance.

    This logic is controlled through the tigershark's stategraphs.
    --]]

    inst.AttackCounter = 0
    inst.NextFeedTime = 0
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.GroundTypesMatch = GroundTypesMatch
    inst.FindSharkHome = FindSharkHome
    inst.GetTarget = GetTarget
    inst.MakeGround = MakeGround
    inst.MakeWater = MakeWater

    inst:SetStateGraph("SGtigershark_water")
    inst:SetBrain(brain)

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)
    inst:ListenForEvent("attacked", OnAttacked)

    inst:DoTaskInTime(1*FRAMES, function(inst)
        if IsOnOcean(inst) then
            inst:MakeWater()
            inst.sg:GoToState("idle")
        else
            inst:MakeGround()
            inst.sg:GoToState("idle")
        end
    end)

    return inst
end

return Prefab( "tigershark", fn, assets, prefabs)
