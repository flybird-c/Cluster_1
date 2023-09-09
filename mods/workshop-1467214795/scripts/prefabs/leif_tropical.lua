local IA_CONFIG = IA_CONFIG or {}
local brain = require "brains/treeguardbrain"

local assets_palm = {
    Asset("ANIM", "anim/treeguard_walking.zip"),
    Asset("ANIM", "anim/treeguard_actions.zip"),
    Asset("ANIM", "anim/treeguard_attacks.zip"),
    Asset("ANIM", "anim/treeguard_idles.zip"),
    Asset("ANIM", "anim/treeguard_build.zip"),
}

local assets_jungle = {
    Asset("ANIM", "anim/jungletreeguard_walking.zip"),
    Asset("ANIM", "anim/jungletreeguard_actions.zip"),
    Asset("ANIM", "anim/jungletreeguard_attacks.zip"),
    Asset("ANIM", "anim/jungletreeguard_idles.zip"),
    Asset("ANIM", "anim/jungletreeguard_build.zip"),
}

local prefabs = {
    "meat",
    "log",
    "character_fire",
    "livinglog",
}

local prefabs_palm = {
    "treeguard_coconut",
}

local prefabs_jungle = {
    "bird_egg",
    "treeguard_banana",
    "treeguard_snake",
    "treeguard_snake_poison",
}

for i,v in pairs(prefabs) do
    table.insert(prefabs_palm, v)
    table.insert(prefabs_jungle, v)
end

SetSharedLootTable( 'leif_palm',
{
    {"livinglog",   1.0},
    {"livinglog",   1.0},
    {"livinglog",   1.0},
    {"livinglog",   1.0},
    {"livinglog",   1.0},
    {"livinglog",   1.0},
    {"monstermeat", 1.0},
    {"coconut",     1.0},
    {"coconut",     1.0},
})

SetSharedLootTable( 'leif_jungle',
{
    {"livinglog",     1.0},
    {"livinglog",     1.0},
    {"livinglog",     1.0},
    {"livinglog",     1.0},
    {"livinglog",     1.0},
    {"livinglog",     1.0},
    {"monstermeat",   1.0},
    {"cave_banana",   1.0},
    {"cave_banana",   1.0},
    {"bird_egg",      0.25},
    {"snake",         1.0},
    {"snake",         0.5},
    {"snake_poison",  0.25},
})

local statsdata_palm = {
    health = TUNING.PALMTREEGUARD_HEALTH,
    damage = TUNING.PALMTREEGUARD_DAMAGE,
    period = TUNING.PALMTREEGUARD_ATTACK_PERIOD,
    flammability = TUNING.PALMTREEGUARD_FLAMMABILITY,
    playerdamagepercent = TUNING.PALMTREEGUARD_DAMAGE_PLAYER_PERCENT,
    capsulesize = 0.5,
    shadow1 = 4,
    shadow2 = 1.5,
}

local statsdata_jungle = {
    health = TUNING.JUNGLETREEGUARD_HEALTH,
    damage = TUNING.JUNGLETREEGUARD_DAMAGE,
    period = TUNING.JUNGLETREEGUARD_ATTACK_PERIOD,
    flammability = TUNING.JUNGLETREEGUARD_FLAMMABILITY,
    playerdamagepercent = TUNING.JUNGLETREEGUARD_DAMAGE_PLAYER_PERCENT,
    capsulesize = 0.75,
    shadow1 = 7,
    shadow2 = 2,
}

local function SetLeifScale(inst, scale)
    inst._scale = scale ~= 1 and scale or nil

    inst.Transform:SetScale(scale,scale,scale)
    inst.Physics:SetCapsule(inst.statsdata.capsulesize * scale, 1)
    inst.DynamicShadow:SetSize(inst.statsdata.shadow1 * scale, inst.statsdata.shadow2 * scale)

    inst.components.locomotor.walkspeed = 1.5 * scale

    inst.components.combat:SetDefaultDamage(inst.statsdata.damage * scale)
    inst.components.combat:SetRange(20, 25)

    local health_percent = inst.components.health:GetPercent()
    inst.components.health:SetMaxHealth(inst.statsdata.health * scale)
    inst.components.health:SetPercent(health_percent, true)
end

local function onpreloadfn(inst, data)
    if data ~= nil and data.leifscale ~= nil then
        SetLeifScale(inst, data.leifscale)
    end
end

local function onloadfn(inst, data)
    if data ~= nil then
        if data.hibernate then
            inst.components.sleeper.hibernate = true
        end
        if data.sleep_time ~= nil then
            inst.components.sleeper.testtime = data.sleep_time
        end
        if data.sleeping then
            inst.components.sleeper:GoToSleep()
        end
    end
end

local function onsavefn(inst, data)
    data.leifscale = inst._scale

    if inst.components.sleeper:IsAsleep() then
        data.sleeping = true
        data.sleep_time = inst.components.sleeper.testtime
    end

    if inst.components.sleeper:IsHibernating() then
        data.hibernate = true
    end
end

local function CalcSanityAura(inst)
    return inst.components.combat.target ~= nil and -TUNING.SANITYAURA_LARGE or -TUNING.SANITYAURA_MED
end

