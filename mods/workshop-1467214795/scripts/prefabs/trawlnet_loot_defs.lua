
local chance =
{
    verylow = 1,
    low = 2,
    medium = 4,
    high = 8,
}

-- Normal loot;
local TROPICAL_LOOT = {
    shallow = {
        {"roe", chance.medium},
        {"seaweed", chance.high},
        {"mussel", chance.medium},
        {"lobster", chance.low},
        {"jellyfish", chance.low},
        {"pondfish", chance.medium},
        {"coral", chance.medium},
        {"ia_messagebottleempty", chance.medium},
        {"fishmeat", chance.low},
        {"rocks", chance.high},
        {"saltrock", chance.high},
    },

    medium =
    {
        {"roe", chance.medium},
        {"seaweed", chance.high},
        {"mussel", chance.high},
        {"lobster", chance.low},
        {"jellyfish", chance.medium},
        {"pondfish", chance.high},
        {"coral", chance.high},
        {"fishmeat", chance.medium},
        {"ia_messagebottleempty", chance.medium},
        {"boneshard", chance.medium},
        {"spoiled_fish_large", chance.medium},
        {"dubloon", chance.low},
        {"goldnugget", chance.low},
        {"telescope", chance.verylow},
        {"firestaff", chance.verylow},
        {"icestaff", chance.verylow},
        {"panflute", chance.verylow},
        {"trinket_ia_16", chance.low},
        {"trinket_ia_17", chance.medium},
        {"trinket_ia_18", chance.verylow},
        {"saltrock", chance.high},
    },

    deep =
    {
        {"roe", chance.low},
        {"seaweed", chance.high},
        {"mussel", chance.high},
        {"lobster", chance.low},
        {"jellyfish", chance.high},
        {"pondfish", chance.high},
        {"coral", chance.high},
        {"fishmeat", chance.high},
        {"ia_messagebottleempty", chance.medium},
        {"boneshard", chance.medium},
        {"spoiled_fish_large", chance.medium},
        {"dubloon", chance.medium},
        {"goldnugget", chance.medium},
        {"telescope", chance.low},
        {"firestaff", chance.low},
        {"icestaff", chance.low},
        {"panflute", chance.low},
        {"redgem", chance.low},
        {"bluegem", chance.low},
        {"purplegem", chance.low},
        {"goldenshovel", chance.low},
        {"goldenaxe", chance.low},
        {"razor", chance.low},
        {"spear", chance.low},
        {"compass", chance.low},
        {"amulet", chance.verylow},
        {"trinket_ia_16", chance.low},
        {"trinket_ia_17", chance.low},
        {"trinket_ia_18", chance.verylow},
        {"ia_trident", chance.verylow},
        {"saltrock", chance.high},
    }
}

