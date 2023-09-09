AddRoom("BeachClear", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		distributepercent = 0,
		distributeprefabs = {},
	}
})

AddRoom("BeachSand", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .25,
		distributeprefabs = {
            rock_limpet = .05,
            crabhole = .2,
            palmtree = .3,
            rocks = .03,
            rock1 = .1,
            beehive = .01,
            grass = .2,
            sapling = .2,
            flint = .05,
            sanddune = .6,
            seashell_beached = .04,
			wildborehouse = .005,
			crate = .02,
		},

		countprefabs = {
			spoiled_fish = 0.5,
			spawnpoint_multiplayer = 1,
		}

	}
})

AddRoom("BeachSandHome", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece"},
	contents = {
	    distributepercent = .3,
	    distributeprefabs = {
            seashell_beached = .5,
            rock_limpet= .05,
            crabhole = .1,
            palmtree = .3,
            rocks = .03,
            rock1 = .05,
            rock_flintless = .1,
            grass = .5,
            sapling = .3,
            flint = .05,
            sanddune = .1,
            crate = .025,
		},

		countprefabs = {
			flint = 1,
			sapling = 1,
			spawnpoint_multiplayer = 1,
		}
	}
})

AddRoom("BeachDebris", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece"},
	contents = {
	    distributepercent = .3,
	    distributeprefabs = {
			seashell_beached = .25,
            grass = .3,
            sapling = .2,
            rock_limpet =.02,
            crabhole = .015,
            palmtree = .1,
            rocks = .003,
            flint = .02,
            sanddune = .05,
		},

		countprefabs = {
			flint = 1,
			sapling = 1,
			spawnpoint_multiplayer = 1,
		},
		
		countstaticlayouts = {
			["WallyIntroDebris"] = 1,
		},
	}
})

AddRoom("BeachUnkept", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece"},
	contents = {
	    distributepercent = .3,
	    distributeprefabs = {
            seashell_beached = .25,
            grass = .3,
            sapling = .2,
            rock_limpet =.02,
            crabhole = .015,
            palmtree = .1,
            rocks = .003,
            beehive = .003,
            flint = .02,
            sanddune = .05,
            dubloon = .001,
			wildborehouse = .005,
		},

		countprefabs = {
			spoiled_fish = 0.3,
			spawnpoint_multiplayer = 1,
		}
	}
})

AddRoom("BeachUnkeptDubloon", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .3,
	    distributeprefabs = {
            seashell_beached = .05,
            grass = .1,
            sapling = .1,
            rock_limpet =.02,
            palmtree = .1,
            rocks = .003,
            flint = .01,
            sanddune = .05,
            goldnugget = .007,
            dubloon = .01,
            skeleton = .025,
			wildborehouse = .005,
		},

		countprefabs = {
			spawnpoint_multiplayer = 1,
		}
	}
})

AddRoom("BeachGravel", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .3,
	    distributeprefabs = {
			rock_limpet = 0.01,
			rocks = 0.1,
			flint = 0.02,
			rock1 = 0.05,
			rock_flintless = 0.05,
			grass = .05,
			sanddune = .05,
            seashell_beached = .05,
			wildborehouse = .005,
		},

		countprefabs = {
			spawnpoint_multiplayer = 1,
		}

	}
})

AddRoom("BeachSinglePalmTreeHome", {
	colour = {r = .66, g = .66, b = .66, a = .50},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece"},
	contents = {
		countprefabs = {
			palmtree = 1,
			seashell_beached = 1,
			raft = 1,
			sanddune = .05,
		}
	}
})

AddRoom("DoydoyBeach", {
	colour = {r = .66, g = .66, b = .66, a = .50},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		    distributepercent = .3,
	    distributeprefabs = {
			flower_evil = 0.5,
			fireflies = 1,
			flower = .75,
			sanddune = .5,
		},
		countprefabs = {
			doydoy = 1,
			palmtree = 1,
			seashell_beached = 1,
			sanddune = .05,
		}
	}
})

AddRoom("BeachWaspy", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .1,
	    distributeprefabs = {
			flower_evil =0.05,
			wasphive = .005,
			sanddune = .05,
			rock_limpet = 0.01,
            flint = .005,
            seashell_beached = .05,
		},
	}
})

AddRoom("BeachPalmForest", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .3,
	    distributeprefabs = {
			palmtree = .5,
			sanddune = .05,
			crabhole = .025,
			grass = .05,
			rock_limpet = .015,
            flint = .005,
            seashell_beached = .05,
			wildborehouse = .005,
		},
	}
})

AddRoom("BeachPiggy", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .2,
	    distributeprefabs = {
			sapling = 0.5,
			grass = .5,
			palmtree = .1,
			wildborehouse = .05,
			rock_limpet = 0.1,
			sanddune = .3,
            seashell_beached = .25,
		},

		countprefabs = {
			spawnpoint_multiplayer = 1,
		},
	}
})

AddRoom("BeesBeach", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .3,
	    distributeprefabs = {
            seashell_beached = .05,
            rock_limpet= .05,
            crabhole = .2,
            palmtree = .3,
            rocks = .03,
            rock1 = .1,
            beehive = .1,
            wasphive = .05,
            grass = .4,
            sapling = .4,
            flint = .05,
            sanddune = .4,
		},

		countprefabs = {
			spawnpoint_multiplayer = 1,
		}
	}
})

