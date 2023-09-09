local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", inst.overridesymbol, "swap_body")
    if inst.OnBlocked then
        inst:ListenForEvent("blocked", inst.OnBlocked, owner)
    end
    if inst.components.fueled then
        inst.components.fueled:StartConsuming()
    end
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if inst.OnBlocked then
        inst:RemoveEventCallback("blocked", inst.OnBlocked, owner)
    end
    if inst.components.fueled then
        inst.components.fueled:StopConsuming()
    end
end

local function onequiptomodel(inst, owner, from_ground)
    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end
end

local function commonfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_water", "anim")

    return inst
end

local function masterfn(inst)
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    MakeHauntableLaunch(inst)
end

-------------------------------------------------------------

local seashell_assets = {
    Asset("ANIM", "anim/armor_seashell.zip"),
}

local function seashell_OnBlocked(owner)
    owner.SoundEmitter:PlaySound("ia/common/armour/shell")
end

local function seashell_fn()
    local inst = commonfn()

    inst.AnimState:SetBank("armor_seashell")
    inst.AnimState:SetBuild("armor_seashell")
    inst.AnimState:PlayAnimation("anim")

    inst.foleysound = "ia/common/foley/seashell_suit"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst.overridesymbol = "armor_seashell"

    inst.OnBlocked = seashell_OnBlocked

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMORSEASHELL, TUNING.ARMORSEASHELL_ABSORPTION)

    inst.components.equippable.poisonblocker = true

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    --inst:AddComponent("fuel")
    --inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    return inst
end

-------------------------------------------------------------

local limestone_assets = {
    Asset("ANIM", "anim/armor_limestone.zip"),
}

local function limestone_OnBlocked(owner)
    owner.SoundEmitter:PlaySound("ia/common/armour/limestone")
end

local function limestone_fn()
    local inst = commonfn()

    inst.AnimState:SetBank("armor_limestone")
    inst.AnimState:SetBuild("armor_limestone")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("heavyarmor")

    inst.foleysound = "ia/common/foley/limestone_suit"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst.overridesymbol = "armor_limestone"

    inst.OnBlocked = limestone_OnBlocked

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMORLIMESTONE, TUNING.ARMORLIMESTONE_ABSORPTION)

    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
    inst.components.equippable.walkspeedmult = TUNING.ARMORLIMESTONE_SPEED_MULT

    return inst
end

-------------------------------------------------------------

local obsidian_assets = {
    Asset("ANIM", "anim/armor_obsidian.zip"),
}

local function obsidian_OnBlocked(owner, data)
    owner.SoundEmitter:PlaySound("ia/common/armour/obsidian")

    if data.attacker ~= nil and
    not (data.attacker.components.health ~= nil
    and data.attacker.components.health:IsDead())
    and (data.weapon == nil
    or ((data.weapon.components.weapon == nil or data.weapon.components.weapon.projectile == nil)
        and data.weapon.components.projectile == nil))
    and data.attacker.components.burnable ~= nil
    and not data.redirected
    and not data.attacker:HasTag("thorny")
    and data.stimuli ~= "thorns" then

        data.attacker.components.burnable:Ignite()
    end
end

local function obsidian_onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "armor_obsidian", "swap_body")

    -- inst:ListenForEvent("blocked", obsidian_OnBlocked, owner)
    inst:ListenForEvent("attacked", obsidian_OnBlocked, owner)

    if owner.components.health then
        owner.components.health.fire_damage_scale = owner.components.health.fire_damage_scale - TUNING.ARMORDRAGONFLY_FIRE_RESIST
    end
end

local function obsidian_onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")

    -- inst:RemoveEventCallback("blocked", obsidian_OnBlocked, owner)
    inst:RemoveEventCallback("attacked", obsidian_OnBlocked, owner)

    if owner.components.health then
        owner.components.health.fire_damage_scale = owner.components.health.fire_damage_scale + TUNING.ARMORDRAGONFLY_FIRE_RESIST
    end
end

