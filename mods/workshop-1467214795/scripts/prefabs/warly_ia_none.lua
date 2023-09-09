local assets = {
	Asset( "ANIM", "anim/warly.zip" ),
	Asset( "ANIM", "anim/ghost_warly_build.zip" ),
}

return CreatePrefabSkin("warly_none",
{
	base_prefab = "warly", 
	type = "base",
	build_name_override = "warly",
	rarity = "Character",
	skin_tags = { "BASE", "WARLY", },
	skins = { normal_skin = "warly", ghost_skin = "ghost_warly_build", },
	release_group = 0,
	
	-- bigportrait = { build = "bigportraits/warly_none.xml", symbol = "warly_none_oval.tex"},
	
	assets = assets,
	skip_item_gen = true,
	skip_giftable_gen = true,
})