local POSSIBLE_VARIANTS = {}

local VISUALVARIANT_PREFABS = {}

local SW_ICONS = 
{
	["dug_grass"] = "dug_grass_tropical",
	["cutgrass"] = "cutgrass_tropical",
	["log"] = "log_tropical",
	["butterfly"] = "butterfly_tropical",
	["butterflywings"] = "butterflywings_tropical",
	["cave_banana"] = "bananas",
	["cave_banana_cooked"] = "bananas_cooked",
    ["megaflare"] = "megaflare_tropical",
}

local PORK_ICONS = 
{	
    -- ["dug_grass"] = "dug_grass_tropical",
	-- ["cutgrass"] = "cutgrass_tropical",
	-- ["log"] = "log_plateu",
	-- ["snakeskin"] = "snakeskin_scaly",
	-- ["snake"] = "snake_scaly",
	-- ["snakeskinsail"] = "snakeskinsail_scaly",
	-- ["armor_snakeskin"] = "armor_snakeskin_scaly",
	-- ["snakeskinhat"] = "snakeskinhat_scaly",
	-- ["fish"] = "coi",
	-- ["fish_cooked"] = "coi_cooked",
}

POSSIBLE_VARIANTS.grassgekko = {
    default = {build="grassgecko"},
    tropical = {build="grassgecko_green_build",testfn=IsInIAClimate},
}

POSSIBLE_VARIANTS.grasspartfx = {
    default = {build="grass1"},
    tropical = {build="grassgreen_build"},
}

POSSIBLE_VARIANTS.grass = {
    default = {build="grass1",minimap="grass.png"},
    tropical = {build="grassgreen_build",minimap="grass_tropical.tex",testfn=IsInIAClimate},
}

POSSIBLE_VARIANTS.grass_water = {
    default = {minimap="grass.png",override={
        {"grass_pieces", "grass1", "grass_pieces"},
    }},
    tropical = {minimap="grass_tropical.tex",override={
        {"grass_pieces", "grassgreen_build", "grass_pieces"},

    },testfn=IsInIAClimate},
}

POSSIBLE_VARIANTS.dug_grass = {
    default = {build="grass1",invimage="default"},
    tropical = {build="grassgreen_build",invimage="dug_grass_tropical", sourceprefabs={
        "grass_water",
    },testfn=IsInIAClimate},
}

POSSIBLE_VARIANTS.krampus = {
    default = {build="krampus_build"},
    tropical = {build="krampus_hawaiian_build",testfn=IsInIAClimate},
}

POSSIBLE_VARIANTS.butterfly = {
    default = {build="butterfly_basic",invimage="default"},
    tropical = {build="butterfly_tropical_basic",invimage="butterfly_tropical",testfn=IsInIAClimate},
}
    
POSSIBLE_VARIANTS.cutgrass = {
    default = {build="cutgrass",invimage="default",sourceprefabs={
        "grassgator", -- Maybe make this a visualvariant?
        "tumbleweed",
    },sourcetags={
        "cavedweller",
    }},
    tropical = {build="cutgrassgreen",invimage="cutgrass_tropical",testfn=IsInIAClimate},
}

POSSIBLE_VARIANTS.butterflywings = {
    default = {build="butterfly_wings",bank="butterfly_wings",invimage="default"},
    tropical = {build="butterfly_tropical_wings",bank="butterfly_tropical_wings",invimage="butterflywings_tropical",testfn=IsInIAClimate},
}

POSSIBLE_VARIANTS.log = {
    default = {build="log",invimage="default",sourceprefabs={
        "marsh_tree",
        "evergreen",
        "evergreen_sparse",
        "winter_tree",
        "twiggytree",
        "winter_twiggytree",
        "deciduoustree",
        "winter_deciduoustree",
        "palmconetree",
        "winter_palmconetree",
        "leif",
        "leif_sparse",
        "moon_tree",
        "oceantree",
        "oceantree_pillar",
    },sourcetags={
        "deciduoustree",
        "cavedweller",
        "mushtree",
    }},
    tropical = {build="log_tropical",invimage="log_tropical",sourceprefabs={
        "palmtree",
        "winter_palmtree",
        "jungletree",
        "winter_jungletree",
        "mangrovetree",
        "livingjungletree",
        "leif_palm",
        "leif_jungle",
        "wallyintro_debris_1",
        "wallyintro_debris_2",
        "wallyintro_debris_3",
    },testfn=IsInIAClimate},
}

POSSIBLE_VARIANTS.cave_banana = {
    default = {build="cave_banana",invimage="default",sourceprefabs={
        "cave_banana_tree",
        "cave_banana_burnt",
        "cave_banana_stump",
    },sourcetags={
        "cavedweller",
    }},
    tropical = {build="bananas",invimage="bananas",sourceprefabs={
        "primeape",
        "primeapebarrel",
        "jungletree",
        "bananabush", --neat
        "leif_jungle",
        "treeguard_banana",
    },testfn=IsInIAClimate},
}

POSSIBLE_VARIANTS.cave_banana_cooked = {
    default = {build="cave_banana",invimage="default"},
    tropical = {build="bananas",invimage="bananas_cooked",testfn=IsInIAClimate},
}

POSSIBLE_VARIANTS.resurrectionstone = {
    default = {build="resurrection_stone",bank="resurrection_stone"},
    tropical = {build="resurrection_stone_sw",bank="resurrection_stone_sw",testfn=IsInIAClimate},
}

POSSIBLE_VARIANTS.megaflare = {
    default = {build="flare_large",invimage="default"},
    tropical = {build="flare_large_blubber",invimage="megaflare_tropical",testfn=IsInIAClimate},
}

return {POSSIBLE_VARIANTS = POSSIBLE_VARIANTS, VISUALVARIANT_PREFABS = VISUALVARIANT_PREFABS, SW_ICONS = SW_ICONS, PORK_ICONS = PORK_ICONS}