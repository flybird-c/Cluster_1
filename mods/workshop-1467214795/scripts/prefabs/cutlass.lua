local assets =
{
	Asset("ANIM", "anim/cutlass.zip"),
	Asset("ANIM", "anim/swap_cutlass.zip"),
}

local function owneronattack(attacker, data)
	if data.weapon and data.weapon.prefab == "cutlass" then --just to failsafe
		if data.target and data.target:HasTag("twister") then
			data.weapon.components.weapon:SetDamage(TUNING.CUTLASS_DAMAGE + TUNING.CUTLASS_BONUS_DAMAGE)
		else
			data.weapon.components.weapon:SetDamage(TUNING.CUTLASS_DAMAGE)
		end
	end
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_cutlass", "swap_cutlass")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
	inst:ListenForEvent("onattackother", owneronattack, owner)
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
	inst:RemoveEventCallback("onattackother", owneronattack, owner)
end


local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("cutlass")
    inst.AnimState:SetBuild("cutlass")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddTag("sharp")
	inst:AddTag("fishmeat")
    inst:AddTag("cutlass")
	-- weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")
	
	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inventoryitem")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.CUTLASS_DAMAGE)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.CUTLASS_USES)
    inst.components.finiteuses:SetUses(TUNING.CUTLASS_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("inspectable")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    
	MakeHauntableLaunch(inst)

    return inst
end

return Prefab("cutlass", fn, assets) 
