AddRoom("JungleClearing", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone", "Terrarium_Spawner_Shipwrecked"},
	contents = {
		countstaticlayouts = {
			["MushroomRingLarge"] = function()
				if math.random(0,1000) > 985 then
					return 1
				end
				return 0
			end
		},

		distributepercent = .2,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 1,
			rock1 = 0.03,
			flint = 0.03,
			grass = .03,
			red_mushroom = .03,
			green_mushroom = .02,
			blue_mushroom = .02,
			flower = 0.75,
			bambootree = .5,
			wasphive = 0.125,
			spiderden = 0.2,
		},
	}
})

AddRoom("Jungle", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.35,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 4,
			rock1 = 0.05,
			rock2 = 0.1,
			flint = 0.1,
			berrybush2 = .09,
			berrybush2_snake = 0.01,
			red_mushroom = .03,
			green_mushroom = .02,
			blue_mushroom = .02,
			flower = 1,
			bambootree = 1,
			bush_vine = .2,
			snakeden = 0.01,
			primeapebarrel = .1,
			spiderden = .05,

		},
	}
})

AddRoom("JungleSparse", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone", "Terrarium_Spawner_Shipwrecked"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.25,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 2,
			rock1 = 0.05,
			rock2 = 0.05,
			rocks = .3,
			flint = .1,
			berrybush2 = .05,
			berrybush2_snake = 0.01,
			red_mushroom = .03,
			green_mushroom = .02,
			blue_mushroom = .02,
			flower = .5,
			bambootree = 1,
			bush_vine = .2,
			snakeden = 0.01,
			spiderden = 0.05,
		},
	}
})

AddRoom("JungleSparseHome", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.3,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = .6,
			rock_flintless = 0.05,
			flint = .1,
			berrybush2 = .05,
			berrybush2_snake = 0.01,
			red_mushroom = .03,
			green_mushroom = .02,
			blue_mushroom = .02,
			flower = 2,
			bambootree = 1,
			bush_vine = 1,
			snakeden = 0.1,
			spiderden = .01,

		},
	}
})

AddRoom("JungleDense", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.4,
		distributeprefabs = {
            fireflies = 0.02,
			jungletree = 3,
			rock1 = 0.05,
 		    rock2 = 0.1,
			berrybush2 = .05,
			berrybush2_snake = 0.01,
			red_mushroom = .03,
			green_mushroom = .02,
			blue_mushroom = .02,
			flower = 0.75,
			bambootree = 1,
			flint = 0.1,
			spiderden = .1,
			bush_vine = 1,
			snakeden = 0.1,
			primeapebarrel = .05,
		},
	}
})

AddRoom("JungleDenseHome", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.3,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 4,
			rock1 = 0.05,
			berrybush2 = .1,
			berrybush2_snake = 0.03,
			red_mushroom = .03,
			green_mushroom = .02,
			blue_mushroom = .02,
			flower = 0.75,
			bambootree = 1,
			flint = 0.1,
			spiderden = .01,
			bush_vine = 1,
			snakeden = 0.1,
		},
	}
})

AddRoom("JungleDenseMed", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone", "Terrarium_Spawner_Shipwrecked"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.4,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 2,
			rock1 = 0.05,
			rock2 = 0.05,
			berrybush2 = .06,
			berrybush2_snake = .02,
			red_mushroom = .03,
			green_mushroom = .02,
			blue_mushroom = .02,
			flower = 0.75,
			bambootree = 1,
			spiderden = .05,
			bush_vine = 1,
			snakeden = 0.1,

		},
	}
})

AddRoom("JungleDenseBerries", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		countstaticlayouts = {["BerryBushBunch"] =1},
		distributepercent = 0.35,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 4,
			rock1 = 0.05,
			rock2 = 0.05,
			berrybush2 = .6,
			berrybush2_snake = .03,
			red_mushroom = .03,
			green_mushroom = .02,
			blue_mushroom = .02,
			flower = 0.75,
			bambootree = 1,
			spiderden =.05,
			bush_vine = 1,
			snakeden = 0.1,
		},
	}
})

AddRoom("JungleDenseMedHome", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.5,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 2,
			rock_flintless = 0.05,
			berrybush2 = .06,
			berrybush2_snake = .02,
			red_mushroom = .03,
			green_mushroom = .02,
			blue_mushroom = .02,
			flower = 0.75,
			bambootree = 1,
			spiderden = .05,
			bush_vine = 0.8,
			snakeden = 0.1,
		},
	}
})

