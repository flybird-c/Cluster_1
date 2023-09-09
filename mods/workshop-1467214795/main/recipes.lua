--[[
AddRecipe("name", {Ingredient("name", numrequired)}, GLOBAL.RECIPETABS.LIGHT, TECH.NONE, "placer", min_spacing, b_nounlock, numtogive, "builder_required_tag", nil, "image.tex", testfn)

AquaticRecipe("name", {distance=, shore_distance=, platform_distance=, shore_buffer_max=, shore_buffer_min=, platform_buffer_max=, platform_buffer_min=, aquatic_buffer_min=, noshore=})
]]

local AddRecipe2 = AddRecipe2
local AddRecipePostInit = AddRecipePostInit
local AddRecipePostInitAny = AddRecipePostInitAny
local AddDeconstructRecipe = AddDeconstructRecipe
local AddCharacterRecipe = AddCharacterRecipe

local BOATMODE_RECIPES = require("prefabs/recipe_gamemode_defs").BOATMODE_RECIPES
local GAMEMODE_RECIPES = require("prefabs/recipe_gamemode_defs").GAMEMODE_RECIPES

GLOBAL.setfenv(1, GLOBAL)

local function SortRecipe(a, b, filter_name, offset)
    local filter = CRAFTING_FILTERS[filter_name]
    if filter and filter.recipes then
        for sortvalue, product in ipairs(filter.recipes) do
            if product == a then
                table.remove(filter.recipes, sortvalue)
                break
            end
        end

        local target_position = #filter.recipes + 1
        for sortvalue, product in ipairs(filter.recipes) do
            if product == b then
                target_position = sortvalue + offset
                break
            end
        end
        table.insert(filter.recipes, target_position, a)
    end
end

local function SortBefore(a, b, filter_name)
    SortRecipe(a, b, filter_name, 0)
end

local function SortAfter(a, b, filter_name)
    SortRecipe(a, b, filter_name, 1)
end

local function IsSWMarshLand(pt, rot)
    local ground_tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
    return ground_tile and (ground_tile == WORLD_TILES.MARSH or ground_tile == WORLD_TILES.TIDALMARSH)
end

local function AquaticRecipe(name, data)
    if AllRecipes[name] then
        -- data = {distance=, shore_distance=, platform_distance=, shore_buffer_max=, shore_buffer_min=, platform_buffer_max=, platform_buffer_min=, aquatic_buffer_min=, noshore=}
        data = data or {}
        data.platform_buffer_max = data.platform_buffer_max or (data.platform_distance and math.sqrt(data.platform_distance)) or (data.distance and math.sqrt(data.distance)) or nil
        data.shore_buffer_max = data.shore_buffer_max or (data.shore_distance and ((data.shore_distance+1)/2)) or nil
        AllRecipes[name].aquatic = data
        AllRecipes[name].build_mode = BUILDMODE.WATER
    end
end


-- local function GameModeRecipe(name, game_type)
--     if AllRecipes[name] then
--         AllRecipes[name].game_type = game_type
--         GAMEMODE_RECIPES[game_type][name] = AllRecipes[name]
--     end
-- end

local function BoatModeRecipe(name, boat_type)
    if AllRecipes[name] then
        AllRecipes[name].boat_type = boat_type
        BOATMODE_RECIPES[boat_type][name] = AllRecipes[name]
    end
end

AddRecipe2("chiminea", {Ingredient("limestonenugget", 2), Ingredient("sand", 2), Ingredient("log", 2)}, TECH.NONE, {placer = "chiminea_placer"}, {"LIGHT","COOKING","WINTER","RAIN"})
SortAfter("chiminea", "firepit", "LIGHT")
SortAfter("chiminea", "firepit", "COOKING")
SortAfter("chiminea", "firepit", "WINTER")
SortAfter("chiminea", "eyebrellahat", "RAIN")

AddRecipe2("obsidianfirepit", {Ingredient("obsidian", 8), Ingredient("log", 3)}, TECH.SCIENCE_TWO, {placer = "obsidianfirepit_placer"}, {"LIGHT","COOKING","WINTER","RAIN"})
SortAfter("obsidianfirepit", "coldfirepit", "LIGHT")
SortAfter("obsidianfirepit", "chiminea", "COOKING")
SortAfter("obsidianfirepit", "chiminea", "WINTER")
SortAfter("obsidianfirepit", "chiminea", "RAIN")

AddRecipe2("bottlelantern", {Ingredient("ia_messagebottleempty", 1), Ingredient("bioluminescence", 2)}, TECH.SCIENCE_TWO, nil, {"LIGHT"})
SortAfter("bottlelantern", "lantern", "LIGHT")

AddRecipe2("sea_chiminea", {Ingredient("limestonenugget", 6), Ingredient("sand", 4), Ingredient("tar", 6)}, TECH.NONE, {placer="sea_chiminea_placer"}, {"LIGHT","COOKING","WINTER","RAIN"})
AquaticRecipe("sea_chiminea", {shore_distance=7, platform_distance=4, shore_buffer_max= 4.5, shore_buffer_min=3, platform_buffer_max=1.5, platform_buffer_min=0.5})
SortAfter("sea_chiminea", "obsidianfirepit", "LIGHT")
SortAfter("sea_chiminea", "obsidianfirepit", "COOKING")
SortAfter("sea_chiminea", "obsidianfirepit", "WINTER")
SortAfter("sea_chiminea", "obsidianfirepit", "RAIN")

AddRecipe2("waterchest", {Ingredient("boards", 4), Ingredient("tar", 1)}, TECH.NONE, {placer="waterchest_placer", min_spacing=1}, {"STRUCTURES", "CONTAINERS"})
AquaticRecipe("waterchest", {shore_distance=7, platform_distance=4, shore_buffer_max= 4.5, shore_buffer_min=3, platform_buffer_max=1.5, platform_buffer_min=0.5})
SortAfter("waterchest", "treasurechest", "STRUCTURES")
SortAfter("waterchest", "treasurechest", "CONTAINERS")

AddRecipe2("wall_limestone_item", {Ingredient("limestonenugget", 2)}, TECH.SCIENCE_TWO, {numtogive=6}, {"STRUCTURES","DECOR"})
SortAfter("wall_limestone_item", "wall_stone_item", "STRUCTURES")
SortAfter("wall_limestone_item", "wall_stone_item", "DECOR")

AddRecipe2("wall_enforcedlimestone_item", {Ingredient("limestonenugget", 2), Ingredient("seaweed", 4)}, TECH.SCIENCE_ONE, {numtogive=6}, {"STRUCTURES","DECOR"})
SortAfter("wall_enforcedlimestone_item", "wall_limestone_item", "STRUCTURES")
SortAfter("wall_enforcedlimestone_item", "wall_limestone_item", "DECOR")

AddRecipe2("wildborehouse", {Ingredient("bamboo", 8), Ingredient("palmleaf", 5), Ingredient("pigskin", 4)}, TECH.SCIENCE_TWO, {placer="wildborehouse_placer"}, {"STRUCTURES"})
SortAfter("wildborehouse", "pighouse", "STRUCTURES")

AddRecipe2("ballphinhouse", {Ingredient("limestonenugget", 4), Ingredient("seaweed", 4), Ingredient("dorsalfin", 2)}, TECH.SCIENCE_ONE, {placer="ballphinhouse_placer", min_spacing=1}, {"STRUCTURES"})
AquaticRecipe("ballphinhouse", {shore_distance=7, platform_distance=4, shore_buffer_max= 4.5, shore_buffer_min=3, platform_buffer_max=2, platform_buffer_min=1.5})
SortAfter("ballphinhouse", "wildborehouse", "STRUCTURES")

AddRecipe2("primeapebarrel", {Ingredient("twigs", 10), Ingredient("cave_banana", 3), Ingredient("poop", 4)}, TECH.SCIENCE_TWO, {placer="primeapebarrel_placer"}, {"STRUCTURES"})
SortAfter("primeapebarrel", "ballphinhouse", "STRUCTURES")

