--Hornet: MiM Support

--[[TODO:
SW world settings will now show up on EVERY server regardless if IA is enabled or not, let's prevent that

I'll go back to this when stinky lord fixes other shards not showing up when viewing a worlds settings/generations in the server listing
]]

--TODO, Hornet: create mim versions of main/assets and import that? This is small enough that it can just fit here for now though so.
PrefabFiles = {
    "ia_skinprefabs",

    "wilbur",
    "wilbur_none",

    "walani",
    "walani_none",

    "woodlegs",
    "woodlegs_none",
}

Assets = {
    Asset("IMAGE", "images/ia_cookbook.tex"),
    Asset("ATLAS", "images/ia_cookbook.xml"),

    Asset("IMAGE", "images/ia_inventoryimages.tex"),
    Asset("ATLAS", "images/ia_inventoryimages.xml"),

    Asset("ANIM", "anim/farm_plant_sweet_potato.zip"),

    Asset("IMAGE", "images/hud/customization_shipwrecked.tex"),
    Asset("ATLAS", "images/hud/customization_shipwrecked.xml"),

    Asset("ATLAS", "images/ia_skins.xml"),
    Asset("IMAGE", "images/ia_skins.tex"),
    Asset("ATLAS_BUILD", "images/ia_skins.xml", 256),
}

GLOBAL.IA_CONFIG = {
    --IA_CONFIG is limited on client side as we only care for translation.

    --I should... probably add a feature to be able to remove configs when viewing them in the MiM list, as a majority of them are not important for the purposes of client enabled mods
    locale = GetModConfigData("locale", true),
}

modimport("main/characters")
modimport("main/prefabskin")
modimport("main/strings")
modimport("main/cooking")
modimport("main/tuning")
modimport("main/constants")
--modimport("modservercreationmain")

modimport("postinit/components/skinner") --Hornet: For right now ONLY skinner, and it's not even touching the actual component but rather the global SetSkinsOnAnim function

--todo/note, hornet: what the florp, this is loaded as a prefab in the main code but doesn't actually make prefabs, im going to import it here and take a look at main implementation later sometime
modimport("scripts/prefabs/ia_fertilizer_nutrient_defs")

--hornet: what the mother florper, we have to put this on a delay otherwise the game will crash upon reload of the game when it tries to create the farm plant prefabs
GLOBAL.scheduler:ExecuteInTime(0, function()
    modimport("main/ia_farm_plant_defs")
end, 0)

local function GetUpValue(func, varname)
    local i = 1
    local n, v = GLOBAL.debug.getupvalue(func, 1)
    while v ~= nil do
        if n == varname then
            return v
        end
        i = i + 1
        n, v = GLOBAL.debug.getupvalue(func, i)
    end
end

local IAENV = env
GLOBAL.setfenv(1, GLOBAL)
-----------------
--[[PostInits]]-- Small enough that I feel it can all just squeeze in here for now
-----------------

function ShardSaveIndex:IsIAEnabledOnSlot(slot)
    local enabledmods = self:GetSlotEnabledServerMods(slot)

    for k, v in pairs(enabledmods) do
        if k == IAENV.modname then
            return true
        end
    end

    return false
end

--Hornet: Not my favourite, we just see if IA is enabled and then apply string changes, instead of seeing if the worlds are actually different but it works well enough me-thinks

local _GetSlotDayAndSeasonText = ShardSaveIndex.GetSlotDayAndSeasonText

function ShardSaveIndex:GetSlotDayAndSeasonText(slot, ...)
    local _orig_seasons = STRINGS.UI.SERVERLISTINGSCREEN.SEASONS
    if self:IsIAEnabledOnSlot(slot) then
        STRINGS.UI.SERVERLISTINGSCREEN.SEASONS = STRINGS.UI.SERVERLISTINGSCREEN.IA_SEASONS --L tier coding but i'm lazy so.
    end

    local slot_day_and_season_str = _GetSlotDayAndSeasonText(self, slot, ...)

    STRINGS.UI.SERVERLISTINGSCREEN.SEASONS = _orig_seasons

    return slot_day_and_season_str
end

local _GetSlotPresetText = ShardSaveIndex.GetSlotPresetText

function ShardSaveIndex:GetSlotPresetText(slot, ...)
    local preset_str = _GetSlotPresetText(self, slot, ...)

    if self:IsIAEnabledOnSlot(slot) then
        if preset_str == STRINGS.UI.SERVERCREATIONSCREEN.FORESTONLY then
            preset_str = STRINGS.UI.SERVERCREATIONSCREEN.ISLANDSONLY
        elseif preset_str == STRINGS.UI.SERVERCREATIONSCREEN.FORESTANDCAVES then
            preset_str = STRINGS.UI.SERVERCREATIONSCREEN.ISLANDSANDVOLCANO
        end
    end

    return preset_str
end

--Hornet: this is usually supported by gemcore but I'd really rather not MiM have to enable a whole other API just for *one* niche feature like this.
local IA_ICONS = resolvefilepath("images/ia_inventoryimages.xml")
local inventoryItemAtlasLookup = GetUpValue(GetInventoryItemAtlas, "inventoryItemAtlasLookup")
local _GetInventoryItemAtlas = GetInventoryItemAtlas
function GetInventoryItemAtlas(imagename, ...)
    local atlas = inventoryItemAtlasLookup[imagename]
    if atlas then return _GetInventoryItemAtlas(imagename, ...) end

    atlas = TheSim:AtlasContains(IA_ICONS, imagename) and IA_ICONS or nil
    if atlas then inventoryItemAtlasLookup[imagename] = atlas return atlas end

    return _GetInventoryItemAtlas(imagename, ...)
end

-- Note: Arti sucks!
local ServerListingScreen = require("screens/redux/serverlistingscreen")
local _UpdateServerData = ServerListingScreen.UpdateServerData

function ServerListingScreen:UpdateServerData(selected_index_actual, ...)
    _UpdateServerData(self, selected_index_actual, ...)

    local worldgenoptions = self:ProcessServerWorldGenData()
    if worldgenoptions == nil then return end
    if (worldgenoptions[1].overrides == nil) or (worldgenoptions[1].overrides.start_location ~= "ShipwreckedStart") then return end

    local seasondesc = STRINGS.UI.SERVERLISTINGSCREEN.IA_SEASONS[string.upper(self.selected_server.season)]
    if seasondesc then
        local gamedata = self:ProcessServerGameData()
        if gamedata ~= nil and
            type(gamedata.daysleftinseason) == "number" and
            type(gamedata.dayselapsedinseason) == "number" then

            if gamedata.daysleftinseason * 3 <= gamedata.dayselapsedinseason then
                seasondesc = STRINGS.UI.SERVERLISTINGSCREEN.LATE_SEASON_1..seasondesc..STRINGS.UI.SERVERLISTINGSCREEN.LATE_SEASON_2
            elseif gamedata.dayselapsedinseason * 3 <= gamedata.daysleftinseason then
                seasondesc = STRINGS.UI.SERVERLISTINGSCREEN.EARLY_SEASON_1..seasondesc..STRINGS.UI.SERVERLISTINGSCREEN.EARLY_SEASON_2
            end
        end
        self.season_description.text:SetString(seasondesc or STRINGS.UI.SERVERLISTINGSCREEN.UNKNOWN_SEASON)
    end
end
