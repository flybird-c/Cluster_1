require "prefabutil"

local assets =
{
  Asset("ANIM", "anim/musselfarm.zip"),
}

local prefabs =
{
  "mussel",
  "collapse_small",
}


local function getnewpoint(pt)

  local theta = math.random() * 2 * PI
  local radius = 6+math.random()*6

  local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
      local spawn_point = pt + offset
      if TheWorld.Map:GetTileAtPoint(spawn_point:Get()) == WORLD_TILES.OCEAN_SHALLOW then
        return true
      end
      return false
    end)

  if result_offset then
    return pt+result_offset
  end
end

local function movetonewhome(inst, child)
  local pos = Vector3(inst.Transform:GetWorldPosition())
  local spawn_point = getnewpoint(pos)

  if spawn_point then
    child.Transform:SetPosition(spawn_point:Get())
  end
end

local function onpickedfn(inst, picker)

  inst.AnimState:PlayAnimation("picked")


  inst.pickedanimdone = function(inst)
    inst.components.growable:SetStage(1)
    inst:RemoveEventCallback("animover", inst.pickedanimdone)
  end

  inst:ListenForEvent("animover", inst.pickedanimdone)
end

-- for inspect string
local function getstatus(inst)
  if inst.growthstage > 0 then
    return "STICKPLANTED"
  end
end

local function makeemptyfn(inst)
  -- never called?
end

local function makefullfn(inst)
  inst.AnimState:PlayAnimation("idle_full")
end

local function UnderBoat(inst)
  if not inst:HasTag("ignorewalkableplatforms") then
    inst:AddTag("ignorewalkableplatforms")
  end
  if not inst:HasTag("NOBLOCK") then
    inst:AddTag("NOBLOCK")
  end
  if inst:HasTag("blocker") then
    inst:RemoveTag("blocker")
  end
  inst.Physics:ClearCollisionMask()
end

local function AboveBoat(inst)
  if inst:HasTag("ignorewalkableplatforms") then
    inst:RemoveTag("ignorewalkableplatforms")
  end
  if inst:HasTag("NOBLOCK") then
    inst:RemoveTag("NOBLOCK")
  end
  if not inst:HasTag("blocker") then
    inst:AddTag("blocker")
  end
  inst.Physics:SetMass(0) --Bullet wants 0 mass for static objects
  inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
  inst.Physics:ClearCollisionMask()
  inst.Physics:CollidesWith(COLLISION.ITEMS)
  inst.Physics:CollidesWith(COLLISION.CHARACTERS)
  inst.Physics:CollidesWith(COLLISION.GIANTS)
  inst.Physics:CollidesWith(COLLISION.OBSTACLES)
  inst.Physics:SetCapsule(0.2, 1)
end

-- stage 1
local function SetHidden(inst)
  inst.components.pickable.numtoharvest = 0
  inst.components.pickable.canbepicked = false
  inst.components.blowinwindgust:Stop()
  inst.MiniMapEntity:SetEnabled(false)
  inst:Hide()
  inst.components.stickable:UnStuck()
  UnderBoat(inst)
end

-- stage 2
local function SetUnderwater(inst)
  inst.AnimState:PlayAnimation("idle_underwater", true)
  inst.components.pickable.numtoharvest = 0
  inst.components.pickable.canbepicked = false
  inst.components.blowinwindgust:Stop()
  inst.AnimState:SetLayer(LAYER_BACKGROUND)
  inst.AnimState:SetSortOrder(-3)
  inst.MiniMapEntity:SetEnabled(false)
  inst:Show()
  inst.components.stickable:UnStuck()
  UnderBoat(inst)
end

local function SetAboveWater(inst)
  -- common
  inst.AnimState:SetLayer(LAYER_WORLD)
  inst.AnimState:SetSortOrder(0)
  inst.components.blowinwindgust:Start()
  inst.MiniMapEntity:SetEnabled(true)
  inst.components.growable:StartGrowing()
  inst:Show()
  inst.components.stickable:Stuck()
  AboveBoat(inst)
end

-- stage 3
local function SetEmpty(inst)
  inst.AnimState:PlayAnimation("idle_empty", true)
  inst.components.pickable.numtoharvest = 0
  inst.components.pickable.canbepicked = false
  inst.components.pickable.hasbeenpicked = false

  SetAboveWater(inst)
end

-- stage 4
local function SetSmall(inst)
  inst.AnimState:PlayAnimation("idle_small", true)
  inst.components.pickable.numtoharvest = TUNING.MUSSEL_CATCH_SMALL
  inst.components.pickable.canbepicked = true
  inst.components.pickable.hasbeenpicked = false

  SetAboveWater(inst)
end

-- stage 5
local function SetMedium(inst)
  -- there's no real animation for this stage
  inst.AnimState:PlayAnimation("idle_small", true)
  inst.components.pickable.numtoharvest = TUNING.MUSSEL_CATCH_MED
  inst.components.pickable.canbepicked = true
  inst.components.pickable.hasbeenpicked = false

  SetAboveWater(inst)
end

