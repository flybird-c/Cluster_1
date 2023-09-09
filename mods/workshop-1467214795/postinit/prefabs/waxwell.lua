local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("waxwell", function(inst)
    
    if not TheWorld.ismastersim then
        return 
    end

    inst.components.foodaffinity:AddPrefabAffinity("wobsterdinner", TUNING.AFFINITY_15_CALORIES_LARGE)

end)