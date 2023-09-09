local prefs = {}

local woodlegs_skin = {
	woodlegs_none = {
		base_prefab = "woodlegs",

		assets = {Asset("ANIM", "anim/woodlegs.zip"), Asset("ANIM", "anim/ghost_woodlegs_build.zip")},

		rarity = "Character",
		skins = {normal_skin = "woodlegs", ghost_skin = "ghost_woodlegs_build"},
		skin_tags = {"BASE", "woodlegs"},
		build_name_override = "woodlegs",

		feet_cuff_size = {woodlegs = 3},
	}
}

for name, data in pairs(woodlegs_skin) do
	table.insert(prefs, CreatePrefabSkin(name, data))
end

return unpack(prefs)