AddRoom("JungleDenseVery", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone", "Terrarium_Spawner_Shipwrecked"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = .75,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 1,
			rock2 = 0.05,
			flint = 0.05,
			berrybush2 = .05,
			berrybush2_snake = .05,
			red_mushroom = .03,
			green_mushroom = .02,
			blue_mushroom = .02,
			flower = 0.75,
			bambootree = 1,
			spiderden = .05,
			bush_vine = 1,
			snakeden = 0.1,
			primeapebarrel = .125,
		},
	}
})

AddRoom("JunglePigs", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.3,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 3,
			rock1 = 0.05,
			flint = 0.05,
			berrybush2 = .05,
			berrybush2_snake = .05,
			red_mushroom = .06,
			green_mushroom = .04,
			blue_mushroom = .04,
			flower = 0.75,
			bambootree = 1,
			spiderden = .05,
			bush_vine = 1,
			snakeden = 0.1,
			wildborehouse = 0.9,

		},
	}
})

AddRoom("JunglePigGuards", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone", "Terrarium_Spawner_Shipwrecked"},
	contents = {
		countstaticlayouts = {["pigguard_berries_easy"] =1},

		distributepercent = 0.3,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 3,
			rock1 = 0.05,
			flint = 0.05,
			berrybush2 = .05,
			berrybush2_snake = .05,
			red_mushroom = .06,
			green_mushroom = .04,
			blue_mushroom = .04,
			flower = 0.75,
			bambootree = 1,
			spiderden = .05,
			bush_vine = 1,
			snakeden = 0.1,

		},
	}
})

AddRoom("JungleBees", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.3,
		distributeprefabs = {
			beehive = 0.5,
			fireflies = 0.2,
			jungletree = 4,
			rock1 = 0.05,
			flint = 0.05,
			berrybush2 = .05,
			berrybush2_snake = .05,
			red_mushroom = .06,
			green_mushroom = .04,
			blue_mushroom = .04,
			flower = 0.75,
			bambootree = 1,
			spiderden = .01,
			bush_vine = 1,
			snakeden = 0.1,

		},
	}
})

AddRoom("JungleFlower", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone", "Terrarium_Spawner_Shipwrecked"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = .5,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 2,
			rock1 = 0.05,
			berrybush2 = .05,
			berrybush2_snake = .05,
			red_mushroom = .06,
			green_mushroom = .04,
			blue_mushroom = .04,
			flower = 10,
			bambootree = 0.5,
			spiderden = .05,
			bush_vine = 1,
			snakeden = 0.1,

		},

		countprefabs = {
			butterfly_areaspawner = 6,
		},
	}
})

AddRoom("JungleSpidersDense", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.5,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 4,
			rock1 = 0.05,
 		    rock2 = 0.05,
			berrybush2 = .1,
			berrybush2_snake = .05,
			red_mushroom = .03,
			green_mushroom = .02,
			blue_mushroom = .02,
			flower = 0.75,
			bambootree = 1,
			flint = 0.1,
			spiderden = .5,
			bush_vine = 1,
			snakeden = 0.1,
			primeapebarrel = .15,
		},
	}
})

AddRoom("JungleSpiderCity", {
	colour = {r = .30, g = .20, b = .50, a = .50},
	value = WORLD_TILES.JUNGLE,
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		countprefabs = {
            goldnugget = function() return 3 + math.random(3) end,
		},

		distributepercent = 0.3,
		distributeprefabs = {
			jungletree = 3,
			spiderden = 0.3,
		},

		prefabdata = {
			spiderden = function()
				if math.random() < 0.2 then
					return { growable={stage=3} }
				else
					return { growable={stage=2} }
				end
			end,
		},
	}
})


AddRoom("JungleBamboozled", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone", "Terrarium_Spawner_Shipwrecked"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = .75,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = .09,
			rock1 = 0.05,
			berrybush2 = .05,
			berrybush2_snake = .05,
			red_mushroom = .06,
			green_mushroom = .04,
			blue_mushroom = .04,
			flower = 0.1,
			bambootree = 1,
			spiderden = .05,
			bush_vine = .04,
			snakeden = 0.1,
		},
	}
})

AddRoom("JungleMonkeyHell", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = .3,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 2,
			rock1 = 0.125,
			rock2 = 0.125,
			primeapebarrel = .2,
			skeleton = .1,
			flint = 0.5,
			berrybush2 = .1,
			berrybush2_snake = .01,
			red_mushroom = .06,
			green_mushroom = .04,
			blue_mushroom = .04,
			flower = .01,
			bambootree = 0.5,
			spiderden =.01,
			bush_vine = .04,
			snakeden = 0.01,
		},
	}
})

