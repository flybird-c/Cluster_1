--[WARNING]: This file is imported into modclientmain.lua, be careful!
if not env.is_mim_enabled then
    FrontEndAssets = {
        Asset("IMAGE", "images/hud/customization_shipwrecked.tex"),
        Asset("ATLAS", "images/hud/customization_shipwrecked.xml"),
    }
    ReloadFrontEndAssets()

    modimport("main/strings")
end

local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local ImageButton = require("widgets/imagebutton")

local size_descriptions = IAENV.GetCustomizeDescription("size_descriptions")
local yesno_descriptions = IAENV.GetCustomizeDescription("yesno_descriptions")
local enableddisabled_descriptions = IAENV.GetCustomizeDescription("enableddisabled_descriptions")
local frequency_descriptions = IAENV.GetCustomizeDescription("frequency_descriptions")
local worldgen_frequency_descriptions = IAENV.GetCustomizeDescription("worldgen_frequency_descriptions")
local speed_descriptions = IAENV.GetCustomizeDescription("speed_descriptions")
local season_length_descriptions = IAENV.GetCustomizeDescription("season_length_descriptions")

-- TEMP: Remove once we add world prefabs
local tmp_enableddisabled_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.DISABLED, data = "none" },
    { text = "Auto", data = "auto" },
	{ text = STRINGS.UI.SANDBOXMENU.ENABLED, data = "always" },
}

--[[local islandquantity_descriptions = {
    { text = STRINGS.UI.SANDBOXMENU.BRANCHINGLEAST, data = "never" },
    { text = STRINGS.UI.SANDBOXMENU.SLIDERARE,      data = "rare" },
    { text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT,   data = "default" },
    { text = STRINGS.UI.SANDBOXMENU.SLIDEOFTEN,     data = "often" },
    { text = STRINGS.UI.SANDBOXMENU.BRANCHINGMOST,  data = "always" },
}]]

local worldtypes = {
    { text = STRINGS.UI.SANDBOXMENU.WORLDTYPE_DEFAULT,     data = "default" },
    -- { text = STRINGS.UI.SANDBOXMENU.WORLDTYPE_MERGED,      data = "merged" },
    { text = STRINGS.UI.SANDBOXMENU.WORLDTYPE_ISLANDSONLY, data = "islandsonly" },
    { text = STRINGS.UI.SANDBOXMENU.WORLDTYPE_VOLCANOONLY, data = "volcanoonly" },
}

local clocktypes = {
    { text = STRINGS.UI.SANDBOXMENU.CLOCKTYPE_DEFAULT,     data = "default" },
    { text = STRINGS.UI.SANDBOXMENU.CLOCKTYPE_SHIPWRECKED,      data = "tropical" },
    -- { text = STRINGS.UI.SANDBOXMENU.CLOCKTYPE_HAMLET,      data = "plateau" },
}

local LEVELCATEGORY = LEVELCATEGORY
local worldgen_atlas = "images/worldgen_customization.xml"
local ia_atlas = "images/hud/customization_shipwrecked.xml"

local function add_group_and_item(category, name, text, desc, atlas, order, items)
    if text then  -- assume that if the group has a text string its new
        IAENV.AddCustomizeGroup(category, name, text, desc, atlas or ia_atlas, order)
    end
    if items then
        for k, v in pairs(items) do
            IAENV.AddCustomizeItem(category, name, k, v)
        end
    end
end

