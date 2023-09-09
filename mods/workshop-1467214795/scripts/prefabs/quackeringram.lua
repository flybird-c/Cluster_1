local MakeVisualBoatEquip = require("prefabs/visualboatequip")
local easing = require "easing"

local RAM_ONACTIVATE_BOOST = 8
local RAM_ONRAM_BOOST = 25

local assets = {
    Asset("ANIM", "anim/swap_quackeringram.zip"),
}

local prefabs =
{
    "quackeringram_wave",
    "quackering_wake"
}

local function SpawnWave(inst)
    local sailor = inst.components.rammer:FindSailor()
    local wave = SpawnPrefab("quackeringram_wave")
    wave.entity:SetParent(sailor.entity)
    wave:StartAnim()
    inst.wave = wave
end

local function DespawnWave(inst)
    if inst.wave then
        inst.wave:Remove()
    end
end

local function SpawnWake(inst)
	local wake = SpawnPrefab("quackering_wake")
	if inst.wakeleft == true then
		wake.idleanimation = "idle"
		inst.wakeleft = false
	else
		wake.idleanimation = "idle_2"
		inst.wakeleft = true
	end

    local sailor = inst.components.rammer:FindSailor()
	local x, y, z = sailor.Transform:GetWorldPosition()
    wake.Transform:SetPosition( x, y, z )
    wake.Transform:SetRotation(inst.Transform:GetRotation())

	if inst.waketask then
		inst.waketask:Cancel()
		inst.waketask = nil
	end
	inst.waketask = inst:DoTaskInTime(5 * FRAMES, SpawnWake)
end

local function StopWake(inst)
    if inst and inst.waketask then
        inst.waketask:Cancel()
        inst.waketask = nil
    end
end

local function OnEquip(inst, owner)
    if owner.components.boatvisualmanager then
        owner.components.boatvisualmanager:SpawnBoatEquipVisuals(inst, inst.prefab)
    end

    if inst.visual then
        inst.visual.AnimState:OverrideSymbol("swap_lantern", "swap_quackeringram", "swap_quackeringram")
    end

    local sailor = owner and owner.components.sailable and owner.components.sailable.sailor or nil
    if sailor then
        inst.components.rammer:Start(sailor)
    end

    inst:ListenForEvent("embarked", inst.onembarked, owner)
    inst:ListenForEvent("disembarked", inst.ondisembarked, owner)
end

local function OnUnequip(inst, owner)
    if owner.components.boatvisualmanager then
        owner.components.boatvisualmanager:RemoveBoatEquipVisuals(inst)
    end

    StopWake(inst)
    DespawnWave(inst)

    if inst.visual then
        inst.visual.AnimState:ClearOverrideSymbol("swap_lantern")
    end

    inst.components.rammer:Stop()

    inst:RemoveEventCallback("embarked", inst.onembarked, owner)
    inst:RemoveEventCallback("disembarked", inst.ondisembarked, owner)
end

local function OnFinished(inst)
    inst.components.rammer:Stop()
    StopWake(inst)
    DespawnWave(inst)
	inst:Remove()
end

local function PerformRamFX(inst, target)
    for i=1, 5, 1 do
        local impactFX = SpawnPrefab("boat_hit_fx_quackeringram")

        local dx = math.random(-3, 3)
        local dz = math.random(-3, 3)

        local x, y, z = target.Transform:GetWorldPosition()

        impactFX.Transform:SetPosition(x + dx, y, z + dz)
    end

    local sailor = inst.components.rammer:FindSailor()
    if sailor then
        inst.SoundEmitter:PlaySound("ia/common/quackering_ram/impact")
        -- sailor.Physics:SetMotorVel(sailor.Physics:GetMotorSpeed() + RAM_ONRAM_BOOST, 0, 0)
        sailor:PushEvent("boostmomentum", {boost = RAM_ONRAM_BOOST})

        inst.wakeleft = true
        SpawnWake(inst)
        inst:DoTaskInTime(40 * FRAMES, StopWake)

        -- minor camera shake on hit
        -- function PlayerController:ShakeCamera(inst, shakeType, duration, speed, maxShake, maxDist)
        local distSq = distsq(sailor:GetPosition(), target:GetPosition())
        local maxShake, maxDist = 0.35, 40
        local t = math.max(0, math.min(1, distSq / (maxDist * maxDist)))
        local scale = easing.outQuad(t, maxShake, -maxShake, 1)
        if scale > 0 then
            sailor:ShakeCamera(CAMERASHAKE.VERTICAL, 0.2, 0.025, scale)
        end
    end
