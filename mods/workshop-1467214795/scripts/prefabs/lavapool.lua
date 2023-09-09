local assets =
{
	Asset("ANIM", "anim/lava_pool.zip"),
}

local prefabs =
{
    "ash",
    "rocks",
    "charcoal",
    -- "dragoon",
    "rock1",
    "obsidian",
}

local function OnExtinguish(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    -- spawn some things
    local radius = 1
    local things = {"rocks", "rocks", "ash", "ash", "charcoal"}
    for i = 1, #things, 1 do
        local thing = SpawnPrefab(things[i])
        thing.Transform:SetPosition(x + radius * UnitRand(), y, z + radius * UnitRand())
    end

    inst.AnimState:ClearBloomEffectHandle()
    inst:Remove()
end

local function OnIgnite(inst)
end

local function ShouldAcceptItem(inst, item)
    return item.prefab == "ice"
end

local function OnGetItemFromPlayer(inst, giver, item)
    local x, y, z = inst.Transform:GetWorldPosition()
    local obsidian = SpawnPrefab("obsidian")
    obsidian.Transform:SetPosition(x, y, z)

    SpawnPrefab("collapse_small").Transform:SetPosition(x, y, z)
    inst:Remove()
end

local function OnRefuseItem(inst, giver, item)
    -- print("Lavapool refuses " .. tostring(item.prefab))
end

local function CollectUseActions(inst, useitem, actions, right)
    if useitem.prefab == "ice" then
        table.insert(actions, ACTIONS.GIVE)
    elseif useitem.components.cookable then
        table.insert(actions, ACTIONS.COOK)
    end
end

local function OnUpdateFueled(inst)
    if inst.components.burnable then
        inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
    end
end

local function OnFuelChange(newsection, oldsection, inst)
    if newsection == 0 then
        inst.components.burnable:Extinguish()

    else
        if not inst.components.burnable:IsBurning() then
            inst.components.burnable:Ignite()
        end

        inst.components.burnable:SetFXLevel(newsection, inst.components.fueled:GetSectionPercent())
        local ranges = {1, 1, 1, 1}
        local output = {2, 5, 5, 10}
        inst.components.propagator.propagaterange = ranges[newsection]
        inst.components.propagator.heatoutput = output[newsection]
    end
end

local function OnFloodedStart(inst)
    if inst.components.burnable then
        inst.components.burnable:Extinguish()
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lava_pool")
    inst.AnimState:SetBuild("lava_pool")
    inst.Transform:SetFourFaced()

    inst:AddTag("fire")
    inst:AddTag("lavapool")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:PlayAnimation("dump")
    inst.AnimState:PushAnimation("idle_loop")
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("cooker")
    MakeObstaclePhysics(inst, .6)
    inst.Physics:SetCollides(false)

    inst:AddComponent("burnable")
    inst.components.burnable:AddBurnFX("campfirefire", Vector3(0, 0, 0))
    -- inst.components.burnable:MakeNotWildfireStarter()
    inst:ListenForEvent("onextinguish", OnExtinguish)
    inst:ListenForEvent("onignite", OnIgnite)

    inst:AddComponent("propagator")
    inst.components.propagator.damagerange = 1
    inst.components.propagator.damages = true

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.CollectUseActions = CollectUseActions

    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = TUNING.LAVAPOOL_FUEL_MAX
    inst.components.fueled:InitializeFuelLevel(TUNING.LAVAPOOL_FUEL_START)
    inst.components.fueled:SetSections(4)
    inst.components.fueled.rate = 1
    inst.components.fueled:SetUpdateFn(OnUpdateFueled)
    inst.components.fueled:SetSectionCallback(OnFuelChange)

    inst:AddComponent("floodable")
    inst.components.floodable.onStartFlooded = OnFloodedStart

    return inst
end

return Prefab("lavapool", fn, assets, prefabs)
