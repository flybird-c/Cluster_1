local MakeVisualBoatEquip = require("prefabs/visualboatequip")

local palmsailassets = {
    Asset("ANIM", "anim/swap_sail.zip"),
}

local clothsailassets = {
    Asset("ANIM", "anim/swap_sail_cloth.zip"),
}

local feathersailassets = {
    Asset("ANIM", "anim/swap_sail_feathers.zip"),
}

local snakeskinsailassets = {
    Asset("ANIM", "anim/swap_sail_snakeskin.zip"),
}

local ironwindassets = {
    Asset("ANIM", "anim/swap_propeller.zip"),
}

local woodlegssailassets = {
    Asset("ANIM", "anim/swap_sail_pirate.zip"),
}

local function startconsuming(inst)
    if inst.components.fueled and not inst.components.fueled.consuming then 
        inst.components.fueled:StartConsuming()
    end 
end 

local function stopconsuming(inst)
    if inst.components.fueled and inst.components.fueled.consuming then 
        inst.components.fueled:StopConsuming()
    end 
end 

local function onembarked(boat, data)
    local item = boat.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)

    if data.sailor.components.locomotor then
        data.sailor.components.locomotor:SetExternalSpeedMultiplier(item, "SAIL", item.sail_speed_mult)
        data.sailor.components.locomotor:SetExternalAccelerationMultiplier(item, "SAIL", item.sail_accel_mult)
        data.sailor.components.locomotor:SetExternalDecelerationMultiplier(item, "SAIL", item.sail_accel_mult)
    end
end 

local function ondisembarked(boat, data) 
    local item = boat.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
    stopconsuming(item)

    if data.sailor.components.locomotor then
        data.sailor.components.locomotor:RemoveExternalSpeedMultiplier(item, "SAIL")
        data.sailor.components.locomotor:RemoveExternalAccelerationMultiplier(item, "SAIL")
        data.sailor.components.locomotor:RemoveExternalDecelerationMultiplier(item, "SAIL")
    end
end


local function onstartmoving(boat, data)
    local item = boat.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
    startconsuming(item)
end 

local function onstopmoving(boat, data)
    local item = boat.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
    stopconsuming(item)
end 

local function onequip(inst, owner)
    if not owner or not owner.components.sailable then
		print("WARNING: Equipped sail (",inst,") without valid boat: ", owner)
		return false
	end

    if owner.components.boatvisualmanager then
        owner.components.boatvisualmanager:SpawnBoatEquipVisuals(inst, inst.visualprefab)
    end
	
	if owner.components.sailable.sailor then 
        local sailor = owner.components.sailable.sailor
        sailor:PushEvent("sailequipped")
        inst.sailquipped:set_local(true)
        inst.sailquipped:set(true)
        if inst.flapsound then 
            sailor.SoundEmitter:PlaySound(inst.flapsound) 
        end
        if sailor.components.locomotor then
            sailor.components.locomotor:SetExternalSpeedMultiplier(inst, "SAIL", inst.sail_speed_mult)
            sailor.components.locomotor:SetExternalAccelerationMultiplier(inst, "SAIL", inst.sail_accel_mult)
            sailor.components.locomotor:SetExternalDecelerationMultiplier(inst, "SAIL", inst.sail_accel_mult)
        end
    end

    inst:ListenForEvent("embarked", onembarked, owner)
    inst:ListenForEvent("disembarked", ondisembarked, owner)
    inst:ListenForEvent("boatstartmoving", onstartmoving, owner)
    inst:ListenForEvent("boatstopmoving", onstopmoving, owner)
end

local function onunequip(inst, owner)
    if owner then
        if owner.components.boatvisualmanager then
            owner.components.boatvisualmanager:RemoveBoatEquipVisuals(inst)
        end
		if owner.components.sailable and owner.components.sailable.sailor then
			local sailor = owner.components.sailable.sailor
			sailor:PushEvent("sailunequipped")
			inst.sailquipped:set_local(false)
			inst.sailquipped:set(false)
			if inst.flapsound then 
				sailor.SoundEmitter:PlaySound(inst.flapsound) 
			end

			if sailor.components.locomotor then
				sailor.components.locomotor:RemoveExternalSpeedMultiplier(inst, "SAIL")
				sailor.components.locomotor:RemoveExternalAccelerationMultiplier(inst, "SAIL")
				sailor.components.locomotor:RemoveExternalDecelerationMultiplier(inst, "SAIL")
			end
		end 

		inst:RemoveEventCallback("embarked", onembarked, owner)
		inst:RemoveEventCallback("disembarked", ondisembarked, owner)
		inst:RemoveEventCallback("boatstartmoving", onstartmoving, owner)
		inst:RemoveEventCallback("boatstopmoving", onstopmoving, owner)
	end
	
    stopconsuming(inst)

    if inst.RemoveOnUnequip then
        inst:DoTaskInTime(2*FRAMES, inst.Remove)
    end    
end

local function sail_perish(inst)
    onunequip(inst, inst.components.inventoryitem.owner)
    inst:Remove()
end 

