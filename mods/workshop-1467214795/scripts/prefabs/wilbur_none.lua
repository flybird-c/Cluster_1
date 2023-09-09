local skins = {}
return CreatePrefabSkin("wilbur_none", {
	base_prefab = "wilbur",
	build_name_override = "wilbur",
	rarity = "Character",
	skins = {
		normal_skin = "wilbur",
		ghost_skin = "ghost_wilbur_build",
	},
	assets = {
		Asset( "ANIM", "anim/wilbur.zip" ),
		Asset( "ANIM", "anim/ghost_wilbur_build.zip" ),
	},
	skin_tags = { "BASE", "WILBUR", },
	torso_tuck_builds = { "wilbur", },
	torso_untuck_wide_builds = { "wilbur", },
	has_alternate_for_body = { "wilbur", },
	skip_item_gen = true,
	skip_giftable_gen = true,
}), unpack(skins)