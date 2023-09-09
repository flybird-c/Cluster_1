local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

IAENV.AddPrefabPostInit("spicepack", function(inst)
    if IA_CONFIG.oldwarly then
        if inst:HasTag("foodpreserver") then
            inst:RemoveTag("foodpreserver")
        end
        inst:AddTag("fridge")
    end
end)