local HURRICANE_LOOT = {
    shallow =
    {

        {"roe", chance.medium},
        {"seaweed", chance.high},
        {"mussel", chance.medium},
        {"lobster", chance.medium},
        {"jellyfish", chance.medium},
        {"pondfish", chance.high},
        {"coral", chance.high},
        {"ia_messagebottleempty", chance.high},
        {"fishmeat", chance.medium},
        {"rocks", chance.high},
        {"dubloon", chance.low},
        {"trinket_ia_16", chance.low},
        {"trinket_ia_17", chance.low},
        {"saltrock", chance.high},
    },

    medium =
    {
        {"roe", chance.medium},
        {"seaweed", chance.high},
        {"mussel", chance.high},
        {"lobster", chance.medium},
        {"jellyfish", chance.high},
        {"pondfish", chance.high},
        {"coral", chance.high},
        {"fishmeat", chance.high},
        {"ia_messagebottleempty", chance.high},
        {"boneshard", chance.high},
        {"spoiled_fish_large", chance.high},
        {"dubloon", chance.medium},
        {"goldnugget", chance.medium},
        {"telescope", chance.low},
        {"firestaff", chance.low},
        {"icestaff", chance.low},
        {"panflute", chance.low},
        {"trinket_ia_16", chance.low},
        {"trinket_ia_17", chance.low},
        {"trinket_ia_18", chance.verylow},
        {"ia_trident", chance.verylow},
        {"saltrock", chance.high},
    },

    deep =
    {
        {"roe", chance.low},
        {"seaweed", chance.high},
        {"mussel", chance.high},
        {"lobster", chance.low},
        {"jellyfish", chance.high},
        {"pondfish", chance.high},
        {"coral", chance.high},
        {"fishmeat", chance.high},
        {"ia_messagebottleempty", chance.high},
        {"boneshard", chance.high},
        {"spoiled_fish_large", chance.high},
        {"dubloon", chance.medium},
        {"goldnugget", chance.medium},
        {"telescope", chance.medium},
        {"firestaff", chance.low},
        {"icestaff", chance.medium},
        {"panflute", chance.medium},
        {"redgem", chance.medium},
        {"bluegem", chance.medium},
        {"purplegem", chance.medium},
        {"goldenshovel", chance.medium},
        {"goldenaxe", chance.medium},
        {"razor", chance.medium},
        {"spear", chance.medium},
        {"compass", chance.medium},
        {"amulet", chance.verylow},
        {"trinket_ia_16", chance.medium},
        {"trinket_ia_17", chance.medium},
        {"trinket_ia_18", chance.verylow},
        {"ia_trident", chance.low},
        {"saltrock", chance.high},
    }
}

local DRY_LOOT = {
    shallow =
    {
        {"seaweed", chance.high},
        {"mussel", chance.high},
        {"lobster", chance.medium},
        {"jellyfish", chance.medium},
        {"pondfish", chance.high},
        {"coral", chance.high},
        {"ia_messagebottleempty", chance.high},
        {"fishmeat", chance.medium},
        {"rocks", chance.high},
        {"dubloon", chance.low},
        {"obsidian", chance.high},
        {"saltrock", chance.high},
    },

    medium =
    {
        {"seaweed", chance.high},
        {"mussel", chance.high},
        {"lobster", chance.medium},
        {"jellyfish", chance.high},
        {"pondfish", chance.high},
        {"coral", chance.high},
        {"fishmeat", chance.high},
        {"ia_messagebottleempty", chance.high},
        {"boneshard", chance.high},
        {"spoiled_fish_large", chance.high},
        {"dubloon", chance.medium},
        {"goldnugget", chance.medium},
        {"telescope", chance.low},
        {"firestaff", chance.medium},
        {"icestaff", chance.low},
        {"panflute", chance.low},
        {"obsidian", chance.medium},
        {"trinket_ia_16", chance.low},
        {"trinket_ia_17", chance.low},
        {"trinket_ia_18", chance.verylow},
        {"ia_trident", chance.verylow},
        {"saltrock", chance.high},
    },

    deep =
    {
        {"seaweed", chance.high},
        {"mussel", chance.high},
        {"lobster", chance.low},
        {"jellyfish", chance.high},
        {"pondfish", chance.high},
        {"coral", chance.high},
        {"fishmeat", chance.high},
        {"ia_messagebottleempty", chance.high},
        {"boneshard", chance.high},
        {"spoiled_fish_large", chance.high},
        {"dubloon", chance.medium},
        {"goldnugget", chance.medium},
        {"telescope", chance.medium},
        {"firestaff", chance.medium},
        {"icestaff", chance.low},
        {"panflute", chance.medium},
        {"redgem", chance.medium},
        {"bluegem", chance.medium},
        {"purplegem", chance.medium},
        {"goldenshovel", chance.medium},
        {"goldenaxe", chance.medium},
        {"razor", chance.medium},
        {"spear", chance.medium},
        {"compass", chance.medium},
        {"amulet", chance.verylow},
        {"obsidian", chance.medium},
        {"trinket_ia_16", chance.low},
        {"trinket_ia_17", chance.low},
        {"trinket_ia_18", chance.verylow},
        {"ia_trident", chance.low},
        {"saltrock", chance.high},
    }
}

