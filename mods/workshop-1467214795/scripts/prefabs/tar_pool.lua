local assets=
{
	Asset("ANIM", "anim/tar_pit.zip"),
}

local prefabs=
{
	"tar",
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddSoundEmitter()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("tar.tex")
	
	inst.AnimState:SetBank("tar_pit")
	inst.AnimState:SetBuild("tar_pit")
	inst.AnimState:PlayAnimation("idle", true)
	--inst.AnimState:SetRayTestOnBB(true)
	inst.AnimState:SetLayer( LAYER_BACKGROUND ) -- TODO: Sort below docks
	inst.AnimState:SetSortOrder( -3 )
	
	inst:AddTag("NOBLOCK")
	inst:AddTag("tarpit")
    inst:AddTag("ignorewalkableplatforms")

	-- This looping sound seems to show up at 0,0,0..
	-- so waiting a frame to start it when the tarpool will be in the world at it's location.
	inst:DoTaskInTime(0, function() inst.SoundEmitter:PlaySound("ia/common/tar_LP","burble") end)
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)  
	
	-- MakeSmallBurnable(inst)
	-- MakeSmallPropagator(inst)

	return inst
end

return Prefab( "tar_pool", fn, assets) 
