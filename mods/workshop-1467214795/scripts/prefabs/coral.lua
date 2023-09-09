local assets =
{
  Asset("ANIM", "anim/coral.zip"),
}

local function fn()
    local inst  = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("coral")
    inst.AnimState:SetBuild("coral")
    inst.AnimState:PlayAnimation("idle_water", true)

    inst.pickupsound = "rock"

    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle")
        
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tradable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    if IA_CONFIG.limestonerepair then
        inst:AddComponent("repairer")
        inst.components.repairer.repairmaterial = MATERIALS.LIMESTONE
        inst.components.repairer.workrepairvalue = TUNING.REPAIR_CORAL_WORK
        inst.components.repairer.healthrepairvalue = TUNING.REPAIR_CORAL_HEALTH
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("coral", fn, assets)
