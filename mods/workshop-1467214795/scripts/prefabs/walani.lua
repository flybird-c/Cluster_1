local MakePlayerCharacter = require("prefabs/player_common")

local assets = {
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local prefabs = {
    "surfboard_item",
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
	start_inv[string.lower(k)] = v.WALANI
end

prefabs = FlattenTree({prefabs, start_inv}, true)

local function common_postinit(inst)
	inst.MiniMapEntity:SetIcon("walani.tex")
    inst:AddTag("walani")
	inst:AddTag("surfer")
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.components.health:SetMaxHealth(TUNING.WALANI_HEALTH)
	inst.components.hunger:SetMax(TUNING.WALANI_HUNGER)
	inst.components.sanity:SetMax(TUNING.WALANI_SANITY)

    inst.components.foodaffinity:AddPrefabAffinity("seafoodgumbo", TUNING.AFFINITY_15_CALORIES_LARGE)

    inst.components.moisture.baseDryingRate = TUNING.WALANI_MOISTURE_RATE_DRYING
    inst.components.sanity.rate_modifier = TUNING.WALANI_SANITY_RATE_MODIFIER
	inst.components.sanity.no_moisture_penalty = TUNING.WALANI_SANITY_NO_MOISTURE_PENALTY
	inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE * TUNING.WALANI_HUNGER_RATE_MODIFIER)

    inst.soundsname = "walani"
    inst.talker_path_override = "ia/characters/"
end

return MakePlayerCharacter("walani", prefabs, assets, common_postinit, master_postinit, start_inv)
