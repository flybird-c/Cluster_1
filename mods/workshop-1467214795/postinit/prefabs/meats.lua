
local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local function packimfish(inst)
    inst:AddTag("packimfood")

    if TheWorld.ismastersim then

        if inst.components.tradable then
            inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
        end
        
        inst:AddComponent("appeasement")
        inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL
        
    end
end
IAENV.AddPrefabPostInit("fishmeat_small", packimfish)
IAENV.AddPrefabPostInit("fishmeat_small_cooked", packimfish)
IAENV.AddPrefabPostInit("fishmeat", packimfish)
IAENV.AddPrefabPostInit("fishmeat_cooked", packimfish)
