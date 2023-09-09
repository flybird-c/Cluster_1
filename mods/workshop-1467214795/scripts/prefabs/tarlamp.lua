local MakeVisualBoatEquip = require("prefabs/visualboatequip")

local assets =
{
	Asset("ANIM", "anim/tarlamp.zip"),
	Asset("ANIM", "anim/swap_tarlamp.zip"),
	Asset("ANIM", "anim/swap_tarlamp_boat.zip"),
}

local prefabs =
{
	-- "tarlampfire",
}

--Note: The tarlamp combines "lantern", "torch" and "boat_lantern" in one prefab. Good luck reading the code!

local function toggleon(inst)
    inst.components.machine:TurnOn()
end

local function toggleoff(inst)
    inst.components.machine:TurnOff()
end

local function DoTurnOffSound(inst, owner)
	inst._soundtask = nil
	(owner ~= nil and owner:IsValid() and owner.SoundEmitter or inst.SoundEmitter):PlaySound("dontstarve/wilson/lighter_off")
end

local function PlayTurnOffSound(inst)
	if inst._soundtask == nil and inst:GetTimeAlive() > 0 then
		inst._soundtask = inst:DoTaskInTime(0, DoTurnOffSound, inst.components.inventoryitem.owner)
	end
end

local function PlayTurnOnSound(inst)
	if inst._soundtask ~= nil then
		inst._soundtask:Cancel()
		inst._soundtask = nil
	elseif not POPULATING then
		inst._light.SoundEmitter:PlaySound("dontstarve/wilson/lighter_on")
	end
end

local function stoptrackingowner(inst)
	if inst._owner ~= nil then
		inst:RemoveEventCallback("equip", inst._onownerequip, inst._owner)
		inst._owner = nil
	end
end

local function starttrackingowner(inst, owner)
	if owner ~= inst._owner then
		stoptrackingowner(inst)
        inst._owner = owner
		if owner ~= nil and owner.components.inventory ~= nil then
			inst:ListenForEvent("equip", inst._onownerequip, owner)
		end
	end
end

local function setswapsymbol(inst, symbol)
	if inst._owner ~= nil then
		if inst.visual then
			inst.visual.AnimState:OverrideSymbol("swap_lantern", "swap_tarlamp_boat", symbol)
		else
			inst._owner.AnimState:OverrideSymbol("swap_object", "swap_tarlamp", symbol)
		end
	end
end

local function turnoff(inst)
	inst.components.fueled:StopConsuming()
	inst.components.burnable:Extinguish()

	if inst._light ~= nil then
		if inst._light:IsValid() then
            inst._light:Remove()
        end
        inst._light = nil
		PlayTurnOffSound(inst)
	end

	if inst.components.equippable:IsEquipped() then
		setswapsymbol(inst, "swap_lantern_off")
	end
	inst.components.floater:UpdateAnimations("idle_off_water", "idle_off")
end

local function turnon(inst)
    if not inst.components.fueled:IsEmpty() then

        inst.components.fueled:StartConsuming()
        inst.components.burnable:Ignite()

        if inst._light == nil then
            inst._light = SpawnPrefab("tarlamplight")
            PlayTurnOnSound(inst)
        end
        local owner = inst.components.inventoryitem.owner

        inst._light.entity:SetParent((owner or inst).entity)

        if inst.components.equippable:IsEquipped() then
            setswapsymbol(inst, "swap_lantern")
    	end
		inst.components.floater:UpdateAnimations("idle_on_water", "idle_on")
	end
end

local function onequip(inst, owner)
    if owner and owner.sg and owner.sg:HasStateTag("rowing") then return end
    starttrackingowner(inst, owner)

    if owner.components.boatvisualmanager then
        owner.components.boatvisualmanager:SpawnBoatEquipVisuals(inst, "tarlamp")
    else
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    end
    setswapsymbol(inst, "swap_lantern_off")

    if inst.wason then
        inst.components.equippable:ToggleOn()
    end
end

local function onunequip(inst, owner)
    stoptrackingowner(inst, owner)
    if owner.components.boatvisualmanager then
        owner.components.boatvisualmanager:RemoveBoatEquipVisuals(inst)
    else
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
    end

    inst.wason = inst.components.fueled.consuming
    inst.components.equippable:ToggleOff()
end

local function onequiptomodel(inst, owner, from_ground)
    if inst.components.machine.ison then
        starttrackingowner(inst, owner)
    end

    turnoff(inst)
end

--------------------------------------------------------------------------

