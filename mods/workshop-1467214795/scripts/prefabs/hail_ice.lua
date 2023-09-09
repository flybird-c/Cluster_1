local assets =
{
    Asset("ANIM", "anim/ice_hail.zip"),
}

local names = {"f1", "f2", "f3"}

local function onsave(inst, data)
    data.anim = inst.animname
end

local function onload(inst, data)
    if data and data.anim then
        inst.animname = data.anim
        inst.AnimState:PlayAnimation(inst.animname)
    end
end

local function onperish(inst)
    local owner = inst.components.inventoryitem.owner
    if owner ~= nil then
        local stacksize = inst.components.stackable:StackSize()
        if owner.components.moisture ~= nil then
            owner.components.moisture:DoDelta(2 * stacksize)
        elseif owner.components.inventoryitem ~= nil then
            owner.components.inventoryitem:AddMoisture(4 * stacksize)
        end
        inst:Remove()
    else
        local stacksize = inst.components.stackable:StackSize()
		local x, y, z = inst.Transform:GetWorldPosition()
        TheWorld.components.farming_manager:AddSoilMoistureAtPoint(x, y, z, stacksize * TUNING.ICE_MELT_GROUND_MOISTURE_AMOUNT / 2)

        inst.persists = false
        inst.components.inventoryitem.canbepickedup = false
        inst.AnimState:PlayAnimation("melt")
        inst:ListenForEvent("animover", inst.Remove)
    end
end

local function onfiremelt(inst)
    inst.components.perishable.frozenfiremult = true
end

local function onstopfiremelt(inst)
    inst.components.perishable.frozenfiremult = false
end

--TODO imrpove this function
local function playfallsound(inst)
    local ice_fall_sound =
    {
        [WORLD_TILES.BEACH] = "ia/common/ice_fall/beach",
        [WORLD_TILES.JUNGLE] = "ia/common/ice_fall/jungle",
        [WORLD_TILES.TIDALMARSH] = "ia/common/ice_fall/marsh",
        [WORLD_TILES.MAGMAFIELD] = "ia/common/ice_fall/rocks",
        [WORLD_TILES.MEADOW] = "ia/common/ice_fall/grass",
        [WORLD_TILES.VOLCANO] = "ia/common/ice_fall/rocks",
        [WORLD_TILES.ASH] = "ia/common/ice_fall/rocks",
    }

    local tile = inst:GetCurrentTileType()
    if ice_fall_sound[tile] ~= nil then
        inst.SoundEmitter:PlaySound(ice_fall_sound[tile])
    elseif IsLandTile(tile) then
        inst.SoundEmitter:PlaySound("ia/common/ice_fall/grass")
    end
end

-- local function onhitground_hail(inst, onwater)
--     if not onwater then
--         playfallsound(inst)
--     else
--         inst.persists = false --let the default behaviour handle this
--         -- inst:Remove()
--     end
-- end

local function onlanded_hail(inst)
    if inst.components.inventoryitem:ShouldSink() then
        inst.persists = false -- let the default behaviour handle this --TODO verify this works in R08_ROT_TURNOFTIDES
        -- inst:Remove()
    else
        playfallsound(inst)
    end
end

local function onlanded_haildrop(inst)
    if not inst.components.inventoryitem:ShouldSink() then
        if math.random() < TUNING.HURRICANE_HAIL_BREAK_CHANCE then
            inst.components.inventoryitem.canbepickedup = false
            inst.AnimState:PlayAnimation("break")
            inst:ListenForEvent("animover", inst.Remove)
        else
            inst.components.inventoryitem.canbepickedup = true
            inst.persists = true
            inst:RemoveEventCallback("on_landed", onlanded_haildrop)
        end
    end
end

local function hail_startfalling(inst, x, y, z)
    -- inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    -- inst.Physics:ClearCollisionMask()
    -- inst.Physics:CollidesWith(COLLISION.GROUND)
    -- inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    -- inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    -- inst.Physics:SetCollisionCallback(function(inst, other)
    --     if other and other.components.health and other.Physics:GetCollisionGroup() == COLLISION.CHARACTERS then
    --         other.components.health:DoDelta(-TUNING.HURRICANE_HAIL_DAMAGE, false, "hail")
    --     end
    -- end)
    inst.Physics:Teleport(x, 35, z)
    inst:ListenForEvent("on_landed", onlanded_haildrop)
    inst.components.inventoryitem:SetLanded(false, true)
    inst.components.inventoryitem.canbepickedup = false
    inst.persists = false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("ice_hail")
    inst.AnimState:SetBuild("ice_hail")

    inst:AddTag("frozen")
    inst:AddTag("molebait")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.animname = names[math.random(#names)]
    inst.AnimState:PlayAnimation(inst.animname)

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "ELEMENTAL"
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/8
    inst.components.edible.degrades_with_spoilage = false
    inst.components.edible.temperaturedelta = TUNING.COLD_FOOD_BONUS_TEMP
    inst.components.edible.temperatureduration = TUNING.FOOD_TEMP_BRIEF * 1.5

    inst:AddComponent("smotherer")

    inst:ListenForEvent("firemelt", onfiremelt)
    inst:ListenForEvent("stopfiremelt", onstopfiremelt)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_ONE_DAY)
    inst.components.perishable:StartPerishing()
    inst.components.perishable:SetOnPerishFn(onperish)

    inst:AddComponent("tradable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(onstopfiremelt)
    inst.components.inventoryitem:SetSinks(true)
    inst.nosunkenprefab = true

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.ICE
    inst.components.repairer.perishrepairpercent = .05

    inst:AddComponent("bait")

    inst:ListenForEvent("on_landed", onlanded_hail)

    inst.StartFalling = hail_startfalling

    inst.OnSave = onsave
    inst.OnLoad = onload

    MakeHauntableLaunchAndSmash(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)

    return inst
end

return Prefab("hail_ice", fn, assets)