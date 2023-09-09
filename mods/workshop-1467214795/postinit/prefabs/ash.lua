local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("ash", function(inst)
    if TheWorld.ismastersim then
    	inst:AddComponent("fertilizer")
    	inst.components.fertilizer.fertilizervalue = TUNING.POOP_FERTILIZE
    	inst.components.fertilizer.soil_cycles = TUNING.POOP_SOILCYCLES
    	inst.components.fertilizer.withered_cycles = TUNING.POOP_WITHEREDCYCLES
    	inst.components.fertilizer:MakeVolcanic()
    end
end)
