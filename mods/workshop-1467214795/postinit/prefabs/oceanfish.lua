local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local SPOIL_FISH = table.invert({
    "oceanfish_small_5_inv",
    "oceanfish_medium_5_inv",
})

local FISH = {
    "oceanfish_small_1_inv",
    "oceanfish_small_2_inv",
    "oceanfish_small_3_inv",
    "oceanfish_small_4_inv",
    "oceanfish_small_5_inv",
    "oceanfish_small_6_inv",
    "oceanfish_small_7_inv",
    "oceanfish_small_8_inv",
    "oceanfish_small_9_inv",
    "oceanfish_medium_1_inv",
    "oceanfish_medium_2_inv",
    "oceanfish_medium_3_inv",
    "oceanfish_medium_4_inv",
    "oceanfish_medium_5_inv",
    "oceanfish_medium_6_inv",
    "oceanfish_medium_7_inv",
    "oceanfish_medium_8_inv",
    "oceanfish_medium_9_inv",
}

local function packimfish(inst)
    if not SPOIL_FISH[inst.prefab] then
        inst:AddTag("packimfood")
    else
        inst:AddTag("spoiledbypackim")
    end

    if TheWorld.ismastersim then

        if inst.components.tradable then
            inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
        end
        
        inst:AddComponent("appeasement")
        inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL
        
    end
end

for i,v in pairs(FISH) do
    IAENV.AddPrefabPostInit(v, packimfish)
end
