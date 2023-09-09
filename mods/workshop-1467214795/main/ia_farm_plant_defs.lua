local PLANT_DEFS = require("prefabs/farm_plant_defs").PLANT_DEFS

local function MakeGrowTimes(germination_min, germination_max, full_grow_min, full_grow_max)
	local grow_time = {}

	-- germination time
	grow_time.seed		= {germination_min, germination_max}

	-- grow time
	grow_time.sprout	= {full_grow_min * 0.5, full_grow_max * 0.5}
	grow_time.small		= {full_grow_min * 0.3, full_grow_max * 0.3}
	grow_time.med		= {full_grow_min * 0.2, full_grow_max * 0.2}

	-- harvestable perish time
	grow_time.full		= 4 * TUNING.TOTAL_DAY_TIME
	grow_time.oversized	= 6 * TUNING.TOTAL_DAY_TIME
	grow_time.regrow	= {4 * TUNING.TOTAL_DAY_TIME, 5 * TUNING.TOTAL_DAY_TIME} -- min, max

	return grow_time
end

local drink_low = TUNING.FARM_PLANT_DRINK_LOW
local drink_med = TUNING.FARM_PLANT_DRINK_MED
local drink_high = TUNING.FARM_PLANT_DRINK_HIGH
-- Nutrients
local S = TUNING.FARM_PLANT_CONSUME_NUTRIENT_LOW
local M = TUNING.FARM_PLANT_CONSUME_NUTRIENT_MED
local L = TUNING.FARM_PLANT_CONSUME_NUTRIENT_HIGH

PLANT_DEFS.sweet_potato = {
	build = "farm_plant_sweet_potato",
	bank = "farm_plant_potato",

	grow_time = MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME,		4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME),

	moisture = {drink_rate = drink_low,	min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE},

	good_seasons = {autumn = true,	spring = true, summer = true},

	nutrient_consumption = {0, 0, M},

	nutrient_restoration = {true, true, false},

	max_killjoys_tolerance	= TUNING.FARM_PLANT_KILLJOY_TOLERANCE,

	weight_data	= { 365.56,     561.58,     0.45 },

	prefab = "farm_plant_sweet_potato",

	product = "sweet_potato",

	product_oversized = "sweet_potato_oversized",

	seed = "sweet_potato_seeds",

	plant_type_tag = "farm_plant_sweet_potato",

	loot_oversized_rot = {"spoiled_food", "spoiled_food", "spoiled_food", "sweet_potato_seeds", "fruitfly", "fruitfly"},

	family_min_count = TUNING.FARM_PLANT_SAME_FAMILY_MIN,

	family_check_dist = TUNING.FARM_PLANT_SAME_FAMILY_RADIUS,

	stage_netvar = net_tinybyte,

	sounds = PLANT_DEFS.potato.sounds,

	plantregistryinfo = {
		{
			text = "seed",
			anim = "crop_seed",
			grow_anim = "grow_seed",
			learnseed = true,
			growing = true,
		},
		{
			text = "sprout",
			anim = "crop_sprout",
			grow_anim = "grow_sprout",
			growing = true,
		},
		{
			text = "small",
			anim = "crop_small",
			grow_anim = "grow_small",
			growing = true,
		},
		{
			text = "medium",
			anim = "crop_med",
			grow_anim = "grow_med",
			growing = true,
		},
		{
			text = "grown",
			anim = "crop_full",
			grow_anim = "grow_full",
			revealplantname = true,
			fullgrown = true,
		},
		{
			text = "oversized",
			anim = "crop_oversized",
			grow_anim = "grow_oversized",
			revealplantname = true,
			fullgrown = true,
		},
		{
			text = "rotting",
			anim = "crop_rot",
			grow_anim = "grow_rot",
			stagepriority = -100,
			is_rotten = true,
			hidden = true,
		},
		{
			text = "oversized_rotting",
			anim = "crop_rot_oversized",
			grow_anim = "grow_rot_oversized",
			stagepriority = -100,
			is_rotten = true,
			hidden = true,
		},
	},
	plantregistrywidget = "widgets/redux/farmplantpage",
	plantregistrysummarywidget = "widgets/redux/farmplantsummarywidget",
	pictureframeanim = {anim = "emoteXL_happycheer", time = 0.5} ,
}