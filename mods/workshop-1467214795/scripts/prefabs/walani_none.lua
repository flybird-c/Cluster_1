local prefs = {}

local walani_skin = {
	walani_none = {
		base_prefab = "walani",

		assets = {Asset("ANIM", "anim/walani.zip"), Asset("ANIM", "anim/ghost_walani_build.zip")},

		rarity = "Character",
		skins = {normal_skin = "walani", ghost_skin = "ghost_walani_build"},
		skin_tags = {"BASE", "WALANI"},
		build_name_override = "walani",

		feet_cuff_size = {walani = 3},
	}
}

for name, data in pairs(walani_skin) do
	table.insert(prefs, CreatePrefabSkin(name, data))
end

return unpack(prefs)