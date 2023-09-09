
local meadow_fairy_rings = {
	["MushroomRingLarge"] = function() if math.random(1, 1000) > 985 then return 1 end return 0 end,
	["MushroomRingMedium"] = function() if math.random(1, 1000) > 985 then return 1 end return 0 end,
	["MushroomRingSmall"] = function() if math.random(1, 1000) > 985 then return 1 end return 0 end
}

AddRoom("NoOxMeadow", {
	colour = {r = .8, g = .4, b = .4, a = .50},
	value = WORLD_TILES.MEADOW,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    countstaticlayouts = meadow_fairy_rings,
	    distributepercent = .4,
	    distributeprefabs = {
	        flint = 0.01,
	        grass = .4,
	        sweet_potato_planted = 0.05,
	        beehive = 0.003,
	        rocks = 0.003,
	        rock_flintless = 0.01,
	        flower = .25,
	    },
	}
})

AddRoom("MeadowOxBoon", {
	colour = {r = .8, g = .4, b = .4, a = .50},
	value = WORLD_TILES.MEADOW,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    countstaticlayouts = meadow_fairy_rings,
	    distributepercent = .4,
	    distributeprefabs = {
	        ox = .5,
	        grass = 1,
	        flower = .5,
	        beehive = 0.1,
	    },
	}
})

AddRoom("MeadowFlowery", {
	colour = {r = .8, g = .4, b = .4, a = .50},
	value = WORLD_TILES.MEADOW,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    countstaticlayouts = meadow_fairy_rings,
	    distributepercent = .5,
	    distributeprefabs = {
	        flower = .5,
	        beehive = .05,
	        grass = .4,
	        rocks = .05,
	        mandrake_planted = 0.005,
	    },
	}
})

AddRoom("MeadowBees", {
	colour = {r = .8, g = .4, b = .4, a = .50},
	value = WORLD_TILES.MEADOW,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    countstaticlayouts = meadow_fairy_rings,
	    distributepercent = .4,
	    distributeprefabs = {
	        flint = 0.05,
	        grass = 3,
	        sweet_potato_planted = 0.1,
	        rock_flintless = 0.01,
	        flower = 0.15,
	        beehive = 0.5,
	    },
	}
})

AddRoom("MeadowCarroty", {
	colour = {r = .8, g = .4, b = .4, a = .50},
	value = WORLD_TILES.MEADOW,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    countstaticlayouts = meadow_fairy_rings,
	    distributepercent = .35,
	    distributeprefabs = {
	        sweet_potato_planted = 1,
	        grass = 1.5,
	        rocks = .2,
	        flower = .5,
	    },
	}
})

AddRoom("MeadowSappy", {
	colour = {r = .8, g = .4, b = .4, a = .50},
	value = WORLD_TILES.MEADOW,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .3,
	    distributeprefabs = {
	        grass = 3,
	        flower = .5,
	        beehive = .1,
	        sweet_potato_planted = 0.3,
	        wasphive = 0.01,
	    },
	}
})

AddRoom("MeadowSpider", {
	colour = {r = .8, g = .4, b = .4, a = .50},
	value = WORLD_TILES.MEADOW,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .4,
	    distributeprefabs = {
	        spiderden = .5,
	        grass = 1,
	        ox = .5,
	        flower = .5,
	    },
	}
})

AddRoom("MeadowRocky", {
	colour = {r = .8, g = .4, b = .4, a = .50},
	value = WORLD_TILES.MEADOW,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .4,
	    distributeprefabs = {
	        rock_flintless = 1,
	        rocks = 1,
	        rock1 = 1,
	        rock2 = 1,
	        grass = 4,
	        flower = 1,
	    },
	}
})

AddRoom("MeadowMandrake", {
	colour = {r = .8, g = .4, b = .4, a = .50},
	value = WORLD_TILES.MEADOW,
	contents = {
	    distributepercent = .3,
	    distributeprefabs = {
	        grass = .8,
	        sweet_potato_planted = 0.05,
	        rocks = 0.003,
	        rock_flintless = 0.01,
	        flower = .25,
	    },

	    countprefabs = {
	    	mandrake_planted = math.random(2, 5)
		}
	}
})

AddRoom("MeadowQueen", {
    colour = {r = .8, g = .4, b = .4, a = .50},
    value = WORLD_TILES.MEADOW,
    contents =  {
        countprefabs = {
            beequeenhive = 1,
            wasphive = function() return math.random(1, 3) end,
        },

        distributepercent = .45,
        distributeprefabs = {
			grass = 3,
            flower = 4,
            berrybush2 = 0.75,
			sweet_potato_planted = 0.75,
			beehive = 0.5,
        },
    }
})

AddRoom("MeadowBerries", {
    colour = {r = .8, g = .4, b = .4, a = .50},
    value = WORLD_TILES.MEADOW,
    contents =  {
        distributepercent = .45,
        distributeprefabs = {
			grass = 3,
            flower = 4,
            berrybush2 = 0.75,
			sweet_potato_planted = 0.75,
			beehive = 0.5,
        },
    }
})