end

local function HitCommon(inst, target)
    -- show fx
    PerformRamFX(inst, target)

    -- use up a charge
    inst.components.finiteuses:Use()

    -- cooldown, avoid double hits
    inst.components.rammer:StartCooldown()
end

local function OnPotentialRamHit(inst, target)
    local sailor = inst.components.rammer:FindSailor()

    local inventory = sailor and sailor.components.inventory or nil
    local _IsInsulated = nil
    if inventory then
		_IsInsulated = inventory.IsInsulated
		function inventory:IsInsulated()
			return true  -- will break if electrified on ramming
		end
	end

    if (target.components.inventoryitem == nil or not target.components.inventoryitem:IsHeld() and target.components.inventoryitem.is_landed) 
        and target ~= sailor and not target:HasTag("companion") 
        and (target.components.follower == nil or target.components.follower:GetLeader() ~= sailor) then
		-- 当玩家在船上时不能毁掉船（when player in boat, don't destroy boat） -K
		if (target.components.sailable == nil or not target.components.sailable.sailor)
            and target.components.combat and not target:HasTag("playerghost") 
            and (TheNet:GetPVPEnabled() or not target:HasTag("player")) then
            if sailor then
	            target.components.combat:GetAttacked(sailor, TUNING.QUACKERINGRAM_DAMAGE, inst)
			end
            HitCommon(inst, target)
        elseif target.components.workable and not target:HasTag("busy") then --Haaaaaaack!
            target.components.workable:Destroy(inst)
            HitCommon(inst, target)
        end
    end

    if _IsInsulated then
        inventory.IsInsulated = _IsInsulated
    end
end

local function RammerOnActivate(inst)
    inst.SoundEmitter:PlaySound("ia/common/quackering_ram/impact")
    inst.SoundEmitter:PlaySound("ia/common/quackering_ram/ram_LP", "ram_LP")

    local sailor = inst.components.rammer:FindSailor()
    -- sailor.Physics:SetMotorVel(sailor.Physics:GetMotorSpeed() + RAM_ONACTIVATE_BOOST, 0, 0)
    sailor:PushEvent("boostmomentum", {boost = RAM_ONACTIVATE_BOOST})

    if sailor.components.boatvisualmanager then
        sailor.components.boatvisualmanager:SpawnBoatEquipVisuals(inst, "quackeringram_wave")
    end

    SpawnWave(inst)
end

local function RammerOnDeactivate(inst)
    inst.SoundEmitter:KillSound("ram_LP")

    DespawnWave(inst)
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddNetwork()
    inst.Transform:SetFourFaced()
    inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

    -- used for collision checks in boat.lua
    inst:AddTag("quackeringram")

    inst.AnimState:SetBuild("swap_quackeringram")
    inst.AnimState:SetBank("quackeringram")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

    inst:AddComponent("inspectable")

	MakeHauntableLaunch(inst)

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.boatequipslot = BOATEQUIPSLOTS.BOAT_LAMP
    inst.components.equippable.equipslot = nil
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable.insulated = true

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.QUACKERINGRAM_USE_COUNT)
    inst.components.finiteuses:SetUses(TUNING.QUACKERINGRAM_USE_COUNT)
    inst.components.finiteuses:SetOnFinished(OnFinished)

	inst:AddComponent("rammer")
    inst.components.rammer:SetMinSpeed(2.5)
	inst.components.rammer:SetOnRamTarget(OnPotentialRamHit)
    inst.components.rammer:SetOnActivate(RammerOnActivate)
	inst.components.rammer:SetOnDeactivate(RammerOnDeactivate)

    inst.onembarked = function(owner, data)
        if inst:IsValid() then
            local sailor = data ~= nil and data.sailor or nil
            if sailor ~= nil then
                inst.components.rammer:Start(sailor)
            end
        end
    end
    inst.ondisembarked = function()
        if inst:IsValid() then
            inst.components.rammer:Stop()
        end
    end

    inst:ListenForEvent("onremove", DespawnWave)

    return inst
end

local function quackeringram_visual_common(inst)
    inst.AnimState:SetBank("sail_visual")
    inst.AnimState:SetBuild("swap_quackeringram")
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

return Prefab("quackeringram", fn, assets, prefabs),
    MakeVisualBoatEquip("quackeringram", assets, nil, quackeringram_visual_common)