-- Porkland loot;
local LILYPOND_LOOT = {
    shallow = {
        -- { "cutreeds", chance_high },
        -- { "cutgrass", chance_high },
        -- { "twigs", chance_high },
        -- { "rocks", chance_high },
        -- { "log", chance_high },
        -- { "fish", chance_high },
        -- { "lotus_flower", chance_medium },
        -- { "rottenegg", chance_medium },
        -- { "oinc", chance_medium },
        -- { "iron", chance_medium },
        -- { "spoiled_fish_large", chance_medium },
        -- { "bill_quill", chance_medium },
        -- { "boneshard", chance_medium },
        -- { "goldnugget", chance_low },
        -- { "fabric", chance_low },
        -- { "goldenshovel", chance_low },
        -- { "goldenaxe", chance_low },
        -- { "disarming_kit", chance_low },
        -- { "shears", chance_low },
        -- { "trinket_17", chance_low },
        -- { "oinc10", chance_low },
        -- { "redgem", chance_verylow },
        -- { "bluegem", chance_verylow },
        -- { "purplegem", chance_verylow },
        -- { "amulet", chance_verylow },
        -- { "relic_1", chance_verylow },
        -- { "relic_2", chance_verylow },
        -- { "relic_3", chance_verylow },
        -- { "trinket_giftshop_1", chance_verylow },
        -- { "trinket_giftshop_3", chance_verylow },
        -- { "trinket_18", chance_verylow },
    },
    medium = {},
    deep = {},
}

-- Forest loot:
local RETURNOFTHEM_LOOT = {
    shallow =
    {
        {"slurtle_shellpieces", chance.medium},
        {"kelp", chance.high},
        {"barnacle", chance.high},
        {"wobster_sheller_land", chance.medium},
        {"malbatross_feather", chance.medium},
        {"driftwood_log", chance.high},
        {"cookiecuttershell", chance.high},
        {"messagebottleempty", chance.high},
        {"fishmeat", chance.medium},
        {"rocks", chance.high},
        {"moonglass", chance.low},
        {"saltrock", chance.high},
    },
    
    
    medium =
    {
        {"slurtle_shellpieces", chance.medium},
        {"kelp", chance.high},
        {"barnacle", chance.high},
        {"wobster_sheller_land", chance.medium},
        {"malbatross_feather", chance.high},
        {"driftwood_log", chance.high},
        {"cookiecuttershell", chance.high},
        {"fishmeat", chance.high},
        {"messagebottleempty", chance.high},
        {"boneshard", chance.high},
        {"spoiled_fish", chance.high},
        {"moonglass", chance.medium},
        {"goldnugget", chance.medium},
        {"cannonball_rock_item", chance.low},
        {"waterplant_bomb", chance.medium},
        {"pocket_scale", chance.low},
        {"panflute", chance.low},
        {"trinket_8", chance.low},
        {"trinket_17", chance.low},
        {"gnarwail_horn", chance.low},
        {"trident", chance.verylow},
        {"saltrock", chance.high},
    },
    
    deep =
        {
        {"slurtle_shellpieces", chance.low},
        {"kelp", chance.high},
        {"barnacle", chance.high},
        {"wobster_sheller_land", chance.low},
        {"malbatross_feather", chance.high},
        {"driftwood_log", chance.high},
        {"cookiecuttershell", chance.high},
        {"fishmeat", chance.high},
        {"messagebottleempty", chance.high},
        {"boneshard", chance.high},
        {"spoiled_fish", chance.high},
        {"moonglass", chance.medium},
        {"goldnugget", chance.medium},
        {"cannonball_rock_item", chance.medium},
        {"waterplant_bomb", chance.medium},
        {"pocket_scale", chance.low},
        {"panflute", chance.medium},
        {"redgem", chance.medium},
        {"bluegem", chance.medium},
        {"purplegem", chance.medium},
        {"yellowgem", chance.verylow},
        {"greengem", chance.verylow},
        {"orangegem", chance.verylow},
        {"bathbomb", chance.low},
        {"chum", chance.low},
        {"dug_trap_starfish", chance.verylow},
        {"trinket_8", chance.low},
        {"trinket_17", chance.low},
        {"gnarwail_horn", chance.low},
        {"trident", chance.verylow},
        {"saltrock", chance.high},
    }
}

