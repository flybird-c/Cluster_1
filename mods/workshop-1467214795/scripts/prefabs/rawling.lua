local assets =
{
	Asset("ANIM", "anim/basketball.zip"),
	Asset("ANIM", "anim/swap_basketball.zip"),
}

local function onputininventory(inst)
    inst.Physics:SetFriction(.1)
end

local function onhitground(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle")
end

local function onthrown(inst, thrower, pt)

    inst.Physics:SetFriction(.2)
	inst.Transform:SetFourFaced()
	inst:FacePoint(pt:Get())
    inst.components.floater:UpdateAnimations("idle_water", "throw")
    inst.AnimState:PlayAnimation("throw", true)
    inst.SoundEmitter:PlaySound("ia/common/coconade_throw")

    if thrower.components.sanity then
    	thrower.components.sanity:DoDelta(TUNING.SANITY_SUPERTINY)
    end

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
		end
	end)
end

local function oncollision(inst, other)
	inst.SoundEmitter:PlaySound("ia/common/monkey_ball/bounce")
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_basketball", "swap_basketball")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")

	if inst.components.sentientball then
		inst.components.sentientball:OnEquipped()
	end
end

local function onunequip(inst, owner)
	owner.AnimState:ClearOverrideSymbol("swap_object")
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function OnHaunt(inst)
    if inst.components.sentientball ~= nil then
        inst.components.sentientball:Say(STRINGS.RAWLING.on_haunt)
        return true
    end
    return false
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst.AnimState:SetBank("basketball")
	inst.AnimState:SetBuild("basketball")
	inst.AnimState:PlayAnimation("idle")

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("rawling.tex")

	MakeInventoryPhysics(inst)
    inst.Physics:ClearCollidesWith(COLLISION.LIMITS)

	inst:AddTag("nopunch")
    inst:AddTag("allow_action_on_impassable")
	inst:AddTag("irreplaceable")

	inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function()
        return inst.components.throwable:GetThrowPoint()
    end
    inst.components.reticule.ease = true

	inst:AddComponent("talker")
	inst.components.talker.fontsize = 28
	inst.components.talker.font = TALKINGFONT
	inst.components.talker.colour = Vector3(.9, .4, .4, 1)
	inst.components.talker.offset = Vector3(0,100,0)
	inst.components.talker.symbol = "swap_object"

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(onputininventory)
	inst.components.inventoryitem.bouncesound = "ia/common/monkey_ball/bounce"

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.equipstack = true
	inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

	-- note: We don't actually use a classified, so the lines do not sync up. Who cares? -M
	inst:AddComponent("sentientball")

	inst:AddComponent("throwable")
	inst.components.throwable.onthrown = onthrown

	inst.Physics:SetCollisionCallback(oncollision)

	inst:ListenForEvent("ontalk", function()
		if not inst.SoundEmitter:PlayingSound("special") then
			inst.SoundEmitter:PlaySound("ia/characters/rawling/talk_LP", "talk")
		end
	end)
	inst:ListenForEvent("donetalking", function() inst.SoundEmitter:KillSound("talk") end)

    MakeHauntableLaunch(inst)
	AddHauntableCustomReaction(inst, OnHaunt, true, false, true)

	return inst
end

return Prefab( "rawling", fn, assets, prefabs)
