local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

IAENV.AddPrefabPostInit("sewing_tape", function(inst)
    if TheWorld.ismastersim then
        inst:AddComponent("repairer")
        inst.components.repairer.healthrepairvalue = TUNING.TRUSTY_TAPE_BOAT_HEALING
        inst.components.repairer.repairmaterial = "boat"
    end
end)
