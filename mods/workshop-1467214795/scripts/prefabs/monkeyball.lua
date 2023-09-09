local assets=
{
	Asset("ANIM", "anim/monkey_ball.zip"),
	Asset("ANIM", "anim/swap_monkeyball.zip"),
}

local function unclaim(inst)
	inst.claimed = nil
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_monkeyball", "swap_monkeyball")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
	owner.AnimState:ClearOverrideSymbol("swap_object")
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function onputininventory(inst)
	-- print('monkeyball in invnentory')
	inst.claimed = true
    inst.Physics:SetFriction(.1)
end

local function onhitground(inst)
	if inst.unclaimtask then
		inst.unclaimtask:Cancel()
		inst.unclaimtask = nil
	end
	unclaim(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle")
end

local function pop(inst)
	inst.SoundEmitter:PlaySound("ia/common/monkey_ball/pop")
	SpawnPrefab("small_puff_light").Transform:SetPosition(inst.Transform:GetWorldPosition())
	SpawnPrefab("coconut_chunks").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst:Remove()
end

local function onthrown(inst, thrower, pt)
	inst.unclaimtask = inst:DoTaskInTime(1, unclaim)

    inst.Physics:SetFriction(.2)
	inst.Transform:SetFourFaced()
	inst:FacePoint(pt:Get())
    inst.components.floater:UpdateAnimations("idle_water", "throw")
    inst.AnimState:PlayAnimation("throw", true)
    inst.SoundEmitter:PlaySound("ia/common/coconade_throw")

	inst.TrackHeight = inst:DoPeriodicTask(FRAMES, function()
		local pos = inst:GetPosition()

		if pos.y <= 1 then
			onhitground(inst)
			inst.TrackHeight:Cancel()
			inst.TrackHeight = nil

			if IsOnOcean(inst) then
				inst.components.floater:PlayWaterAnim()
			else
				inst.components.floater:PlayLandAnim()
				inst.SoundEmitter:PlaySound("ia/common/monkey_ball/bounce")
			end

			if inst.onfinished then
				inst:DoTaskInTime(.1, pop)
			end
		end
	end)

    -- inst.components.inventoryitem.canbepickedup = false
end

local function oncollision(inst, other)
	if inst.Physics:GetVelocity() ~= 0 then
		inst.SoundEmitter:PlaySound("ia/common/monkey_ball/bounce")
	end
end

local function onfinished(inst)
	inst.onfinished = true
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("monkeyball")
	inst.AnimState:SetBuild("monkey_ball")
	inst.AnimState:PlayAnimation("idle")

    MakeSmallBurnable(inst)
	MakeInventoryPhysics(inst)
    inst.Physics:ClearCollidesWith(COLLISION.LIMITS)
	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

	inst:AddTag("thrown")
	inst:AddTag("projectile")
	inst:AddTag("monkeybait")
    inst:AddTag("allow_action_on_impassable")

	inst.onfinished = false

	inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

    MakeHauntableLaunch(inst)

	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(onputininventory)
	inst.components.inventoryitem.bouncesound = "ia/common/monkey_ball/bounce"

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.equipstack = true

	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.MONKEYBALL_USES)
	inst.components.finiteuses:SetUses(TUNING.MONKEYBALL_USES)
	inst.components.finiteuses:SetOnFinished(onfinished)
	inst.components.finiteuses:SetConsumption(ACTIONS.THROW, 1)

	inst:AddComponent("throwable")
	inst.components.throwable.onthrown = onthrown

	inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function()
        return inst.components.throwable:GetThrowPoint()
    end
    inst.components.reticule.ease = true

    inst.Physics:SetCollisionCallback(oncollision)

	return inst
end

return Prefab("monkeyball", fn, assets)
