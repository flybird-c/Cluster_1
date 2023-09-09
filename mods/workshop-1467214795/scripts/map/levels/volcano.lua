local STRINGS = GLOBAL.STRINGS

AddLevel(LEVELTYPE.SURVIVAL, {
	id = "SURVIVAL_VOLCANO_CLASSIC",
	name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.SURVIVAL_VOLCANO_CLASSIC,
	desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.SURVIVAL_VOLCANO_CLASSIC,
	location = "forest",
	version = 4,
	overrides = {
		location =			"forest",
		task_set = 			"volcano",
		start_location = 	"VolcanoPortal",

		world_size = 		"small", --mini in DS

		loop_percent =		"always",

		boons =				"never",
		poi = 				"never",
		traps =				"never",
		protected = 		"never",
		roads = 			"never",

		frograin = 			"never",
		wildfires = 		"never",

		deerclops = 		"never",
		bearger = 			"never",

		--Note: these are already disabled based on climate so this is just for optimization
		grassgekkos =		"never",
		perd = 				"never",
		penguins = 			"never",
		hunt = 				"never",
		hounds = 			"never",
		birds = 			"never",
		butterfly = 		"never",

		primaryworldtype = "volcanoonly",
		primarywatertype = "highsea", --Unused atm but will be in the future so keep here for compat

		clocktype = "tropical",
		has_ocean = false,
	},

	background_node_range = {0,0},
})
