local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function makepostinitfn(rainrate, floodrate, windrate)
	local updatefn_old
	local function updatefn(inst)
		if IsInIAClimate(inst) then
			inst.components.fueled.rate = 1
				+ rainrate * TheWorld.state.islandprecipitationrate
				+ (inst:HasTag("flooded") and floodrate or 0)
				+ windrate * ((inst.components.whirlspeed_adjustable and inst.components.whirlspeed_adjustable:IsSpeedAdjusted() and (TheWorld.state.gustspeed * TUNING.SAILSTICK_BONUSSPEEDMULT)) or TheWorld.state.gustspeed)
		else
			updatefn_old(inst)
		end
	end

	----------------------------------------------------------------------------------------

	return function(inst)
		inst:AddComponent("floodable")

		if TheWorld.ismastersim then

			inst.components.floodable:SetFX(nil, .5) --update faster
			if inst.components.fueled and inst.components.fueled.updatefn then
				updatefn_old = inst.components.fueled.updatefn
				inst.components.fueled.updatefn = updatefn
				--We should be editing sectionfn too, but that's just one update period (a second) per section.
			end
		else
			--allow the sailstick to modify the windspeed if nearby
			inst:AddComponent("whirlspeed_adjustable")
		end
	end
end


IAENV.AddPrefabPostInit("campfire", makepostinitfn(TUNING.CAMPFIRE_RAIN_RATE, TUNING.CAMPFIRE_FLOOD_RATE, TUNING.CAMPFIRE_WIND_RATE))
IAENV.AddPrefabPostInit("firepit", makepostinitfn(TUNING.FIREPIT_RAIN_RATE, TUNING.CAMPFIRE_FLOOD_RATE, TUNING.CAMPFIRE_WIND_RATE))
IAENV.AddPrefabPostInit("coldfire", makepostinitfn(TUNING.COLDFIRE_RAIN_RATE, TUNING.COLDFIRE_FLOOD_RATE, TUNING.COLDFIRE_WIND_RATE))
IAENV.AddPrefabPostInit("coldfirepit", makepostinitfn(TUNING.COLDFIREPIT_RAIN_RATE, TUNING.COLDFIRE_FLOOD_RATE, TUNING.COLDFIRE_WIND_RATE))