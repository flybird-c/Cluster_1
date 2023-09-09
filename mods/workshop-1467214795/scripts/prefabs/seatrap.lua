local assets =
{
	Asset("ANIM", "anim/trap_sea.zip"),
}

local function onharvested(inst)
    if inst.components.finiteuses then
        inst.components.finiteuses:Use(1)
    end
end

local function onbaited(inst, bait)
	inst:PushEvent("baited")
	bait:Hide()
end

local function onpickup(inst, doer)
	if inst.components.trap and inst.components.trap.bait and doer.components.inventory then
		inst.components.trap.bait:Show()
		doer.components.inventory:GiveItem(inst.components.trap.bait)
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    inst.Physics:SetShouldPassGround(false)

    inst.MiniMapEntity:SetIcon("rabbittrap.png")

	inst.AnimState:SetBank("trap_sea")
	inst.AnimState:SetBuild("trap_sea")
	inst.AnimState:PlayAnimation("idle")

    inst:AddTag("trap")
	
	inst.no_wet_prefix = true

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.nobounce = true
	inst.components.inventoryitem:SetOnPickupFn( onpickup )

	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.TRAP_USES)
	inst.components.finiteuses:SetUses(TUNING.TRAP_USES)
	inst.components.finiteuses:SetOnFinished( inst.Remove )

    inst:AddComponent("trap")
    inst.components.trap.targettag = "lobster"
    inst.components.trap:SetOnHarvestFn( onharvested )
	inst.components.trap:SetOnBaitedFn( onbaited )
    -- inst.components.trap.baitsortorder = 1 --not needed, we hide the bait anyways
	inst.components.trap.range = 2
	inst.components.trap.water = true

    MakeHauntableLaunch(inst)

    inst:SetStateGraph("SGseatrap")

    return inst
end

return Prefab("seatrap", fn, assets)