AddRecipe2("dragoonden", {Ingredient("dragoonheart", 1), Ingredient("rocks", 5), Ingredient("obsidian", 4)}, TECH.SCIENCE_TWO, {placer="dragoonden_placer"}, {"STRUCTURES"})
SortAfter("dragoonden", "primeapebarrel", "STRUCTURES")

AddRecipe2("turf_snakeskin", {Ingredient("snakeskin", 2), Ingredient("fabric", 1)}, TECH.SCIENCE_TWO, {numtogive=4}, {"DECOR"})
SortAfter("turf_snakeskin", "turf_carpetfloor", "DECOR")

AddRecipe2("sandbagsmall_item", {Ingredient("sand", 3), Ingredient("fabric", 2)}, TECH.SCIENCE_ONE, {numtogive=4}, {"STRUCTURES","RAIN","DECOR"})
SortAfter("sandbagsmall_item", "wall_enforcedlimestone_item", "STRUCTURES")
SortAfter("sandbagsmall_item", "lightning_rod", "RAIN")
SortAfter("sandbagsmall_item", "wall_enforcedlimestone_item", "DECOR")

AddRecipe2("sandcastle", {Ingredient("sand", 4), Ingredient("palmleaf", 2), Ingredient("seashell", 3)}, TECH.NONE, {placer="sandcastle_placer"}, {"STRUCTURES","DECOR"})
SortAfter("sandcastle", "sisturn", "STRUCTURES")
SortAfter("sandcastle", "endtable", "DECOR")

AddRecipe2("mussel_stick", {Ingredient("bamboo", 2), Ingredient("vine", 1), Ingredient("seaweed", 1)}, TECH.SCIENCE_ONE, nil, {"GARDENING"})
SortAfter("mussel_stick", "premiumwateringcan", "GARDENING")

AddRecipe2("fish_farm", {Ingredient("coconut", 4), Ingredient("rope", 2), Ingredient("silk", 2)}, TECH.SCIENCE_ONE, {placer="fish_farm_placer"}, {"GARDENING"})
AllRecipes.fish_farm.testfn = function(pt, rot)
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 5, {"structure"})
    if #ents < 1 then
        return true
    end
    return false
end
AquaticRecipe("fish_farm", {shore_distance=7, platform_distance=4, shore_buffer_max= 4.5, shore_buffer_min=3, platform_buffer_min=2})
SortAfter("fish_farm", "seedpouch", "GARDENING")

AddRecipe2("mussel_bed", {Ingredient("mussel", 1), Ingredient("coral", 1)}, TECH.SCIENCE_ONE, nil, {"GARDENING"})
SortAfter("mussel_bed", "compostwrap", "GARDENING")

if IA_CONFIG.oldwarly then
    AllRecipes["portablecookpot_item"].ingredients = {Ingredient("limestonenugget", 3), Ingredient("redgem", 1), Ingredient("log", 3)}
    AllRecipes["portableblender_item"].builder_tag = "invalid"
    AllRecipes["portablespicer_item"].builder_tag = "invalid"
end

AddRecipe2("monkeyball", {Ingredient("snakeskin", 4), Ingredient("cave_banana", 1), Ingredient("rope", 2)}, TECH.SCIENCE_ONE, nil, {"TOOLS"})
SortAfter("monkeyball", "megaflare", "TOOLS")

AddRecipe2("palmleaf_umbrella", {Ingredient("palmleaf", 3), Ingredient("twigs", 4), Ingredient("petals", 6)}, TECH.NONE, nil, {"RAIN","SUMMER","CLOTHING"})
SortAfter("palmleaf_umbrella", "grass_umbrella", "RAIN")
SortAfter("palmleaf_umbrella", "grass_umbrella", "SUMMER")
SortAfter("palmleaf_umbrella", "grass_umbrella", "CLOTHING")

AddRecipe2("antivenom", {Ingredient("venomgland", 1), Ingredient("coral", 2), Ingredient("seaweed", 3)}, TECH.SCIENCE_ONE, nil, {"RESTORATION"})
SortAfter("antivenom", "healingsalve", "RESTORATION")

AddRecipe2("thatchpack", {Ingredient("palmleaf", 4)}, TECH.NONE, nil, {"CONTAINERS","CLOTHING"})
SortBefore("thatchpack", "backpack", "CONTAINERS")
SortBefore("thatchpack", "backpack", "CLOTHING")

if IA_CONFIG.oldwarly then
    AllRecipes["spicepack"].ingredients = {
        Ingredient("fabric", 1),
        Ingredient("rope", 1),
        Ingredient("bluegem", 1)
    }
end

AddRecipe2("seasack", {Ingredient("shark_gills", 1), Ingredient("vine", 2), Ingredient("seaweed", 5)}, TECH.SCIENCE_TWO, nil, {"CONTAINERS","COOKING"})
SortAfter("seasack", "icepack", "CONTAINERS")
SortAfter("seasack", "icepack", "COOKING")

AddRecipe2("palmleaf_hut", {Ingredient("palmleaf", 4), Ingredient("bamboo", 4), Ingredient("rope", 4)}, TECH.SCIENCE_TWO, {placer="palmleaf_hut_placer"}, {"STRUCTURES","RAIN","SUMMER"})
SortAfter("palmleaf_hut", "siestahut", "STRUCTURES")
SortAfter("palmleaf_hut", "sandbagsmall_item", "RAIN")
SortAfter("palmleaf_hut", "siestahut", "SUMMER")

AddRecipe2("tropicalfan", {Ingredient("doydoyfeather", 5), Ingredient("cutreeds", 2), Ingredient("rope", 2)}, TECH.SCIENCE_TWO, nil, {"SUMMER","CLOTHING"})
SortAfter("tropicalfan", "featherfan", "SUMMER")
SortAfter("tropicalfan", "featherfan", "CLOTHING")

AddRecipe2("doydoynest", {Ingredient("doydoyfeather", 2), Ingredient("twigs", 8), Ingredient("poop", 4)}, TECH.SCIENCE_TWO, {placer="doydoynest_placer"}, {"STRUCTURES"})
SortAfter("doydoynest", "rabbithouse", "STRUCTURES")

AddRecipe2("machete", {Ingredient("flint", 3), Ingredient("twigs", 1)}, TECH.NONE, nil, {"TOOLS"})
SortAfter("machete", "axe", "TOOLS")

AddRecipe2("goldenmachete", {Ingredient("goldnugget", 2), Ingredient("twigs", 4)}, TECH.SCIENCE_TWO, nil, {"TOOLS"})
SortAfter("goldenmachete", "goldenaxe", "TOOLS")

AddRecipe2("sea_lab", {Ingredient("limestonenugget", 2), Ingredient("sand", 2), Ingredient("transistor", 2)}, TECH.SCIENCE_ONE, {placer="sea_lab_placer"}, {"PROTOTYPERS","STRUCTURES"})
AquaticRecipe("sea_lab", {shore_distance=7, platform_distance=4, shore_buffer_max= 4.5, shore_buffer_min=3, platform_buffer_max=1.5, platform_buffer_min=0.5})
SortAfter("sea_lab", "researchlab2", "PROTOTYPERS")
SortAfter("sea_lab", "researchlab2", "STRUCTURES")

AddRecipe2("icemaker", {Ingredient("heatrock", 1), Ingredient("bamboo", 5), Ingredient("transistor", 2)}, TECH.SCIENCE_TWO, {placer="icemaker_placer"}, {"COOKING","SUMMER","STRUCTURES"})
SortBefore("icemaker", "icebox", "COOKING")
SortAfter("icemaker", "firesuppressor", "SUMMER")
SortAfter("icemaker", "firesuppressor", "STRUCTURES")

AddRecipe2("piratihatitator", {Ingredient("parrot", 1), Ingredient("boards", 4), Ingredient("piratehat", 1)}, TECH.SCIENCE_ONE, {placer="piratihatitator_placer"}, {"PROTOTYPERS","MAGIC","STRUCTURES"})
SortAfter("piratihatitator", "researchlab4", "PROTOTYPERS")
SortAfter("piratihatitator", "researchlab4", "MAGIC")
SortAfter("piratihatitator", "researchlab4", "STRUCTURES")

