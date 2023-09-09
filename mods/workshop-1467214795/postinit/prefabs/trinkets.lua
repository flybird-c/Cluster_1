local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function makepostinitfn(dubloonvalue)
	dubloonvalue = dubloonvalue or 3
	return function(inst)
		if inst.components.tradable then
			inst.components.tradable.dubloonvalue = dubloonvalue
		end
	end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

for i = 1, NUM_TRINKETS do
	IAENV.AddPrefabPostInit("trinket_".. i, makepostinitfn(TUNING.DUBLOON_VALUES.TRINKETS[i]))
end
