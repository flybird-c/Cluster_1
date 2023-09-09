--[WARNING]: This file is imported into modclientmain.lua, be careful!

local character_assets = {
    -- Woodlegs
    Asset("ATLAS", "images/crafting_menu_avatars/avatar_woodlegs.xml"),
    Asset("IMAGE", "images/crafting_menu_avatars/avatar_woodlegs.tex"),

    Asset("IMAGE", "images/saveslot_portraits/woodlegs.tex"),
    Asset("ATLAS", "images/saveslot_portraits/woodlegs.xml"),

    Asset("IMAGE", "bigportraits/woodlegs.tex"),
    Asset("ATLAS", "bigportraits/woodlegs.xml"),

    Asset("IMAGE", "bigportraits/woodlegs_none.tex"),
    Asset("ATLAS", "bigportraits/woodlegs_none.xml"),

    Asset("IMAGE", "images/avatars/avatar_woodlegs.tex"),
    Asset("ATLAS", "images/avatars/avatar_woodlegs.xml"),

    Asset("IMAGE", "images/avatars/avatar_ghost_woodlegs.tex"),
    Asset("ATLAS", "images/avatars/avatar_ghost_woodlegs.xml"),

    Asset("IMAGE", "images/avatars/self_inspect_woodlegs.tex"),
    Asset("ATLAS", "images/avatars/self_inspect_woodlegs.xml"),

    Asset("IMAGE", "images/names_woodlegs.tex"),
    Asset("ATLAS", "images/names_woodlegs.xml"),

    Asset("IMAGE", "images/names_gold_woodlegs.tex"),
	Asset("ATLAS", "images/names_gold_woodlegs.xml"),

    -- Asset("IMAGE", "images/names_gold_cn_woodlegs.tex"),
	-- Asset("ATLAS", "images/names_gold_cn_woodlegs.xml"),

    -- Walani
    Asset("ATLAS", "images/crafting_menu_avatars/avatar_walani.xml"),
    Asset("IMAGE", "images/crafting_menu_avatars/avatar_walani.tex"),

    Asset("IMAGE", "images/saveslot_portraits/walani.tex"),
    Asset("ATLAS", "images/saveslot_portraits/walani.xml"),

    Asset("IMAGE", "bigportraits/walani.tex"),
    Asset("ATLAS", "bigportraits/walani.xml"),

    Asset("IMAGE", "bigportraits/walani_none.tex"),
    Asset("ATLAS", "bigportraits/walani_none.xml"),

    Asset("IMAGE", "images/avatars/avatar_walani.tex"),
    Asset("ATLAS", "images/avatars/avatar_walani.xml"),

    Asset("IMAGE", "images/avatars/avatar_ghost_walani.tex"),
    Asset("ATLAS", "images/avatars/avatar_ghost_walani.xml"),

    Asset("IMAGE", "images/avatars/self_inspect_walani.tex"),
    Asset("ATLAS", "images/avatars/self_inspect_walani.xml"),

    Asset("IMAGE", "images/names_walani.tex"),
    Asset("ATLAS", "images/names_walani.xml"),

    Asset("IMAGE", "images/names_gold_walani.tex"),
	Asset("ATLAS", "images/names_gold_walani.xml"),

    Asset("IMAGE", "images/names_gold_cn_walani.tex"),
	Asset("ATLAS", "images/names_gold_cn_walani.xml"),

    -- Wilbur
    Asset("ATLAS", "images/crafting_menu_avatars/avatar_wilbur.xml"),
    Asset("IMAGE", "images/crafting_menu_avatars/avatar_wilbur.tex"),

    Asset("IMAGE", "images/saveslot_portraits/wilbur.tex"),
    Asset("ATLAS", "images/saveslot_portraits/wilbur.xml"),

    Asset("IMAGE", "bigportraits/wilbur.tex"),
    Asset("ATLAS", "bigportraits/wilbur.xml"),

    Asset("IMAGE", "bigportraits/wilbur_none.tex"),
    Asset("ATLAS", "bigportraits/wilbur_none.xml"),

    Asset("IMAGE", "images/avatars/avatar_wilbur.tex"),
    Asset("ATLAS", "images/avatars/avatar_wilbur.xml"),

    Asset("IMAGE", "images/avatars/avatar_ghost_wilbur.tex"),
    Asset("ATLAS", "images/avatars/avatar_ghost_wilbur.xml"),

    Asset("IMAGE", "images/avatars/self_inspect_wilbur.tex"),
    Asset("ATLAS", "images/avatars/self_inspect_wilbur.xml"),

    Asset("IMAGE", "images/names_wilbur.tex"),
    Asset("ATLAS", "images/names_wilbur.xml"),

    Asset("IMAGE", "images/names_gold_wilbur.tex"),
	Asset("ATLAS", "images/names_gold_wilbur.xml"),

    Asset("IMAGE", "images/names_gold_cn_wilbur.tex"),
	Asset("ATLAS", "images/names_gold_cn_wilbur.xml"),
}

for _, asset in pairs(character_assets) do
    table.insert(Assets, asset)
end

local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

IAENV.AddModCharacter("walani", "FEMALE")
IAENV.AddModCharacter("wilbur", "MALE")
IAENV.AddModCharacter("woodlegs", "MALE")

PREFAB_SKINS["walani"] = {
	"walani_none",
}

PREFAB_SKINS_IDS["walani"] = {
    ["walani_none"] = 1
}

PREFAB_SKINS["wilbur"] = {
    "wilbur_none",
}

PREFAB_SKINS_IDS["wilbur"] = {
    ["wilbur_none"] = 1
}

PREFAB_SKINS["woodlegs"] = {
	"woodlegs_none",
}

PREFAB_SKINS_IDS["woodlegs"] = {
    ["woodlegs_none"] = 1
}

if IAENV.is_mim_enabled then
	return
end

CUSTOM_CHARACTER_SAILFACES["walani"] = {
    walani_none = true
}

CUSTOM_CHARACTER_SAILFACES["wilbur"] = {
    wilbur_none = true,
}

CUSTOM_CHARACTER_SAILFACES["woodlegs"] = {
    woodlegs_none = true
}
