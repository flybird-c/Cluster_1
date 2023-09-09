local assets = {
    Asset("ANIM", "anim/swap_pirate_booty_bag.zip"),
}

local function SpawnDubloon(inst, owner)
    local dubloon = SpawnPrefab("dubloon")
    local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0, 2, 0)

    dubloon.Transform:SetPosition(pt:Get())
    local angle = owner.Transform:GetRotation()*(PI / 180)
    local sp = (math.random() + 1) * -1
    dubloon.Physics:SetVel(sp * math.cos(angle), math.random() * 2 + 8, -sp * math.sin(angle))
	dubloon.components.inventoryitem:SetLanded(false, true)
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "swap_pirate_booty_bag", "backpack")
    owner.AnimState:OverrideSymbol("swap_body", "swap_pirate_booty_bag", "swap_body")

    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end

    inst.dubloon_task = inst:DoPeriodicTask(TUNING.TOTAL_DAY_TIME, function() SpawnDubloon(inst, owner) end)
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("backpack")

    if inst.components.container ~= nil then
        inst.components.container:Close(owner)
    end

    if inst.dubloon_task then
        inst.dubloon_task:Cancel()
        inst.dubloon_task = nil
    end
end

local function onequiptomodel(inst, owner, from_ground)
    if inst.components.container ~= nil then
        inst.components.container:Close(owner)
    end

    if inst.dubloon_task then
        inst.dubloon_task:Cancel()
        inst.dubloon_task = nil
    end
end

--[[ local function onburnt(inst)
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
    end

    SpawnPrefab("ash").Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst:Remove()
 end

local function onignite(inst)
    if inst.components.container ~= nil then
        inst.components.container.canbeopened = false
    end
end

local function onextinguish(inst)
    if inst.components.container ~= nil then
        inst.components.container.canbeopened = true
    end
end]]

local function OnHaunt(inst, haunter)
	if math.random() <= TUNING.HAUNT_CHANCE_RARE then
		SpawnDubloon(inst, haunter)
	end
	return false
end

local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("pirate_booty_bag")
    inst.AnimState:SetBuild("swap_pirate_booty_bag")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("backpack")

    inst.MiniMapEntity:SetIcon("piratepack.tex")

    inst.foleysound = "ia/common/foley/pirate_booty_pack"

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "anim")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BACK

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("piratepack")

    -- [Game Update] - 525640: Removed burnable from seed pack it and insulated pack
    -- MakeSmallBurnable(inst)
    -- MakeSmallPropagator(inst)
    -- inst.components.burnable:SetOnBurntFn(onburnt)
    -- inst.components.burnable:SetOnIgniteFn(onignite)
    -- inst.components.burnable:SetOnExtinguishFn(onextinguish)

    MakeHauntableLaunchAndDropFirstItem(inst)
	AddHauntableCustomReaction(inst, OnHaunt, true, false, true)
    inst.components.hauntable.hauntvalue = TUNING.HAUNT_LARGE

    return inst
end

return Prefab("piratepack", fn, assets)
