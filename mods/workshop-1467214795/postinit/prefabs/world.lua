local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local _tile_physics_init
local function tile_physics_init(inst, ...)
    print("new_tile_physics_init", inst:HasTag("forest"))
    if inst:HasTag("forest") then
        -- a slightly modified version of the forest map's primary collider.
        inst.Map:AddTileCollisionSet(
            COLLISION.LAND_OCEAN_LIMITS,
            TileGroups.TransparentOceanTiles, true,
            TileGroups.LandTiles, true,
            0.25, 64
        )
        -- IA's ocean collider
        inst.Map:AddTileCollisionSet(
            COLLISION.LAND_OCEAN_LIMITS,
            TileGroups.LandTiles, true,
            TileGroups.IAOceanTiles, true,
            0.25, 64
        )
        --standard impassable collider
        inst.Map:AddTileCollisionSet(
            COLLISION.PERMEABLE_GROUND, -- maybe split permable into its own sub group in the future?
            TileGroups.ImpassableTiles, true,
            TileGroups.ImpassableTiles, false,
            0.25, 128
        )
        return
    end
    return _tile_physics_init ~= nil and _tile_physics_init(inst, ...)
end

local function SwapStrings(world)
    STRINGS.NAMES.FISHINGROD = world.has_ia_ocean and STRINGS.NAMES.IA_FISHINGROD or STRINGS.NAMES.DST_FISHINGROD
    STRINGS.NAMES.OCEANFISHINGROD = world.has_ia_ocean and STRINGS.NAMES.IA_OCEANFISHINGROD or STRINGS.NAMES.DST_OCEANFISHINGROD
    STRINGS.TABS.SEAFARING = world.has_ia_ocean and STRINGS.TABS.NAUTICAL or STRINGS.TABS.SEAFARING
    STRINGS.UI.CRAFTING_FILTERS.SEAFARING = world.has_ia_ocean and STRINGS.UI.CRAFTING_FILTERS.NAUTICAL or STRINGS.UI.CRAFTING_FILTERS.SEAFARING
end

local function InstallIaComponents(inst)
    print("Loading world with IA:",
        inst:HasTag("forest") and "Has Forest" or "No Forest",
        inst:HasTag("cave") and "Has Cave" or "No Cave",
        inst:HasTag("island") and "Has Islands" or "No Islands",
        inst:HasTag("volcano") and "Has Volcano" or "No Volcano"
    )

    if not TheNet:IsDedicated() then
        if inst:HasTag("volcano") then
            inst:AddComponent("volcanowave")
        end
    end

    --temp
    inst.has_ia_ocean = inst:HasTag("island") or inst:HasTag("volcano")
    Map.ia_overhang = inst:HasTag("island")
    inst.items_pass_ground = inst:HasTag("island") or inst:HasTag("volcano")

    SwapStrings(inst)

	if inst:HasTag("island") then
		inst:AddComponent("flooding")
        inst.Flooding = {GetTileCenterPoint = function(self, x, y, z) return inst.components.flooding:GetFloodCenterPoint(x, y, z) end} -- GEOPLACEMENT SUPPORT
        if inst.ismastersim then
			inst:AddComponent("monsoonflooding")
		end
        if inst.net and inst.net.components.weather then
            inst.net.components.weather.cannotsnow = true
        end
	end

    if inst:HasTag("volcano") then
        if inst.net then
            inst.net:AddComponent("volcanoambience")
        end
    end

    if not inst.ismastersim then
        return
    end

    if inst:HasTag("forest") then
        inst:AddComponent("flotsamrebatcher")
    end

    if inst:HasTag("island") or inst:HasTag("volcano") then
        inst:AddComponent("worldislandtemperature")
        inst:AddComponent("volcanomanager")
    end

    if inst:HasTag("island") then
        inst:AddComponent("hailrain")
        inst:AddComponent("wavelanemanager") -- only for ripples not shimmer
        inst:AddComponent("chessnavy")
        inst:AddComponent("whalehunter")
        inst:AddComponent("tigersharker")
        inst:AddComponent("twisterspawner")
        inst:AddComponent("floodmosquitospawner")
        inst:AddComponent("rainbowjellymigration")
        inst:AddComponent("krakener")
        inst:AddComponent("buriedtreasuremanager")
    end

    if inst:HasTag("volcano") then
        inst:AddComponent("daywalkerspawner")
    end

    inst:AddComponent("doydoyspawner")

    inst.InstallIaComponents = nil -- destruct after use
end

local function SpawnIaPrefab(inst)

    if not inst.ismastersim then
        return
    end

    if inst:HasTag("island") then
    end

    if inst:HasTag("forest") then
        SpawnUtil.SpawnSunkenBoat(inst)
    end

    if inst:HasTag("volcano") then
        SpawnUtil.SpawnVolcanoLavaFX(inst)
    end
end

IAENV.AddPrefabPostInit("world", function(inst)
    _tile_physics_init = inst.tile_physics_init
    inst.tile_physics_init = tile_physics_init

    inst.SpawnIaPrefab = SpawnIaPrefab
    inst.InstallIaComponents = InstallIaComponents

    local _OnPreLoad = inst.OnPreLoad
    inst.OnPreLoad = function(...)
        local primaryworldtype = inst.topology and inst.topology.overrides and inst.topology.overrides.primaryworldtype
        if not inst.topology or not inst.topology.ia_worldgen_version then
            primaryworldtype = "default"   -- pre-RoT fix
        end

        if primaryworldtype == nil then
            primaryworldtype = "default"  -- RoT: Forgotten Knowledge pruned world settings for a while.
        end

        if primaryworldtype then
            if WORLDTYPES.volcanoclimate[primaryworldtype] and not inst:HasTag("volcano") then
                inst:AddTag("volcano")
            end
            if WORLDTYPES.islandclimate[primaryworldtype] and not inst:HasTag("island") then
                inst:AddTag("island")
                local volcanoisland = inst.topology.ia_worldgen_version and inst.topology and inst.topology.overrides and inst.topology.overrides.volcanoisland or "none"
                if volcanoisland == "always" and not inst:HasTag("volcano") then
                    inst:AddTag("volcano")
                end
            end
            if not WORLDTYPES.defaultclimate[primaryworldtype] and inst:HasTag("forest") then
                inst:RemoveTag("forest")
            end
        end

        if inst.SpawnIaPrefab then
            inst:SpawnIaPrefab()
        end

        if inst.InstallIaComponents then
            inst:InstallIaComponents()
        end

        return _OnPreLoad and _OnPreLoad(...)
    end
end)