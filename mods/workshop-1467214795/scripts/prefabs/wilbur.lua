local MakePlayerCharacter = require("prefabs/player_common")

local assets = 
{
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
	Asset("ANIM", "anim/wilbur.zip"),
	Asset("ANIM", "anim/player_monkeyking_run.zip"),
	Asset("ANIM", "anim/ghost_wilbur_build.zip"),

	Asset("SOUND", "sound/ia_wilbur.fsb")
}

local prefabs = {
    "guano_wilbur",
}

local function IsWhitelisted(string)
    return STRINGS.CHARACTERS.WILBUR ~= nil and STRINGS.CHARACTERS.WILBUR._WHITELIST ~= nil and STRINGS.CHARACTERS.WILBUR._WHITELIST[string]
end

local function Wilburify(inst, string)
    if inst:HasTag("playerghost") or IsWhitelisted(string) then
        return string
    else
        return CraftMonkeyKingSpeech()
    end
end

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WONKEY
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local function oneat(inst, food)
	if food ~= nil and (food.prefab == "cave_banana" or food.prefab == "cave_banana_cooked") and inst.components.sanity then
		inst.components.sanity:DoDelta(TUNING.SANITY_SMALL)
	end
end

local function onbecamehuman(inst)
	inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED + TUNING.WILBUR_WALK_SPEED_PENALTY
	inst.components.periodicspawner:SetPrefab("poop")
end

local function onbecameghost(inst)
	inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
	inst.components.periodicspawner:SetPrefab("guano_wilbur")
end

local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
end

local function common_postinit(inst)
	inst.MiniMapEntity:SetIcon( "wilbur.tex" )
	inst:AddTag("wilbur")
	inst:AddTag("monkey")
    inst:AddTag("monkeyking")
	inst:AddTag("poopthrower")
	inst:AddTag("MONKEY_curseimmune")

    inst.components.talker.mod_str_fn = function(...) return Wilburify(inst, ...) end
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default



    inst.components.foodaffinity:AddPrefabAffinity("cave_banana", TUNING.AFFINITY_15_CALORIES_SMALL)
	inst.components.foodaffinity:AddPrefabAffinity("cave_banana_cooked", TUNING.AFFINITY_15_CALORIES_SMALL)

    -- inst.customidleanim = "idle_wilbur"
	inst.soundsname = "wilbur"
	inst.talker_path_override = "ia/characters/"

    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED + TUNING.WILBUR_WALK_SPEED_PENALTY

    --inst:DoTaskInTime(0,function() --unused dst code?
    --    if TheWorld.components.piratespawner then
    --    end
    --end)

	inst.components.health:SetMaxHealth(TUNING.WILBUR_HEALTH)
	inst.components.hunger:SetMax(TUNING.WILBUR_HUNGER)
	inst.components.sanity:SetMax(TUNING.WILBUR_SANITY)

	inst.components.eater:SetOnEatFn(oneat)

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("poop")
    inst.components.periodicspawner:SetRandomTimes(TUNING.TOTAL_DAY_TIME * 2, TUNING.SEG_TIME * 2)
    inst.components.periodicspawner:Start()

	inst.OnLoad = onload
	inst.OnNewSpawn = onload
end

return MakePlayerCharacter("wilbur", prefabs, assets, common_postinit, master_postinit)
