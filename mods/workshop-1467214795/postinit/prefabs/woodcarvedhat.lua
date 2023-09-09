local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

IAENV.AddPrefabPostInit("woodcarvedhat", function(inst)
    if TheWorld.ismastersim then
        if inst.components.resistance then
            inst.components.resistance:AddResistance("coconut")
        end
    end
end)
