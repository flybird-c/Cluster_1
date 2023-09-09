local assets =
{
	Asset("ANIM", "anim/quackering_ram_splash.zip"),
}

local function PlayAnim(inst)
    inst.AnimState:PlayAnimation(inst.idleanimation or "idle" )
end

local function fn()
    local inst = CreateEntity()
    inst.persists = false
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst.entity:AddAnimState()

    inst.AnimState:SetBuild("quackering_ram_splash")
    inst.AnimState:SetBank("fx")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(-3)
    inst:DoTaskInTime(6 * FRAMES, PlayAnim)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)
    inst:ListenForEvent("entitysleep", inst.Remove)

    inst:AddComponent("colourtweener")
    inst.components.colourtweener:StartTween({0,0,0,0}, FRAMES*30)

    return inst
end

return Prefab("quackering_wake", fn, assets)
