local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

--set it in any.lua if they have a common tag between them otherwise do it here
local poisonimmune_postinit = {
	"bernie_active",
	"bernie_big",
	"ivy_snare",
	"lunarthrall_plant",
	"eyeturret",
	"moonstorm_static",
}

local function fn(inst)
    inst:AddTag("poisonimmune")
end

for i,prefab in pairs(poisonimmune_postinit) do
    IAENV.AddPrefabPostInit(prefab, fn)
end
