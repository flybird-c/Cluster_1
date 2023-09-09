local require = GLOBAL.require

if GetModConfigData("devmode") then
    GLOBAL.CHEATS_ENABLED = true
    GLOBAL.require( 'debugkeys' )
end

-- Dependencies are imported in modworldgenmain.lua

-- Import constants and data.

local windgustable = {
    all = {nohammer = false, nochop = false, nopick = false, nohack = false, noitems = false},
    nowalls = {nohammer = true, nochop = false, nopick = false, nohack = false, noitems = false},
    noitems = {nohammer = false, nochop = false, nopick = false, nohack = false, noitems = true},
    nowallsnoitems = {nohammer = true, nochop = false, nopick = false, nohack = false, noitems = true},
    none = {nohammer = true, nochop = true, nopick = true, nohack = true, noitems = true},
}

GLOBAL.IA_CONFIG = {
    -- Some of these may be treated as client-side, as indicated by the bool
    dynamicmusic = GetModConfigData("dynamicmusic", true),
    locale = GetModConfigData("locale", true),
    droplootground = GetModConfigData("droplootground"),
    limestonerepair = GetModConfigData("limestonerepair"),
    windgustable = windgustable[GetModConfigData("windgustable") or "all"],
    tuningmodifiers = GetModConfigData("tuningmodifiers"),
    windstaffbuff = GetModConfigData("windstaffbuff"),
    oldwarly = GetModConfigData("oldwarly"),
    newplayerboats = GetModConfigData("newplayerboats"),
    poisonenabled = true, --set in worldsettings_overrides_ia
    pondfishable = GetModConfigData("pondfishable"),
    octopustrade = GetModConfigData("octopustrade"),
    octopuskingtweak = GetModConfigData("octopuskingtweak"),
    newloot = GetModConfigData("newloot"),
    slotmachineloot = GetModConfigData("slotmachineloot"),
    leif_jungle = GetModConfigData("leif_jungle"),
    quickseaworthy = GetModConfigData("quickseaworthy"),
    forestid =  GetModConfigData("forestid"),
    caveid = GetModConfigData("caveid"),
    shipwreckedid = GetModConfigData("shipwreckedid"),
    volcanoid = GetModConfigData("volcanoid"),
}

-- modimport "main/strings"
modimport "main/ia_farm_plant_defs" --yes this does infact need to load here
modimport "main/assets"
modimport "main/fx"

-- Import the framework.

-- Formerly imported via SetupGemCoreEnv()
UpvalueHacker = gemrun("tools/upvaluehacker")
SetSoundAlias = gemrun("tools/soundmanager")

modimport "libraries/particletilestate"
modimport "libraries/dynamiczoom"
modimport "main/standardcomponents"

--------------------------------- Crafting ---------------------------------

local CustomTechTree = gemrun("tools/customtechtree")

-- Create the custom techtrees
CustomTechTree.AddNewTechType("OBSIDIAN")

GLOBAL.TECH.OBSIDIAN_TWO = {OBSIDIAN = 2}

CustomTechTree.AddPrototyperTree("SEALAB", {SCIENCE = 3})
CustomTechTree.AddPrototyperTree("OBSIDIAN_BENCH", {OBSIDIAN = 2})

--if TUNING.PROTOTYPER_TREES.ALCHEMYMACHINE then
--    TUNING.PROTOTYPER_TREES.ALCHEMYMACHINE.WATER = 1
--end

--------------------------------- Crafting Filter ---------------------------------
--set based on what world type
local function GetSeafaringAtlas(owner)
    return owner ~= nil and (GLOBAL.TheWorld:HasTag("island") or GLOBAL.TheWorld:HasTag("volcano")) and "images/hud/ia_hud.xml" or "images/crafting_menu_icons.xml"
end
local function GetSeafaringImage(owner)
    return owner ~= nil and (GLOBAL.TheWorld:HasTag("island") or GLOBAL.TheWorld:HasTag("volcano")) and "filter_nautical.tex" or "filter_sailing.tex"
end
GLOBAL.CRAFTING_FILTERS.SEAFARING.atlas = GetSeafaringAtlas
GLOBAL.CRAFTING_FILTERS.SEAFARING.image = GetSeafaringImage

AddPrototyperDef("obsidian_workbench", {icon_atlas = "images/hud/ia_hud.xml", icon_image = "station_obsidian.tex", is_crafting_station = true, action_str = "FORGING", filter_text = "Volcanic"})

GLOBAL.PROTOTYPER_DEFS.sea_lab = GLOBAL.PROTOTYPER_DEFS.researchlab
GLOBAL.PROTOTYPER_DEFS.piratihatitator = GLOBAL.PROTOTYPER_DEFS.researchlab4
GLOBAL.PROTOTYPER_DEFS.critterlab_water = GLOBAL.PROTOTYPER_DEFS.critterlab

