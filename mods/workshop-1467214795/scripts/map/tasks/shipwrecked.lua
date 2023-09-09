require "map/rooms/shipwrecked/terrain_island"
require "map/rooms/shipwrecked/terrain_beach"
require "map/rooms/shipwrecked/terrain_jungle"
require "map/rooms/shipwrecked/terrain_magmafield"
require "map/rooms/shipwrecked/terrain_mangrove"
require "map/rooms/shipwrecked/terrain_meadow"
require "map/rooms/shipwrecked/terrain_ocean"
require "map/rooms/shipwrecked/terrain_tidalmarsh"
require "map/rooms/shipwrecked/water_content"

AddTask("HomeIslandVerySmall", {
    locks = LOCKS.NONE,
    keys_given = {KEYS.ISLAND1},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleDenseMedHome"] = 1,
        ["BeachSandHome"] = 2,
        ["BeachDebris"] = 1,
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("HomeIslandSmall", {
    locks = LOCKS.NONE,
    keys_given = {KEYS.ISLAND1},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleDenseMedHome"] = 2,
        ["BeachUnkept"] = 1,
        ["BeachDebris"] = 1,
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"BeachSandHome"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("HomeIslandSmallBoon", {
    locks = LOCKS.NONE,
    keys_given = {KEYS.ISLAND1},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleDenseHome"] = 2,
        ["JungleDenseMedHome"] = 1,
        ["BeachSandHome"] = 1,
        ["BeachUnkept"] = 1,
        ["BeachDebris"] = 1,
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"BeachSandHome"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("HomeIslandSingleTree", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["OceanShallow"] = 1,
    },
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("HomeIslandMed", {
    locks = LOCKS.NONE,
    keys_given = {KEYS.ISLAND1},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleDenseMedHome"] = 3 + math.random(0, 3),
        ["BeachUnkept"] = 1,
        ["BeachDebris"] = 1,
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"BeachSandHome"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("HomeIslandLarge", {
    locks = LOCKS.NONE,
    keys_given = {KEYS.ISLAND1},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleDenseMedHome"] = 3 + math.random(0, 3),
        ["BeachUnkept"] = 2,
        ["BeachDebris"] = 1,
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"BeachSandHome"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("HomeIslandLargeBoon", {
    locks = LOCKS.NONE,
    keys_given = {KEYS.ISLAND1},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleDenseMedHome"] = 3 + math.random(0, 3),
        ["BeachUnkept"] = 2,
        ["BeachDebris"] = 1,
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"BeachSandHome"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("DesertIsland", {
    locks = LOCKS.NONE,
    keys_given = {KEYS.ISLAND1},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachSand"] = 1 + math.random(0, 3),
    },
    room_bg = WORLD_TILES.BEACH,
    background_room = {"BeachSand", "BeachUnkept"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("DEBUGVolcanoIsland", {
    locks = LOCKS.ISLAND4,
    keys_given = {KEYS.NONE},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["VolcanoRock"] = 1,
        ["MagmaVolcano"] = 1,
        ["VolcanoObsidian"] = 1,
        ["VolcanoObsidianBench"] = 1,
        ["VolcanoAltar"] = 1,
        ["VolcanoLava"] = 1
    },
    room_bg = WORLD_TILES.BEACH,
    background_room = {"BeachSand", "BeachUnkept"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("JungleMarsh", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    gen_method = "lagoon",
    room_choices = {
        {
            ["TidalMarsh"] = 2
        },
        {
            ["JungleDense"] = 6,
            ["JungleDenseBerries"] = 2
        },
    },
    room_bg = WORLD_TILES.JUNGLE,
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("BeachJingleS", {
    locks = LOCKS.NONE,
    keys_given = {KEYS.ISLAND1},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleDenseMed"] = 3,
        ["BeachUnkept"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"BeachSand", "BeachSand", "BeachSand", "BeachUnkept"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("BeachBothJungles", {
    locks = LOCKS.NONE,
    keys_given = {KEYS.ISLAND1},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleDenseMed"] = 1,
        ["JungleDense"] = 2,
        ["BeachSand"] = 3
    },
    room_bg = WORLD_TILES.JUNGLE,
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("BeachJungleD", {
    locks = LOCKS.ISLAND1,
    keys_given = {KEYS.ISLAND2},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleDense"] = 2,
        ["BeachSand"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"BeachSand", "BeachUnkept"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("BeachSavanna", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachSand"] = 2,
        ["NoOxMeadow"] = 2
    },
    room_bg = WORLD_TILES.BEACH,
    background_room = {"BeachSand", "BeachUnkept"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("GreentipA", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachSand"] = 2,
        ["MeadowCarroty"] = 1,
        ["JungleDenseMed"] = 3,
        ["BeachUnkept"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("GreentipB", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachSand"] = 1,
        ["NoOxMangrove"] = 2,
        ["JungleDense"] = 2
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("HalfGreen", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachSand"] = 3,
        ["Mangrove"] = 1,
        ["JungleDenseMed"] = 1,
        ["NoOxMeadow"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"BeachSand", "BeachUnkept"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("BeachRockyland", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachSand"] = 1,
        ["Magma"] = 1
    },
    room_bg = WORLD_TILES.BEACH,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("LotsaGrass", {
    locks = LOCKS.ISLAND1,
    keys_given = {KEYS.ISLAND2},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["NoOxMangrove"] = 1,
        ["JungleDenseMed"] = 1,
        ["NoOxMeadow"] = 2
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("AllBeige", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachSand"] = 1,
        ["Magma"] = 1,
        ["NoOxMangrove"] = 1
    },
    room_bg = WORLD_TILES.BEACH,
    background_room = {"BeachSand", "BeachUnkept"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("BeachMarsh", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachSand"] = 1,
        ["TidalMarsh"] = 2
    },
    room_bg = WORLD_TILES.BEACH,
    background_room = {"BeachSand", "BeachUnkept"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("Verdant", {
    locks = LOCKS.ISLAND1,
    keys_given = {KEYS.ISLAND2},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachSand"] = 1,
        ["BeachPiggy"] = 1,
        ["JungleDenseMed"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("VerdantMost", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachSand"] = 1,
        ["BeachSappy"] = 1,
        ["JungleDenseMed"] = 1,
        ["JungleDenseBerries"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("Vert", {
    locks = LOCKS.ISLAND1,
    keys_given = {KEYS.ISLAND2},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachSand"] = 1,
        ["MeadowCarroty"] = 1,
        ["JungleDense"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("Florida Timeshare", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["TidalMarsh"] = 1,
        ["JungleDenseMed"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"BeachSand"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("JungleSRockyland", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    gen_method = "lagoon",
    room_choices = {
        {
            ["JungleDenseMed"] = 2
        },
        {
            ["Magma"] = 6
        },
    },
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("JungleSSavanna", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BareMangrove"] = 1,
        ["JungleDenseMed"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"JungleDenseMed", "NoOxMangrove"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("JungleBeige", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BareMangrove"] = 1,
        ["Magma"] = 1,
        ["JungleDenseMed"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("FullofBees", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeesBeach"] = 2,

        ["JungleDense"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("JungleDense", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["TidalMarsh"] = 1,
        ["JungleFlower"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = "JungleDense",
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("JungleDMarsh", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["TidalMarsh"] = 1,
        ["JungleDense"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"JungleDenseMed", "TidalMermMarsh"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("JungleDRockyland", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    gen_method = "lagoon",
    room_choices = {
        {
            ["JungleDense"] = 2,
        },
        {
            ["Magma"] = 4
        },
    },

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("JungleDRockyMarsh", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    gen_method = "lagoon",
    room_choices = {
        {
            ["TidalMarsh"] = 2
        },
        {
            ["JungleDense"] = 4,
            ["Magma"] = 2
        },
    },

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("JungleDSavanna", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BareMangrove"] = 1,
        ["JungleDense"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"JungleDense", "NoOxMangrove"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("JungleDSavRock", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BareMangrove"] = 1,
        ["Magma"] = 1,
        ["JungleDense"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("HotNSticky", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["TidalMarsh"] = 2,
        ["JungleDenseMed"] = 1,
        ["JungleDense"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("Marshy", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["TidalMarsh"] = 1,
        ["TidalMermMarsh"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("NoGreen A", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["TidalMarsh"] = 1,
        ["Magma"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"Magma", "TidalMarsh"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("NoGreen B", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["ToxicTidalMarsh"] = 2,
        ["Magma"] = 1,
        ["BareMangrove"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("Savanna", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachUnkept"] = 1,
        ["BareMangrove"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = "BeachNoCrabbits",
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("Rockyland", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["Magma"] = 2,
        ["ToxicTidalMarsh"] = math.random(0, 1),
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"BeachUnkept"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("PalmTreeIsland", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = 1,
    make_loop = true,
    room_choices = {
        ["BeachSinglePalmTree"] = 1,
        ["OceanShallowSeaweedBed"] = 1,
        ["OceanShallow"] = 1,
    },
    room_bg = WORLD_TILES.OCEAN_SHALLOW,
    background_room = "OceanShallow",
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("DoydoyIslandGirl", {
    locks = LOCKS.ISLAND4,
    keys_given = {KEYS.NONE},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleSparse"] = 2,
    },
    set_pieces = {
        {name = "DoydoyGirl"}
    },
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("DoydoyIslandBoy", {
    locks = LOCKS.ISLAND4,
    keys_given = {KEYS.NONE},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
            ["JungleSparse"] = 2,
    },
    set_pieces = {
        {name = "DoydoyBoy"}
    },
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandCasino", {
    locks = LOCKS.ISLAND4,
    keys_given = {KEYS.ISLAND5},
    crosslink_factor = 1,
    make_loop = true,
    room_choices = {
        ["BeachPalmCasino"] = 1,
        ["Mangrove"] = math.random(1, 2)
    },
    set_pieces = {
        {name = "Casino"}
    },
    room_bg = WORLD_TILES.OCEAN_SHALLOW,
    background_room = "OceanShallow",
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("KelpForest", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = 1,
    make_loop = true,
    room_choices = {
        ["OceanMediumSeaweedBed"] = math.random(1, 3),
    },
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("GreatShoal", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = 1,
    make_loop = true,
    room_choices = {
        ["OceanMediumShoal"] = math.random(1, 3),
    },
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("BarrierReef", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = 0,
    make_loop = false,
    room_choices = {
        ["OceanCoral"] = math.random(1, 3),
    },
    colour = {r = 1, g = 1, b = 0, a = 1}
})


AddTask("IslandParadise", {
    locks = LOCKS.NONE,
    keys_given = {KEYS.PICKAXE, KEYS.AXE, KEYS.GRASS, KEYS.WOOD, KEYS.TIER1, KEYS.ISLAND1},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachSand"] = 1,
        ["Jungle"] = 2,
        ["MeadowMandrake"] = 1,
        ["Magma"] = 1,
        ["JungleDenseVery"] = math.random(0, 1),
        ["BareMangrove"] = 1,
    },
    room_bg = WORLD_TILES.BEACH,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("MeadowBeeQueenIsland", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["MeadowQueen"] = 1,
        ["MeadowBerries"] = 3,
    },
    room_bg = WORLD_TILES.BEACH ,
    colour = {r = 1, g = 1, b = 0, a = 1},
})

AddTask("PiggyParadise", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3, KEYS.ISLAND4},
    gen_method = "lagoon",
    room_choices = {
        {
            ["JungleDenseBerries"] = 3,
        },
        {
            ["BeachPiggy"] = 5 + math.random(1, 3),
        },
    },
    room_bg = WORLD_TILES.TIDALMARSH,
    background_room = {"BeachSand","BeachPiggy","BeachPiggy","BeachPiggy","TidalMarsh"},
    colour = {r = 0.5, g = 0, b = 1, a = 1}
})

AddTask("BeachPalmForest", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3 ,KEYS.ISLAND4},

    room_choices = {
        ["BeachPalmForest"] = 1 + math.random(0, 3),
    },

    room_bg = WORLD_TILES.TIDALMARSH,
    background_room = "OceanShallow",
    colour = {r = 0.5, g = 0, b = 1, a = 1}
})

AddTask("ThemeMarshCity", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},

    room_choices = {
        ["TidalMermMarsh"] = 1 + math.random(0, 1),
        ["ToxicTidalMarsh"] = 1 + math.random(0, 1),
        ["JungleSpidersDense"] = 1,
    },

    room_bg = WORLD_TILES.TIDALMARSH,

    colour = {r = 0.5, g = 0, b = 1, a = 1}
})

AddTask("Spiderland", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["MagmaSpiders"] = 1,
        ["JungleSpidersDense"] = 2,
        ["JungleSpiderCity"] = 1
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandJungleBamboozled", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleBamboozled"] = 1 + math.random(0, 1),
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"OceanShallow"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandJungleMonkeyHell", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleMonkeyHell"] = 3,
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandJungleCritterCrunch", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleCritterCrunch"] = 2,
        ["JungleDenseCritterCrunch"] = 1,

    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandJungleShroomin", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleShroomin"] = 2,


    },
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandJungleRockyDrop", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    gen_method = "lagoon",
    room_choices = {
        {
            ["MagmaSpiders"] = 2
        },
        {
            ["JungleRockyDrop"] = 4,
            ["Jungle"] = 2
        },
    },
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandJungleEyePlant", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleEyeplant"] = 1,
        ["TidalMarsh"] = 1,

    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"JungleDenseMedHome"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandJungleBerries", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleDenseBerries"] = 4,
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandJungleNoBerry", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleNoBerry"] = 3,
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandJungleNoRock", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleNoRock"] = 1,

        ["TidalMarsh"] = 1,
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandJungleNoMushroom", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleNoMushroom"] = 1,

    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"JungleNoMushroom"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandJungleNoFlowers", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleNoFlowers"] = math.random(3,5),

    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandJungleEvilFlowers", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleEvilFlowers"] = 2,
        ["ToxicTidalMarsh"] = 1,
    },
    room_bg = WORLD_TILES.JUNGLE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandJungleSkeleton", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["JungleSkeleton"] = 1,
        ["JungleDenseMedHome"] = 1,
        ["TidalMermMarsh"] = 1,
    },
    room_bg = WORLD_TILES.JUNGLE,
    background_room = {"Jungle", "JungleDense"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandBeachCrabTown", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachCrabTown"] = math.random(1,3),
    },
    room_bg = WORLD_TILES.BEACH,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandBeachDunes", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachDunes"] = 1,
        ["BeachUnkept"] = 1,

    },
    room_bg = WORLD_TILES.BEACH,
    background_room = {"BeachSand", "BeachUnkept"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandBeachGrassy", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachGrassy"] = 1,
        ["BeachPalmForest"]=1,
        ["BeachSandHome"]=1,
    },
    room_bg = WORLD_TILES.BEACH,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandBeachSappy", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachSappy"] = 1,
        ["BeachSand"] = 1,
        ["BeachUnkept"] = 1,
    },
    room_bg = WORLD_TILES.BEACH,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandBeachRocky", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachRocky"] = 1,

        ["BeachUnkept"] = 1,
        ["BeachSandHome"] = 1,
    },
    room_bg = WORLD_TILES.BEACH,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandBeachLimpety", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachLimpety"] = 1,
        ["BeachSand"] = 1,
    },
    room_bg = WORLD_TILES.BEACH,
    background_room = {"BeachSand", "BeachUnkept"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandBeachForest", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachPalmForest"] = 1,
        ["BeachSandHome"] = 1,

    },
    room_bg = WORLD_TILES.BEACH,
    background_room = {"BeachUnkept", "BeachSandHome"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandBeachSpider", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachSpider"] = 2,

    },
    room_bg = WORLD_TILES.BEACH,
    background_room = {"BeachSand", "BeachUnkept"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandBeachNoFlowers", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachNoFlowers"] = 1,
        ["BeachUnkept"] = 1,
    },
    room_bg = WORLD_TILES.BEACH,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandBeachNoLimpets", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachNoLimpets"] = 1,
    },
    room_bg = WORLD_TILES.BEACH,
    background_room = {"BeachSand"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandBeachNoCrabbits", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachNoCrabbits"] = 2,


    },
    room_bg = WORLD_TILES.BEACH,
    background_room = {"BeachUnkept", "BeachUnkept"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandMangroveOxBoon", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["MangroveOxBoon"] = 1,
        ["MangroveWetlands"] = 1,
        ["JungleNoRock"] = 1,
    },
    room_bg = WORLD_TILES.MANGROVE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandMeadowBees", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["MeadowBees"] = 1,
        ["NoOxMeadow"] = 1,
    },
    room_bg = WORLD_TILES.MANGROVE,
    background_room = {"NoOxMeadow"},
    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandMeadowCarroty", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["MeadowCarroty"] = 1,
        ["NoOxMeadow"] = 1,
    },
    room_bg = WORLD_TILES.MANGROVE,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandRockyGold", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["MagmaGoldBoon"] = 1,
        ["MagmaGold"] = 1,
        ["BeachSandHome"] = 1,
    },
    room_bg = WORLD_TILES.BEACH ,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandRockyTallBeach", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["MagmaTallBird"] = 1,
        ["GenericMagmaNoThreat"] = 1,
        ["BeachUnkept"] = 1,
    },
    room_bg = WORLD_TILES.BEACH ,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("IslandRockyTallJungle", {
    locks = LOCKS.ISLAND3,
    keys_given = {KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["MagmaTallBird"] = 1,
        ["BG_Magma"] = 1,
        ["JungleDenseMed"] = 1,
    },
    room_bg = WORLD_TILES.JUNGLE ,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("Chess", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["MarbleForest"] = 1,
        ["ChessArea"] = 1,


    },
    colour = {r = 0.5, g = 0.7, b = 0.5, a = 0.3},
})
AddTask("PirateBounty", {
    locks = LOCKS.ISLAND4,
    keys_given = {KEYS.ISLAND5},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachUnkeptDubloon"] = 1,
    },
    set_pieces = {
        {name = "Xspot"}
    },
    room_bg = WORLD_TILES.BEACH ,

    colour = {r = 0.5, g = 0.7, b = 0.5, a = 0.3},
})

AddTask("IslandOasis", {
    locks = LOCKS.ISLAND4,
    keys_given = {KEYS.ISLAND5},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["Jungle"] = 1,
    },
    set_pieces = {
        {name = "JungleOasis"}
    },
    room_bg = WORLD_TILES.BEACH ,

    colour = {r = 0.5, g = 0.7, b = 0.5, a = 0.3},
})

AddTask("ShellingOut", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3, KEYS.ISLAND4},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachShells"] = 2,
    },
    room_bg = WORLD_TILES.BEACH ,
    background_room = {"OceanShallow"},
    colour = {r = 0.5, g = 0.7, b = 0.5, a = 0.3},
})

AddTask("Cranium", {
    locks = LOCKS.ISLAND4,
    keys_given = {KEYS.ISLAND5},
    gen_method = "lagoon",
    room_choices = {
        {
            ["BeachSkull"] = 1,
        },
        {
            ["Jungle"] = 6,
        },
    },
    room_bg = WORLD_TILES.BEACH,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("CrashZone", {
    locks = LOCKS.ISLAND2,
    keys_given = {KEYS.ISLAND3},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["Jungle"] = 2,
        ["MagmaForest"] = 1,
    },
    room_bg = WORLD_TILES.BEACH,

    colour = {r = 1, g = 1, b = 0, a = 1}
})

AddTask("SharkHome", {
    locks = LOCKS.ISLAND4,
    keys_given = {KEYS.ISLAND5},
    crosslink_factor = math.random(0, 1),
    make_loop = math.random(0, 100) < 50,
    room_choices = {
        ["BeachSand"] = 1,
    },
    set_pieces = {
        {name = "SharkHome"}
    },
    room_bg = WORLD_TILES.BEACH ,

    colour = {r = 0.5, g = 0.7, b = 0.5, a = 0.3},
})
