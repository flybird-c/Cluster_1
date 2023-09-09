local STRINGS = GLOBAL.STRINGS
--LEVELTYPE.SHIPWRECKED = "SHIPWRECKED"

AddLevel(LEVELTYPE.SURVIVAL, {
	id = "SURVIVAL_SHIPWRECKED_CLASSIC",
	name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.SURVIVAL_SHIPWRECKED_CLASSIC,
	desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.SURVIVAL_SHIPWRECKED_CLASSIC,
	location = "forest",
	overrides = {
		-- location = "shipwrecked",
		task_set = "shipwrecked",
		start_location = "ShipwreckedStart",

		prefabswaps_start = "classic",

		loop = "never",

		roads = "never",
		poi = "never",

		stageplays="never",

		frograin = "never",
		wildfires = "never",

		deerclops = "never",
		bearger = "never",

		perd = "never",
		penguins = "never",
		hunt = "never",

		--dragonfly = "never", unnecessary for now, some mods that add dragonfly would be affected by this

		primaryworldtype = "islandsonly",
		primarywatertype = "highsea", --Unused atm but will be in the future so keep here for compat

		clocktype = "tropical",
	},

	--The random range of background rooms (biomes) that get added to each room in a task.
	background_node_range = {0, 2},

	numrandom_set_pieces = 0,
	random_set_pieces = {},
})