local function onfueledupdate(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    local rate = 1
    if TheWorld.state.israining and not
    (owner and owner.components.sheltered and
    owner.components.sheltered.sheltered) then
        rate = rate + TUNING.TORCH_RAIN_RATE * TheWorld.state.precipitationrate
    end
    --rate = rate + TUNING.TORCH_WIND_RATE * TheWorld.state.hurricanewindspeed
    inst.components.fueled.rate = rate
end

local function depleted(inst)
	SpawnPrefab("ash").Transform:SetPosition(inst:GetPosition():Get())
end

local function ondropped(inst)
   inst.components.equippable:ToggleOff()
   inst.components.equippable:ToggleOn()
end

local function onpickup(inst)
    inst.components.equippable:ToggleOff()
end

local function OnLoad(inst,data)
    if not data then
        return
    end
    inst.wason = data.wason
end

local function OnSave(inst,data)
    data.wason = inst.wason
end

--------------------------------------------------------------------------

local function nofuel(inst)
    depleted(inst)
	turnoff(inst)
	inst:Remove()
end

local function caninteractfn()
    return not inst.components.fueled:IsEmpty() and inst.components.inventoryitem.owner == nil
end

local function onattack(weapon, attacker, target)
	--target may be killed or removed in combat damage phase
	if target ~= nil and target:IsValid()
	and weapon.components.burnable.burning
	and target.components.burnable ~= nil
	and math.random() < TUNING.LIGHTER_ATTACK_IGNITE_PERCENT * target.components.burnable.flammability then
		target.components.burnable:Ignite(nil, attacker)
	end
end

local function OnRemove(inst)
    if inst._light ~= nil then
        if inst._light:IsValid() then
            inst._light:Remove()
        end
        inst._light = nil
    end
    if inst._soundtask ~= nil then
        inst._soundtask:Cancel()
        inst._soundtask = nil
    end
end

--------------------------------------------------------------------------

local function OnLightWake(inst)
	if not inst.SoundEmitter:PlayingSound("loop") then
		inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_LP", "loop")
		inst.SoundEmitter:SetParameter("loop", "intensity", 1)
	end
end

local function OnLightSleep(inst)
	inst.SoundEmitter:KillSound("loop")
end

--------------------------------------------------------------------------

local function lightfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddLight()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst:AddTag("FX")

	inst.Light:SetColour(197/255, 197/255, 50/255)
	inst.Light:SetIntensity(0.75)
	inst.Light:SetFalloff(0.5)
	inst.Light:SetRadius(TUNING.TARLAMP_RADIUS)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false

	inst.OnEntityWake = OnLightWake
	inst.OnEntitySleep = OnLightSleep

	return inst
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("tarlamp")
	inst.AnimState:SetBuild("tarlamp")
	inst.AnimState:PlayAnimation("idle_off")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_off_water", "idle_off")

	inst:AddTag("light")
	inst:AddTag("wildfireprotected")
	inst:AddTag("lighter") --added to pristine state for optimization
    inst:AddTag("ignoreburning")
    -- weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	-----------------------------------

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPickupFn(onpickup)

	-----------------------------------

	--TODO these components should only exist when turned on!
	-- For the heater, we might get away with setting equippedheat to 0

	inst:AddComponent("lighter")

	inst:AddComponent("heater")
	inst.components.heater.equippedheat = 5

	-----------------------------------

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.LIGHTER_DAMAGE)
	inst.components.weapon:SetAttackCallback(onattack)

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnPocket(function(owner) turnoff(inst) end)
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable:SetOnEquipToModel(onequiptomodel)

	inst.components.equippable.boatequipslot = BOATEQUIPSLOTS.BOAT_LAMP
	inst.components.equippable.togglable = true
	inst.components.equippable.toggledonfn = toggleon
	inst.components.equippable.toggledofffn = toggleoff

	-----------------------------------

	inst:AddComponent("burnable")
	inst.components.burnable.canlight = false
	inst.components.burnable.fxprefab = nil
    inst.components.burnable:SetIgnoreBurning(true)

	inst:AddComponent("machine")
	inst.components.machine.turnonfn = turnon
	inst.components.machine.turnofffn = turnoff
	inst.components.machine.cooldowntime = 0
	inst.components.machine.caninteractfn = caninteractfn

	inst:AddComponent("fueled")
    inst.components.fueled:SetUpdateFn(onfueledupdate)
    inst.components.fueled:SetDepletedFn(nofuel)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
	inst.components.fueled:InitializeFuelLevel(TUNING.TARLAMP_FUEL)
	inst.components.fueled.fueltype = FUELTYPE.TAR
	inst.components.fueled.accepting = true

	-----------------------------------

	inst._light = nil

	inst._onownerequip = function(owner, data)
		if data.item ~= inst and
			(   data.eslot == EQUIPSLOTS.HANDS or
				(data.eslot == EQUIPSLOTS.BODY and data.item:HasTag("heavy"))
			) then
			turnoff(inst)
		end
	end

	MakeHauntableLaunch(inst)

    inst:ListenForEvent("startrowing", function(inst,data)
        onunequip(inst, data.owner)
    end, inst)

    inst:ListenForEvent( "stoprowing", function(inst, data)
        onequip(inst, data.owner)
    end, inst)

	inst.OnRemoveEntity = OnRemove
    inst.wason = true

	return inst
end

function tarlamp_visual_common(inst)
    inst.AnimState:SetBank("sail_visual")
    inst.AnimState:SetBuild("swap_tarlamp_boat")
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

return Prefab("tarlamp", fn, assets, prefabs),
    MakeVisualBoatEquip("tarlamp", assets, nil, tarlamp_visual_common),
	Prefab("tarlamplight", lightfn)