-- Don't collect more than one of these.
local UNIQUE_ITEMS = {
    "trinket_ia_16",
    "trinket_ia_17",
    "trinket_ia_18",
    "ia_trident",
    -- "relic_1",
    -- "relic_2",
    -- "relic_3",
    -- "trinket_giftshop_1",
    -- "trinket_giftshop_3",
    "trinket_8",
    "trinket_17",
    "trident",
}

local SPECIAL_CASE_PREFABS = {
    seaweed_planted = function(inst, net)
        if inst and inst.components.pickable then
            if inst.components.pickable.canbepicked
                and inst.components.pickable.caninteractwith then
                net:pickupitem(SpawnPrefab(inst.components.pickable.product))
            end

            inst:Remove()
            return SpawnPrefab("seaweed_stalk")
        end
    end,

    jellyfish_planted = function(inst)
        inst:Remove()
        return SpawnPrefab("jellyfish")
    end,

    rainbowjellyfish_planted = function(inst) --Note: Not in SW
        inst:Remove()
        return SpawnPrefab("rainbowjellyfish")
    end,

    mussel_farm = function(inst, net)
        if inst then
            if inst.growthstage <= 0 then
                inst:Remove()
                return SpawnPrefab(inst.components.pickable.product)
            end
        end
    end,

    sunkenprefab = function(inst)
        local record = inst.components.sunkenprefabinfo:GetSunkenPrefab()
		if not record or not record.prefab then record = {prefab = ""} end --prevent crash from missing record
        local sunken = SpawnSaveRecord(record)
		if sunken and sunken:IsValid() then --might be nil if the thing is a prefab from a no-longer-enabled mod
			sunken:LongUpdate(inst.components.sunkenprefabinfo:GetTimeSubmerged() or 0)
		end
        inst:Remove()
        return sunken and sunken:IsValid() and sunken
    end,

    lobster = function(inst)
        return inst
    end,

    bioluminescence = function(inst)
        return inst
    end,

    bullkelp_plant = function(inst, net)
        if inst and inst.components.pickable then
            if inst.components.pickable.canbepicked
                and inst.components.pickable.caninteractwith then
                net:pickupitem(SpawnPrefab(inst.components.pickable.product))
            end

            inst:Remove()
            return SpawnPrefab("bullkelp_root")
        end
    end,
}

-- Made this public for easier modding -Half
local function GetLootTable(inst)
    local _world = TheWorld

    if _world:HasTag("island") or _world:HasTag("volcano") then
        if _world.state.iswinter then
            return HURRICANE_LOOT
        elseif _world.state.issummer then
            return DRY_LOOT
        else
            return TROPICAL_LOOT
        end
    elseif _world:HasTag("porkland") then
        return LILYPOND_LOOT
    end
    -- Safer to default to rot loot
    return RETURNOFTHEM_LOOT
end

return {
    TROPICAL_LOOT        = TROPICAL_LOOT,
    HURRICANE_LOOT       = HURRICANE_LOOT,
    DRY_LOOT             = DRY_LOOT,
    LILYPOND_LOOT        = LILYPOND_LOOT,
    RETURNOFTHEM_LOOT    = RETURNOFTHEM_LOOT,
    UNIQUE_ITEMS         = UNIQUE_ITEMS,
    SPECIAL_CASE_PREFABS = SPECIAL_CASE_PREFABS,

    GetLootTable = GetLootTable
}
