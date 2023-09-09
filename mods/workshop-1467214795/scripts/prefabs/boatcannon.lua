local MakeVisualBoatEquip = require("prefabs/visualboatequip")

local assets = {
    Asset("ANIM", "anim/swap_cannon.zip"),
}

local prefabs = {
    "cannonshot",
    "collapse_small",
}

local woodlegs_assets = {
    Asset("ANIM", "anim/swap_cannon_pirate.zip"),
}

local woodlegs_prefabs = {
    "woodlegs_cannonshot",
    "collapse_small",
}

local HAUNT_MUST_TAGS = { "mime" }
local HAUNT_CANT_TAGS = { "playerghost", "INLIMBO" }

local function onequip(inst, owner)
    if owner.components.boatvisualmanager then
        owner.components.boatvisualmanager:SpawnBoatEquipVisuals(inst, inst.prefab)
    end
    if inst.visual then
        inst.visual.AnimState:OverrideSymbol("swap_lantern", inst.swap_build, "swap_cannon")
    end
end

local function onunequip(inst, owner)
    if owner.components.boatvisualmanager then
        owner.components.boatvisualmanager:RemoveBoatEquipVisuals(inst)
    end
    if inst.visual then
        inst.visual.AnimState:ClearOverrideSymbol("swap_lantern")
    end

    if inst.RemoveOnUnequip then
        inst:DoTaskInTime(2*FRAMES, inst.Remove)
    end
end

local function onthrowfn(inst)
    if inst.components.finiteuses then
        inst.components.finiteuses:Use()
    end
end

local function OnHaunt(inst)
	if math.random() <= TUNING.HAUNT_CHANCE_OCCASIONAL then
		local target = FindEntity(inst, 35, nil, HAUNT_MUST_TAGS, HAUNT_CANT_TAGS)
		if target ~= nil then
			local pos = target:GetPosition()
			inst.components.thrower:Throw(pos)
		else
			local pos = inst:GetPosition()
			pos.x, pos.z = pos.x+math.random(-20, 20), pos.z+math.random(-20, 20)
			inst.components.thrower:Throw(pos)
		end
	end
	return false
end

local function common()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    inst.AnimState:SetBank("cannon")
    inst.AnimState:SetBuild("swap_cannon")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function() 
        return inst.components.thrower:GetThrowPoint()
    end
    inst.components.reticule.ease = true

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

    inst:AddTag("cannon")

    return inst
end

local function master(inst)
    inst:AddComponent("inventoryitem")
        
    inst:AddComponent("inspectable")

    MakeHauntableLaunch(inst)
	AddHauntableCustomReaction(inst, OnHaunt, true, false, true)
    inst.components.hauntable.hauntvalue = TUNING.HAUNT_LARGE

    inst:AddComponent("equippable")
    inst.components.equippable.boatequipslot = BOATEQUIPSLOTS.BOAT_LAMP
    inst.components.equippable.equipslot = nil
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.BOATCANNON_AMMO_COUNT)
    inst.components.finiteuses:SetUses(TUNING.BOATCANNON_AMMO_COUNT)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    --TODO use complexprojectile --how -Z?
    inst:AddComponent("thrower")
    inst.components.thrower.throwable_prefab = "cannonshot"
    inst.components.thrower.onthrowfn = onthrowfn

    function inst.components.thrower.getthrowposition(inst)
        if inst.visual then
            return inst.visual.AnimState:GetSymbolPosition("swap_lantern", 0, 0, 0)
        else 
            return inst.Transform:GetWorldPosition()
        end
    end

    return inst
end

local function cannon_fn()

    --NOTE!! Most of the logic for this happens in cannonshot.lua

    local inst = common()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst = master(inst)

    inst.swap_build = "swap_cannon"

    return inst
end

local function woodlegs_fn()

    --NOTE!! Most of the logic for this happens in cannonshot.lua

    local inst = common()

    inst.AnimState:SetBuild("swap_cannon_pirate")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst = master(inst)

    inst:RemoveComponent("finiteuses")

    inst.RemoveOnUnequip = true
    
    inst.components.thrower.throwable_prefab = "woodlegs_cannonshot"

    inst.swap_build = "swap_cannon_pirate"

    return inst
end

function boatcannon_visual_common(inst)
    inst.AnimState:SetBank("sail_visual")
    inst.AnimState:SetBuild("swap_cannon")
    inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:SetSortWorldOffset(0, 0.05, 0) --below the player

    function inst.components.boatvisualanims.update(inst, dt)
        if inst.AnimState:GetCurrentFacing() == FACING_DOWN then
            inst.AnimState:SetSortWorldOffset(0, 0.15, 0) --above the player
        else
            inst.AnimState:SetSortWorldOffset(0, 0.05, 0) --below the player
        end
    end
end

function woodlegs_boatcannon_visual_common(inst)
    inst.AnimState:SetBank("sail_visual")
    inst.AnimState:SetBuild("swap_cannon_pirate")
    inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:SetSortWorldOffset(0, 0.05, 0) --below the player

    function inst.components.boatvisualanims.update(inst, dt)
        if inst.AnimState:GetCurrentFacing() == FACING_DOWN then
            inst.AnimState:SetSortWorldOffset(0, 0.15, 0) --above the player
        else
            inst.AnimState:SetSortWorldOffset(0, 0.05, 0) --below the player
        end
    end
end

return Prefab("boatcannon", cannon_fn, assets, prefabs),
    Prefab("woodlegs_boatcannon", woodlegs_fn, woodlegs_assets, woodlegs_prefabs),
    MakeVisualBoatEquip("boatcannon", assets, nil, boatcannon_visual_common),
    MakeVisualBoatEquip("woodlegs_boatcannon", woodlegs_assets, nil, woodlegs_boatcannon_visual_common)
