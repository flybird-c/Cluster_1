local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("antliontrinket", function(inst)
    if TheWorld.ismastersim then
        inst:AddTag("beachtoy")
        inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.BEACHTOY
    end
end)