AddRecipe2("ox_flute", {Ingredient("ox_horn", 1), Ingredient("nightmarefuel", 2), Ingredient("rope", 1)}, TECH.MAGIC_TWO, nil, {"MAGIC"})
SortAfter("ox_flute", "panflute", "MAGIC")

AddRecipe2("shipwrecked_entrance", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 4), Ingredient("sunken_boat_trinket_4", 1)}, TECH.MAGIC_TWO, {placer="shipwrecked_entrance_placer"}, {"MAGIC","STRUCTURES"})
AllRecipes.shipwrecked_entrance.testfn = function(pt, rot)
    if TheWorld:HasTag("island") or TheWorld:HasTag("volcano") then
        AllRecipes.shipwrecked_entrance.product = "shipwrecked_exit"
    else
        AllRecipes.shipwrecked_entrance.product = "shipwrecked_entrance"
    end
    return true, false
end
SortAfter("shipwrecked_entrance", "telebase", "MAGIC")
SortAfter("shipwrecked_entrance", "telebase", "STRUCTURES")

AddRecipe2("fabric", {Ingredient("bamboo", 3)}, TECH.SCIENCE_ONE, nil, {"REFINE"})
SortAfter("fabric", "beeswax", "REFINE")

AddRecipe2("limestonenugget", {Ingredient("coral", 3)}, TECH.SCIENCE_ONE, nil, {"REFINE"})
SortAfter("limestonenugget", "fabric", "REFINE")

AddRecipe2("nubbin", {Ingredient("corallarve", 1), Ingredient("limestonenugget", 3)}, TECH.SCIENCE_ONE, nil, {"REFINE"})
SortAfter("nubbin", "limestonenugget", "REFINE")

AddRecipe2("goldnugget", {Ingredient("dubloon", 3)}, TECH.SCIENCE_ONE, nil, {"REFINE"})
SortAfter("goldnugget", "nubbin", "REFINE")

AddRecipe2("ice", {Ingredient("hail_ice", 4)}, TECH.SCIENCE_TWO, nil, {"REFINE"})
SortAfter("ice", "goldnugget", "REFINE")

AddRecipe2("ia_messagebottleempty", {Ingredient("sand", 3)}, TECH.SCIENCE_TWO, nil, {"REFINE"})
SortAfter("ia_messagebottleempty", "ice", "REFINE")

AddRecipe2("spear_poison", {Ingredient("venomgland", 1), Ingredient("spear", 1)}, TECH.SCIENCE_ONE, nil, {"WEAPONS"})
SortAfter("spear_poison", "spear", "WEAPONS")

AddRecipe2("armorseashell", {Ingredient("seashell", 10), Ingredient("seaweed", 2), Ingredient("rope", 1)}, TECH.SCIENCE_ONE, nil, {"ARMOUR"})
SortAfter("armorseashell", "armorwood", "ARMOUR")

AddRecipe2("armorlimestone", {Ingredient("limestonenugget", 3), Ingredient("rope", 2)}, TECH.SCIENCE_TWO, nil, {"ARMOUR"})
SortAfter("armorlimestone", "armormarble", "ARMOUR")

AddRecipe2("armorcactus", {Ingredient("needlespear", 3), Ingredient("armorwood", 1)}, TECH.SCIENCE_TWO, nil, {"ARMOUR"})
SortAfter("armorcactus", "armorlimestone", "ARMOUR")

AddRecipe2("oxhat", {Ingredient("ox_horn", 1), Ingredient("seashell", 4), Ingredient("rope", 1)}, TECH.SCIENCE_TWO, nil, {"ARMOUR"})
SortAfter("oxhat", "footballhat", "ARMOUR")

AddRecipe2("blowdart_poison", {Ingredient("cutreeds", 2), Ingredient("venomgland", 1), Ingredient("feather_crow", 1)}, TECH.SCIENCE_ONE, nil, {"WEAPONS"})
SortAfter("blowdart_poison", "blowdart_fire", "WEAPONS")

AddRecipe2("coconade", {Ingredient("coconut", 1), Ingredient("rope", 1), Ingredient("gunpowder", 1)}, TECH.SCIENCE_ONE, nil, {"WEAPONS"})
SortAfter("coconade", "gunpowder", "WEAPONS")

AddRecipe2("spear_launcher", {Ingredient("jellyfish", 1), Ingredient("bamboo", 3)}, TECH.SCIENCE_ONE, nil, {"WEAPONS"})
SortAfter("spear_launcher", "spear_wathgrithr", "WEAPONS")

AddRecipe2("cutlass", {Ingredient("swordfish_dead", 1), Ingredient("goldnugget", 2), Ingredient("twigs", 1)}, TECH.SCIENCE_TWO, nil, {"WEAPONS"})
SortAfter("cutlass", "nightstick", "WEAPONS")

AddRecipe2("brainjellyhat", {Ingredient("coral_brain", 1), Ingredient("jellyfish", 1), Ingredient("rope", 2)}, TECH.SCIENCE_TWO, nil, {"PROTOTYPERS","CLOTHING"})
SortAfter("brainjellyhat", "researchlab3", "PROTOTYPERS")
SortAfter("brainjellyhat", "catcoonhat", "CLOTHING")

AddRecipe2("shark_teethhat", {Ingredient("houndstooth", 5), Ingredient("goldnugget", 1)}, TECH.SCIENCE_ONE, nil, {"CLOTHING"})
SortAfter("shark_teethhat", "brainjellyhat", "CLOTHING")

AddRecipe2("snakeskinhat", {Ingredient("snakeskin", 1), Ingredient("strawhat", 1), Ingredient("boneshard", 1)}, TECH.SCIENCE_TWO, nil, {"CLOTHING","RAIN"})
SortAfter("snakeskinhat", "rainhat", "CLOTHING")
SortAfter("snakeskinhat", "rainhat", "RAIN")

AddRecipe2("armor_snakeskin", {Ingredient("snakeskin", 2), Ingredient("vine", 2), Ingredient("boneshard", 2)}, TECH.SCIENCE_ONE, nil, {"CLOTHING","RAIN","WINTER"})
SortAfter("armor_snakeskin", "raincoat", "CLOTHING")
SortAfter("armor_snakeskin", "raincoat", "RAIN")
SortAfter("armor_snakeskin", "raincoat", "WINTER")

AddRecipe2("blubbersuit", {Ingredient("blubber", 4), Ingredient("fabric", 2), Ingredient("palmleaf", 2)}, TECH.SCIENCE_TWO, nil, {"CLOTHING","RAIN","WINTER"})
SortAfter("blubbersuit", "armor_snakeskin", "CLOTHING")
SortAfter("blubbersuit", "armor_snakeskin", "RAIN")
SortAfter("blubbersuit", "armor_snakeskin", "WINTER")

AddRecipe2("tarsuit", {Ingredient("tar", 4), Ingredient("fabric", 2), Ingredient("palmleaf", 2)}, TECH.SCIENCE_ONE, nil, {"CLOTHING","RAIN"})
SortAfter("tarsuit", "blubbersuit", "CLOTHING")
SortAfter("tarsuit", "blubbersuit", "RAIN")

AddRecipe2("armor_windbreaker", {Ingredient("blubber", 2), Ingredient("fabric", 1), Ingredient("rope", 1)}, TECH.SCIENCE_TWO, nil, {"CLOTHING","RAIN"})
SortAfter("armor_windbreaker", "tarsuit", "CLOTHING")
SortAfter("armor_windbreaker", "tarsuit", "RAIN")

AddRecipe2("gashat", {Ingredient("ia_messagebottleempty", 2), Ingredient("coral", 3), Ingredient("jellyfish", 1)}, TECH.SCIENCE_TWO, nil, {"CLOTHING"})
SortAfter("gashat", "brainjellyhat", "CLOTHING")