local ia_customize_table = {

   --[[ adding setting to existing category:
    global = {
        category = LEVELCATEGORY.SETTINGS,
        items = {
            clocktype = { value = "default", enable = false, image = "blank_world.tex", atlas = ia_atlas, desc = clocktypes, order = 50, world = { "forest","cave" } },
        }
    },]]

    island_worldgen_misc = {
        order = 2.5,
        category = LEVELCATEGORY.WORLDGEN,
        text = STRINGS.UI.SANDBOXMENU.CUSTOMIZATIONPREFIX_IA..STRINGS.UI.SANDBOXMENU.CHOICEMISC,
        items = {
            primaryworldtype = { value = "default", image = "world_map.tex", atlas = worldgen_atlas, desc = worldtypes, world = { "forest","cave" } },
            --islandquantity   = { value = "default", image = "world_size.tex", atlas = worldgen_atlas, desc = size_descriptions, world = {"forest"} },
            volcano          = { value = "default", image = "volcano.tex", desc = yesno_descriptions, world = {"forest"} },
            --tides            = { value = "default", image = "tides.tex", desc = yesno_descriptions, world = {"forest"} },
            bermudatriangle  = { value = "default", image = "bermudatriangle.tex", desc = worldgen_frequency_descriptions, world = {"forest"} },
            volcanoisland    = { value = "none", image = "volcano.tex", desc = enableddisabled_descriptions, world = {"forest"} },
        }
    },

    island_worldgen_resources = {
        order = 3.5,
        category = LEVELCATEGORY.WORLDGEN,
        text = STRINGS.UI.SANDBOXMENU.CUSTOMIZATIONPREFIX_IA..STRINGS.UI.SANDBOXMENU.CHOICERESOURCES,
        desc = worldgen_frequency_descriptions,
        items = {
            sweet_potato        = { value = "default", image = "sweetpotatos.tex", world = {"forest"} },
            limpets             = { value = "default", image = "limpets.tex", world = {"forest"} },
            mussel_farm         = { value = "default", image = "mussels.tex", world = {"forest"} },
            seaweed             = { value = "default", image = "seaweed.tex", world = {"forest"} },
            seashell            = { value = "default", image = "seashell.tex", world = {"forest"} },
            bamboo              = { value = "default", image = "bamboo.tex", world = {"forest"} },
            bush_vine           = { value = "default", image = "vines.tex", world = {"forest"} },
            coral               = { value = "default", image = "coral.tex", world = {"forest"} },
            coral_brain_rock    = { value = "default", image = "braincoral.tex", world = {"forest"} },
            crate               = { value = "default", image = "crates.tex", world = {"forest"} },
            tidalpool           = { value = "default", image = "tidalpools.tex", world = {"forest"} },
            sandhill            = { value = "default", image = "sand.tex", world = {"forest"} },
            poisonhole          = { value = "default", image = "poisonhole.tex", world = {"forest"} },
            bioluminescence     = { value = "default", image = "bioluminescence.tex", world = {"forest"} },
            magma_rocks         = { value = "default", image = "magmarocks.tex", world = {"forest"} },
            tar_pool             = { value = "default", image = "tarpools.tex", world = {"forest"} },
        }
    },

    island_worldgen_animals = {
        order = 4,
        category = LEVELCATEGORY.WORLDGEN,
        text = STRINGS.UI.SANDBOXMENU.CUSTOMIZATIONPREFIX_IA..STRINGS.UI.SANDBOXMENU.WORLDGENERATION_ANIMALS,
        desc = worldgen_frequency_descriptions,
        items = {
            crabhole        = { value = "default", image = "crabbithole.tex", world = {"forest"} },
            ox              = { value = "default", image = "ox.tex", world = {"forest"} },
            doydoy          = { value = "default", image = "doydoy.tex", desc = yesno_descriptions, world = {"forest"} },
            wildbores       = { value = "default", image = "wildborehouse.tex", world = {"forest"} },
            ballphin        = { value = "default", image = "ballphinhouse.tex", world = {"forest"} },
            primeape        = { value = "default", image = "primeapehut.tex", world = {"forest"} },
            fishermerm      = { value = "default", image = "fishermermhouse.tex", world = {"forest"} },
            lobster         = { value = "default", image = "lobsterhole.tex", world = {"forest"} },
            solofish        = { value = "default", image = "dogfish.tex", world = {"forest"} },
            jellyfish       = { value = "default", image = "jellyfish.tex", world = {"forest"} },
            fishinhole      = { value = "default", image = "shoals.tex", world = {"forest"} },
            seagull         = { value = "default", image = "seagulls.tex", world = {"forest"} },
        }
    },

    island_worldgen_monsters = {
        order = 5,
        category = LEVELCATEGORY.WORLDGEN,
        text = STRINGS.UI.SANDBOXMENU.CUSTOMIZATIONPREFIX_IA..STRINGS.UI.SANDBOXMENU.WORLDGENERATION_HOSTILE_CREATURES,
        desc = worldgen_frequency_descriptions,
        items = {
            flup        = { value = "default", image = "flups.tex", world = {"forest"} },
            swordfish  = { value = "default", image = "swordfish.tex", world = {"forest"} },
            stungray   = { value = "default", image = "stinkrays.tex", world = {"forest"} },
        }
    },

    island_settings_global = {
        order = 0,
        category = LEVELCATEGORY.SETTINGS,
        text = STRINGS.UI.SANDBOXMENU.CUSTOMIZATIONPREFIX_IA..STRINGS.UI.SANDBOXMENU.CHOICEGLOBAL,
        items = {
            clocktype   = {value = "default", image = "blank_world.tex", desc = clocktypes, order = 1, world = { "forest","cave" } },
            mild        = {value = "default", image = "mild.tex", options_remap = {img = "blank_season_yellow.tex", atlas = "images/customisation.xml"}, desc = season_length_descriptions, order = 2, master_controlled = true},
            hurricane   = {value = "default", image = "hurricane.tex", options_remap = {img = "blank_season_yellow.tex", atlas = "images/customisation.xml"}, desc = season_length_descriptions, order = 3, master_controlled = true},
            monsoon     = {value = "default", image = "monsoon.tex", options_remap = {img = "blank_season_yellow.tex", atlas = "images/customisation.xml"}, desc = season_length_descriptions, order = 4, master_controlled = true},
            dry         = {value = "default", image = "dry.tex", options_remap = {img = "blank_season_yellow.tex", atlas = "images/customisation.xml"}, desc = season_length_descriptions, order = 5, master_controlled = true},
        }
    },

    island_settings_misc = {
        order = 3.5,
        category = LEVELCATEGORY.SETTINGS,
        text = STRINGS.UI.SANDBOXMENU.CUSTOMIZATIONPREFIX_IA..STRINGS.UI.SANDBOXMENU.CHOICEMISC,
        items = {
            poison           = {value = "default", image = "poison.tex", desc = yesno_descriptions, world = {"forest"}},
            floods           = {value = "default", image = "floods.tex", desc = frequency_descriptions, world = {"forest"}},
            dragoonegg       = {value = "default", image = "dragooneggs.tex", desc = frequency_descriptions, world = {"forest"}},
            oceanwaves       = {value = "default", image = "waves.tex", desc = frequency_descriptions, world = {"forest"}},
            whalehunt        = {value = "default", image = "whales.tex", desc = frequency_descriptions, world = {"forest"}},
            no_dst_boats     = {value = "auto", image = "cookieboats.tex", desc = tmp_enableddisabled_descriptions, order = 1, world = {"forest", "cave"}},
            has_ia_boats     = {value = "auto", image = "smallboats.tex", desc = tmp_enableddisabled_descriptions, order = 2, world = {"forest", "cave"}},
            has_ia_drowning  = {value = "auto", image = "deadlydrowning.tex", desc = tmp_enableddisabled_descriptions, order = 3, world = {"forest"}},
        }
    },

    island_settings_resources = {
        order = 5,
        category = LEVELCATEGORY.SETTINGS,
        text = STRINGS.UI.SANDBOXMENU.CUSTOMIZATIONPREFIX_IA..STRINGS.UI.SANDBOXMENU.WORLDSETTINGS_RESOURCEREGROWTH,
        desc = speed_descriptions,
        items = {
            sweet_potato_regrowth = {value = "default", image = "sweetpotatos.tex", world={"forest"}},
            palmtree_regrowth = {value = "default", image = "trees.tex", world={"forest"}},
            jungletree_regrowth = {value = "default", image = "jungletree.tex", world={"forest"}},
            --mangrovetree_regrowth = {value = "default", image = "mangrovetree.tex", world={"forest"}},
        }
    },

    island_settings_animals = {
        order = 6,
        category = LEVELCATEGORY.SETTINGS,
        text = STRINGS.UI.SANDBOXMENU.CUSTOMIZATIONPREFIX_IA..STRINGS.UI.SANDBOXMENU.WORLDSETTINGS_ANIMALS,
        desc = frequency_descriptions,
        items = {
            crab_setting        = {value = "default", image = "crabbits.tex", world = {"forest"}},
            wildbores_setting   = {value = "default", image = "wildbores.tex", world = {"forest", "cave"}},
            ballphin_setting    = {value = "default", image = "ballphins.tex", world = {"forest"}},
            primeape_setting    = {value = "default", image = "monkeys.tex", world = {"forest", "cave"}},
            fishermerm_setting  = {value = "default", image = "merms.tex", world = {"forest"} },
            sharkitten_setting  = {value = "default", image = "sharkitten.tex", world = {"forest"}},
            lobster_setting     = {value = "default", image = "lobsters.tex", world = {"forest"}},
            jellyfish_setting   = {value = "default", image = "jellyfish.tex", world = {"forest"}},
            solofish_setting    = {value = "default", image = "dogfish.tex", world = {"forest"}},
        }
    },

    island_settings_monsters = {
        order = 7,
        category = LEVELCATEGORY.SETTINGS,
        text = STRINGS.UI.SANDBOXMENU.CUSTOMIZATIONPREFIX_IA..STRINGS.UI.SANDBOXMENU.WORLDSETTINGS_HOSTILE_CREATURES,
        desc = frequency_descriptions,
        items = {
            -- TODO implement "Sharx" as "likelihood of sharx/crocodogs when meat lands on water" ?
            -- sharx = { value = "default", image = "crocodog.tex", world = {"forest"} },
            -- Note: This one is houndwaves, which technically speaking already exists.
            -- crocodog = { value = "default", image = "crocodog.tex", world = {"forest"} },
            mosquito            = {value = "default", image = "mosquitos.tex", world = {"forest"}},
            swordfish_setting   = {value = "default", image = "swordfish.tex", world = {"forest"}},
            stungray_setting    = {value = "default", image = "stinkrays.tex", world = {"forest"}},
            dragoon_setting     = {value = "default", image = "dragoons.tex", world = {"forest", "cave"}},
        }
    },

    island_settings_giants = {
        order = 8,
        category = LEVELCATEGORY.SETTINGS,
        text = STRINGS.UI.SANDBOXMENU.CUSTOMIZATIONPREFIX_IA..STRINGS.UI.SANDBOXMENU.CHOICEGIANTS,
        desc = frequency_descriptions,
        items = {
            twister       = {value = "default", image = "twister.tex", world = {"forest"}},
            tigershark    = {value = "default", image = "tigershark.tex", world = {"forest"}},
            kraken        = {value = "default", image = "kraken.tex", world = {"forest"}},
        }
    },

}