-------------------------------------------------------------------------------------

-- Import various scripts
modimport "main/util"
modimport "main/networking"
modimport "main/stringutil"
modimport "main/commands"
modimport "main/recipes"
modimport "main/cooking"
modimport "main/containers"
modimport "main/tuning"
modimport "main/writeables"
modimport "main/actions"
modimport "main/postinit"
modimport "main/worldsettings_overrides_ia"
modimport "main/treasurehunt"
modimport "main/volcanoschedule"
modimport "main/characters"
modimport "main/prefabskin"
modimport "main/RPC"

--Extra Equip Slots
--Zarklord: god i love metatables, this is really a perfect solution cause this function is only called for undefined values so if EES is running BACK NECK and or WAIST is defined and we dont execute this metatable.
GLOBAL.setmetatable(GLOBAL.EQUIPSLOTS, {__index = function(t,k)
    if k == "BACK" or k == "NECK" then
        return GLOBAL.rawget(t, "BODY")
    elseif k == "WAIST" then
        return GLOBAL.rawget(t, "HANDS")
    end
    return GLOBAL.rawget(t, k)
end})

local ES = require("equipslotutil")

local _ESInitialize = ES.Initialize
local BOATEQUIPSLOT_NAMES, BOATEQUIPSLOT_IDS
function ES.Initialize()
    _ESInitialize()
    GLOBAL.assert(BOATEQUIPSLOT_NAMES == nil and BOATEQUIPSLOT_IDS == nil, "Equip slots already initialized")

    BOATEQUIPSLOT_NAMES = {}
    for k, v in pairs(GLOBAL.BOATEQUIPSLOTS) do
        table.insert(BOATEQUIPSLOT_NAMES, v)
    end

    GLOBAL.assert(#BOATEQUIPSLOT_NAMES <= 63, "Too many equip slots!")

    BOATEQUIPSLOT_IDS = table.invert(BOATEQUIPSLOT_NAMES)
end

--These are meant for networking, and can be used in prefab or
--component logic. They are not valid when modmain is loading.
function ES.BoatToID(eslot)
    return BOATEQUIPSLOT_IDS[eslot] or 0
end

function ES.BoatFromID(eslotid)
    return BOATEQUIPSLOT_NAMES[eslotid] or "INVALID"
end
local _ESToID = ES.ToID
function ES.ToID(eslot)
    return _ESToID(eslot) or 0
end

local _ESFromID = ES.FromID
function ES.FromID(eslotid)
    return _ESFromID(eslotid) or "INVALID"
end

function ES.BoatCount()
    return #BOATEQUIPSLOT_NAMES
end


-- Import strings only afterwards to reset API nonsense
modimport "main/strings"
modimport "main/play_generalscripts"
modimport "main/ia_skilltree_defs"
modimport "main/ia_scrapbook"

GLOBAL.PROTOTYPER_DEFS.obsidian_workbench.filter_text = GLOBAL.STRINGS.UI.CRAFTING_STATION_FILTERS.FORGING --make it use the string now that its been loaded

SetSoundAlias("dontstarve/movement/ia_run_sand", "ia/movement/walk_sand")
SetSoundAlias("dontstarve/movement/ia_run_sand_small", "ia/movement/walk_sand_small")
SetSoundAlias("dontstarve/movement/ia_run_sand_large", "ia/movement/walk_sand_large")
SetSoundAlias("dontstarve/movement/ia_walk_sand", "ia/movement/walk_sand")
SetSoundAlias("dontstarve/movement/ia_walk_sand_small", "ia/movement/walk_sand_small")
SetSoundAlias("dontstarve/movement/ia_walk_sand_large", "ia/movement/walk_sand_large")

SetSoundAlias("dontstarve/movement/run_slate", "ia/movement/walk_slate")
SetSoundAlias("dontstarve/movement/run_slate_small", "ia/movement/walk_slate_small")
SetSoundAlias("dontstarve/movement/run_slate_large", "ia/movement/walk_slate_large")
SetSoundAlias("dontstarve/movement/walk_slate", "ia/movement/walk_slate")
SetSoundAlias("dontstarve/movement/walk_slate_small", "ia/movement/walk_slate_small")
SetSoundAlias("dontstarve/movement/walk_slate_large", "ia/movement/walk_slate_large")

--TODO, get the actual sounds, and replace these "placeholder sounds"
SetSoundAlias("dontstarve/movement/run_rock", "dontstarve/movement/run_dirt")
SetSoundAlias("dontstarve/movement/run_rock_small", "dontstarve/movement/run_dirt_small")
SetSoundAlias("dontstarve/movement/run_rock_large", "dontstarve/movement/run_dirt_large")
SetSoundAlias("dontstarve/movement/walk_rock", "dontstarve/movement/walk_dirt")
SetSoundAlias("dontstarve/movement/walk_rock_small", "dontstarve/movement/walk_dirt_small")
SetSoundAlias("dontstarve/movement/walk_rock_large", "dontstarve/movement/walk_dirt_large")

--fix item images in menu and on minisigns
local AddInventoryItemAtlas = gemrun("tools/misc").Local.AddInventoryItemAtlas
AddInventoryItemAtlas(GLOBAL.resolvefilepath("images/ia_inventoryimages.xml"))

-- Add mod character to mod character list. Also specify a gender. Possible genders are MALE, FEMALE, ROBOT, NEUTRAL, PLURAL
-- AddModCharacter("warly", "MALE")
--dumb fix because Klei is dumb and changed the way bigportraits work without adjusting the API
-- GLOBAL.PREFAB_SKINS["warly"] = {"warly_none"}
-- GLOBAL.PREFAB_SKINS_IDS["warly"] = {["warly_none"] = 1}

--------------------------------- FLOOD ---------------------------------

GLOBAL.RegisterParticleTileState("flood", "images/flood_particle.tex", "shaders/floodstate.ksh", GLOBAL.ParticleTileScale.SMALL)

--------------------------------- Naughtiness ---------------------------------

local function GetDoyDoyNaughtiness()
    return GLOBAL.TheWorld.components.doydoyspawner:GetInnocenceValue()
end

local AddNaughtinessFor = gemrun("tools/krampednaughtiness")

AddNaughtinessFor("doydoy", GetDoyDoyNaughtiness)
AddNaughtinessFor("doydoybaby", GetDoyDoyNaughtiness)
AddNaughtinessFor("ballphin", 2)
AddNaughtinessFor("toucan", 2)
AddNaughtinessFor("parrot", 1)
AddNaughtinessFor("parrot_pirate", 6)
AddNaughtinessFor("seagull", 1)
AddNaughtinessFor("cormorant", 1)
AddNaughtinessFor("crab", 1)
AddNaughtinessFor("solofish", 2)
AddNaughtinessFor("swordfish", 4)
AddNaughtinessFor("whale_white", 6)
AddNaughtinessFor("whale_blue", 7)
AddNaughtinessFor("jellyfish_planted", 1)
AddNaughtinessFor("rainbowjellyfish_planted", 1)
AddNaughtinessFor("ox", 4)
AddNaughtinessFor("babyox", 6)
AddNaughtinessFor("lobster", 2)
AddNaughtinessFor("primeape", 2)
AddNaughtinessFor("twister_seal", 50)

--------------------------------- Projectile Fix ---------------------------------

local function UpdateFloatable(inst)
    if inst.components.inventoryitem and not inst.components.inventoryitem:IsHeld() then
        local water = GLOBAL.IsOnOcean(inst)
        --tell the component to refresh
        --this has a 1 tick delay to the anim, so don't do it if the water floating didn't change
        if not water or not (inst.components.floater and inst.components.floater:IsFloating()) then
            inst.components.inventoryitem:SetLanded(false,true)
        end
    end
end

local _Launch = GLOBAL.Launch
function GLOBAL.Launch(inst, ...)
    _Launch(inst, ...)
    if inst and inst:IsValid() then
        inst:DoTaskInTime(.6, UpdateFloatable)
    end
end
local _Launch2 = GLOBAL.Launch2
function GLOBAL.Launch2(inst, ...)
    local launched_angle = _Launch2(inst, ...)
    if inst and inst:IsValid() then
        inst:DoTaskInTime(.6, UpdateFloatable)
    end
    return launched_angle
end
local _LaunchAt = GLOBAL.LaunchAt
function GLOBAL.LaunchAt(inst, ...)
    _LaunchAt(inst, ...)
    if inst and inst:IsValid() then
        inst:DoTaskInTime(.6, UpdateFloatable)
    end
end
-- end

------------------------------ SW Replicatable Components ------------------------------------------------------------

AddReplicableComponent("geyserfx")
AddReplicableComponent("mapwrapper")
AddReplicableComponent("sailable")
AddReplicableComponent("sailor")
AddReplicableComponent("boathealth")
AddReplicableComponent("boatcontainer")
AddReplicableComponent("volcanoambience")

local AddSpoofedReplicableComponent = gemrun("tools/componentspoofer")

AddSpoofedReplicableComponent("boatcontainer", "container")

------------------------------ Replicatable Components ---------------------------------------