AddRecipe2("aerodynamichat", {Ingredient("shark_fin", 1), Ingredient("vine", 2), Ingredient("coconut", 1)}, TECH.SCIENCE_TWO, nil, {"CLOTHING"})
SortAfter("aerodynamichat", "gashat", "CLOTHING")

AddRecipe2("double_umbrellahat", {Ingredient("shark_gills", 2), Ingredient("umbrella", 1), Ingredient("strawhat", 1)}, TECH.SCIENCE_TWO, nil, {"CLOTHING","RAIN","SUMMER"})
SortAfter("double_umbrellahat", "eyebrellahat", "CLOTHING")
SortAfter("double_umbrellahat", "eyebrellahat", "RAIN")
SortAfter("double_umbrellahat", "eyebrellahat", "SUMMER")

AddRecipe2("boat_lograft", {Ingredient("log", 6), Ingredient("cutgrass", 4)}, TECH.NONE, {placer="boat_lograft_placer"}, {"SEAFARING"})
AquaticRecipe("boat_lograft", {distance=4, platform_buffer_min=2, boat = true})

AddRecipe2("boat_raft", {Ingredient("bamboo", 4), Ingredient("vine", 3)}, TECH.NONE, {placer="boat_raft_placer"}, {"SEAFARING"})
AquaticRecipe("boat_raft", {distance=4, platform_buffer_min=2, boat = true})

AddRecipe2("boat_row", {Ingredient("boards", 3), Ingredient("vine", 4)}, TECH.SCIENCE_ONE, {placer="boat_row_placer"}, {"SEAFARING"})
AquaticRecipe("boat_row", {distance=4, platform_buffer_min=2, boat = true})

AddRecipe2("boat_cargo", {Ingredient("boards", 6), Ingredient("rope", 3)}, TECH.SCIENCE_TWO, {placer="boat_cargo_placer"}, {"SEAFARING"})
AquaticRecipe("boat_cargo", {distance=4, platform_buffer_min=2, boat = true})

AddRecipe2("boat_armoured", {Ingredient("boards", 6), Ingredient("rope", 3), Ingredient("seashell", 10)}, TECH.SCIENCE_TWO, {placer="boat_armoured_placer"}, {"SEAFARING"})
AquaticRecipe("boat_armoured", {distance=4, platform_buffer_min=2, boat = true})

AddRecipe2("boat_encrusted", {Ingredient("boards", 6), Ingredient("rope", 3), Ingredient("limestonenugget", 4)}, TECH.SCIENCE_TWO, {placer="boat_encrusted_placer"}, {"SEAFARING"})
AquaticRecipe("boat_encrusted", {distance=4, platform_buffer_min=2, boat = true})

AddRecipe2("boatrepairkit", {Ingredient("boards", 2), Ingredient("stinger", 2), Ingredient("rope", 2)}, TECH.SCIENCE_ONE, nil, {"SEAFARING"})

AddRecipe2("tarlamp", {Ingredient("tar", 1), Ingredient("seashell", 1)}, TECH.NONE, nil, {"LIGHT","SEAFARING"})
SortBefore("tarlamp", "lantern", "LIGHT")

AddRecipe2("boat_torch", {Ingredient("twigs", 2), Ingredient("torch", 1)}, TECH.SCIENCE_ONE, nil, {"LIGHT","SEAFARING"})
SortAfter("boat_torch", "bottlelantern", "LIGHT")

AddRecipe2("boat_lantern", {Ingredient("ia_messagebottleempty", 1), Ingredient("twigs", 2), Ingredient("fireflies", 1)}, TECH.SCIENCE_ONE, nil, {"LIGHT","SEAFARING"})
SortAfter("boat_lantern", "boat_torch", "LIGHT")

AddRecipe2("sail_palmleaf", {Ingredient("bamboo", 2), Ingredient("vine", 2), Ingredient("palmleaf", 4)}, TECH.SCIENCE_ONE, nil, {"SEAFARING"})

AddRecipe2("sail_cloth", {Ingredient("bamboo", 2), Ingredient("rope", 2), Ingredient("fabric", 2)}, TECH.SCIENCE_TWO, nil, {"SEAFARING"})

AddRecipe2("sail_snakeskin", {Ingredient("log", 4), Ingredient("rope", 2), Ingredient("snakeskin", 2)}, TECH.SCIENCE_TWO, nil, {"SEAFARING"})

AddRecipe2("sail_feather", {Ingredient("bamboo", 4), Ingredient("rope", 2), Ingredient("doydoyfeather", 4)}, TECH.SCIENCE_ONE, nil, {"SEAFARING"})

AddRecipe2("ironwind", {Ingredient("turbine_blades", 1), Ingredient("transistor", 1), Ingredient("goldnugget", 2)},  TECH.SCIENCE_TWO, nil, {"SEAFARING"})

AddRecipe2("boatcannon", {Ingredient("coconut", 6), Ingredient("log", 5), Ingredient("gunpowder", 4)},  TECH.SCIENCE_ONE, nil, {"SEAFARING"})

AddRecipe2("seatrap", {Ingredient("palmleaf", 4), Ingredient("ia_messagebottleempty", 3), Ingredient("jellyfish", 1)},  TECH.SCIENCE_ONE, nil, {"SEAFARING","TOOLS","GARDENING"})
SortAfter("seatrap", "birdtrap", "TOOLS")
SortAfter("seatrap", "birdtrap", "GARDENING")

AddRecipe2("trawlnet", {Ingredient("bamboo", 2), Ingredient("rope", 3)}, TECH.SCIENCE_ONE, nil, {"SEAFARING", "TOOLS", "FISHING"})
SortAfter("trawlnet", "oceanfishingrod", "TOOLS")
SortAfter("trawlnet", "oceanfishingrod", "FISHING")

AddRecipe2("telescope", {Ingredient("ia_messagebottleempty", 1), Ingredient("pigskin", 1), Ingredient("goldnugget", 1)}, TECH.SCIENCE_ONE, nil, {"SEAFARING","TOOLS"})
SortAfter("telescope", "compass", "TOOLS")

AddRecipe2("supertelescope", {Ingredient("telescope", 1), Ingredient("tigereye", 1), Ingredient("goldnugget", 1)}, TECH.SCIENCE_TWO, nil, {"SEAFARING","TOOLS"})
SortAfter("supertelescope", "telescope", "TOOLS")

AddRecipe2("captainhat", {Ingredient("seaweed", 1), Ingredient("boneshard", 1), Ingredient("strawhat", 1)}, TECH.SCIENCE_ONE, nil, {"SEAFARING","CLOTHING"})
SortAfter("captainhat", "shark_teethhat", "CLOTHING")

AddRecipe2("piratehat", {Ingredient("boneshard", 2), Ingredient("silk", 2), Ingredient("rope", 1)}, TECH.SCIENCE_ONE, nil, {"SEAFARING","CLOTHING"})
SortAfter("piratehat", "captainhat", "CLOTHING")

AddRecipe2("armor_lifejacket", {Ingredient("fabric", 2), Ingredient("vine", 2), Ingredient("ia_messagebottleempty", 3)}, TECH.SCIENCE_ONE, nil, {"SEAFARING","CLOTHING"})
SortAfter("armor_lifejacket", "armor_windbreaker", "CLOTHING")

AddRecipe2("buoy", {Ingredient("ia_messagebottleempty", 1), Ingredient("bioluminescence", 2), Ingredient("bamboo", 4)}, TECH.SCIENCE_ONE, {placer="buoy_placer"}, {"LIGHT","SEAFARING","STRUCTURES"})
AquaticRecipe("buoy", {shore_distance=7, platform_distance=4, shore_buffer_max= 4.5, shore_buffer_min=3, platform_buffer_max=1.5, platform_buffer_min=0.5})
SortBefore("buoy", "nightlight", "STRUCTURES")
SortAfter("buoy", "sea_chiminea", "LIGHT")