local function sizzlesound(inst)
    inst.SoundEmitter:PlaySound("ia/common/obsidian_wetsizzles")
end

local function obsidian_fn()
    local inst = commonfn()

    inst.AnimState:SetBank("armor_obsidian")
    inst.AnimState:SetBuild("armor_obsidian")
    inst.AnimState:PlayAnimation("anim")

	-- waterproofer (from waterproofer component) added to pristine state for optimization
	inst:AddTag("waterproofer")
	-- shadowlevel (from shadowlevel component) added to pristine state for optimization
	inst:AddTag("shadowlevel")

    inst.foleysound = "ia/common/foley/obsidian_armour"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst.overridesymbol = "armor_obsidian"

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMORDRAGONFLY, TUNING.ARMORDRAGONFLY_ABSORPTION)

    inst.components.equippable:SetOnEquip( obsidian_onequip )
    inst.components.equippable:SetOnUnequip( obsidian_onunequip )

    inst:ListenForEvent("floater_startfloating", sizzlesound)

	inst:AddComponent("shadowlevel")
    inst.components.shadowlevel:SetDefaultLevel(TUNING.OBSIDIANARMOR_SHADOW_LEVEL)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)

    return inst
end

-------------------------------------------------------------

local cactus_assets = {
    Asset("ANIM", "anim/armor_cactus.zip"),
}

local function cactus_OnBlocked(owner, data)

    if data.attacker ~= nil
    and not (data.attacker.components.health ~= nil
    and data.attacker.components.health:IsDead())
    and (data.weapon == nil
    or ((data.weapon.components.weapon == nil or data.weapon.components.weapon.projectile == nil)
        and data.weapon.components.projectile == nil))
    and data.attacker.components.combat ~= nil
    and not data.redirected
    and not data.attacker:HasTag("thorny")
    and data.stimuli ~= "thorns" then

        owner.SoundEmitter:PlaySound("ia/common/armour/cactus")
        data.attacker.components.combat:GetAttacked(owner, TUNING.ARMORCACTUS_DMG, nil, "thorns")
    end
end

local function cactus_onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "armor_cactus", "swap_body")
    owner:AddTag("armorcactus")

    inst:ListenForEvent("blocked", cactus_OnBlocked, owner)
    inst:ListenForEvent("attacked", cactus_OnBlocked, owner)
end

local function cactus_onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner:RemoveTag("armorcactus")

    inst:RemoveEventCallback("blocked", cactus_OnBlocked, owner)
    inst:RemoveEventCallback("attacked", cactus_OnBlocked, owner)
end

local function cactus_fn()
    local inst = commonfn()

    inst.AnimState:SetBank("armor_cactus")
    inst.AnimState:SetBuild("armor_cactus")
    inst.AnimState:PlayAnimation("anim")

    inst.foleysound = "ia/common/foley/cactus_armour"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst.overridesymbol = "armor_cactus"

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMORCACTUS, TUNING.ARMORCACTUS_ABSORPTION)

    inst.components.equippable:SetOnEquip(cactus_onequip)
    inst.components.equippable:SetOnUnequip(cactus_onunequip)

    return inst
end

-------------------------------------------------------------

local snakeskin_assets = {
    Asset("ANIM", "anim/armor_snakeskin.zip"),
}

local function snakeskin_fn()
    local inst = commonfn()

    inst.AnimState:SetBank("armor_snakeskin")
    inst.AnimState:SetBuild("armor_snakeskin")
    inst.AnimState:PlayAnimation("anim")

    -- waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")

    inst.foleysound = "ia/common/foley/snakeskin_jacket"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst.overridesymbol = "armor_snakeskin"

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:InitializeFuelLevel(TUNING.ARMOR_SNAKESKIN_PERISHTIME)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
    inst.components.fueled:SetDepletedFn(inst.Remove)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer.effectiveness = TUNING.WATERPROOFNESS_HUGE
    inst.components.equippable.insulated = true

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

    return inst
end

-------------------------------------------------------------

local lifejacket_assets = {
    Asset("ANIM", "anim/armor_lifejacket.zip"),
}

