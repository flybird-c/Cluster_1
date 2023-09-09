local assets =
{
    Asset("ANIM", "anim/player_ghost_withhat.zip"),
    Asset("ANIM", "anim/ghost_pirate_build.zip"),
}

local function fn()
	local inst = Prefabs["ghost"].fn()
	
    inst.AnimState:SetBuild("ghost_pirate_build")
	
	return inst
end

return Prefab("pirateghost", fn, assets)
