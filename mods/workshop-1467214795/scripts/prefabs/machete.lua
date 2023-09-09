local machete_assets = {
    Asset("ANIM", "anim/machete.zip"),
    Asset("ANIM", "anim/swap_machete.zip"),
}

local machete_obsidian_assets = {
    Asset("ANIM", "anim/machete_obsidian.zip"),
    Asset("ANIM", "anim/swap_machete_obsidian.zip"),
}

local machete_golden_assets = {
    Asset("ANIM", "anim/goldenmachete.zip"),
    Asset("ANIM", "anim/swap_goldenmachete.zip"),
}

local function onequip(inst, owner)
	local symbolswapdata = inst.components.symbolswapdata

    if symbolswapdata.is_skinned then
        owner.AnimState:OverrideItemSkinSymbol("swap_object", inst:GetSkinBuild(), symbolswapdata.build, inst.GUID, symbolswapdata.symbol)
    else
        owner.AnimState:OverrideSymbol("swap_object", symbolswapdata.build, symbolswapdata.symbol)
    end
    
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function pristinefn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("machete")
    inst.AnimState:SetBuild("machete")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("machete")
    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle")

    return inst
end

local function masterfn(inst)
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.MACHETE_DAMAGE)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.HACK)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.MACHETE_USES)
    inst.components.finiteuses:SetUses(TUNING.MACHETE_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.HACK, 1)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

local function normal()
    local inst = pristinefn()

    inst:AddComponent("symbolswapdata")
	inst.components.symbolswapdata:SetData("swap_machete", "swap_machete")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    return inst
end

local function onequipgold(inst, owner)
    onequip(inst, owner)
    owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
end

local function golden()
    local inst = pristinefn()

    inst.AnimState:SetBuild("goldenmachete")

    inst:AddComponent("symbolswapdata")
	inst.components.symbolswapdata:SetData("swap_goldenmachete", "swap_goldenmachete")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst.components.finiteuses:SetConsumption(ACTIONS.HACK, 1 / TUNING.GOLDENTOOLFACTOR)
    inst.components.weapon.attackwear = 1 / TUNING.GOLDENTOOLFACTOR
    inst.components.equippable:SetOnEquip(onequipgold)

    return inst
end

local function OnSuffixDirty(inst)
    local suffix = inst._suffix:value()
    inst.components.symbolswapdata:SetData("swap_machete_obsidian", "swap_machete" .. suffix)
end

local function OnChargeDelta(inst)
    local suffix = inst.components.obsidiantool ~= nil and inst.components.obsidiantool:GetAnimSuffix() or ""
    if suffix ~= inst._suffix:value() then
        inst._suffix:set(suffix)
    end
end

local function obsidian()
    local inst = pristinefn()

    inst.AnimState:SetBuild("machete_obsidian")
    inst.AnimState:SetBank("machete_obsidian")

    -- waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")
    -- shadowlevel (from shadowlevel component) added to pristine state for optimization
    inst:AddTag("shadowlevel")
    -- obsidiantool (from obsidiantool component) added to pristine state for optimization
    inst:AddTag("obsidiantool")

    inst:AddComponent("symbolswapdata")
	inst.components.symbolswapdata:SetData("swap_machete_obsidian", "swap_machete")

    inst._suffix = net_string(inst.GUID, "obsidiantool._suffix", "suffixdirty")
    inst._suffix:set("")

    inst:ListenForEvent("suffixdirty", OnSuffixDirty)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst:AddComponent("shadowlevel")
    inst.components.shadowlevel:SetDefaultLevel(TUNING.OBSIDIANMACHETE_SHADOW_LEVEL)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)

    MakeObsidianTool(inst, "machete")
    inst.components.obsidiantool.onchargedelta = OnChargeDelta

    inst.components.tool:SetAction(ACTIONS.HACK, TUNING.OBSIDIANTOOL_WORK)

    inst.components.finiteuses:SetConsumption(ACTIONS.HACK, 1 / TUNING.OBSIDIANTOOLFACTOR)
    inst.components.weapon.attackwear = 1 / TUNING.OBSIDIANTOOLFACTOR


    return inst
end

return Prefab("machete", normal, machete_assets),
    Prefab("goldenmachete", golden, machete_golden_assets),
    Prefab("obsidianmachete", obsidian, machete_obsidian_assets)
