local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("balloonvest", function(inst)
    if TheWorld.ismastersim then
        inst.components.inventoryitem.keepondeath = true
        inst.components.equippable.preventdrowning = true
        inst:ListenForEvent("preventdrowning", inst.Remove) 
    end
end)
