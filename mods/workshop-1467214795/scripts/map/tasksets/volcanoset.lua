local STRINGS = GLOBAL.STRINGS

AddTaskSet("volcano", {
	name = STRINGS.UI.CUSTOMIZATIONSCREEN.TASKSETNAMES.VOLCANO,
	location = "forest",
	tasks = {
		"Volcano",
	},
	numoptionaltasks = 0,
	optionaltasks = {
	},
	valid_start_tasks = {
		"VolcanoNoise"
	},

	required_prefabs = {"volcano_altar", "obsidian_workbench", "volcano_exit", "daywalkerspawningground"},
})
