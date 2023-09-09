AddRoom("OceanShallow", {
	colour = {r = 0.0, g = 0.0, b = .280, a = .50},
	value = WORLD_TILES.OCEAN_SHALLOW,
	type = "water",
	contents = {
	    distributepercent = 0.005,
	    distributeprefabs = {},
	}
})

AddRoom("OceanShallowSeaweedBed", {
	colour = {r = 0.0, g = 0.0, b = .280, a = .50},
	value = WORLD_TILES.OCEAN_SHALLOW,
	type = "water",
	contents = {
	    distributepercent = 0.075,
	    distributeprefabs = {
	    	seaweed_planted = 0.5,
	    	mussel_farm = 0.5,
	    },
	}
})

AddRoom("OceanShallowReef", {
	colour = {r = 0.0, g = 0.0, b = .280, a = .50},
	value = WORLD_TILES.OCEAN_SHALLOW,
	type = "water",
	contents = {
	    distributepercent = 0.05,
	    distributeprefabs = {
	    	rock_coral = 1,
	    },
	}
})

AddRoom("OceanMedium", {
	colour = {r = 0.0, g = 0.0, b = .180, a = .30},
	value = WORLD_TILES.OCEAN_MEDIUM,
	type = "water",
	contents = {
	    distributepercent = 0.0005,
	    distributeprefabs = {
	    	barrel_gunpowder = 1, -- redbarrel = 1,
	    },
	}
})

AddRoom("OceanMediumSeaweedBed", {
	colour = {r = 0.0, g = 0.0, b = .180, a = .30},
	value = WORLD_TILES.OCEAN_MEDIUM,
	type = "water",
	contents = {
	    distributepercent = 0.05,
	    distributeprefabs = {
	    	seaweed_planted = 1,
	    },
	}
})

AddRoom("OceanMediumShoal", {
	colour = {r = 0.0, g = 0.0, b = .180, a = .30},
	value = WORLD_TILES.OCEAN_MEDIUM,
	type = "water",
	contents = {
	    distributepercent = 0.025,
	    distributeprefabs = {
	    	fishinhole = 1,
	    	seaweed_planted = .5,
	    },
	}
})

AddRoom("OceanDeep", {
	colour = {r = 0.0, g = 0.0, b = .080, a = .10},
	value = WORLD_TILES.OCEAN_DEEP,
	type = "water",
	contents = {
	    distributepercent = 0.0005,
	    distributeprefabs = {
	    	barrel_gunpowder = 1, -- redbarrel = 1,
	    },
	}
})

AddRoom("OceanCoral", {
	colour = {r = 0.0, g = 0.0, b = .280, a = .50},
	value = WORLD_TILES.OCEAN_CORAL,
	type = "water",
	contents = {
	    distributepercent = 0.05,
	    distributeprefabs = {
	    	rock_coral = .1,
	    	fishinhole = 1,
	    	seaweed_planted = 10,
	    	solofish = 1,
	    },
	}
})