AddRoom("BeachCrabTown", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .25,
	    distributeprefabs = {
            rock_limpet = 0.005,
            crabhole = 1,
            sapling = .3,
            palmtree = .75,
            grass = .5,
            seashell_beached = .02,
            rocks=.1,
            rock1=.2,
            flint=.01,
            sanddune=.3,
		},
	}
})

AddRoom("BeachDunes", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .1,
	    distributeprefabs = {
            sanddune = 1.5,
            grass = 1,
            seashell_beached = 1,
            sapling = 1,
            rock1 = .5,
            rock_limpet = 0.1,
			wildborehouse = .05,
		},
	}
})

AddRoom("BeachGrassy", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .2,
	    distributeprefabs = {
            grass = 1.5,
            rock_limpet = .25,
            beehive = .1,
            sanddune = 1,
            rock1 = .5,
            crabhole = .5,
            flint = .05,
            seashell_beached = .5,
		},
	}
})

AddRoom("BeachSappy", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .1,
	    distributeprefabs = {
            sapling = 2,
            crabhole = .5,
            palmtree = 1,
            rock_limpet = 0.1,
            flint = .05,
            seashell_beached = .5,
		},
	}
})

AddRoom("BeachRocky", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .1,
	    distributeprefabs = {
            rock1 = 1,
            rocks = 1,
            rock_flintless = 1,
            grass = 2,
            crabhole = 2,
            rock_limpet = 0.01,
            flint = .05,
            seashell_beached = .5,
			wildborehouse = .05,
		},
	}
})

AddRoom("BeachLimpety", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .1,
	    distributeprefabs = {
            rock_limpet = 1,
            rock1 = 1,
            grass = 1,
            seashell = 1,
            sapling = .75,
            flint = .05,
            seashell_beached = .5,
			wildborehouse = .05,
		},

		countprefabs = {
			spoiled_fish = 0.8,
			spawnpoint_multiplayer = 1,
		}
	}
})

AddRoom("BeachSpider", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .2,
	    distributeprefabs = {
            rock_limpet = 0.01,
            spiderden = 1,
            palmtree = 1,
            grass = 1,
            rocks = 0.5,
            sapling = 0.5,
            flint = .05,
            seashell_beached = .5,
			wildborehouse = .025,
		},
	}
})

AddRoom("BeachNoFlowers", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .1,
	    distributeprefabs = {
            seashell_beached = .005,
            rock_limpet = .005,
            crabhole = .002,
            palmtree = .3,
            rocks = .003,
            beehive = .005,
            grass = .3,
            sapling = .25,
            flint = .05,
            sanddune =.055,
		},
	}
})

AddRoom("BeachFlowers", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		distributepercent = .5,
		distributeprefabs = {
            beehive = .1,
            flower = 2,
            palmtree = .3,
            rock1 = .1,
            grass = .2,
            sapling = .15,
            seashell_beached = .05,
            rock_limpet = 0.01,
            flint = .05,
		},
	}
})

AddRoom("BeachNoLimpets", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .1,
	    distributeprefabs = {
            seashell_beached = .005,
            crabhole = .002,
            palmtree = .3,
            rocks = .003,
            beehive = .0025,
            grass = .3,
            sapling = .25,
            flint = .05,
            sanddune =.055,
			wildborehouse = .05,
		},
	}
})

AddRoom("BeachNoCrabbits", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .1,
	    distributeprefabs = {
            seashell_beached = .005,
            rock_limpet = .01,
            palmtree = .3,
            rocks = .003,
            beehive = .005,
            grass = .3,
            sapling = .25,
            flint = .05,
            sanddune =.055,
		},
	}
})

AddRoom("BeachPalmCasino", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .1,
	    distributeprefabs = {
            seashell_beached = .05,
            rock_limpet = .01,
            palmtree = .3,
            rocks = .003,
            beehive = .005,
            grass = .3,
            sapling = .25,
            flint = .05,
            sanddune =.055,
		},
	}
})

AddRoom("BeachShells", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
	    distributepercent = .25,
		distributeprefabs = {
            seashell_beached = 2.5,
            rock_limpet = .05,
            crabhole = .2,
            palmtree = .3,
            rocks = .03,
            rock1 = .025,
            beehive = .02,
            grass = .3,
            sapling = .25,
            flint = .25,
            sanddune = .1,
			wildborehouse = .05,
		},

		countprefabs = {
			spawnpoint_multiplayer = 1,
		}
	}
})

AddRoom("BeachSkull", {
	colour = {r = .5, g = 0.6, b = .080, a = .10},
	value = WORLD_TILES.BEACH,
	tags = {"ExitPiece", "Packim_Fishbone"},
	contents = {
		distributepercent = .25,
		distributeprefabs = {
            rock_limpet = .05,
            crabhole = .2,
            palmtree = .3,
            rocks = .03,
            rock1 = .1,
            beehive = .01,
            grass = .2,
            sapling = .2,
            flint = .05,
            sanddune = .6,
            seashell_beached = .04,
			wildborehouse = .005,
			crate = .02,
		},
		
		countstaticlayouts =
		{
		  ["RockSkull"] = 1
		},
  
		treasures = {
			{name = "DeadmansTreasure"}
		},
	}
})
