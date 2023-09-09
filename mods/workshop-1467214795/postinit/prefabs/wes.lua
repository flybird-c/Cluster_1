local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("wes", function(inst)

    if TheWorld.ismastersim then
        inst.components.workmultiplier:AddMultiplier(ACTIONS.HACK, TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
        inst.components.efficientuser:AddMultiplier(ACTIONS.HACK,   TUNING.WES_WORKEFFECTIVENESS_MODIFIER, inst)
    end 

end)