local assets =
{
	Asset("ANIM", "anim/swap_harpoon.zip"),
	Asset("ANIM", "anim/harpoon.zip"),
}

local prefabs = 
{
	"impact",
}


local function onequip(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_object", "swap_harpoon", "swap_object")
	owner.AnimState:Show("ARM_carry") 
	owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
	owner.AnimState:ClearOverrideSymbol("swap_object")
	owner.AnimState:Hide("ARM_carry") 
	owner.AnimState:Show("ARM_normal") 
end

local function onhit(inst, attacker, target)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.Default)
	inst.AnimState:PlayAnimation("idle")
	
	local impactfx = SpawnPrefab("impact")
	if impactfx then
		local follower = impactfx.entity:AddFollower()
		follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0 )
        if attacker then
            impactfx:FacePoint(attacker.Transform:GetWorldPosition())
        end
	end
end

local function onthrown(inst, data)
	inst.AnimState:PlayAnimation("thrown")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
end


local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("harpoon")
	inst.AnimState:SetBuild("harpoon")
	inst.AnimState:PlayAnimation("idle")
	
	inst:AddTag("thrown")
	inst:AddTag("projectile")
	-- weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")
	
	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")
	
    inst.entity:SetPristine()
	
    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inventoryitem")
	inst:AddComponent("inspectable")

	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.HARPOON_USES)
	inst.components.finiteuses:SetUses(TUNING.HARPOON_USES)
	inst.components.finiteuses:SetOnFinished(inst.Remove)

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.HARPOON_DAMAGE)
	inst.components.weapon:SetRange(TUNING.HARPOON_RANGE, TUNING.HARPOON_RANGE+2)
	
	inst:AddComponent("projectile")
	inst.components.projectile:SetSpeed(TUNING.HARPOON_SPEED)
	inst.components.projectile:SetOnHitFn(onhit)
	-- inst.components.projectile:SetOnThrownFn(onthrown)
	inst:ListenForEvent("onthrown", onthrown)

	return inst
end

return Prefab("harpoon", fn, assets, prefabs)
