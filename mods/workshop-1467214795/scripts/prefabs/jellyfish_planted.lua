local assets = {
    Asset("Anim", "anim/jellyfish.zip")
}

local prefabs = {
    "jellyfish_dead"
}

local brain = require("brains/jellyfishbrain")

local function onworked(inst, worker)
    -- stupid DST change, explosives do a "work" check before an attack check, this is reversed in SW
    if not worker.components.explosive then
        if worker.components.inventory then
            local toGive = SpawnPrefab("jellyfish")
            worker.components.inventory:GiveItem(toGive, nil, inst:GetPosition())
            worker.SoundEmitter:PlaySound("ia/common/bugnet_inwater")

            if toGive.components.weighable ~= nil then
                toGive.components.weighable:SetPlayerAsOwner(worker)
            end
        end
        inst:Remove()
    end
end

local function onattacked(inst, data) --based on lightninggoats in dst
    if data ~= nil and data.attacker ~= nil and data.attacker.components.health ~= nil and not data.attacker.components.health:IsDead()
    and (data.weapon == nil or ((data.weapon.components.weapon == nil or data.weapon.components.weapon.projectile == nil) and data.weapon.components.projectile == nil))
    and not (data.attacker.components.inventory ~= nil and data.attacker.components.inventory:IsInsulated())
    and not (data.attacker.sg ~= nil and data.attacker.sg:HasStateTag("dead")) then
        data.attacker.components.health:DoDelta(-TUNING.JELLYFISH_DAMAGE, nil, inst.prefab, nil, inst)
        if data.attacker.sg ~= nil and data.attacker.sg:HasState("electrocute") then
            data.attacker.sg:GoToState("electrocute")
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("jellyfish")
    inst.AnimState:SetBuild("jellyfish")
    inst.AnimState:PlayAnimation("idle", true)

    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    MakeCharacterPhysics(inst, 1, 0.5)
    inst.Transform:SetFourFaced()

	inst:AddTag("animal")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.JELLYFISH_WALKSPEED
    inst.components.locomotor.pathcaps = {allowocean = true, ignoreLand = true}

    inst:SetStateGraph("SGjellyfish")
    inst:SetBrain(brain)

    inst:AddComponent("drydrownable")
    inst.components.drydrownable.break_period = 30

    inst:AddComponent("combat")
    inst.components.combat:SetHurtSound("ia/creatures/jellyfish/hit")
    inst:ListenForEvent("attacked", onattacked)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.JELLYFISH_HEALTH)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"jellyfish_dead"})

    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")

    inst:AddComponent("sleeper")
    inst.components.sleeper.onlysleepsfromitems = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onworked)

    MakeHauntablePanic(inst)
    MakeMediumFreezableCharacter(inst, "jelly")

    return inst
end

return Prefab("jellyfish_planted", fn, assets, prefabs)