AddRoom("JungleCritterCrunch", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone", "Terrarium_Spawner_Shipwrecked"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = .25,
		distributeprefabs = {
            fireflies = 3,
			jungletree = 3,
			rock1 = 0.05,
			berrybush2 = .05,
			berrybush2_snake = .05,
			red_mushroom = .06,
			green_mushroom = .04,
			blue_mushroom = .04,
			flower = 2,
			bambootree = 1,
			spiderden = 1,
			bush_vine = 0.2,
			snakeden = 0.1,
			beehive = 1.5,
			wasphive = 2,
		},
	}
})

AddRoom("JungleDenseCritterCrunch", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.5,
		distributeprefabs = {
            fireflies = 2,
			jungletree = 6,
			rock_flintless = 0.05,
			berrybush2 = .75,
			berrybush2_snake = .02,
			red_mushroom = .03,
			green_mushroom = .02,
			blue_mushroom = .02,
			flower = 1.5,
			bambootree = 1,
			spiderden = .05,
			bush_vine = 0.8,
			snakeden = 0.1,
			beehive = .01,
		},
	}
})


AddRoom("JungleFrogSanctuary", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone", "Terrarium_Spawner_Shipwrecked"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.35,
		distributeprefabs = {
            fireflies = 1,
			jungletree = 1,
			rock1 = 0.05,
			berrybush2 = .05,
			berrybush2_snake = .05,
			red_mushroom = .06,
			green_mushroom = .04,
			blue_mushroom = .04,
			flower = 1,
			bambootree = 0.5,
			spiderden = .05,
			bush_vine = 0.6,
			snakeden = 0.1,
			pond = 4,
		},
	}
})

AddRoom("JungleShroomin", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = .5,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 3,
			rock1 = 0.05,
			berrybush2 = .05,
			berrybush2_snake = .05,
			red_mushroom = 3,
			green_mushroom = 3,
			blue_mushroom = 2,
			flower = 0.7,
			bambootree = 0.5,
			spiderden =.05,
			bush_vine = .5,
			snakeden = 0.1,

		},
	}
})

AddRoom("JungleRockyDrop", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone", "Terrarium_Spawner_Shipwrecked"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = .35,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 6,
			rock1 = 1,
			rock2 = .5,
			rock_flintless = 2,
			rocks = 3,
			berrybush2 = .05,
			berrybush2_snake = .05,
			red_mushroom = .06,
			green_mushroom = .04,
			blue_mushroom = .04,
			flower = .9,
			bambootree = 0.5,
			spiderden = .05,
			bush_vine = 1,
			snakeden = 0.1,
		},
	}
})

AddRoom("JungleEyeplant", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = .5,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 2,
			berrybush2 = .05,
			berrybush2_snake = .05,
			red_mushroom = .06,
			green_mushroom = .04,
			blue_mushroom = .04,
			flower = 1,
			bambootree = 0.5,
			spiderden = .25,
			bush_vine = 1,
			snakeden = 0.1,
			eyeplant = 4,
		},

		countprefabs = {
			lureplant = 2,
		},
	}
})

AddRoom("JungleGrassy", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone", "Terrarium_Spawner_Shipwrecked"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = .5,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 2,
			rock1 = 0.05,
			berrybush2 = .05,
			berrybush2_snake = .05,
			red_mushroom = .06,
			green_mushroom = .04,
			blue_mushroom = .04,
			flower = .2,
			bambootree = 0.5,
			spiderden = .05,
			bush_vine = 1,
			snakeden = 0.1,
		},
	}
})

AddRoom("JungleSappy", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = .5,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 1.5,
			rock1 = 0.05,
			sapling = 6,
			berrybush2 = .05,
			berrybush2_snake = .05,
			red_mushroom = .06,
			green_mushroom = .04,
			blue_mushroom = .04,
			flower = .3,
			bambootree = 0.5,
			spiderden = .001,
			bush_vine = 0.3,
			snakeden = 0.1,
		},
	}
})

AddRoom("JungleEvilFlowers", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone", "Terrarium_Spawner_Shipwrecked"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = .5,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 2,
			rock1 = 0.05,
			berrybush2 = .05,
			berrybush2_snake = .05,
			red_mushroom = .06,
			green_mushroom = .04,
			blue_mushroom = .04,
			flower = .9,
			bambootree = 0.5,
			spiderden = .05,
			bush_vine = 1,
			snakeden = 0.1,
			flower_evil = 10,
			wasphive = 0.25,
		},

	}
})

AddRoom("JungleParrotSanctuary", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.9,
		distributeprefabs = {
			jungletree = .5,
			rock1 = 0.5,
 		    rock2 = 0.5,
 		    rocks = 0.4,
			berrybush2 = .1,
			berrybush2_snake = .05,
			red_mushroom = 0.05,
			green_mushroom = 0.03,
			blue_mushroom = 0.02,
			flower = 0.2,
			bambootree = 0.5,
			flint = 0.001,
			spiderden = 0.5,
			bush_vine = 0.9,
			snakeden = 0.1,
			primeapebarrel = 0.05,
			fireflies = 0.02,
		},

	}
})

