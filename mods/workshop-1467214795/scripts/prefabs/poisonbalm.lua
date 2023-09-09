local assets =
{
	Asset("ANIM", "anim/poison_salve.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("poison_salve")
	inst.AnimState:SetBuild("poison_salve")
	inst.AnimState:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")

	inst:AddComponent("poisonhealer")

	MakeHauntableLaunch(inst)

	return inst
end

return Prefab( "poisonbalm", fn, assets) 
