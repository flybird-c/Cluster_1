local assets =
{
    Asset("ANIM", "anim/twister_build.zip"),
    Asset("ANIM", "anim/twister_basic.zip"),
    Asset("ANIM", "anim/twister_actions.zip"),
    Asset("ANIM", "anim/twister_seal.zip"),
}

local prefabs =
{
    "collapse_small",
    "turbine_blades",
    "twister_seal",
    "magic_seal",
    "chesspiece_twister_sketch",
}

SetSharedLootTable("twister",
{
    {"turbine_blades",   1.00},
    {"chesspiece_twister_sketch",   1.00},
})

local TARGET_DIST = 20

local function OnEntitySleep(inst)
    if inst.shouldGoAway then
        inst.shouldGoAway = false
        TheWorld:PushEvent("storetwister", inst)
        inst:Remove()
    end
end

local function CalcSanityAura(inst, observer)
    if inst.components.combat.target then
        return -TUNING.SANITYAURA_HUGE
    end

    return -TUNING.SANITYAURA_LARGE
end

local MUST_TAGS = {"prey", "smallcreature"}
local function RetargetFn(inst)
    return FindEntity(inst, TARGET_DIST, function(guy)
        return inst.components.combat:CanTarget(guy)
    end, nil, MUST_TAGS)
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target) 
end

local function OnSave(inst, data)
    data.CanVacuum = inst.CanVacuum
    data.CanCharge = inst.CanCharge
    data.shouldGoAway = inst.shouldGoAway
end

local function OnLoad(inst, data)
    if data then
        inst.CanVacuum = data.CanVacuum
        inst.CanCharge = data.CanCharge
        inst.shouldGoAway = data.shouldGoAway or false
    end
end

local function OnSeasonChange(inst, data)
    inst.shouldGoAway = not TheWorld.state.isspring or inst.shouldGoAway

    if inst:IsAsleep() then
        OnEntitySleep(inst)
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    if data.attacker:HasTag("player") then
        inst.shouldGoAway = false
    end
end

local function OnRemove(inst)
    inst.components.vacuum:Release_Held_Players()
    TheWorld:PushEvent("twisterremoved", inst)
end

local function OnDead(inst)
    inst.components.vacuum:Release_Held_Players()
    TheWorld:PushEvent("twisterkilled", inst)
end

local function ontimerdone(inst, data)
    if data.name == "Vacuum" then 
        inst.CanVacuum = true 
    elseif data.name == "Charge" then
        inst.CanCharge = true
    end
end

local function OnKill(inst, data)
    if data and data.victim and data.victim:HasTag("player") then
        inst.shouldGoAway = true
    end
end

local function fn(Sim)
    local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()
    
    inst.Transform:SetFourFaced()
    inst.DynamicShadow:SetSize(6, 3.5)
    
    inst.Transform:SetScale(1, 1, 1)

    inst.Physics:SetMass(1000)
    inst.Physics:SetCapsule(1.5, 1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith((TheWorld.has_ocean and COLLISION.GROUND) or COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)

    inst.AnimState:SetBank("twister")
    inst.AnimState:SetBuild("twister_build")
    inst.AnimState:PlayAnimation("idle_loop", true)

	inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("twister")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")
    inst:AddTag("soulless")
    inst:AddTag("poisonimmune")
    inst:AddTag("ignorewalkableplatforms") --might need to start using amphib creature now...

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    ------------------

    inst:AddComponent("inventory")
    inst:AddComponent("timer")

    ------------------
    
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    ------------------
    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.TWISTER_HEALTH)
    inst.components.health.destroytime = 5
    
    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.TWISTER_DAMAGE)
    inst.components.combat.playerdamagepercent = TUNING.TWISTER_DAMAGE_PLAYER_PERCENT
    inst.components.combat:SetRange(TUNING.TWISTER_ATTACK_RANGE, TUNING.TWISTER_MELEE_RANGE)
    inst.components.combat:SetAreaDamage(TUNING.TWISTER_MELEE_RANGE, 0.8)
    inst.components.combat:SetAttackPeriod(TUNING.TWISTER_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    --inst.components.combat:SetHurtSound("")
 
    ------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("twister")
    
    ------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    ------------------

    inst:AddComponent("vacuum")
    inst.components.vacuum:TurnOn()
    inst.components.vacuum.playervacuumdamage = TUNING.TWISTER_VACUUM_DAMAGE
    inst.components.vacuum.playervacuumsanityhit = TUNING.TWISTER_VACUUM_SANITY_HIT
    inst.components.vacuum.vacuumradius = TUNING.TWISTER_VACUUM_DISTANCE
    inst.components.vacuum.playervacuumradius = TUNING.TWISTER_PLAYER_VACUUM_DISTANCE

    ------------------

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.TWISTER_CALM_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.TWISTER_RUN_SPEED
    inst.components.locomotor:SetShouldRun(true)
    inst.components.locomotor.pathcaps = { allowocean = true }

    ------------------

    inst:AddComponent("knownlocations")
    
    inst:SetStateGraph("SGtwister")
    local brain = require("brains/twisterbrain")
    inst:SetBrain(brain)

    ------------------
    inst:WatchWorldState("season", OnSeasonChange)

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("entitysleep", OnEntitySleep)
    inst:ListenForEvent("timerdone", ontimerdone)
    inst:ListenForEvent("killed", OnKill)
    inst:ListenForEvent("death", OnDead)
    inst:ListenForEvent("onremove", OnRemove)

    ------------------

    inst.CanVacuum = true
    inst.CanCharge = true
    inst.shouldGoAway = false
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst.SoundEmitter:PlaySound("ia/creatures/twister/active_LP", "wind_loop")
    inst.SoundEmitter:SetParameter("wind_loop", "intensity", 0)

    inst.AnimState:Hide("twister_water_fx")
    ------------------

    return inst
end

return Prefab("twister", fn, assets, prefabs)
