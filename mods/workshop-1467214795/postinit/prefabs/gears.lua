local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

IAENV.AddPrefabPostInit("gears", function(inst)
    if TheWorld.ismastersim then
        inst:AddComponent("fuel")
        inst.components.fuel.fueltype = FUELTYPE.MECHANICAL
        inst.components.fuel.fuelvalue = TUNING.TOTAL_DAY_TIME
    end
end)
