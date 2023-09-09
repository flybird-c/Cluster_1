

local assets =
{
  Asset("ANIM", "anim/sandbag.zip"),
}

local prefabs =
{
  "gridplacer",
}

local function ondeploy(inst, pt, deployer)
  local wall = SpawnPrefab("sandbag")
  if wall then
    local map = TheWorld.Map
    local cx, cy, cz = map:GetTileCenterPoint(pt.x, pt.y, pt.z)
    pt = Vector3(cx, cy, cz)
    wall.Physics:SetCollides(false)
    wall.Physics:Teleport(pt.x, pt.y, pt.z)
    wall.Physics:SetCollides(true)
    inst.components.stackable:Get():Remove()
  end
end

local function onhammered(inst, worker)
  inst.components.lootdropper:SpawnLootPrefab("sand")

  SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())

  inst:Remove()
end

local function onhit(inst)
end

local function test_sandbag(inst, pt)
  local tiletype = TheWorld.Map:GetTileAtPoint(pt:Get())
  local ground_OK = tiletype ~= WORLD_TILES.IMPASSABLE and not IsOceanTile(tiletype)

  if ground_OK then
    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 2, nil, {"NOBLOCK", "player", "FX", "INLIMBO", "DECOR"}) -- or we could include a flag to the search?

    for k, v in pairs(ents) do
      if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
        local dsq = distsq( Vector3(v.Transform:GetWorldPosition()), pt)
        if  dsq< 2.83 * 2.83 then return false end
      end
    end
    return true
  end
  return false
end


local function fn()
  local inst = CreateEntity()
  local trans = inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddNetwork()
--  inst.entity:AddFloodingBlockerEntity()

  inst:AddTag("wall")

  MakeObstaclePhysics(inst, 1.5)
  inst.entity:SetCanSleep(false)
  inst.AnimState:SetBank("sandbag")
  inst.AnimState:SetBuild("sandbag")
  inst.AnimState:PlayAnimation("full")

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  inst:AddComponent("inspectable")
  inst:AddComponent("lootdropper")

  inst:AddComponent("workable")
  inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
  inst.components.workable:SetWorkLeft(3)
  inst.components.workable:SetOnFinishCallback(onhammered)
  inst.components.workable:SetOnWorkCallback(onhit)

  ---------------------
  return inst
end

local function itemfn()
  local inst = CreateEntity()
  local trans = inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddNetwork()

  MakeInventoryPhysics(inst)

  inst.AnimState:SetBank("sandbag")
  inst.AnimState:SetBuild("sandbag")
  inst.AnimState:PlayAnimation("idle")

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end

  inst:AddComponent("stackable")
  inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

  inst:AddComponent("inspectable")

  inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetSinks(true)

  inst:AddComponent("deployable")
  inst.components.deployable.ondeploy = ondeploy
  inst.components.deployable.min_spacing = 2.83
  inst.components.deployable.placer = "gridplacer"
  inst.components.deployable:SetDeployMode(DEPLOYMODE.TURF)

  ---------------------
  return inst
end

return Prefab( "sandbag", fn, assets, prefabs ),
Prefab( "sandbag_item", itemfn, assets, prefabs )
