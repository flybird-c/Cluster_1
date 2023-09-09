local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

---------------------------------------------------------------------------------------------------------------------------------------------

local LIGHT = "LIGHT"
local MEDIUM = "MEDIUM"
local HEAVY = "HEAVY"

local add_blow_in_wind = {
    nubbin = MEDIUM,
    coral = LIGHT,
    acorn = MEDIUM,
    balloons_empty = LIGHT,
    balloon = LIGHT,
    balloonspeed = LIGHT,
    balloonparty = LIGHT,
    balloonvest = LIGHT,
    balloonhat = LIGHT,
    butterflywings = LIGHT,
    moonbutterflywings = LIGHT,
    charcoal = LIGHT,
    cutgrass = LIGHT,
    cutreeds = LIGHT,
    bird_egg = LIGHT,
    featherfan = LIGHT,
    feather_crow = LIGHT,
    feather_robin = LIGHT,
    feather_robin_winter = LIGHT,
    feather_canary = LIGHT,
    malbatross_feather = LIGHT,
    goose_feather = LIGHT,
    guano = MEDIUM,
    flint = HEAVY,
    froglegs = MEDIUM,
    gears = HEAVY,
    goldnugget = MEDIUM,
    moonrocknugget = HEAVY,
    moonglass = MEDIUM,
    moonglass_charged = MEDIUM,
    heatrock = HEAVY,
    rocks = HEAVY,
    saltrock = MEDIUM,
    marble = HEAVY,
    rock_avocado_fruit = HEAVY,
    ice = MEDIUM,
    cave_banana = LIGHT,
    fig = LIGHT,
    berries = LIGHT,
    berries_cooked = LIGHT,
    berries_juicy = LIGHT,
    berries_juicy_cooked = LIGHT,
    kelp = LIGHT,
    kelp_cooked = LIGHT,
    kelp_dried = LIGHT,
    livinglog = HEAVY,
    log = HEAVY,
    slurtle_shellpieces = LIGHT,
    lureplantbulb = HEAVY,
    batwing = MEDIUM,
    batwing_cooked = MEDIUM,
    driftwood_log = MEDIUM,
    drumstick = MEDIUM,
    drumstick_cooked = MEDIUM,
    trunk_summer = MEDIUM,
    trunk_winter = MEDIUM,
    trunk_cooked = MEDIUM,
    plantmeat = MEDIUM,
    plantmeat_cooked = MEDIUM,
    meat = MEDIUM,
    mussel = MEDIUM,
    mussel_cooked = MEDIUM,
    barnacle = MEDIUM,
    barnacle_cooked = MEDIUM,
    cookedmeat = MEDIUM,
    meat_dried = MEDIUM,
    smallmeat = LIGHT,
    cookedsmallmeat = LIGHT,
    smallmeat_dried = LIGHT,
    monstermeat = MEDIUM,
    cookedmonstermeat = MEDIUM,
    monstermeat_dried = MEDIUM,
    blue_cap = LIGHT,
    green_cap = LIGHT,
    red_cap = LIGHT,
    moon_cap = LIGHT,
    red_cap_cooked = LIGHT,
    blue_cap_cooked = LIGHT,
    green_cap_cooked = LIGHT,
    moon_cap_cooked = LIGHT,
    nightmarefuel = LIGHT,
    nitre = MEDIUM,
    papyrus = LIGHT,
    petals = LIGHT,
    petals_evil = LIGHT,
    pinecone = LIGHT,
    palmcone_scale = LIGHT,
    palmcone_seed = LIGHT,
    pigskin = MEDIUM,
    poop = MEDIUM,
    rottenegg = LIGHT,
    rope = LIGHT,
    seeds = LIGHT,
    silk = LIGHT,
    spidergland = MEDIUM,
    spoiled_food = MEDIUM,
    spoiled_fish_small = MEDIUM,
    spoiled_fish = MEDIUM,
    spoiled_fish_large = MEDIUM,
    stinger = LIGHT,
    torch = MEDIUM,
    transistor = MEDIUM,
    twigs = LIGHT,
    twiggy_nut = LIGHT,
    dug_marsh_bush = MEDIUM,
    dug_coffeebush = MEDIUM,
    dug_elephantcactus = MEDIUM,
    dug_berrybush = MEDIUM,
    dug_berrybush2 = MEDIUM,
    dug_berrybush_juicy = MEDIUM,
    dug_bananabush = MEDIUM,
    dug_monkeytail = MEDIUM,
    dug_sapling = MEDIUM,
    dug_sapling_moon = MEDIUM,
    dug_grass = MEDIUM,
    dug_bambootree = MEDIUM,
    dug_bush_vine = MEDIUM,
    dug_rock_avocado_bush = MEDIUM,
    carrot = LIGHT,
    carrot_seeds = LIGHT,
    corn = LIGHT,
    corn_seeds = LIGHT,
    pumpkin = MEDIUM,
    pumpkin_seeds = LIGHT,
    eggplant = MEDIUM,
    eggplant_seeds = LIGHT,
    durian = LIGHT,
    durian_seeds = LIGHT,
    pomegranate = LIGHT,
    pomegranate_seeds = LIGHT,
    dragonfruit = LIGHT,
    dragonfruit_seeds = LIGHT,
    watermelon = MEDIUM,
    watermelon_seeds = LIGHT,
    tomato = LIGHT,
    tomato_seeds = LIGHT,
    potato = LIGHT,
    potato_seeds = LIGHT,
    asparagus = LIGHT,
    asparagus_seeds = LIGHT,
    onion = LIGHT,
    onion_seeds = LIGHT,
    garlic = LIGHT,
    garlic_seeds = LIGHT,
    pepper = LIGHT,
    pepper_seeds = LIGHT,
    sweet_potato = LIGHT,
    sweet_potato_seeds = LIGHT,
}

