local assets =
{
    Asset("ANIM", "anim/quacken_tentacle.zip"),
    Asset("ANIM", "anim/quacken_tentacle_yule.zip"),
}

local prefabs =
{
    "kraken_tentacle",
}

SetSharedLootTable('kraken_tentacle',
{
    {'tentaclespots', 0.10},
    {'tentaclespike', 0.05},
})

local brain = require("brains/krakententaclebrain")

local RETARGET_CANT_TAGS = {"prey"}
local RETARGET_ONOF_TAGS = {"character", "monster", "animal"}
local function RetargetFn(inst)
    return FindEntity(inst, 7, function(guy)
        if guy.components.combat and guy.components.health and not guy.components.health:IsDead() then
            return not (guy.prefab == inst.prefab)
        end
    end, nil, RETARGET_CANT_TAGS, RETARGET_ONOF_TAGS)
end

local function ShouldKeepTarget(inst, target)
    if target and target:IsValid() and target.components.health and not target.components.health:IsDead() then
        local distsq = target:GetDistanceSqToInst(inst)
        return distsq < 200
    else
        return false
    end
end

local function teleport_override_fn(inst)
    return inst:GetPosition()
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("quacken_tentacle")
    if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
        inst.AnimState:SetBuild("quacken_tentacle_yule")
    else
        inst.AnimState:SetBuild("quacken_tentacle")
    end

    inst.AnimState:PlayAnimation("enter", true)

    inst:AddTag("kraken_tentacle")
    inst:AddTag("tentacle")
    inst:AddTag("epic")
    inst:AddTag("animal")
    inst:AddTag("scarytoprey")
    inst:AddTag("hostile")
    inst:AddTag("largecreature")
    inst:AddTag("birdblocker")
    inst:AddTag("soulless")
    inst:AddTag("nowaves")

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("quacken_tentacle.tex")
    inst.MiniMapEntity:SetPriority(4)

    MakePoisonableCharacter(inst)
    MakeCharacterPhysics(inst, 1000, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.QUACKEN_TENTACLE_HEALTH)

    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.QUACKEN_TENTACLE_HIT_RANGE)
    inst.components.combat:SetDefaultDamage(TUNING.QUACKEN_TENTACLE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.QUACKEN_TENTACLE_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('kraken_tentacle')
    if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
        inst.components.lootdropper:AddChanceLoot("winter_ornament_boss_kraken_tentacle", 0.20)
    end

    inst:AddComponent("locomotor")

    inst:AddComponent("teleportedoverride")
    inst.components.teleportedoverride:SetDestPositionFn(teleport_override_fn)

    inst:SetStateGraph("SGkrakententacle")
    inst:SetBrain(brain)

    return inst
end

return Prefab("kraken_tentacle", fn, assets, prefabs)
