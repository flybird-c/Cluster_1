local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
	Asset("SOUNDPACKAGE", "sound/ia_warly.fsb"),
	Asset("ANIM", "anim/warly.zip"),
	Asset("ANIM", "anim/ghost_warly_build.zip"),
}
local prefabs = {
	"spicepack",
	"portablecookpot_item",
}

-- Custom starting items
local start_inv = {
	-- "spicepack", --does not spawn properly, check onnewspawn
	"portablecookpot_item",
}


local function refresh_consumed_foods(inst)
	local to_remove = {}
	local timetonext
	for k,v in pairs(inst.consumed_foods) do
		if GetTime() >= v.time_of_reset then
			table.insert(to_remove, k)
		else
			timetonext = math.min(timetonext or TUNING.WARLY_IA_SAME_OLD_COOLDOWN, v.time_of_reset - GetTime()) 
		end
	end

	for k,v in pairs(to_remove) do
		inst.consumed_foods[v] = nil
	end

	if inst.refreshfoodstask then
		inst.refreshfoodstask:Cancel()
	end
	if timetonext then
		inst.refreshfoodstask = inst:DoTaskInTime(timetonext, refresh_consumed_foods)
	else
		inst.refreshfoodstask = nil
	end
end

local function wisecrack(inst, foodstate)
	if foodstate and inst and inst.components.talker and not inst.components.talker.task then
		inst.components.talker:Say(GetString(inst, "ANNOUNCE_EAT", foodstate))
	end
end

local function oneatpre(inst, data)
	local s = 1
	local foodstate
	if data and data.food and data.food.components.edible then
		if data.food:HasTag("preparedfood") then
			--repeat meal penalty
			local prefab = data.food.prefab
			if prefab:sub(-8) == "_gourmet" then
				prefab = prefab:sub(1, -9)
			end
			if inst.consumed_foods[prefab] then
				local stage = math.min(inst.consumed_foods[prefab].count or 1, #TUNING.WARLY_IA_SAME_OLD_MULTIPLIERS)
				s = TUNING.WARLY_IA_SAME_OLD_MULTIPLIERS[stage]
				foodstate = "SAME_OLD_".. stage
			else
				inst.consumed_foods[prefab] = {}
				if prefab == "monstertartare" or prefab == "freshfruitcrepes" then
					foodstate = "TASTY"
				else
					foodstate = "PREPARED"
				end
			end
			if prefab == "wetgoop" then
				foodstate = "PAINFUL"
			end
			inst.consumed_foods[prefab].count = (inst.consumed_foods[prefab].count or 0) + 1
			inst.consumed_foods[prefab].time_of_reset = GetTime() + TUNING.WARLY_IA_SAME_OLD_COOLDOWN
			refresh_consumed_foods(inst)
		elseif data.food.components.edible.foodstate == "COOKED" or string.find(data.food.prefab, "cooked") then
			s = TUNING.WARLY_IA_MULT_COOKED
			foodstate = "COOKED"
		elseif data.food.components.edible.foodstate == "DRIED" or string.find(data.food.prefab, "dried") then
			s = TUNING.WARLY_IA_MULT_DRIED
			foodstate = "DRIED"
		else
			s = TUNING.WARLY_IA_MULT_RAW
			foodstate = "RAW"
		end
	end
	-- print("warly eatmultiplier:",s)
	inst.components.eater:SetAbsorptionModifiers(s, s, s)
	inst:DoTaskInTime(0,wisecrack,foodstate)
end

local function onlongupdate(inst, dt)
	for k,v in pairs(inst.consumed_foods) do
		v.time_of_reset = v.time_of_reset - dt
	end
	refresh_consumed_foods(inst)
end

-- When the character is revived from ghost
-- local function onbecamehuman(inst)
-- end

-- local function onbecameghost(inst)
-- end

-- When loading or spawning the character
local function onload(inst, data)
	-- inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
	-- inst:ListenForEvent("ms_becameghost", onbecameghost)

	-- if inst:HasTag("playerghost") then
		-- onbecameghost(inst)
	-- else
		-- onbecamehuman(inst)
	-- end
	
	if data and data.consumed_foods then
		inst.consumed_foods = data.consumed_foods
		refresh_consumed_foods(inst) --kick the timer off
	end
end
local function onsave(inst, data)
	refresh_consumed_foods(inst) --clean up first
	local consumed_foods = {}
	for k,v in pairs(inst.consumed_foods) do
		consumed_foods[k] = {}
		consumed_foods[k].count = v.count
		consumed_foods[k].time_of_reset = v.time_of_reset - GetTime()
	end
	data.consumed_foods = consumed_foods
end

local function onnewspawn(inst)
	onload(inst)
	-- inst:DoTaskInTime(1,function()
		-- inst.components.inventory:GiveItem(SpawnAt("spicepack",inst))
	-- end)
	inst.components.inventory:Equip(SpawnAt("spicepack",inst))
end



local common_postinit = function(inst) 
	inst.MiniMapEntity:SetIcon( "warly.tex" )
	inst:AddTag("warly")
end

local master_postinit = function(inst)
	-- choose which sounds this character will play
	inst.soundsname = "warly"
	inst.talker_path_override = "ia/characters/"
	
	-- inst.components.health:SetMaxHealth(150)
	inst.components.hunger:SetMax(TUNING.WARLY_HUNGER)
	-- inst.components.sanity:SetMax(200)
	
	inst.components.hunger.burnratemodifiers:SetModifier(inst, TUNING.WARLY_IA_HUNGER_RATE_MODIFIER, "warly")
	
	inst:ListenForEvent("oneatpre", oneatpre)
	
	inst.consumed_foods = {}
	
	inst.OnSave = onsave
	inst.OnLoad = onload
	inst.OnNewSpawn = onnewspawn
	inst.OnLongUpdate = onlongupdate
	
end

return MakePlayerCharacter("warly", prefabs, assets, common_postinit, master_postinit, start_inv)
