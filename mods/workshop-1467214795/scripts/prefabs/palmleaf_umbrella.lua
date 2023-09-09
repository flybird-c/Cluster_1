local assets =
{
    Asset("ANIM", "anim/swap_parasol_palmleaf.zip"),
    Asset("ANIM", "anim/parasol_palmleaf.zip"),
}

local function onfinished(inst)
    inst:Remove()
end

local function onperish(inst)
    local equippable = inst.components.equippable
    if equippable ~= nil and equippable:IsEquipped() then
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if owner ~= nil then
            local data = {prefab = inst.prefab, equipslot = equippable.equipslot}
            owner:PushEvent("umbrellaranout", data)
        end
    end
    inst:Remove()
end


local function common_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst:AddTag("nopunch")
    inst:AddTag("umbrella")

    MakeSnowCoveredPristine(inst)
    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle")

    return inst
end

local function master_fn(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)

    inst:AddComponent("waterproofer")
    inst:AddComponent("inspectable")
    inst:AddComponent("equippable")

    inst:AddComponent("insulator")
    inst.components.insulator:SetSummer()
end

local function onequip_palmleaf(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_parasol_palmleaf", "swap_parasol_palmleaf")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    owner.DynamicShadow:SetSize(1.7, 1)
end

local function onunequip_palmleaf(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    owner.DynamicShadow:SetSize(1.3, 0.6)
end

local function palmleaf()
    local inst = common_fn()

    inst.AnimState:SetBank("parasol_palmleaf")
    inst.AnimState:SetBuild("parasol_palmleaf")
    inst.AnimState:PlayAnimation("idle")

    -- waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")
    inst:AddTag("show_spoilage")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    master_fn(inst)

    inst:AddComponent("inventoryitem")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.GRASS_UMBRELLA_PERISHTIME)
    inst.components.perishable:StartPerishing()
    inst.components.perishable:SetOnPerishFn(onperish)

    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_MED)

    inst.components.equippable:SetOnEquip(onequip_palmleaf)
    inst.components.equippable:SetOnUnequip(onunequip_palmleaf)

    inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL

    MakeHauntableLaunch(inst)
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    return inst
end

return Prefab("palmleaf_umbrella", palmleaf, assets)
