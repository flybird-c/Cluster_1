local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

if not IA_CONFIG.oldwarly then return end

local onnewspawn_old
local function onnewspawn(inst,...)
	inst.components.inventory:Equip(SpawnAt("spicepack",inst))

	if onnewspawn_old then return onnewspawn_old(inst,...) end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("warly", function(inst)
	if TheWorld.ismastersim then
		if inst.components.hunger ~= nil then
			inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE * TUNING.WARLY_IA_HUNGER_RATE_MODIFIER)	
		end
		if inst.components.eater ~= nil then
			--Damnit Klei stop screwing with this stuff. -M
			if inst.components.eater.preferseatingtags ~= nil then
				for i = #inst.components.eater.preferseatingtags, 1, -1 do
					if inst.components.eater.preferseatingtags[i] == "preparedfood"
					or inst.components.eater.preferseatingtags[i] == "pre-preparedfood" then
						inst.components.eater.preferseatingtags[i] = nil
					end
				end
				if #inst.components.eater.preferseatingtags == 0 then
					inst.components.eater.preferseatingtags = nil
				end
			else
				inst.components.eater:SetPrefersEatingTag(nil)
			end
		end
		if inst.components.foodmemory ~= nil then
			inst.components.foodmemory:SetDuration(TUNING.WARLY_IA_SAME_OLD_COOLDOWN)
			inst.components.foodmemory:SetMultipliers(TUNING.WARLY_IA_SAME_OLD_MULTIPLIERS)
			inst.components.foodmemory.restricttag = "preparedfood"
			inst.components.foodmemory.rawmult = TUNING.WARLY_IA_MULT_RAW
			inst.components.foodmemory.cookedmult = TUNING.WARLY_IA_MULT_COOKED
			inst.components.foodmemory.driedmult = TUNING.WARLY_IA_MULT_DRIED
		end
		if not onnewspawn_old then
			onnewspawn_old = inst.OnNewSpawn
		end
		inst.OnNewSpawn = onnewspawn
	end
end)
