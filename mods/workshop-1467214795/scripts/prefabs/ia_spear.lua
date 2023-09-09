local poison_assets = {
    Asset("ANIM", "anim/spear_poison.zip"),
    Asset("ANIM", "anim/swap_spear_poison.zip"),
}
local obsidian_assets = {
    Asset("ANIM", "anim/spear_obsidian.zip"),
    Asset("ANIM", "anim/swap_spear_obsidian.zip"),
}
local needle_assets = {
    Asset("ANIM", "anim/swap_cactus_spike.zip"),
    Asset("ANIM", "anim/cactus_spike.zip"),
}
local pegleg_assets = {
    Asset("ANIM", "anim/swap_peg_leg.zip"),
    Asset("ANIM", "anim/peg_leg.zip"),
}

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end
end

local function commonfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("sharp")
    inst:AddTag("pointy")
    -- weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle")

    return inst
end

local function masterfn(inst)
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SPEAR_DAMAGE)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SPEAR_USES)
    inst.components.finiteuses:SetUses(TUNING.SPEAR_USES)

    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")

    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)
end


local function poisonattack(inst, attacker, target, projectile)
    if target.components.poisonable then
    -- TODO unless attack gets blocked?
        target.components.poisonable:Poison()
    end
    -- if target.components.combat then
        -- target.components.combat:SuggestTarget(attacker)
    -- end
    -- this was commented out as the attack with the spear will do an attacked event. The poison itself doesn't need a second one pushed
    -- target:PushEvent("attacked", {attacker = attacker, damage = 0, projectile = projectile})
end

local function onequip_poison(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_spear_poison", "swap_spear")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function poison_fn()
    local inst = commonfn()

    inst.AnimState:SetBuild("spear_poison")
    inst.AnimState:SetBank("spear_poison")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst.components.weapon:SetOnAttack(poisonattack)

    inst.components.equippable:SetOnEquip(onequip_poison)

    return inst
end


local function onequip_obsidian(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_spear_obsidian", "swap_spear")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function obsidian_fn()
    local inst = commonfn()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBuild("spear_obsidian")
    inst.AnimState:SetBank("spear_obsidian")
    inst.AnimState:PlayAnimation("idle")

    -- waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")
    -- shadowlevel (from shadowlevel component) added to pristine state for optimization
    inst:AddTag("shadowlevel")
    -- obsidiantool (from obsidiantool component) added to pristine state for optimization
    inst:AddTag("obsidiantool")

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst.components.weapon:SetDamage(TUNING.OBSIDIAN_SPEAR_DAMAGE)
    inst.components.weapon.attackwear = 1 / TUNING.OBSIDIANTOOLFACTOR

    inst.components.equippable:SetOnEquip(onequip_obsidian)
    
    inst:AddComponent("shadowlevel")
    inst.components.shadowlevel:SetDefaultLevel(TUNING.OBSIDIANSPEAR_SHADOW_LEVEL)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)

    MakeObsidianTool(inst, "spear")
    inst.components.obsidiantool.maxcharge = TUNING.OBSIDIAN_WEAPON_MAXCHARGES
    inst.components.obsidiantool.cooldowntime = TUNING.TOTAL_DAY_TIME / TUNING.OBSIDIAN_WEAPON_MAXCHARGES

    return inst
end


local function onequip_needle(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_cactus_spike", "swap_cactus_spike")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function needle_fn()
    local inst = commonfn()

    inst.AnimState:SetBuild("cactus_spike")
    inst.AnimState:SetBank("cactus_spike")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst.components.weapon:SetDamage(TUNING.NEEDLESPEAR_DAMAGE)

    inst.components.finiteuses:SetMaxUses(TUNING.NEEDLESPEAR_USES)
    inst.components.finiteuses:SetUses(TUNING.NEEDLESPEAR_USES)

    inst.components.equippable:SetOnEquip(onequip_needle)

	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
	MakeSmallPropagator(inst)

    return inst
end


local function onequip_pegleg(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_peg_leg", "swap_object")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function pegleg_fn()
    local inst = commonfn()

    inst.AnimState:SetBuild("peg_leg")
    inst.AnimState:SetBank("peg_leg")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("pegleg")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst.components.weapon:SetDamage(TUNING.PEG_LEG_DAMAGE)

    inst.components.finiteuses:SetMaxUses(TUNING.PEG_LEG_USES)
    inst.components.finiteuses:SetUses(TUNING.PEG_LEG_USES)

    inst.components.equippable:SetOnEquip(onequip_pegleg)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL

    return inst
end

return Prefab("spear_poison", poison_fn, poison_assets),
    Prefab("spear_obsidian", obsidian_fn, obsidian_assets),
    Prefab("needlespear", needle_fn, needle_assets),
    Prefab("peg_leg", pegleg_fn, pegleg_assets)
