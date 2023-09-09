local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local POSSIBLE_VARIANTS = require("prefabs/visualvariant_defs").POSSIBLE_VARIANTS
local VISUALVARIANT_PREFABS = require("prefabs/visualvariant_defs").VISUALVARIANT_PREFABS

local function setupfn() -- Allow others to override us
    for name,variants in pairs(POSSIBLE_VARIANTS) do
        VISUALVARIANT_PREFABS[name] = {}
        for variant,data in pairs(variants) do
            VISUALVARIANT_PREFABS[name][variant] = gemrun("getspecialprefab", name, function(prefab)
                if prefab.components.visualvariant ~= nil then
                    prefab.components.visualvariant:Set(variant)
                end
            end)
        end
    end
end

----------------------------------------------------------------------------------------

local function fn(inst)
	if TheWorld.ismastersim then
		if not inst.components.visualvariant then
			inst:AddComponent("visualvariant")
		end
	end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddSimPostInit(setupfn)

for k,v in pairs(POSSIBLE_VARIANTS) do
	IAENV.AddPrefabPostInit(k, fn)
end