AddRoom("JungleNoBerry", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone", "Terrarium_Spawner_Shipwrecked"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.3,
		distributeprefabs = {
			jungletree = 5,
			rock1 = 0.5,
 		    rock2 = 0.5,
 		    rocks = 0.4,
			red_mushroom = 0.05,
			green_mushroom = 0.03,
			blue_mushroom = 0.02,
			flower = 0.2,
			bambootree = 3,
			flint = 0.001,
			spiderden = 0.5,
			bush_vine = 0.9,
			snakeden = 0.1,
			primeapebarrel = 0.05,
			fireflies = 0.02,
		},

	}
})

AddRoom("JungleNoRock", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.2,
		distributeprefabs = {
			jungletree = 5,
			berrybush2 = .05,
			berrybush2_snake = 0.01,
			red_mushroom = 0.05,
			green_mushroom = 0.03,
			blue_mushroom = 0.02,
			flower = 0.2,
			bambootree = 0.5,
			flint = 0.001,
			spiderden = 0.5,
			bush_vine = 0.9,
			snakeden = 0.1,
			primeapebarrel = .25,
			fireflies = 0.02,
		},

	}
})

AddRoom("JungleNoMushroom", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone", "Terrarium_Spawner_Shipwrecked"},
	contents = {

		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.4,
		distributeprefabs = {
			jungletree = 5,
			rock1 = 0.05,
 		    rock2 = 0.05,
 		    rocks = 0.04,
			berrybush2 = .1,
			berrybush2_snake = .05,
			flower = 0.2,
			bambootree = 0.5,
			flint = 0.001,
			spiderden = 0.5,
			bush_vine = 0.9,
			snakeden = 0.1,
			primeapebarrel = .15,
			fireflies = 0.02,
		},

	}
})

AddRoom("JungleNoFlowers", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {

		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = 0.2,
		distributeprefabs = {
			jungletree = 5,
			rock1 = 0.05,
 		    rock2 = 0.05,
 		    rocks = 0.04,
			berrybush2 = .1,
			berrybush2_snake = .05,
			red_mushroom = 0.05,
			green_mushroom = 0.03,
			blue_mushroom = 0.02,
			bambootree = 0.5,
			flint = 0.001,
			spiderden = 0.5,
			bush_vine = 0.9,
			snakeden = 0.1,
			primeapebarrel = .15,
			fireflies = 0.02,
		},

	}
})



AddRoom("JungleMorePalms", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone", "Terrarium_Spawner_Shipwrecked"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = .5,
		distributeprefabs = {
			jungletree = .3,
			rock1 = 0.05,
 		    rock2 = 0.05,
 		    rocks = 0.04,
			berrybush2 = .1,
			berrybush2_snake = .05,
			red_mushroom = 0.05,
			green_mushroom = 0.03,
			blue_mushroom = 0.02,
			flower = 0.6,
			bambootree = 0.5,
			flint = 0.001,
			spiderden = 0.5,
			bush_vine = 0.9,
			snakeden = 0.1,

			primeapebarrel = .15,
			fireflies = 0.02,
		},

	}
})

AddRoom("JungleSkeleton", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.JUNGLE,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		countstaticlayouts = {
			["LivingJungleTree"] = function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end
		},

		distributepercent = .5,
		distributeprefabs = {
            fireflies = 0.2,
			jungletree = 1.5,
			rock1 = 0.05,
			berrybush2 = .05,
			berrybush2_snake = .05,
			red_mushroom = .06,
			green_mushroom = .04,
			blue_mushroom = .04,
			flower = .9,
			bambootree = 0.5,
			spiderden =.05,
			bush_vine = 1,
			snakeden = 0.1,
			flower_evil = .001,
			skeleton = 1.25,
		},
	}
})

AddRoom("SW_Graveyard", {
	colour = {r = .010, g = .010, b = .10, a = .50},
	value = WORLD_TILES.JUNGLE,
	tags = {"Town"},
	contents = {
		distributepercent = .3,
		distributeprefabs= {
            grass = .1,
            sapling = .1,
            flower_evil = 0.05,
            rocks = .03,
            beehive = .0003,
            flint = .02,
		},

		countprefabs= {
			jungletree = 3,
            goldnugget = function() return math.random(5) end,
			gravestone = function () return 4 + math.random(4) end,
			mound = function () return 4 + math.random(4) end
		}
	}
})
