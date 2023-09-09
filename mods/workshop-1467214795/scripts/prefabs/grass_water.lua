local assets =
{
    Asset("ANIM", "anim/grass_inwater.zip"),
    Asset("ANIM", "anim/grassgreen_build.zip"),
}

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", true)
    inst.AnimState:SetLayer(LAYER_WORLD)
end

local function onpickedfn(inst, picker)
    inst.Physics:SetCollides(false)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")

    inst.AnimState:PlayAnimation("picking")
    inst.AnimState:PushAnimation("picked", true)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
end

local _Regen = nil
local function Regen(self, ...)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    if TheWorld.Map:GetNearbyPlatformAtPoint(x, y, z, 0.5) == nil then
        return _Regen(self, ...)
    else
        self:MakeEmpty()
    end
end

local function makeemptyfn(inst)
    inst.AnimState:PlayAnimation("picked", true)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
end

local function makefullfn(inst)
    inst.AnimState:PushAnimation("idle", true)
    inst.AnimState:SetLayer(LAYER_WORLD)
end

local function OnCollide(inst, other)
    if inst.components.pickable and inst.components.pickable.canbepicked and
        other and other.Physics and other.Physics:GetCollisionGroup() == COLLISION.BOAT_LIMITS then
        if inst.components.pickable then
            local success, loot = inst.components.pickable:Pick(TheWorld)

            if loot ~= nil then
                for i, item in ipairs(loot) do
                    FlingItem(inst, item, other:GetPosition(), 60)
                end
            end
        end
    end
end

local function OnTridentExplosion(inst, trident, owner, position, launch_away)
    local ae_x, ae_y, ae_z = inst.Transform:GetWorldPosition()

    if inst.components.pickable and inst.components.pickable:CanBePicked() then
        local product = inst.components.pickable.product
        local loot = SpawnPrefab(product)
        if loot ~= nil then
            loot.Transform:SetPosition(ae_x, ae_y, ae_z)
            if loot.components.inventoryitem ~= nil then
                loot.components.inventoryitem:InheritWorldWetnessAtTarget(self.inst)
            end
            if loot.components.stackable ~= nil
                    and inst.components.pickable.numtoharvest > 1 then
                loot.components.stackable:SetStackSize(inst.components.pickable.numtoharvest)
            end
            if loot.components.visualvariant then
                loot.components.visualvariant:CopyOf(inst)
            end
            launch_away(loot, position)
        end
    end

    local uprooted_grass_plant = SpawnPrefab("dug_grass")
    if uprooted_grass_plant ~= nil then
        if uprooted_grass_plant.components.visualvariant then
            uprooted_grass_plant.components.visualvariant:CopyOf(inst)
        end
        uprooted_grass_plant.Transform:SetPosition(ae_x, ae_y, ae_z)
        launch_away(uprooted_grass_plant, position + Vector3(0.5*math.random(), 0, 0.5*math.random()))
    end

    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst, 0, 0.25)
    inst:AddTag("ignorewalkableplatforms")
    inst.Physics:SetCollides(false)  -- Still will get collision callback, just not dynamic collisions.

    inst.MiniMapEntity:SetIcon("grass_tropical.tex")

    inst.AnimState:SetBank("grass_inwater")
    inst.AnimState:SetBuild("grass_inwater")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("plant")
    inst:AddTag("silviculture")  -- for silviculture book

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetTime(math.random() * 2)
    local color = 0.75 + math.random() * 0.25
    inst.AnimState:SetMultColour(color, color, color, 1)

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"

    inst.components.pickable:SetUp("cutgrass", TUNING.GRASS_REGROW_TIME)
    inst.components.pickable.onregenfn = onregenfn
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn
    inst.components.pickable.makefullfn = makefullfn
    inst.components.pickable.use_lootdropper_for_worldpicker = true
    if not _Regen then
        _Regen = inst.components.pickable.Regen
    end
    inst.components.pickable.Regen = Regen

    inst._on_trident_explosion_fn = OnTridentExplosion

    inst:AddComponent("lootdropper")
    inst:AddComponent("inspectable")

    ---------------------

    MakeNoGrowInWinter(inst)
    MakeHauntableIgnite(inst)

    MakePickableBlowInWindGust(inst, TUNING.GRASS_WINDBLOWN_SPEED, TUNING.GRASS_WINDBLOWN_FALL_CHANCE)

    inst.Physics:SetCollisionCallback(OnCollide)

    return inst
end

return Prefab("grass_water", fn, assets)