local function common_pristine()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    inst:AddTag("sail")

    --networking the equip/unequip event
    inst.sailquipped = net_bool(inst.GUID, "sailquipped", not TheWorld.ismastersim and "sailquipped" or nil)

    if not TheWorld.ismastersim then
        inst:ListenForEvent("sailquipped", function(inst)
            if inst.sailquipped:value() then
                ThePlayer:PushEvent("sailequipped")
            else
                ThePlayer:PushEvent("sailunequipped")
            end
        end)
    end

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

    return inst
end

local function common_master(inst)
    inst:AddComponent("inspectable")

    MakeHauntableLaunch(inst)

    inst:AddComponent("inventoryitem")

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:SetDepletedFn(sail_perish)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("equippable")
    inst.components.equippable.boatequipslot = BOATEQUIPSLOTS.BOAT_SAIL
    inst.components.equippable.equipslot = nil
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst.onembarked = onembarked
    inst.ondisembarked = ondisembarked

    return inst
end

local function palmsail_fn()
    local inst = common_pristine()

    inst.AnimState:SetBank("sail")
    inst.AnimState:SetBuild("swap_sail")
    inst.AnimState:PlayAnimation("idle")

    inst.loopsound = "ia/common/sail_LP/leaf"
    inst.flapsound = "ia/common/sail_flap/leaf"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    common_master(inst)

    inst.visualprefab = "sail_palmleaf"

    inst.components.fueled:InitializeFuelLevel(TUNING.SAIL_PALM_PERISH_TIME)
    inst.sail_speed_mult = TUNING.SAIL_PALM_SPEED_MULT
    inst.sail_accel_mult = TUNING.SAIL_PALM_ACCEL_MULT

    return inst
end 

local function palmsail_visual_common(inst)
    inst.AnimState:SetBank("sail_visual")
    inst.AnimState:SetBuild("swap_sail")
    inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:SetSortWorldOffset(0, 0.05, 0) --below the player

    function inst.components.boatvisualanims.update(inst, dt)
        if inst.AnimState:GetCurrentFacing() == FACING_UP then
            inst.AnimState:SetSortWorldOffset(0, 0.15, 0) --above the player
        else
            inst.AnimState:SetSortWorldOffset(0, 0.05, 0) --below the player
        end
    end
end

local function clothsail_fn()
    local inst = common_pristine()

    inst.AnimState:SetBank("sail")
    inst.AnimState:SetBuild("swap_sail_cloth")
    inst.AnimState:PlayAnimation("idle")

    inst.loopsound = "ia/common/sail_LP/cloth"
    inst.flapsound = "ia/common/sail_flap/cloth"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    common_master(inst)

    inst.visualprefab = "sail_cloth"

    inst.components.fueled:InitializeFuelLevel(TUNING.SAIL_CLOTH_PERISH_TIME)
    inst.sail_speed_mult = TUNING.SAIL_CLOTH_SPEED_MULT
    inst.sail_accel_mult = TUNING.SAIL_CLOTH_ACCEL_MULT

    return inst
end 

local function clothsail_visual_common(inst)
    inst.AnimState:SetBank("sail_visual")
    inst.AnimState:SetBuild("swap_sail_cloth")
    inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:SetSortWorldOffset(0, 0.05, 0) --below the player

    function inst.components.boatvisualanims.update(inst, dt)
        if inst.AnimState:GetCurrentFacing() == FACING_UP then
            inst.AnimState:SetSortWorldOffset(0, 0.15, 0) --above the player
        else
            inst.AnimState:SetSortWorldOffset(0, 0.05, 0) --below the player
        end
    end
end

local function snakeskinsail_fn()
    local inst = common_pristine()

    inst.AnimState:SetBank("sail")
    inst.AnimState:SetBuild("swap_sail_snakeskin")
    inst.AnimState:PlayAnimation("idle")

    inst.loopsound = "ia/common/sail_LP/snakeskin"
    inst.flapsound = "ia/common/sail_flap/snakeskin"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    common_master(inst)

    inst.visualprefab = "sail_snakeskin"

    inst.components.fueled:InitializeFuelLevel(TUNING.SAIL_SNAKESKIN_PERISH_TIME)
    inst.sail_speed_mult = TUNING.SAIL_SNAKESKIN_SPEED_MULT
    inst.sail_accel_mult = TUNING.SAIL_SNAKESKIN_ACCEL_MULT

    return inst
end 

local function snakeskinsail_visual_common(inst)
    inst.AnimState:SetBank("sail_visual")
    inst.AnimState:SetBuild("swap_sail_snakeskin")
    inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:SetSortWorldOffset(0, 0.05, 0) --below the player

    function inst.components.boatvisualanims.update(inst, dt)
        if inst.AnimState:GetCurrentFacing() == FACING_UP then
            inst.AnimState:SetSortWorldOffset(0, 0.15, 0) --above the player
        else
            inst.AnimState:SetSortWorldOffset(0, 0.05, 0) --below the player
        end
    end
end

