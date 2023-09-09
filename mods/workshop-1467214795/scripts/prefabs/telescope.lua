local normalassets=
{
	Asset("ANIM", "anim/telescope.zip"),
	Asset("ANIM", "anim/swap_telescope.zip"),
}
local superassets=
{
	Asset("ANIM", "anim/telescope_long.zip"),
	Asset("ANIM", "anim/swap_telescope_long.zip"),
}

local prefabs =
{
}

local function onfinished(inst)
	local user = inst.components.inventoryitem:GetGrandOwner()
	if not user then
		inst:Remove()
	else
		user:ListenForEvent("animover", function() 
			inst:Remove()
		end)
	end
end

local function onequip(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_object", "swap_telescope", "swap_object")
	owner.AnimState:Show("ARM_carry") 
	owner.AnimState:Hide("ARM_normal") 
end

local function onsuperequip(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_object", "swap_telescope_long", "swap_object")
	owner.AnimState:Show("ARM_carry") 
	owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner)
	owner.AnimState:Hide("ARM_carry") 
	owner.AnimState:Show("ARM_normal") 
end

local function oncast(inst, doer, pos)
	-- You can find this line in SGWilson and SGWilsonboating in the peertelescope state
	-- Because the telescope needs to exist after casting the last spell so the putaway animation can play.
	inst.components.finiteuses:Use()
	inst.SoundEmitter:PlaySound("ia/common/use_spyglass_reveal")
end

local function onsupercast(inst, doer, pos)
	inst.components.finiteuses:Use()
	inst.SoundEmitter:PlaySound("ia/common/supertelescope")
end

local function ReticuleTargetFn()
	return Vector3(ThePlayer.entity:LocalToWorldSpace(5,0,0))
end

--I stole these function from the Forge weapons without much thinking about it.
--Could be a neat visual upgrade. -M
-- local function ReticuleMouseTargetFn(inst, mousepos)
    -- if mousepos ~= nil then
        -- local x, y, z = inst.Transform:GetWorldPosition()
        -- local dx = mousepos.x - x
        -- local dz = mousepos.z - z
        -- local l = dx * dx + dz * dz
        -- if l <= 0 then
            -- return inst.components.reticule.targetpos
        -- end
        -- l = 6.5 / math.sqrt(l)
        -- return Vector3(x + dx * l, 0, z + dz * l)
    -- end
-- end
-- local function ReticuleUpdatePositionFn(inst, pos, reticule, ease, smoothing, dt)
    -- local x, y, z = inst.Transform:GetWorldPosition()
    -- reticule.Transform:SetPosition(x, 0, z)
    -- local rot = -math.atan2(pos.z - z, pos.x - x) / DEGREES
    -- if ease and dt ~= nil then
        -- local rot0 = reticule.Transform:GetRotation()
        -- local drot = rot - rot0
        -- rot = Lerp((drot > 180 and rot0 + 360) or (drot < -180 and rot0 - 360) or rot0, rot, dt * smoothing)
    -- end
    -- reticule.Transform:SetRotation(rot)
-- end


local function commonpristine()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst:AddTag("nopunch")
    inst:AddTag("allow_action_on_impassable")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

	inst:AddComponent("reticule")
	inst.components.reticule.targetfn = ReticuleTargetFn
	-- inst.components.reticule.mousetargetfn = ReticuleMouseTargetFn
	-- inst.components.reticule.updatepositionfn = ReticuleUpdatePositionFn
	inst.components.reticule.ease = true

	return inst
end

local function commonmaster(inst)

	MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)
	MakeHauntableLaunch(inst)

	-------
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.TELESCOPE_USES)
	inst.components.finiteuses:SetUses(TUNING.TELESCOPE_USES)
	inst.components.finiteuses:SetOnFinished(onfinished)
	-------
	
	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	
	inst:AddComponent("equippable")
	inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("telescope")
	-- inst:AddComponent("spellcaster")
	-- inst.components.spellcaster:SetAction(ACTIONS.PEER)
    -- inst.components.spellcaster:SetSpellFn(oncast)
    -- inst.components.spellcaster:SetSpellTestFn(peertest)
    -- inst.components.spellcaster.canuseonpoint = true
    -- inst.components.spellcaster.canusefrominventory = false
end

local function normalfn()
	local inst = commonpristine()

	inst.AnimState:SetBank("telescope")
	inst.AnimState:SetBuild("telescope")
	inst.AnimState:PlayAnimation("idle")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	commonmaster(inst)

	inst.components.equippable:SetOnEquip(onequip)

	inst.components.telescope:SetOnUseFn(oncast)
	inst.components.telescope:SetRange(TUNING.TELESCOPE_RANGE)
	-- inst.components.spellcaster:SetSpellFn(oncast)

	return inst
end

local function superfn()
	local inst = commonpristine()

	inst.AnimState:SetBank("telescope_long")
	inst.AnimState:SetBuild("telescope_long")
	inst.AnimState:PlayAnimation("idle")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	commonmaster(inst)
	
	inst.components.equippable:SetOnEquip(onsuperequip)

	inst.components.telescope:SetOnUseFn(onsupercast)
	inst.components.telescope:SetRange(TUNING.SUPERTELESCOPE_RANGE)
	-- inst.components.spellcaster:SetSpellFn(onsupercast)

	return inst
end

return Prefab( "telescope", normalfn, normalassets, prefabs),
	Prefab( "supertelescope", superfn, superassets, prefabs)