AddRecipe2("quackendrill", {Ingredient("quackenbeak", 1), Ingredient("gears", 1), Ingredient("transistor", 2)}, TECH.SCIENCE_TWO, nil, {"TOOLS","SEAFARING"})
SortAfter("quackendrill", "beef_bell", "TOOLS")

AddRecipe2("quackeringram", {Ingredient("quackenbeak", 1), Ingredient("rope", 4), Ingredient("bamboo", 4)}, TECH.SCIENCE_TWO, nil, {"SEAFARING"})

AddRecipe2("tar_extractor", {Ingredient("coconut", 2), Ingredient("limestonenugget", 4), Ingredient("bamboo", 4)}, TECH.SCIENCE_TWO, {placer="tar_extractor_placer"}, {"SEAFARING","STRUCTURES"})
AquaticRecipe("tar_extractor", {shore_distance=7, platform_distance=4, shore_buffer_max= 4.5, shore_buffer_min=3, platform_buffer_max=1.5, platform_buffer_min=0.5})
SortAfter("tar_extractor", "icemaker", "STRUCTURES")
AllRecipes.tar_extractor.testfn = function(pt, rot)
    local range = .1
    local tarpits = TheSim:FindEntities(pt.x, pt.y, pt.z, range, {"tarpit"})

    if #tarpits > 0 then
        for k, v in pairs(tarpits) do
            if not v:HasTag("NOCLICK") then
                return true, false
            end
        end
    end

    -- Fix an extremely inconvenient bug with left-clicking to build a recipe (does not apply to action buttons) -M
    range = 1
    tarpits = TheSim:FindEntities(pt.x, pt.y, pt.z, range, {"tarpit"})

    if #tarpits > 0 then
        for k, v in pairs(tarpits) do
            if not v:HasTag("NOCLICK") then
                local newpt = v:GetPosition()
                -- Realign (editing the actual pt via the table pointer)
                pt.x = newpt.x
                pt.y = newpt.y
                pt.z = newpt.z
                return true, false
            end
        end
    end

    return false, false
end

AddRecipe2("sea_yard", {Ingredient("tar", 6), Ingredient("limestonenugget", 6), Ingredient("log", 4)}, TECH.SCIENCE_TWO, {placer="sea_yard_placer", min_spacing=4}, {"SEAFARING","STRUCTURES"})
AquaticRecipe("sea_yard", {shore_distance=7, platform_distance=4, shore_buffer_max= 4.5, shore_buffer_min=3, platform_buffer_max=1.5, platform_buffer_min=0.5})
SortAfter("sea_yard", "tar_extractor", "STRUCTURES")

-- TURFS

AddRecipe2("turf_jungle", {Ingredient("jungletreeseed", 1), Ingredient("vine", 1)}, TECH.TURFCRAFTING_TWO, {numtogive=4}, {"DECOR"})
SortAfter("turf_jungle", "turf_monkey_ground", "DECOR")

AddRecipe2("turf_meadow", {Ingredient("cutgrass", 1), Ingredient("petals", 1)}, TECH.TURFCRAFTING_TWO, {numtogive=4}, {"DECOR"})
SortAfter("turf_meadow", "turf_jungle", "DECOR")

AddRecipe2("turf_tidalmarsh", {Ingredient("cutreeds", 1), Ingredient("spoiled_food", 2)}, TECH.MASHTURFCRAFTING_TWO, {numtogive=4}, {"DECOR"})
SortAfter("turf_tidalmarsh", "turf_meadow", "DECOR")

AddRecipe2("turf_magmafield", {Ingredient("rocks", 1), Ingredient("nitre", 1)}, TECH.TURFCRAFTING_TWO, {numtogive=4}, {"DECOR"})
SortAfter("turf_magmafield", "turf_tidalmarsh", "DECOR")

AddRecipe2("turf_ash", {Ingredient("ash", 1), Ingredient("charcoal", 1)}, TECH.TURFCRAFTING_TWO, {numtogive=4}, {"DECOR"})
SortAfter("turf_ash", "turf_magmafield", "DECOR")

AddRecipe2("turf_volcano", {Ingredient("rocks", 1), Ingredient("charcoal", 1)}, TECH.TURFCRAFTING_TWO, {numtogive=4}, {"DECOR"})
SortAfter("turf_volcano", "turf_ash", "DECOR")

-- UNCRAFTABLE:
-- NOTE: These recipes are not supposed to be craftable! This is just so the deconstruction staff works as expected.

AddDeconstructRecipe("wildborehead", {Ingredient("pigskin", 2), Ingredient("bamboo", 2)})
AddDeconstructRecipe("ia_trident", {Ingredient("goldnugget", 12), Ingredient("needlespear", 3)})
AddDeconstructRecipe("snakeoil", {})
AddDeconstructRecipe("peg_leg", {Ingredient("log", 1)})
AddDeconstructRecipe("turbine_blades", {Ingredient("trinket_17", 3)}) -- trinket_17 - Bent Spork
AddDeconstructRecipe("magic_seal", {Ingredient("purplegem", 2), Ingredient("nightmarefuel", 4), Ingredient("meat", 1)})
AddDeconstructRecipe("harpoon", {Ingredient("rope", 1), Ingredient("twigs", 2), Ingredient("houndstooth", 3)})
AddDeconstructRecipe("barrel_gunpowder", {Ingredient("boards", 3), Ingredient("gunpowder", 2)})
AddDeconstructRecipe("barrel_gunpowder_land", {Ingredient("boards", 3), Ingredient("gunpowder", 2)})
AddDeconstructRecipe("krakenchest", {Ingredient("boards", 4), Ingredient("tentaclespots", 3), Ingredient("boneshard", 1)})
AddDeconstructRecipe("luggagechest", {Ingredient("boards", 2), Ingredient("fabric", 1)})
AddDeconstructRecipe("boat_surfboard", {Ingredient("boards", 1), Ingredient("seashell", 2)})
AddDeconstructRecipe("piratepack", {Ingredient("boards", 2), Ingredient("dubloon", 20)})
AddDeconstructRecipe("pandoraschest_tropical", {Ingredient("boards", 3)})
AddDeconstructRecipe("shipwrecked_exit", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 4), Ingredient("sunken_boat_trinket_4", 1)})
AddDeconstructRecipe("trawlnetdropped", {Ingredient("bamboo", 2), Ingredient("rope", 3)})

-- OBSIDIAN WORKBENCH

AddRecipe2("obsidianaxe", {Ingredient("axe", 1), Ingredient("obsidian", 2), Ingredient("dragoonheart", 1)}, TECH.OBSIDIAN_TWO, {nounlock=true}, {"CRAFTING_STATION"})
SortAfter("obsidianaxe", "blueprint_craftingset_ruinsglow_builder", "CRAFTING_STATION")

AddRecipe2("obsidianmachete", {Ingredient("machete", 1), Ingredient("obsidian", 3), Ingredient("dragoonheart", 1)}, TECH.OBSIDIAN_TWO, {nounlock=true}, {"CRAFTING_STATION"})
SortAfter("obsidianmachete", "obsidianaxe", "CRAFTING_STATION")

AddRecipe2("spear_obsidian", {Ingredient("spear", 1), Ingredient("obsidian", 3), Ingredient("dragoonheart", 1)}, TECH.OBSIDIAN_TWO, {nounlock=true}, {"CRAFTING_STATION"})
SortAfter("spear_obsidian", "obsidianmachete", "CRAFTING_STATION")

AddRecipe2("volcanostaff", {Ingredient("firestaff", 1), Ingredient("obsidian", 4), Ingredient("dragoonheart", 1)}, TECH.OBSIDIAN_TWO, {nounlock=true}, {"CRAFTING_STATION"})
SortAfter("volcanostaff", "spear_obsidian", "CRAFTING_STATION")

AddRecipe2("armorobsidian", {Ingredient("armorwood", 1), Ingredient("obsidian", 5), Ingredient("dragoonheart", 1)}, TECH.OBSIDIAN_TWO, {nounlock=true}, {"CRAFTING_STATION"})
SortAfter("armorobsidian", "volcanostaff", "CRAFTING_STATION")

