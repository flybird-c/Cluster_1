local STRINGS = GLOBAL.STRINGS
local unpack = GLOBAL.unpack
local weighted_random_choice = GLOBAL.weighted_random_choice
local deepcopy = GLOBAL.deepcopy

local shipwrecked_tasks = require("map/tasks/sw_tasklist")
local all_sw_task = {unpack(shipwrecked_tasks[1]), unpack(shipwrecked_tasks[2])}

local valid_start_tasks = {
    --["HomeIslandVerySmall"] = 0.5,
    ["HomeIslandSmall"] = 1,
    ["HomeIslandSmallBoon"] = 0.2,
    ["HomeIslandMed"] = 1,
    ["HomeIslandLarge"] = 0.75,
    ["HomeIslandLargeBoon"] = 0.2,
}

local valid_start_task = weighted_random_choice(valid_start_tasks)

AddTaskSet("shipwrecked", {
	name = STRINGS.UI.CUSTOMIZATIONSCREEN.TASKSETNAMES.SHIPWRECKED,
	location = "forest",

    valid_start_tasks = {
	    valid_start_task,
	},

    tasks = {
        "DesertIsland",
        "DoydoyIslandGirl",
        "DoydoyIslandBoy",
        "IslandCasino",
        "PirateBounty",
        "ShellingOut",
        "JungleMarsh",
        "IslandMangroveOxBoon",
        "SharkHome",
        "IslandOasis",
        "MeadowBeeQueenIsland",
        "IslandParadise",
        "Marshy",
        "IslandRockyTallJungle",
        valid_start_task
    },

    numoptionaltasks = 0,
    optionaltasks = {},

    selectedtasks = {
        {
            min = 1,
            max = 2,
            task_choices = {
                "BeachBothJungles",
                -- "IslandParadise",  -- change to must task
                "Cranium",
            }
        },
        {
            min = 3,
            max = 5,
            task_choices = {
                "BeachJingleS",
                "BeachSavanna",
                "GreentipA",
                "GreentipB",
                "HalfGreen",
                "BeachRockyland",
                "LotsaGrass",
                "CrashZone",
            }
        },
        {
            min = 3,
            max = 4,
            task_choices = {
                "BeachJungleD",
                "AllBeige",
                "BeachMarsh",
                "Verdant",
                "Vert",
                "VerdantMost",
                "Florida Timeshare",
                "PiggyParadise",
                "BeachPalmForest",
                "IslandJungleShroomin",
                "IslandJungleNoFlowers",
                "IslandBeachGrassy",
                "IslandBeachRocky",
                "IslandBeachSpider",
                "IslandBeachNoCrabbits",
            }
        },
        {
            min = 3,
            max = 5,
            task_choices = {
                "JungleSRockyland",
                "JungleSSavanna",
                "JungleBeige",
                "Spiderland",
                "IslandJungleBamboozled",
                "IslandJungleNoBerry",
                "IslandBeachDunes",
                "IslandBeachSappy",
                "IslandBeachNoLimpets",
                "JungleDense",
                "JungleDMarsh",
                "JungleDRockyland",
                "JungleDRockyMarsh",
                "JungleDSavanna",
                "JungleDSavRock",
                "ThemeMarshCity",
                "IslandJungleCritterCrunch",
                --"IslandRockyTallJungle", now it's a must task
                "IslandBeachNoFlowers",
                "NoGreen A",
                "KelpForest",
                "GreatShoal",
                "BarrierReef",
            }
        },
        {
            min = 5,
            max = 6,
            task_choices = {
                "HotNSticky",
                --"Marshy", now it's a must task
                "Rockyland",
                "IslandJungleMonkeyHell",
                "IslandJungleSkeleton",
                "FullofBees",
                "IslandJungleRockyDrop",
                "IslandJungleEvilFlowers",
                "IslandBeachCrabTown",
                "IslandBeachForest",
                "IslandJungleNoRock",
                "IslandJungleNoMushroom",
                "NoGreen B",
                "Savanna",
                "IslandBeachLimpety",
                "IslandMeadowBees",
                "IslandRockyGold",
                "IslandRockyTallBeach",
                "IslandMeadowCarroty",
            }
        },
    },

    water_content = {
        ["WaterAll"] = {checkFn = function(ground) return GLOBAL.IsOceanTile(ground) and not GLOBAL.SpawnUtil.IsShoreTile(ground) end},
        ["WaterShallow"] = {checkFn = function(ground) return ground == GLOBAL.WORLD_TILES.OCEAN_SHALLOW end},
        ["WaterMedium"] = {checkFn = function(ground) return ground == GLOBAL.WORLD_TILES.OCEAN_MEDIUM end},
        ["WaterDeep"] = {checkFn = function(ground) return ground == GLOBAL.WORLD_TILES.OCEAN_DEEP end},
        ["WaterCoral"] = {checkFn = function(ground) return ground == GLOBAL.WORLD_TILES.OCEAN_CORAL end},
        ["WaterShipGraveyard"] = {checkFn = function(ground) return ground == GLOBAL.WORLD_TILES.OCEAN_SHIPGRAVEYARD end},
    },

    water_prefill_setpieces = {
        ["TeleportatoSwBaseLayout"] = {count = 1}
    },

    numrandom_set_pieces = 0,

    set_pieces = {
        ["ResurrectionStoneSw"] = {
            count = 2,
            tasks = {
                "IslandParadise",
                "VerdantMost",
                "AllBeige",
                "NoGreen B",
                "Florida Timeshare",
                "PiggyParadise",
                "JungleDRockyland",
                "JungleDRockyMarsh",
                "JungleDSavRock",
                "IslandJungleRockyDrop"
            }
        },

        ["SWPortal"] = {
            count = 1,
            tasks = all_sw_task
        },

        ["TeleportatoSwRingLayout"] = {
            count = 1,
            tasks = all_sw_task
        },

        ["TeleportatoSwBoxLayout"] = {
            count = 1,
            tasks = all_sw_task
        },

        ["TeleportatoSwCrankLayout"] = {
            count = 1,
            tasks = all_sw_task
        },

        ["TeleportatoSwPotatoLayout"] = {
            count = 1,
            tasks = all_sw_task
        },
    },

    required_prefabs = {
		"volcano",
		"packim_fishbone",
		"sharkittenspawner",
		"octopusking",
        "critterlab_water",
        "shipwrecked_exit",
        "mermhouse_fisher",
        "wallyintro_shipmast",
        -- for terrarium
        "terrariumchest",
        "beequeenhive",
	},

    required_prefab_count = {
        ["doydoy"] = 2,
    },
})
