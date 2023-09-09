local prefabs = {
	CreatePrefabSkin("ms_double_umbrellahat_legacy", { -- Unused SW asset
		assets = {
			Asset( "DYNAMIC_ANIM", 	"anim/dynamic/ms_double_umbrellahat_legacy.zip"), 
			Asset( "PKGREF", 		"anim/dynamic/ms_double_umbrellahat_legacy.dyn"), 
		},
		base_prefab 		= "double_umbrellahat",
		build_name_override = "ms_double_umbrellahat_legacy",
		type 				= "item",
		rarity 				= "ModMade",
		skin_tags 			= {"DOUBLE_UMBRELLAHAT", "IA", "LEGACY", "CRAFTABLE"},
	}),
	
	CreatePrefabSkin("ms_hat_gas_legacy", { -- Unused SW asset
		assets = {
			Asset( "DYNAMIC_ANIM", 	"anim/dynamic/ms_hat_gas_legacy.zip"), 
			Asset( "PKGREF", 		"anim/dynamic/ms_hat_gas_legacy.dyn"), 
		},
		base_prefab 		= "gashat",
		build_name_override = "ms_hat_gas_legacy",
		type 				= "item",
		rarity 				= "ModMade",
		skin_tags 			= {"GASHAT", "IA", "LEGACY", "CRAFTABLE"},
	}),
	
	CreatePrefabSkin("ms_palmleaf_hut_cawnival", { -- discord: tin_can__
		assets = {
			Asset( "DYNAMIC_ANIM", 	"anim/dynamic/ms_palmleaf_hut_cawnival.zip"), 
			Asset( "PKGREF", 		"anim/dynamic/ms_palmleaf_hut_cawnival.dyn"), 
		},
		base_prefab 		= "palmleaf_hut",
		build_name_override = "ms_palmleaf_hut_cawnival",
		type 				= "item",
		rarity 				= "ModMade",
		skin_tags 			= {"PALMLEAF_HUT", "IA", "CAWNIVAL", "CRAFTABLE"},
	}),
	
	CreatePrefabSkin("ms_palmleaf_hut_cawnival_shdw", { -- discord: tin_can__
		assets = {
			Asset( "DYNAMIC_ANIM", 	"anim/dynamic/ms_palmleaf_hut_cawnival_shdw.zip"), 
			Asset( "PKGREF", 		"anim/dynamic/ms_palmleaf_hut_cawnival_shdw.dyn"), 
		},
		base_prefab 		= "palmleaf_hut_shadow",
		build_name_override = "ms_palmleaf_hut_cawnival_shdw",
		type 				= "item",
		rarity 				= "ModMade",
		skin_tags 			= {},
	}),
}
return unpack(prefabs)