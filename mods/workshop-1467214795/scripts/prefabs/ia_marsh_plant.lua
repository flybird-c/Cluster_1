local assets =
{
    Asset("ANIM", "anim/tidal_plant.zip"),
    Asset("ANIM", "anim/marsh_plant_tropical.zip"),
}

local function fn(bank, build)
  return function()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
      return inst
    end

    MakeMediumBurnable(inst)
    MakeSmallPropagator(inst)
    MakeHauntableIgnite(inst)

    inst:AddComponent("inspectable")

    return inst
  end
end

return Prefab("tidal_plant", fn("tidal_plant", "tidal_plant"), assets),
Prefab("marsh_plant_tropical", fn("marsh_plant_tropical", "marsh_plant_tropical"), assets)