-- stage 6
local function SetLarge(inst)
  inst.AnimState:PlayAnimation("idle_full", true)
  inst.components.pickable.numtoharvest = TUNING.MUSSEL_CATCH_LARGE
  inst.components.pickable.canbepicked = true
  inst.components.pickable.hasbeenpicked = false

  SetAboveWater(inst)
end



local function GrowHidden(inst)

end

local function GrowUnderwater(inst)

end

local function GrowEmpty(inst)
  inst.growthstage = 2
  inst.AnimState:PlayAnimation("empty_to_small")
  inst.AnimState:PushAnimation("idle_small", true)
end

local function GrowSmall(inst)
  --inst.AnimState:PlayAnimation("empty_to_small")
  --inst.AnimState:PushAnimation("idle_small", true)
end

local function GrowMedium(inst)
  inst.AnimState:PlayAnimation("small_to_full")
  inst.AnimState:PushAnimation("idle_full", true)
end

local function GrowLarge(inst)

end


local growth_stages =
{
  {
    name = "hidden",
    time = function(inst)
      return GetRandomWithVariance(TUNING.MUSSEL_CATCH_TIME[1].base, TUNING.MUSSEL_CATCH_TIME[1].random)
    end,
    fn = SetHidden,
    growfn = GrowHidden,
  },
  {
    name = "underwater", -- waiting to be stuck
    time = function(inst)
      return nil -- this stage doesn't grow automatically
    end,
    fn = SetUnderwater,
    growfn = GrowUnderwater,
  },
  {
    name = "empty", -- the stick is in now
    time = function(inst)
      return GetRandomWithVariance(TUNING.MUSSEL_CATCH_TIME[2].base, TUNING.MUSSEL_CATCH_TIME[2].random)
    end,
    fn = SetEmpty,
    growfn = GrowEmpty,
  },
  {
    name = "small",
    time = function(inst)
      return GetRandomWithVariance(TUNING.MUSSEL_CATCH_TIME[3].base, TUNING.MUSSEL_CATCH_TIME[3].random)
    end,
    fn = SetSmall,
    growfn = GrowSmall,
  },
  {
    name = "medium",
    time = function(inst)
      return GetRandomWithVariance(TUNING.MUSSEL_CATCH_TIME[4].base, TUNING.MUSSEL_CATCH_TIME[4].random)
    end,
    fn = SetMedium,
    growfn = GrowMedium,
  },
  {
    name = "large",
    time = function(inst)
      return GetRandomWithVariance(TUNING.MUSSEL_CATCH_TIME[5].base, TUNING.MUSSEL_CATCH_TIME[5].random)
    end,
    fn = SetLarge,
    growfn = GrowLarge,
  },
}


local function onpoked(inst, worker, stick)
    inst.SoundEmitter:PlaySound("ia/common/plant_mussel")
    inst.components.growable:SetStage(3)

    if stick.components.stackable and stick.components.stackable.stacksize > 1 then
        stick = stick.components.stackable:Get()
    end

    stick:Remove()
end

local function OnCollide(inst, data)
  local other_boat_physics = data.other.components.boatphysics
  if other_boat_physics == nil then
      return
  end

  local hit_velocity = math.abs(other_boat_physics:GetVelocity() * data.hit_dot_velocity) / other_boat_physics.max_velocity
  if hit_velocity > 1 then

    SpawnPrefab("collapse_small").Transform:SetPosition(inst:GetPosition():Get())
    SpawnPrefab("bamboo").Transform:SetPosition(inst:GetPosition():Get())

    if inst.components.pickable:CanBePicked() then
      inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product)
    end

    inst.components.growable:SetStage(1)

  end
end


local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("mussel_farm.tex")
    minimap:SetEnabled(false) --Not enabled until poked

    inst:AddTag("structure")
    inst:AddTag("mussel_farm")

    inst.AnimState:SetBank("musselFarm")
    inst.AnimState:SetBuild("musselFarm")
    inst.AnimState:PlayAnimation("idle_underwater", true)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(-2)
    inst.AnimState:SetRayTestOnBB(true)

    inst.no_wet_prefix = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.growthstage = 0
    inst.targettime = nil

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("stickable")
    inst.components.stickable:SetOnPokeCallback(onpoked)

    MakePickableBlowInWindGust(inst, TUNING.MUSSELFARM_WINDBLOWN_SPEED, TUNING.MUSSELFARM_WINDBLOWN_FALL_CHANCE)
    inst.components.blowinwindgust:SetGustStartFn(nil)

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
    inst.components.pickable.canbepicked = false
    inst.components.pickable.hasbeenpicked = false
    inst.components.pickable.product = "mussel"
    inst.components.pickable.numtoharvest = 0
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn
    inst.components.pickable.makebarrenfn = makeemptyfn
    inst.components.pickable.makefullfn = makefullfn

    inst:AddComponent("growable")
    inst.components.growable.stages = growth_stages
    inst.components.growable:SetStage(2)
    inst.components.growable.loopstages = false

    inst:AddComponent("lootdropper")

    inst:ListenForEvent("on_collide", OnCollide)

    return inst
end

return Prefab("mussel_farm", fn, assets, prefabs)