local assets =
{
	Asset("ANIM", "anim/wormhole_shipwrecked.zip"),
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	anim:SetBank("teleporter_worm")
	anim:SetBuild("wormhole_shipwrecked")
	anim:PlayAnimation("in")
	anim:PushAnimation("out", false)

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:DoTaskInTime(0*FRAMES, function() inst.SoundEmitter:PlaySound("ia/common/portal/open") end)
	inst:DoTaskInTime(8*FRAMES, function() inst.SoundEmitter:PlaySound("ia/common/portal/jump_in") end)

	inst:ListenForEvent("animqueueover", inst.Remove)
	
	return inst
end

return Prefab("wormhole_shipwrecked_fx", fn, assets)
