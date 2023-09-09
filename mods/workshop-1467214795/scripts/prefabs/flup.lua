local brain = require("brains/flupbrain")

local assets =
{
    Asset("ANIM", "anim/flup_build.zip"),
    Asset("ANIM", "anim/flup_basic.zip"),
}

local prefabs =
{
    "blowdart_flup",
    "monstermeat",
}

SetSharedLootTable('flup',
{
    {'monstermeat',   1.00},
    {'blowdart_flup', 0.25},
})

local function sleeptestfn(inst)
    return false
end

local RETARGET_CANT_TAGS = {"flup", "FX", "NOCLICK"}
local function retargetfn(inst)
    if inst.sg:HasStateTag("ambusher") then
        -- Hiding in dirt, looking to attack.
        return FindEntity(inst, 7, function(guy)
            return inst.components.combat:CanTarget(guy)
        end, nil, RETARGET_CANT_TAGS)
    end
end

local function keeptargetfn(inst, target)
    local homePos = inst.components.knownlocations:GetLocation("home")

    return target
        and target.components.combat
        and target.components.health
        and not target.components.health:IsDead()
        and inst:GetPosition():Dist(target:GetPosition()) < 15
        and (homePos and homePos:Dist(target:GetPosition()) < 30)
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()

    inst.DynamicShadow:SetSize(1.5, 0.75)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("flup")
    inst.AnimState:SetBuild("flup_build")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("flup")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("poisonimmune")
    inst:AddTag("canbetrapped")

    MakeCharacterPhysics(inst, 1, 0.3)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.FLUP_WALKSPEED
    inst.components.locomotor.runspeed = TUNING.FLUP_RUNSPEED

    inst:SetStateGraph("SGflup")
    inst:SetBrain(brain)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.FLUP_HEALTH)

    inst:AddComponent("combat")
    inst.components.combat:SetRetargetFunction(1.5, retargetfn)
    inst.components.combat:SetKeepTargetFunction(keeptargetfn)
    inst.components.combat:SetDefaultDamage(TUNING.FLUP_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.FLUP_ATTACK_PERIOD)
    inst.components.combat:SetRange(TUNING.FLUP_JUMPATTACK_RANGE, TUNING.FLUP_HIT_RANGE)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable("flup")
    inst:AddComponent("knownlocations")
    inst:AddComponent("inspectable")

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetSleepTest(sleeptestfn)

    -- boat hopping enable.
    inst.components.locomotor:SetAllowPlatformHopping(true)
    inst:AddComponent("embarker")
    inst:AddComponent("drownable")

    inst:DoTaskInTime(FRAMES, function() inst.components.knownlocations:RememberLocation("home", inst:GetPosition(), true) end)

    MakeHauntablePanic(inst)
    MakeTinyFreezableCharacter(inst)
    MakeSmallBurnableCharacter(inst, "flup_body")

    return inst
end

return Prefab("flup", fn, assets, prefabs)
