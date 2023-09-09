local assets=
{
	Asset("ANIM", "anim/seal_of_approval.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("seal_of_approval")
    inst.AnimState:SetBuild("seal_of_approval")
    inst.AnimState:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    MakeHauntableLaunch(inst)

    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab("magic_seal", fn, assets)
