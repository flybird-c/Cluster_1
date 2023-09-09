local assets =
{
    Asset("ANIM", "anim/seaweed_plant.zip"),
}

local underwater_assets =
{
    Asset("ANIM", "anim/seaweed_plant_underwater.zip"),
}

local prefabs =
{
    "seaweed",
    "seaweed_stalk",
}

local function onpickedfn(inst)
    inst.AnimState:PlayAnimation("picking")
    inst.AnimState:PushAnimation("picked", true)
    inst.underwater.AnimState:PlayAnimation("picking")
    inst.underwater.AnimState:PushAnimation("picked", true)
end

local function ontransplantfn(inst)
    inst.components.pickable:MakeEmpty()
    inst.AnimState:PlayAnimation("picked", true)
    inst.underwater.AnimState:PlayAnimation("picked", true)
end

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle_plant", true)
    inst.underwater.AnimState:PlayAnimation("grow")
    inst.underwater.AnimState:PushAnimation("idle_plant", true)
end

local function makeemptyfn(inst)
    inst.AnimState:PushAnimation("picked", true)
    inst.underwater.AnimState:PushAnimation("picked", true)
end

local function CheckBeached(inst)
    -- NOTES(JBK): If this is now beached it was ran ashore through something external force so do not spawn the seaweed_stalk prefab instead spawn the expiring items.
    inst._checkgroundtask = nil
    local x, y, z = inst.Transform:GetWorldPosition()
    if inst:GetCurrentPlatform() ~= nil or TheWorld.Map:IsVisualGroundAtPoint(x, y, z) then
        if inst.components.pickable ~= nil then
            inst.components.pickable:Pick(TheWorld)
        end
        inst:Remove()
        local beached = SpawnPrefab("seaweed_stalk")
        beached.Transform:SetPosition(x, y, z)
    end
end

local function OnCollide(inst, other)
    if inst._checkgroundtask == nil then
        -- This collision callback is called very fast so only do the checks after some time in a staggered method.
        inst._checkgroundtask = inst:DoTaskInTime(1 + math.random(), CheckBeached)
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
            launch_away(loot, position)
        end
    end

    local uprooted_seaweed_plant = SpawnPrefab("seaweed_stalk")
    if uprooted_seaweed_plant ~= nil then
        uprooted_seaweed_plant.Transform:SetPosition(ae_x, ae_y, ae_z)
        launch_away(uprooted_seaweed_plant, position + Vector3(0.5 * math.random(), 0, 0.5 * math.random()))
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

    inst.MiniMapEntity:SetIcon("seaweed.tex")

    MakeInventoryPhysics(inst, nil, 0.7)

    inst.AnimState:SetBank("seaweed_plant")
    inst.AnimState:SetBuild("seaweed_plant")
    inst.AnimState:PlayAnimation("idle_plant", true)

    inst.AnimState:OverrideSymbol("water_ripple", "ripple_build", "water_ripple")
    inst.AnimState:OverrideSymbol("water_shadow", "ripple_build", "water_shadow")

    inst:AddTag("plant")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    ---------------------
    inst.underwater = SpawnPrefab("seaweed_planted_underwater")
	inst.underwater.entity:SetParent(inst.entity)
	inst.underwater.Transform:SetPosition(0, 0, 0)
    ---------------------

    local start_frame = math.random(inst.AnimState:GetCurrentAnimationNumFrames()) - 1
    inst.AnimState:SetFrame(start_frame)
    inst.underwater.AnimState:SetFrame(start_frame)

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "ia/common/item_wet_harvest"
    inst.components.pickable:SetUp("seaweed", TUNING.SEAWEED_REGROW_TIME +  math.random() * TUNING.SEAWEED_REGROW_VARIANCE)
    inst.components.pickable.onregenfn = onregenfn
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn
    inst.components.pickable.ontransplantfn = ontransplantfn

    inst:AddComponent("inspectable")

    inst._on_trident_explosion_fn = OnTridentExplosion

    inst.Physics:SetCollisionCallback(OnCollide)
    inst:DoTaskInTime(1 + math.random(), CheckBeached) -- Does not need to be immediately done stagger over time.

    return inst
end

local function underwaterfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("seaweed_plant_underwater")
    inst.AnimState:SetBuild("seaweed_plant_underwater")
    inst.AnimState:PlayAnimation("idle_plant", true)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)

    inst:AddTag("DECOR")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("seaweed_planted", fn, assets, prefabs),
        Prefab("seaweed_planted_underwater", underwaterfn, underwater_assets)
