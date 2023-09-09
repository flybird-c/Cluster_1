local assets =
{
	Asset("ANIM", "anim/ia_trident.zip"),
	Asset("ANIM", "anim/swap_ia_trident.zip"),
}

-- local prefabs =
-- {
--     "crab_king_waterspout",
-- }

-- local function reticule_target_function(inst)
--     return Vector3(ThePlayer.entity:LocalToWorldSpace(3.5, 0.001, 0))
-- end

local function trident_damage_calculation(inst, attacker, target)
    local is_over_ground = TheWorld.Map:IsVisualGroundAtPoint(attacker:GetPosition():Get())
    return (is_over_ground and TUNING.TRIDENT.IA_DAMAGE) or TUNING.TRIDENT.IA_OCEAN_DAMAGE
end

local function on_uses_finished(inst)
    if inst.components.inventoryitem.owner ~= nil then
        inst.components.inventoryitem.owner:PushEvent("toolbroke", { tool = inst })
    end

    inst:Remove()
end

local function on_equipped(inst, equipper)
    equipper.AnimState:OverrideSymbol("swap_object", "swap_ia_trident", "swap_ia_trident")
    equipper.AnimState:Show("ARM_carry")
    equipper.AnimState:Hide("ARM_normal")
end

local function on_unequipped(inst, equipper)
    equipper.AnimState:Hide("ARM_carry")
    equipper.AnimState:Show("ARM_normal")
end

local function trident()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

    -- inst:AddTag("allow_action_on_impassable")
    -- inst:AddTag("guitar")
    inst:AddTag("pointy")
    inst:AddTag("sharp")
    inst:AddTag("weapon")

    -- inst.spelltype = "MUSIC"

    -- inst:AddComponent("reticule")
    -- inst.components.reticule.targetfn = reticule_target_function
    -- inst.components.reticule.ease = true
    -- inst.components.reticule.ispassableatallpoints = true

    inst.AnimState:SetBank("ia_trident")
	inst.AnimState:SetBuild("ia_trident")
	inst.AnimState:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

    inst.guitarbuild = "swap_ia_trident"
    inst.guitarsymbol = "swap_ia_trident"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -------

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(trident_damage_calculation)

    -------

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.TRIDENT.IA_USES)
    inst.components.finiteuses:SetUses(TUNING.TRIDENT.IA_USES)
    inst.components.finiteuses:SetOnFinished(on_uses_finished)

    -------

    inst:AddComponent("inspectable")

    -- -------

    inst:AddComponent("inventoryitem")

    -- -------

    inst:AddComponent("tradable")

    -------

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(on_equipped)
    inst.components.equippable:SetOnUnequip(on_unequipped)

    -------

    -- inst.DoWaterExplosionEffect = trident.DoWaterExplosionEffect

    -- inst:AddComponent("spellcaster")
    -- inst.components.spellcaster:SetSpellFn(trident.components.spellcaster.spell)
    -- inst.components.spellcaster.canuseonpoint_water = true

	return inst
end

return Prefab( "ia_trident", trident, assets)