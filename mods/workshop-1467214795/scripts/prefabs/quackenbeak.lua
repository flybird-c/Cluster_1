local assets =
{
    Asset("ANIM", "anim/quackenbeak.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst) 
    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle")

    inst.AnimState:SetBank("quackenbeak")
    inst.AnimState:SetBuild("quackenbeak")
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("moistureimmunity")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    MakeHauntableLaunch(inst)

    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab("quackenbeak", fn, assets)