AddRecipe2("obsidiancoconade", {Ingredient("coconade", 3), Ingredient("obsidian", 3), Ingredient("dragoonheart", 1)}, TECH.OBSIDIAN_TWO, {nounlock=true, numtogive=3}, {"CRAFTING_STATION"})
SortAfter("obsidiancoconade", "armorobsidian", "CRAFTING_STATION")

AddRecipe2("wind_conch", {Ingredient("obsidian", 4), Ingredient("purplegem", 1), Ingredient("magic_seal", 1)}, TECH.OBSIDIAN_TWO, {nounlock=true}, {"CRAFTING_STATION"})
SortAfter("wind_conch", "obsidiancoconade", "CRAFTING_STATION")

AddRecipe2("windstaff", {Ingredient("obsidian", 2), Ingredient("nightmarefuel", 3), Ingredient("magic_seal", 1)}, TECH.OBSIDIAN_TWO, {nounlock=true}, {"CRAFTING_STATION"})
SortAfter("windstaff", "wind_conch", "CRAFTING_STATION")

AddRecipe2("turf_ruinsbrick_glow_blueprint", {Ingredient("papyrus", 1)}, TECH.OBSIDIAN_TWO, {nounlock=true, image="blueprint_rare.tex"}, {"CRAFTING_STATION"})
SortAfter("turf_ruinsbrick_glow_blueprint", "windstaff", "CRAFTING_STATION")

-- SCULPTING

