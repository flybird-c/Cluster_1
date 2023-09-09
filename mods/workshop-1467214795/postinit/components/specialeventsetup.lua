local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

IAENV.AddComponentPostInit("specialeventsetup", function(cmp)

    function cmp:_IslandSetupYearOfTheCatcoon()
        print("[YOT Catcoon] [Island Ver] Setting up for the event.")

        local emergency_hidingspot_prefabs = {"rocks", "twigs", "cutgrass", "log", "bamboo", "vine"}
    
        local HIDINGSPOT_NO_TAGS = {"fire", "wall", "INLIMBO", "no_hideandseek", "locomotor"}
        local HIDINGSPOT_TAGS = {"pickable", "structure", "plant"}
    
        local kitten_hiding_data =
        {
            kitcoon_forest     = { biome_name = "JungleMarsh",           fallback_prefab = "jungletree_short",       hiding_spot_all_tags = {"jungletree"},    hiding_spot_notags = {"monster", "fire"},          hiding_spot_some_tags = nil,                                     hiding_spot_fn = nil},
            kitcoon_savanna    = { biome_name = "SharkHome",             fallback_prefab = "grass",                  hiding_spot_all_tags = {"plant"},         hiding_spot_notags = {"fire"},                     hiding_spot_some_tags = nil,                                     hiding_spot_fn = nil},
            kitcoon_deciduous  = { biome_name = "IslandParadise",        fallback_prefab = "rock2",                  hiding_spot_all_tags = {"plant"},         hiding_spot_notags = {"monster", "fire", "tree"},  hiding_spot_some_tags = nil,                                     hiding_spot_fn = nil},
            kitcoon_marsh      = { biome_name = "Marshy",                fallback_prefab = "reeds",                  hiding_spot_all_tags = {"plant"},         hiding_spot_notags = {"fire"},                     hiding_spot_some_tags = nil,                                     hiding_spot_fn = nil},
            kitcoon_grass      = { biome_name = "MeadowBeeQueenIsland",  fallback_prefab = "flower",                 hiding_spot_all_tags = {"flower"},        hiding_spot_notags = nil,                          hiding_spot_some_tags = nil,                                     hiding_spot_fn = nil},
            kitcoon_rocky      = { biome_name = "IslandRockyTallJungle", fallback_prefab = "rock2",                  hiding_spot_all_tags = nil,               hiding_spot_notags = nil,                          hiding_spot_some_tags = {"magmarock", "magmarock_gold"},         hiding_spot_fn = nil},
            kitcoon_desert     = { biome_name = "DesertIsland",          fallback_prefab = "palmtree_short",         hiding_spot_all_tags = nil,               hiding_spot_notags = nil,                          hiding_spot_some_tags = {"sanddune", "palmtree", "limpet_rock"}, hiding_spot_fn = nil},
            kitcoon_moon       = { biome_name = "IslandCasino",          fallback_prefab = "dubloon",                hiding_spot_all_tags = nil,               hiding_spot_notags = {"fire"},                     hiding_spot_some_tags = nil,                                     hiding_spot_fn = function(obj) return obj.prefab == "dubloon" end},
        }
    
        -- TODO: add a hook for modders to add/modify kitten_hiding_data and emergency_hidingspot_prefabs
        
    
        -- remove all the existing kitcoons in the world, its far easier than trying to reuse existing ones
        local collected_kitcoons = { kitcoons = {} }
        TheWorld:PushEvent("ms_collectallkitcoons", collected_kitcoons)
        for _, kitcoon in ipairs(collected_kitcoons.kitcoons) do
            kitten_hiding_data[kitcoon.prefab] = nil
            print("[YOT Catcoon] Using existing kitcoon '"..tostring(kitcoon).."'.")
        end
    
        for prefab, data in pairs(kitten_hiding_data) do
            if data.kitcoon == nil then
                data.kitcoon = SpawnPrefab(prefab)
                print("[YOT Catcoon] Adding new kitcoon '"..tostring(data.kitcoon).."'.")
            end
        end
    
        for kit_prefab, data in pairs(kitten_hiding_data) do
            if data.kitcoon ~= nil then
                self:_yotcatcoon_HideKitcoon(data, emergency_hidingspot_prefabs)
            end
        end
    end

    local _SetupNewSpecialEvent = cmp.SetupNewSpecialEvent
    function cmp:SetupNewSpecialEvent(event, ...)
        if not event then return _SetupNewSpecialEvent(self, event, ...) end

        if TheWorld:HasTag("island") then
            if event == SPECIAL_EVENTS.YOT_CATCOON then
                self:_IslandSetupYearOfTheCatcoon()
            else
                return _SetupNewSpecialEvent(self, event, ...)
            end

            -- for mod support
            TheWorld:PushEvent("ms_setupspecialevent", event)
        else
            return _SetupNewSpecialEvent(self, event, ...)
        end
    end
end)