local function OnBurnt(inst)
    if inst.components.propagator and inst.components.health and not inst.components.health:IsDead() then
        inst.components.propagator.acceptsheat = true
    end
end

local SNAKE_PROTECTION_DIST = 15 --2 for normal jungletrees, but can alert any amount of snakes not just 5
local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    if inst:HasTag("jungletree") then
        inst.components.combat:ShareTarget(data.attacker, SNAKE_PROTECTION_DIST, function(dude) return dude:HasTag("snake")and not dude.components.health:IsDead() end, 5)
    end
end

local function OnAttack(inst, data)
    local numshots = 3
    if data.target and data.target:IsValid() then
        for i = 0, numshots - 1 do
        local offset = Vector3(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
            inst.components.thrower:Throw(data.target:GetPosition() + offset)
        end
    end
end

local function JungleOnThrow(inst)
    local throwable_prefab = "treeguard_banana"
    if math.random() < TUNING.JUNGLETREEGUARD_SNAKE_CHANCE then
        if math.random() < TUNING.JUNGLETREEGUARD_SNAKE_POISON_CHANCE then
            throwable_prefab = "treeguard_snake_poison"
        else
            throwable_prefab = "treeguard_snake"
        end
    end

    inst.components.thrower.throwable_prefab = throwable_prefab
end

local function SetRangeMode(inst)
    if inst.combatmode == "RANGE" then
        return
    end
    local scale = inst._scale or 1
    inst.combatmode = "RANGE"
    inst.components.combat:SetDefaultDamage(0)
    inst.components.combat:SetAttackPeriod(6)
    inst.components.combat:SetRange(20*scale, 25*scale)
    inst:ListenForEvent("onattackother", OnAttack)
end

local function SetMeleeMode(inst)
    if inst.combatmode == "MELEE" then
        return
    end

    local scale = inst._scale or 1
    inst.combatmode = "MELEE"
    inst.components.combat:SetDefaultDamage(inst.statsdata.damage * scale)
    inst.components.combat:SetAttackPeriod(inst.statsdata.period)
    inst.components.combat:SetRange(20*scale, 3*scale)
    inst:RemoveEventCallback("onattackother", OnAttack)
end


local function common_fn(bank, build, tags, hitsymbol, statsdata)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()

    inst.statsdata = statsdata

    inst.DynamicShadow:SetSize(inst.statsdata.shadow1, inst.statsdata.shadow2 )
    inst.Transform:SetFourFaced()

    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 1000, inst.statsdata.capsulesize)

    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("leif")
    inst:AddTag("tree")
    inst:AddTag("largecreature")
    inst:AddTag("epic")

    if type(tags) == "table" then
        for _,tag in pairs(tags) do
            inst:AddTag(tag)
        end
    end

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- Add a random colour multiplier to avoid samey-ness.
    inst.color = 0.5 + math.random() * 0.5
    inst.AnimState:SetMultColour(inst.color, inst.color, inst.color, 1)

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    MakeLargeBurnableCharacter(inst, hitsymbol)
    inst.components.burnable.flammability = inst.statsdata.flammability
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    inst.components.propagator.acceptsheat = true

    MakeHugeFreezableCharacter(inst, hitsymbol)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(inst.statsdata.health)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = hitsymbol
    inst.components.combat:SetDefaultDamage(inst.statsdata.damage)
    inst.components.combat:SetAttackPeriod(inst.statsdata.period)
    inst.components.combat:SetRange(20, 25)
    inst.components.combat.playerdamagepercent = inst.statsdata.playerdamagepercent

    ------------------------------------------
    MakeHauntableIgnite(inst)
    ------------------------------------------
    
    inst:AddComponent("thrower")

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)

    inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    inst:SetBrain(brain)

    inst.OnPreLoad = onpreloadfn
    inst.OnLoad = onloadfn
    inst.OnSave = onsavefn

    inst.SetRange = SetRangeMode
    inst.SetMelee = SetMeleeMode

    inst:ListenForEvent("attacked", OnAttacked)

    inst.SetLeifScale = SetLeifScale

    return inst
end

local function palm_fn()
    local inst = common_fn("treeguard", "treeguard_build", {"palmtree"}, "marker", statsdata_palm)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.locomotor.walkspeed = 1.5

    inst.components.lootdropper:SetChanceLootTable('leif_palm')

    inst.components.thrower.throwable_prefab = "treeguard_coconut"

    inst:SetStateGraph("SGtreeguard")

    return inst
end

local function jungle_fn()
    local inst = common_fn("jungletreeguard", "jungleTreeGuard_build", {"jungletree", "snakefriend"}, "body", statsdata_jungle)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.locomotor.walkspeed = 2.5

    inst.components.inspectable.nameoverride = "leif_palm"

    inst.components.lootdropper:SetChanceLootTable('leif_jungle')

    JungleOnThrow(inst)
    inst.components.thrower.onthrowfn = JungleOnThrow

    inst:SetStateGraph("SGtreeguard_jungle")

    if not IA_CONFIG.leif_jungle then
        inst:DoTaskInTime(0, function(_inst) _inst.components.health:Kill() end)
    end

    return inst
end

return Prefab("leif_palm", palm_fn, assets_palm, prefabs_palm),
    Prefab("leif_jungle", jungle_fn, assets_jungle, prefabs_jungle)
