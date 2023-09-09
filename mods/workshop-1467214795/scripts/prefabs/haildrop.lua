local assets =
{
	Asset( "ANIM", "anim/splash_hail.zip" ),
	Asset( "ANIM", "anim/hail.zip" ),
}

local function fn()
	local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

	inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBuild("splash_hail")
    inst.AnimState:SetBank("splash_hail")
	inst.AnimState:PlayAnimation("idle")
	
	inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("haildrop", fn, assets)