for name, data in pairs(ia_customize_table) do
    add_group_and_item(data.category, name, data.text, data.desc, data.atlas, data.order, data.items)
end

IACustomizeTable = ia_customize_table

local function LoadPreset(worldsettings_widgets, preset)
    for _, v in ipairs(worldsettings_widgets) do
        v:OnPresetButton(preset)
    end
end

scheduler:ExecuteInTime(0, function() -- Delay a frame so we can get ServerCreationScreen when entering a existing world
    local servercreationscreen = TheFrontEnd:GetOpenScreenOfType("ServerCreationScreen") --= TheFrontEnd:GetActiveScreen()

    if not servercreationscreen or not servercreationscreen.world_tabs then
        return
    end

    local forest_tab = servercreationscreen.world_tabs[1]
    local cave_tab = servercreationscreen.world_tabs[2]

    if not forest_tab or not cave_tab  or not KnownModIndex:IsModEnabled(IAENV.modname) then  -- IsModEnabled fix quick turn on-off mod collapse
        return
    end

    if not servercreationscreen:CanResume() then -- Only when first time creating the world
        LoadPreset(forest_tab.worldsettings_widgets, "SURVIVAL_SHIPWRECKED_CLASSIC")  -- Automatically try switching to the Shipwrecked Preset
    end

    if not servercreationscreen:CanResume() and cave_tab:IsLevelEnabled() then  -- Only when first time creating the world and auto add cave
        LoadPreset(cave_tab.worldsettings_widgets, "SURVIVAL_VOLCANO_CLASSIC")  -- Automatically try switching to the Volcano Preset
    end

    local add_cave_btn = cave_tab.sublevel_adder_overlay:GetAddButton()
    add_cave_btn:SetPosition(-170, 0)

    local button = cave_tab.sublevel_adder_overlay:AddChild(ImageButton("images/global_redux.xml", "button_carny_xlong_normal.tex", "button_carny_xlong_hover.tex", "button_carny_xlong_disabled.tex", "button_carny_xlong_down.tex"))
    button.image:SetScale(.49)
    button:SetFont(CHATFONT)
    button.text:SetColour(0, 0, 0, 1)
    button:SetOnClick(function(self, ...)
        add_cave_btn.onclick(self, ...)

        local PopupDialogScreen = TheFrontEnd:GetOpenScreenOfType("PopupDialogScreen")
        if PopupDialogScreen then  -- There is already a world
            local _add_cave_cb = PopupDialogScreen.dialog.actions.items[1].onclick
            PopupDialogScreen.dialog.actions.items[1].onclick = function(_self, ...)
                _add_cave_cb(_self, ...)
                LoadPreset(cave_tab.worldsettings_widgets, "SURVIVAL_VOLCANO_CLASSIC")
            end
        else
            LoadPreset(cave_tab.worldsettings_widgets, "SURVIVAL_VOLCANO_CLASSIC")
        end
    end)
    button:SetTextSize(19.6)
    button:SetText(STRINGS.UI.SANDBOXMENU.ADDVOLCANO)
    button:SetPosition(120, -63)
    table.insert(cave_tab.sublevel_adder_overlay.actions.items, button)
end)
