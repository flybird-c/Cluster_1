local assets=
{
	Asset("ANIM", "anim/earring.zip"),
}

local function shine(inst)
    inst.task = nil

     -- hacky, need to force a floatable anim change
    inst.components.floater:UpdateAnimations("idle_water", "idle")
    inst.components.floater:UpdateAnimations("sparkle_water", "sparkle")

    if inst.components.floater:IsFloating() then
        inst.AnimState:PushAnimation("idle_water")
    else
        inst.AnimState:PushAnimation("idle")
    end
    inst.task = inst:DoTaskInTime(4 + math.random() * 5, function() shine(inst) end)
end

local function fn()

	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst:AddTag("trinket")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle")

	inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

    inst.AnimState:SetBank("earring")
    inst.AnimState:SetBuild("earring")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("stackable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 3
    inst.components.tradable.dubloonvalue = 12

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_HUGE

    shine(inst)
    return inst
end

return Prefab( "common/inventory/earring", fn, assets)