AddRecipe2("chesspiece_kraken_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)}, TECH.LOST, {nounlock = true, actionstr="SCULPTING", image="chesspiece_kraken.tex"})
SortAfter("chesspiece_kraken_builder", "chesspiece_klaus_builder", "CRAFTING_STATION")

AddRecipe2("chesspiece_tigershark_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)}, TECH.LOST, {nounlock = true, actionstr="SCULPTING", image="chesspiece_tigershark.tex"})
SortAfter("chesspiece_tigershark_builder", "chesspiece_kraken_builder", "CRAFTING_STATION")

AddRecipe2("chesspiece_twister_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)}, TECH.LOST, {nounlock = true, actionstr="SCULPTING", image="chesspiece_twister.tex"})
SortAfter("chesspiece_twister_builder", "chesspiece_tigershark_builder", "CRAFTING_STATION")

AddRecipe2("chesspiece_seal_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)}, TECH.LOST, {nounlock = true, actionstr="SCULPTING", image="chesspiece_seal.tex"})
SortAfter("chesspiece_seal_builder", "chesspiece_twister_builder", "CRAFTING_STATION")

-- CRITTERS

AddRecipePostInit("critter_kitten_builder", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("coontail")
    if ingredient then
        ingredient:AddDictionaryPrefab("tunacan")
    end
end)

AddRecipePostInit("critter_lamb_builder", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("steelwool")
    if ingredient then
        ingredient:AddDictionaryPrefab("needlespear")
    end
    local ingredient = recipe:FindAndConvertIngredient("guacamole")
    if ingredient then
        ingredient:AddDictionaryPrefab("mysterymeat")
    end
end)

AddRecipePostInit("critter_perdling_builder", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("trailmix")
    if ingredient then
        ingredient:AddDictionaryPrefab("caviar")
    end
end)

AddRecipePostInit("critter_dragonling_builder", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("lavae_cocoon")
    if ingredient then
        ingredient:AddDictionaryPrefab("dragoonheart")
    end
end)

AddRecipePostInit("critter_glomling_builder", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("glommerfuel")
    if ingredient then
        ingredient:AddDictionaryPrefab("blubber")
    end
end)

AddRecipePostInit("critter_lunarmothling_builder", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("flowersalad")
    if ingredient then
        ingredient:AddDictionaryPrefab("tropicalbouillabaisse")
    end
end)

-- WALANI

AddCharacterRecipe("surfboard_item", {Ingredient("boards", 1), Ingredient("seashell", 2)}, TECH.NONE, {builder_tag = "surfer"}, {"SEAFARING"})
SortAfter("surfboard_item", "wx78_scanner_item", "CHARACTER")
SortBefore("surfboard_item", "boat_lograft", "SEAFARING")

-- WOODLEGS

AddCharacterRecipe("woodlegshat", {Ingredient("fabric", 3), Ingredient("boneshard", 4), Ingredient("dubloon", 10)}, TECH.NONE, {builder_tag = "piratecaptain"}, {"SEAFARING", "CLOTHING"})
SortAfter("woodlegshat", "piratehat", "SEAFARING")
SortAfter("woodlegshat", "mermhat", "CLOTHING")
SortAfter("woodlegshat", "surfboard_item", "CHARACTER")

AddCharacterRecipe("boat_woodlegs", {Ingredient("boatcannon", 1), Ingredient("boards", 4), Ingredient("dubloon", 4)}, TECH.NONE, {builder_tag = "piratecaptain", placer = "boat_woodlegs_placer"}, {"SEAFARING"})
AquaticRecipe("boat_woodlegs", {distance = 4, platform_buffer_min = 2, boat = true})
SortAfter("boat_woodlegs", "boat_encrusted", "SEAFARING")
SortAfter("boat_woodlegs", "woodlegshat", "CHARACTER")

-- WILSON TRANSMUTATION

AddCharacterRecipe("transmute_bamboo", {Ingredient("vine", 2)}, TECH.NONE, {product="bamboo", image="bamboo.tex", builder_tag="alchemist", description="transmute_bamboo"})
SortAfter("transmute_bamboo", "transmute_twigs", "CHARACTER")

AddCharacterRecipe("transmute_vine", {Ingredient("bamboo", 2)}, TECH.NONE, {product="vine", image="vine.tex", builder_tag="alchemist", description="transmute_vine"})
SortAfter("transmute_vine", "transmute_bamboo", "CHARACTER")

AddCharacterRecipe("transmute_dubloons", {Ingredient("goldnugget", 2)}, TECH.NONE, {product="dubloon", image="dubloon.tex", builder_tag="ore_alchemistII", description="transmute_dubloons", numtogive = 3})
SortBefore("transmute_dubloons", "transmute_goldnugget", "CHARACTER")

AddCharacterRecipe("transmute_sand", {Ingredient("limestonenugget", 1)}, TECH.NONE, {product="sand", image="sand.tex", builder_tag="ore_alchemistIII", description="transmute_sand", numtogive = 4})
SortAfter("transmute_sand", "transmute_moonrocknugget", "CHARACTER")

AddCharacterRecipe("transmute_limestone", {Ingredient("sand", 5)}, TECH.NONE, {product="limestonenugget", image="limestonenugget.tex", builder_tag="ore_alchemistIII", description="transmute_limestone"})
SortAfter("transmute_limestone", "transmute_sand", "CHARACTER")

AddCharacterRecipe("transmute_obsidian", {Ingredient("dragoonheart", 1)}, TECH.NONE, {product="obsidian", image="obsidian.tex", builder_tag="gem_alchemistIII", description="transmute_obsidian", numtogive = 2})
SortAfter("transmute_obsidian", "transmute_opalpreciousgem", "CHARACTER")

AddCharacterRecipe("transmute_dragoonheart", {Ingredient("obsidian", 3)}, TECH.NONE, {product="dragoonheart", image="dragoonheart.tex", builder_tag="gem_alchemistIII", description="transmute_dragoonheart"})
SortAfter("transmute_dragoonheart", "transmute_obsidian", "CHARACTER")

AddCharacterRecipe("transmute_jelly", {Ingredient("rainbowjellyfish_dead", 1)}, TECH.NONE, {product="jellyfish_dead", image="jellyfish_dead.tex", builder_tag="ick_alchemistI", description="transmute_jelly", numtogive = 2})
SortAfter("transmute_jelly", "transmute_smallmeat", "CHARACTER")

AddCharacterRecipe("transmute_rainbowjelly", {Ingredient("jellyfish_dead", 3)}, TECH.NONE, {product="rainbowjellyfish_dead", image="rainbowjellyfish_dead.tex", builder_tag="ick_alchemistI", description="transmute_rainbowjelly"})
SortAfter("transmute_rainbowjelly", "transmute_jelly", "CHARACTER")

-- WICKERBOTTOM

AddCharacterRecipe("book_meteor", {Ingredient("papyrus", 2), Ingredient("obsidian", 2)}, TECH.SCIENCE_THREE, {builder_tag="bookbuilder"})
SortAfter("book_meteor", "book_sleep", "CHARACTER")

AddRecipePostInit("book_light", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("lightbulb")
    if ingredient then
        ingredient:AddDictionaryPrefab("rainbowjellyfish_dead")
    end
end)

AddRecipePostInit("book_fish", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("oceanfishingbobber_ball")
    if ingredient then
        ingredient:AddDictionaryPrefab("roe")
    end
end)

AddRecipePostInit("book_rain", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("goose_feather")
    if ingredient then
        ingredient:AddDictionaryPrefab("doydoyfeather")
    end
end)

AddRecipePostInit("book_moon", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("opalpreciousgem")
    if ingredient then
        ingredient:AddDictionaryPrefab("magic_seal")
    end
end)

-- WILLOW

AddRecipePostInit("bernie_inactive", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("beefalowool")
    if ingredient then
        ingredient:AddDictionaryPrefab("fabric")
    end
end)

-- WOLFGANG

AddRecipePostInit("dumbbell_marble", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("marble")
    if ingredient then
        ingredient:AddDictionaryPrefab("limestonenugget")
    end
end)

AddRecipePostInit("dumbbell_gem", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("thulecite")
    if ingredient then
        ingredient:AddDictionaryPrefab("obsidian")
    end
end)

AddRecipePostInit("dumbbell_redgem", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("thulecite")
    if ingredient then
        ingredient:AddDictionaryPrefab("obsidian")
    end
end)

AddRecipePostInit("dumbbell_bluegem", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("thulecite")
    if ingredient then
        ingredient:AddDictionaryPrefab("obsidian")
    end
end)

-- WOODIE

AddRecipePostInit("woodcarvedhat", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("pinecone")
    if ingredient then
        ingredient:AddDictionaryPrefab("jungletreeseed")
    end
end)

-- WX-78

AddRecipePostInit("wx78module_light", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("lightbulb")
    if ingredient then
        ingredient:AddDictionaryPrefab("rainbowjellyfish_dead")
    end
end)

AddRecipePostInit("wx78module_nightvision", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("mole")
    if ingredient then
        ingredient:AddDictionaryPrefab("blowdart_flup")
    end
end)

AddRecipePostInit("wx78module_movespeed", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("rabbit")
    if ingredient then
        ingredient:AddDictionaryPrefab("crab")
    end
end)

AddRecipePostInit("wx78module_maxhunger", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("slurper_pelt")
    if ingredient then
        ingredient:AddDictionaryPrefab("doydoyfeather")
    end
end)

AddRecipePostInit("wx78module_music", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("singingshell_octave3")
    if ingredient then
        ingredient:AddDictionaryPrefab("seashell")
    end
end)

AddRecipePostInit("wx78module_taser", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("goatmilk")
    if ingredient then
        ingredient:AddDictionaryPrefab("jellyfish_dead")
    end
end)

-- WIGFRID

AddRecipePostInit("battlesong_sanitygain", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("moonbutterflywings")
    if ingredient then
        ingredient:AddDictionaryPrefab("coral_brain")
    end
end)

AddRecipePostInit("battlesong_sanityaura", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("nightmare_timepiece")
    if ingredient then
        ingredient:AddDictionaryPrefab("doydoybaby")
    end
end)

AddRecipePostInit("battlesong_fireresistance", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("oceanfish_small_9_inv")
    if ingredient then
        ingredient:AddDictionaryPrefab("pondneon_quattro")
    end
end)

-- WEBBER

AddCharacterRecipe("mutator_tropical_spider_warrior", { Ingredient("monstermeat", 2), Ingredient("silk", 1), Ingredient("venomgland", 1)}, TECH.SPIDERCRAFT_ONE, {builder_tag="spiderwhisperer"})
SortAfter("mutator_tropical_spider_warrior", "mutator_warrior", "CHARACTER")

-- WORMWOOD

AddCharacterRecipe("poisonbalm", {Ingredient("livinglog", 1), Ingredient("venomgland", 1)}, TECH.NONE, {builder_tag="plantkin"}, {"RESTORATION"})
SortAfter("poisonbalm", "antivenom", "RESTORATION")
SortAfter("poisonbalm", "livinglog", "CHARACTER")

AddRecipePostInit("wormwood_lightflier", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("lightbulb")
    if ingredient then
        ingredient:AddDictionaryPrefab("bioluminescence")
    end
end)

-- WURT

local fish = IA_CONFIG.pondfishable and "pondfish_tropical" or "fish_tropical"
AddCharacterRecipe("mermhouse_fisher_crafted", {Ingredient(fish, 2), Ingredient("cutreeds", 3), Ingredient("fishingrod", 2), Ingredient("boards", 4)}, TECH.SCIENCE_ONE, {placer = "mermhouse_fisher_crafted_placer", product = "mermhouse_fisher_crafted", builder_tag="merm_builder"}, {"STRUCTURES"})
SortAfter("mermhouse_fisher_crafted", "mermwatchtower", "CHARACTER")
SortAfter("mermhouse_fisher_crafted", "mermwatchtower", "STRUCTURES")

AddCharacterRecipe("wurt_turf_tidalmarsh", {Ingredient("cutreeds", 1), Ingredient("spoiled_food", 2)},  TECH.NONE, {builder_tag="merm_builder", product="turf_tidalmarsh", numtogive = 4})
SortAfter("wurt_turf_tidalmarsh", "wurt_turf_marsh", "CHARACTER")

AddRecipePostInit("mermhouse_crafted", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("pondfish")
    if ingredient then
        ingredient:AddDictionaryPrefab(fish)
    end
end)

AddRecipePostInit("mermhat", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("pondfish")
    if ingredient then
        ingredient:AddDictionaryPrefab(fish)
    end
end)

AllRecipes["mermthrone"].ingredients = {
    Ingredient("cutreeds", 20),
    Ingredient("pigskin", 10),
    Ingredient("silk", 15)
}

CONSTRUCTION_PLANS["mermthrone_construction"] = {
    Ingredient("cutreeds", 20),
    Ingredient("pigskin", 10),
    Ingredient("silk", 15)
}

AllRecipes["mermhouse_crafted"].testfn = IsSWMarshLand
AllRecipes["mermthrone_construction"].testfn = IsSWMarshLand
AllRecipes["mermwatchtower"].testfn = IsSWMarshLand
AllRecipes["mermhouse_fisher_crafted"].testfn = IsSWMarshLand

-- WALTER

AddRecipePostInit("slingshotammo_marble", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("marble")
    if ingredient then
        ingredient:AddDictionaryPrefab("limestonenugget")
    end
end)

-- Placeholder for Obsidian Ammo
AddCharacterRecipe("slingshotammo_obsidian", {Ingredient("obsidian", 1), Ingredient("nightmarefuel", 1)}, TECH.OBSIDIAN_TWO, {builder_tag="pebblemaker", product="slingshotammo_thulecite", numtogive = 10, no_deconstruction=true, nounlock=true})
SortAfter("slingshotammo_obsidian", "slingshotammo_thulecite", "CHARACTER")

AddRecipePostInit("slingshot", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("mosquitosack")
    if ingredient then
        ingredient:AddDictionaryPrefab("mosquitosack_yellow")
    end
end)

-- WANDA

AddRecipePostInit("pocketwatch_parts", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("thulecite_pieces")
    if ingredient then
        ingredient:AddDictionaryPrefab("dubloon")
    end
end)

AddRecipePostInit("pocketwatch_heal", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("marble")
    if ingredient then
        ingredient:AddDictionaryPrefab("limestonenugget")
    end
end)

AddRecipePostInit("pocketwatch_recall", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("walrus_tusk")
    if ingredient then
        ingredient:AddDictionaryPrefab("ox_horn")
    end
end)

AddRecipePostInit("pocketwatch_weapon", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("marble")
    if ingredient then
        ingredient:AddDictionaryPrefab("limestonenugget")
    end
end)

-- Year of the Bunnyman

AddRecipePostInit("handpillow_kelp", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("kelp")
    if ingredient then
        ingredient:AddDictionaryPrefab("seaweed")
    end
end)

AddRecipePostInit("handpillow_beefalowool", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("beefalowool")
    if ingredient then
        ingredient:AddDictionaryPrefab("fabric")
    end
end)

AddRecipePostInit("handpillow_steelwool", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("steelwool")
    if ingredient then
        ingredient:AddDictionaryPrefab("needlespear")
    end
end)

AddRecipePostInit("bodypillow_kelp", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("kelp")
    if ingredient then
        ingredient:AddDictionaryPrefab("seaweed")
    end
end)

AddRecipePostInit("bodypillow_beefalowool", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("beefalowool")
    if ingredient then
        ingredient:AddDictionaryPrefab("fabric")
    end
end)

AddRecipePostInit("bodypillow_steelwool", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("steelwool")
    if ingredient then
        ingredient:AddDictionaryPrefab("needlespear")
    end
end)

-- WINTER'S FEAST

AddRecipePostInit("wintercooking_berrysauce", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("mosquitosack")
    if ingredient then
        ingredient:AddDictionaryPrefab("mosquitosack_yellow")
    end
end)

AddRecipePostInit("wintercooking_bibingka", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("foliage")
    if ingredient then
        ingredient:AddDictionaryPrefab("jungletreeseed")
    end
end)

AddRecipePostInit("wintercooking_lutefisk", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("driftwood_log")
    if ingredient then
        ingredient:AddDictionaryPrefab("palmleaf")
    end
end)

AddRecipePostInit("wintercooking_pavlova", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("moon_tree_blossom")
    if ingredient then
        ingredient:AddDictionaryPrefab("hail_ice")
    end
end)

AddRecipePostInit("wintercooking_pumpkinpie", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("phlegm")
    if ingredient then
        ingredient:AddDictionaryPrefab("venomgland")
    end
end)

AddRecipePostInit("wintercooking_tourtiere", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("acorn")
    if ingredient then
        ingredient:AddDictionaryPrefab("coconut")
    end
    local ingredient = recipe:FindAndConvertIngredient("pinecone")
    if ingredient then
        ingredient:AddDictionaryPrefab("jungletreeseed")
    end
end)

AddRecipePostInit("wintersfeastoven", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("marble")
    if ingredient then
        ingredient:AddDictionaryPrefab("limestonenugget")
    end
end)

AddRecipePostInit("table_winters_feast", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("beefalowool")
    if ingredient then
        ingredient:AddDictionaryPrefab("fabric")
    end
end)

-- HALLOWED NIGHTS

AddRecipePostInit("halloween_experiment_bravery", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("froglegs")
    if ingredient then
        ingredient:AddDictionaryPrefab("snakeskin")
    end
end)

AddRecipePostInit("halloween_experiment_health", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("mosquito")
    if ingredient then
        ingredient:AddDictionaryPrefab("mosquito_yellow")
    end
end)

AddRecipePostInit("halloween_experiment_sanity", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("crow")
    if ingredient then
        ingredient:AddDictionaryPrefab("toucan")
    end
end)

AddRecipePostInit("halloween_experiment_root", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("batwing")
    if ingredient then
        ingredient:AddDictionaryPrefab("needlespear")
    end
end)

-- Rest of Alt Recipes

AddRecipePostInit("soil_amender", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("kelp")
    if ingredient then
        ingredient:AddDictionaryPrefab("seaweed")
    end
    local ingredient = recipe:FindAndConvertIngredient("messagebottleempty")
    if ingredient then
        ingredient:AddDictionaryPrefab("ia_messagebottleempty")
    end
end)

AddRecipePostInit("cookbook", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("carrot")
    if ingredient then
        ingredient:AddDictionaryPrefab("sweet_potato")
    end
end)

AddRecipePostInit("megaflare", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("glommerfuel")
    if ingredient then
        ingredient:AddDictionaryPrefab("blubber")
    end

    recipe.imagefn = function()
        if IsInIAClimate(TheWorld) then
            recipe.atlas = "images/ia_inventoryimages.xml"
            return "megaflare_tropical.tex"
        end

        recipe.atlas = nil
        return "megaflare.tex"
    end
end)

AddRecipePostInit("waterballoon", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("mosquitosack")
    if ingredient then
        ingredient:AddDictionaryPrefab("mosquitosack_yellow")
    end
end)

AddRecipePostInit("kelphat", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("kelp")
    if ingredient then
        ingredient:AddDictionaryPrefab("seaweed")
    end
end)

AddRecipePostInit("hawaiianshirt", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("cactus_flower")
    if ingredient then
        ingredient:AddDictionaryPrefab("petals")
    end
end)

AddRecipePostInit("polly_rogershat", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("monkey_mediumhat")
    if ingredient then
        ingredient:AddDictionaryPrefab("piratehat")
    end
end)

AddRecipePostInit("boat_bumper_kelp_kit", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("kelp")
    if ingredient then
        ingredient:AddDictionaryPrefab("seaweed")
    end
end)

AddRecipePostInit("trident", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("kelp")
    if ingredient then
        ingredient:AddDictionaryPrefab("seaweed")
    end
end)

AddRecipePostInit("turf_carpetfloor", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("beefalowool")
    if ingredient then
        ingredient:AddDictionaryPrefab("fabric")
    end
end)

AddRecipePostInit("turf_carpetfloor2", function(recipe)
    local ingredient = recipe:FindAndConvertIngredient("beefalowool")
    if ingredient then
        ingredient:AddDictionaryPrefab("fabric")
    end
end)

local global_gemdict_ingredients = {
    wobster_sheller_land = "lobster",
}

AddRecipePostInitAny(function(recipe)
    for target_ingredient, gemdict_ingredient in pairs(global_gemdict_ingredients) do
        -- Sometimes mods break gemdict for there recipes so lets double check
        local ingredient = recipe.FindAndConvertIngredient ~= nil and recipe:FindAndConvertIngredient(target_ingredient) or nil
        if ingredient and ingredient.AddDictionaryPrefab ~= nil then
            if type(gemdict_ingredient) == "table" then
                for i, v in ipairs(gemdict_ingredient) do
                    ingredient:AddDictionaryPrefab(v)
                end
            else
                ingredient:AddDictionaryPrefab(gemdict_ingredient)
            end
        end
    end
end)

BoatModeRecipe("boat_item", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("boat_grass_item", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("boatpatch", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("oar", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("oar_driftwood", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("anchor_item", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("steeringwheel_item", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("boat_rotator_kit", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("mast_item", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("mast_malbatross_item", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("boat_bumper_kelp_kit", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("boat_bumper_shell_kit", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("mastupgrade_lamp_item", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("mastupgrade_lightningrod_item", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("winch", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("waterpump", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("boat_magnet_kit", RECIPE_BOAT_TYPE.DST)
BoatModeRecipe("boat_magnet_beacon", RECIPE_BOAT_TYPE.DST)

BoatModeRecipe("boat_lograft", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("boat_raft", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("boat_row", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("boat_cargo", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("boat_armoured", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("boat_encrusted", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("boat_woodlegs", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("surfboard_item", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("boat_torch", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("boat_lantern", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("sail_palmleaf", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("sail_cloth", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("sail_snakeskin", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("sail_feather", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("boatrepairkit", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("ironwind", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("boatcannon", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("trawlnet", RECIPE_BOAT_TYPE.IA)
BoatModeRecipe("quackeringram", RECIPE_BOAT_TYPE.IA)