local function onpreventdrowningdamagefn(inst)
    inst:Remove()
end

local function lifejacket_fn()
    local inst = commonfn()

    inst.AnimState:SetBank("armor_lifejacket")
    inst.AnimState:SetBuild("armor_lifejacket")
    inst.AnimState:PlayAnimation("anim")

    inst.foleysound = "ia/common/foley/life_jacket"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst.overridesymbol = "armor_lifejacket"

    inst:AddComponent("flotationdevice")
    inst.components.flotationdevice.onpreventdrowningdamagefn = onpreventdrowningdamagefn

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    return inst
end

-------------------------------------------------------------

local windbreaker_assets = {
    Asset("ANIM", "anim/armor_windbreaker.zip"),
}

local function windbreaker_fn()
    local inst = commonfn()

    inst.AnimState:SetBank("armor_windbreaker")
    inst.AnimState:SetBuild("armor_windbreaker")
    inst.AnimState:PlayAnimation("anim")

    -- waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")

    inst.foleysound = "ia/common/foley/windbreaker"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst.overridesymbol = "armor_windbreaker"

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:InitializeFuelLevel(TUNING.WINDBREAKER_PERISHTIME)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
    inst.components.fueled:SetDepletedFn(inst.Remove)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_MED)

    inst:AddComponent("windproofer")
    inst.components.windproofer:SetEffectiveness(TUNING.WINDPROOFNESS_ABSOLUTE)

    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL

    return inst
end

-------------------------------------------------------------

local tarsuit_assets = {
    Asset("ANIM", "anim/armor_tarsuit.zip"),
}

local function tarsuit_fn()
    local inst = commonfn()

    inst.AnimState:SetBank("armor_tarsuit")
    inst.AnimState:SetBuild("armor_tarsuit")
    inst.AnimState:PlayAnimation("anim")

    -- waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")

    inst.foleysound = "ia/common/foley/blubber_suit"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst.overridesymbol = "armor_tarsuit"

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:InitializeFuelLevel(TUNING.TARSUIT_PERISHTIME)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
    inst.components.fueled:SetDepletedFn(inst.Remove)
	inst.components.fueled.fueltype = FUELTYPE.TAR
	inst.components.fueled.accepting = true
	inst.components.fueled.bonusmult = 2

    inst:AddComponent("waterproofer")
    inst.components.waterproofer.effectiveness = TUNING.WATERPROOFNESS_ABSOLUTE
    inst.components.equippable.insulated = true

    return inst
end

-------------------------------------------------------------

local blubber_assets = {
    Asset("ANIM", "anim/armor_blubbersuit.zip"),
}

local function blubber_fn()
    local inst = commonfn()

    inst.AnimState:SetBank("armor_blubbersuit")
    inst.AnimState:SetBuild("armor_blubbersuit")
    inst.AnimState:PlayAnimation("anim")

    --waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")

    inst.foleysound = "ia/common/foley/blubber_suit"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst.overridesymbol = "armor_blubbersuit"

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:InitializeFuelLevel(TUNING.BLUBBERSUIT_PERISHTIME)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
    inst.components.fueled:SetDepletedFn(inst.Remove)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer.effectiveness = TUNING.WATERPROOFNESS_ABSOLUTE

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)

    return inst
end

-------------------------------------------------------------

return Prefab("armorseashell", seashell_fn, seashell_assets),
    Prefab("armorlimestone", limestone_fn, limestone_assets),
    Prefab("armorobsidian", obsidian_fn, obsidian_assets),
    Prefab("armorcactus", cactus_fn, cactus_assets),
    Prefab("armor_snakeskin", snakeskin_fn, snakeskin_assets),
    Prefab("armor_lifejacket", lifejacket_fn, lifejacket_assets),
    Prefab("armor_windbreaker", windbreaker_fn, windbreaker_assets),
    Prefab("tarsuit", tarsuit_fn, tarsuit_assets),
    Prefab("blubbersuit", blubber_fn, blubber_assets)
