local assets =
{
	Asset("ANIM", "anim/blades.zip"),
}

local function fn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("blades")
    inst.AnimState:SetBuild("blades")
    inst.AnimState:PlayAnimation("idle")

    inst.pickupsound = "metal"

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    
    MakeHauntableLaunch(inst)
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

	return inst
end

return Prefab("turbine_blades", fn, assets)
