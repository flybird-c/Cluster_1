local assets=
{
	Asset("ANIM", "anim/rowboat_wake_quack.zip")
}

local function StartAnim(inst)
    -- Four faced, much better than a stupid loop like in ds -_-
    inst.AnimState:PlayAnimation("quack", true)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst:AddTag("nointerpolate")

	inst.AnimState:SetBuild("rowboat_wake_quack")
	inst.AnimState:SetBank("wakeTrail")
    inst.AnimState:SetLayer(LAYER_BACKGROUND )
	inst.AnimState:SetSortOrder(-3)
    
    -- In ds the sort order is set in a loop with the following comment
    -- "when facing up, let the wind effect be behind the boat"
    -- This is stupid because the effect will ALWAYS be behind the boat (has the background layer)
    -- Im not going to change the sort because its pretty obvious its just pointless leftover code

    inst.persists = false

    inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

    -- Start the anim only after its been attached to the player
    inst.StartAnim = StartAnim

    return inst
end

return Prefab("quackeringram_wave", fn, assets)
