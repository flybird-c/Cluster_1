local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local function packimfish(inst)
    inst:AddTag("packimfood")

    if TheWorld.ismastersim then

        if inst.components.tradable then
            inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
        end
        
        inst:AddComponent("appeasement")
        inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_MEDIUM
        
    end
end
IAENV.AddPrefabPostInit("wobster_sheller_dead", packimfish)
IAENV.AddPrefabPostInit("wobster_sheller_dead_cooked", packimfish)
IAENV.AddPrefabPostInit("wobster_sheller_land", packimfish)
IAENV.AddPrefabPostInit("wobster_moonglass_land", packimfish)