local NeverOnWater = {
	livingjungletree = true,
	flower_evil = true,
	tidalpool = true,
    skeleton = true,
}

local function RemoveOnWater(inst)
	if IsOnOcean(inst) then
		inst:Remove()
	end
end

---------------------------------------------------------------------------------------------------------------------------------------------

local COLLISION = COLLISION

local function CheckItemBeached(inst)
    -- NOTES(JBK): If this is now beached it was ran ashore through something external force so do not spawn the seaweed_stalk prefab instead spawn the expiring items.
    if inst.components.inventoryitem ~= nil then
        inst._checkgroundtask = nil
        inst.components.inventoryitem:UpdateWater()
    end
end

local function OnItemCollide(boat, item)
    if item == nil or item.Physics == nil or item.components.inventoryitem == nil or not item.Physics:ShouldPassGround() then return end
    if item._checkgroundtask == nil then
        -- This collision callback is called very fast so only do the checks after some time in a staggered method.
        item._checkgroundtask = item:DoTaskInTime(1 + math.random(), CheckItemBeached)
    end
end

local function SetupShouldPassGround(inst)
    if inst.Physics ~= nil then
        if inst.Physics:GetCollisionGroup() == COLLISION.BOAT_LIMITS then
            if inst:GetPhysicsCollisionCallback() == nil then
                -- OnPhysicsCollision doesnt run unless SetCollisionCallback
                -- has been set at least once
                inst.Physics:SetCollisionCallback(function() end)
            end
            inst:AddPhysicsCallback("item_beached_check", OnItemCollide)
        elseif TheWorld.items_pass_ground and inst.components.inventoryitem ~= nil and (inst.components.inventoryitem.sinks or inst.components.floater) 
            and inst.Physics:ShouldPassGround() == nil and not inst.Physics:CollidesWith(COLLISION.LAND_OCEAN_LIMITS + COLLISION.PERMEABLE_GROUND) then
            inst.Physics:SetShouldPassGround(true)
        end
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
---------------------------------------------------------------------------------------------------------------------------------------------

IAENV.AddPrefabPostInitAny(function(inst)
    if inst and TheWorld.ismastersim then
        --if this list gets larger we can modify this a bit.
        if (inst.prefab == "wx78" or inst:HasTag("shadow") or inst:HasTag("chess") or inst:HasTag("wall") or inst:HasTag("poisonimmune")
        or inst:HasTag("mech") or inst:HasTag("brightmare") or inst:HasTag("hive") or inst:HasTag("ghost") or inst:HasTag("veggie")
        or inst:HasTag("balloon") or inst:HasTag("equipmentmodel") or inst:HasTag("shadowthrall") or inst:HasTag("stalker")
        or inst:HasTag("stalkerminion") or inst:HasTag("shadowchesspiece") or inst:HasTag("smashable") or inst:HasTag("groundspike"))
        and inst.poisonimmune ~= false then inst.poisonimmune = true end

        if inst.components and inst.components.combat and inst.components.health and not inst.poisonimmune and not inst.components.poisonable then
            if inst:HasTag("player") then
                MakePoisonableCharacter(inst, nil, nil, "player", 0, 0, 1)
                inst.components.poisonable.duration = TUNING.TOTAL_DAY_TIME * 3
                inst.components.poisonable.transfer_poison_on_attack = false
            else
                MakePoisonableCharacter(inst)
            end
        end

        if add_blow_in_wind[inst.prefab] then
            MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN[add_blow_in_wind[inst.prefab]], TUNING.WINDBLOWN_SCALE_MAX[add_blow_in_wind[inst.prefab]])
        end
        
        SetupShouldPassGround(inst)

        if (inst:HasTag("shadow") or inst:HasTag("shadowchesspiece") or inst:HasTag("brightmare") or inst:HasTag("playermerm")) and not inst:HasTag("flood_immune") then
            inst:AddTag("flood_immune")
        end

        if (inst:HasTag("shadow") or inst:HasTag("shadowchesspiece") or inst:HasTag("brightmare") or inst:HasTag("ghost")) and not inst:HasTag("wind_immune") then
            inst:AddTag("wind_immune")
        end

        if NeverOnWater[inst.prefab] then
    		inst:DoTaskInTime(0,RemoveOnWater)
    	end

        if inst:HasTag("SnowCovered") then
            if not inst.components.climatetracker then
                inst:AddComponent("climatetracker")
            end

            --objects that move between climates now properly update being snow covered.
            inst:ListenForEvent("climatechange", function(inst, data)
                if not IsInIAClimate(inst) and TheWorld.state.issnowcovered then
                    inst.AnimState:Show("snow")
                else
                    inst.AnimState:Hide("snow")
                end
            end)
        end
    end
end)