local function feathersail_fn()
    local inst = common_pristine()

    inst.AnimState:SetBank("sail")
    inst.AnimState:SetBuild("swap_sail_feathers")
    inst.AnimState:PlayAnimation("idle")

    inst.loopsound = "ia/common/sail_LP/feather"
    inst.flapsound = "ia/common/sail_flap/feather"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    common_master(inst)

    inst.visualprefab = "sail_feather"

    inst.components.fueled:InitializeFuelLevel(TUNING.SAIL_FEATHER_PERISH_TIME)
    inst.sail_speed_mult = TUNING.SAIL_FEATHER_SPEED_MULT
    inst.sail_accel_mult = TUNING.SAIL_FEATHER_ACCEL_MULT

    return inst
end 

local function feathersail_visual_common(inst)
    inst.AnimState:SetBank("sail_visual")
    inst.AnimState:SetBuild("swap_sail_feathers")
    inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:SetSortWorldOffset(0, 0.05, 0) --below the player

    function inst.components.boatvisualanims.update(inst, dt)
        if inst.AnimState:GetCurrentFacing() == FACING_UP then
            inst.AnimState:SetSortWorldOffset(0, 0.15, 0) --above the player
        else
            inst.AnimState:SetSortWorldOffset(0, 0.05, 0) --below the player
        end
    end
end

local function ironwind_fn()
    local inst = common_pristine()

    inst.AnimState:SetBank("propeller")
    inst.AnimState:SetBuild("swap_propeller")
    inst.AnimState:PlayAnimation("idle")

    inst.loopsound = "ia/common/boatpropellor_lp"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    common_master(inst)

    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")

    inst.visualprefab = "ironwind"

    inst.components.fueled:InitializeFuelLevel(TUNING.IRON_WIND_PERISH_TIME)
    inst.sail_speed_mult = TUNING.IRON_WIND_SPEED_MULT
    inst.sail_accel_mult = TUNING.IRON_WIND_ACCEL_MULT

    inst.components.fueled.fueltype = FUELTYPE.MECHANICAL
    inst.components.fueled.accepting = true

    return inst
end

local function ironwind_visual_common(inst)
    inst.AnimState:SetBank("sail_visual")
    inst.AnimState:SetBuild("swap_propeller")
    inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:SetSortWorldOffset(0, -0.05, 0) --below the boat

    function inst.components.boatvisualanims.update(inst, dt)
        if inst.AnimState:GetCurrentFacing() == FACING_UP then
            inst.AnimState:SetSortWorldOffset(0, 0.05, 0) --above the boat
        else
            inst.AnimState:SetSortWorldOffset(0, -0.05, 0) --below the boat
        end
    end
end

local function woodlegssail_fn()
    local inst = common_pristine()

    inst.AnimState:SetBank("sail")
    inst.AnimState:SetBuild("swap_sail_pirate")
    inst.AnimState:PlayAnimation("idle")
    
    inst.loopsound = "ia/common/sail_LP/sealegs"
    inst.flapsound = "ia/common/sail_flap/sealegs"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    common_master(inst)

    inst.visualprefab = "sail_woodlegs"

    inst:RemoveComponent("fueled")
    inst.sail_speed_mult = TUNING.SAIL_WOODLEGS_SPEED_MULT or 1
    inst.sail_accel_mult = TUNING.SAIL_WOODLEGS_ACCEL_MULT

    inst.RemoveOnUnequip = true

    return inst
end

local function woodlegssail_visual_common(inst)
    inst.AnimState:SetBank("sail_visual")
    inst.AnimState:SetBuild("swap_sail_pirate")
    inst.AnimState:PlayAnimation("idle_loop")
    inst.AnimState:SetSortWorldOffset(0, 0.05, 0) --below the player

    function inst.components.boatvisualanims.update(inst, dt)
        if inst.AnimState:GetCurrentFacing() == FACING_UP then
            inst.AnimState:SetSortWorldOffset(0, 0.15, 0) --above the player
        else
            inst.AnimState:SetSortWorldOffset(0, 0.05, 0) --below the player
        end
    end
end

return Prefab("sail_palmleaf", palmsail_fn, palmsailassets), 
    MakeVisualBoatEquip("sail_palmleaf", palmsailassets, nil, palmsail_visual_common),
    Prefab("sail_cloth", clothsail_fn, clothsailassets),
    MakeVisualBoatEquip("sail_cloth", clothsailassets, nil, clothsail_visual_common),
    Prefab("sail_snakeskin", snakeskinsail_fn, snakeskinsailassets),
    MakeVisualBoatEquip("sail_snakeskin", snakeskinsailassets, nil, snakeskinsail_visual_common),
    Prefab("sail_feather", feathersail_fn, feathersailassets),
    MakeVisualBoatEquip("sail_feather", feathersailassets, nil, feathersail_visual_common),
    Prefab("ironwind", ironwind_fn, ironwindassets),
    MakeVisualBoatEquip("ironwind", ironwindassets, nil, ironwind_visual_common),
    Prefab("sail_woodlegs", woodlegssail_fn, woodlegssailassets),
    MakeVisualBoatEquip("sail_woodlegs", woodlegssailassets, nil, woodlegssail_visual_common)
