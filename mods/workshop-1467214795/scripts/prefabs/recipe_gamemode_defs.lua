local BOATMODE_RECIPES = {}

BOATMODE_RECIPES[RECIPE_BOAT_TYPE.IA] = {}
BOATMODE_RECIPES[RECIPE_BOAT_TYPE.DST] = {}

local GAMEMODE_RECIPES = {}

GAMEMODE_RECIPES[RECIPE_GAME_TYPE.ROG] = {}
GAMEMODE_RECIPES[RECIPE_GAME_TYPE.SW] = {}
GAMEMODE_RECIPES[RECIPE_GAME_TYPE.HAM] = {}

local test_boat_type = {}

test_boat_type[RECIPE_BOAT_TYPE.IA] = function(world) return world.has_ia_boats end
test_boat_type[RECIPE_BOAT_TYPE.DST] = function(world) return not world.no_dst_boats end

local test_game_type = {}

test_game_type[RECIPE_GAME_TYPE.ROG] = function(world) return not world:HasTag("volcano") and not world:HasTag("island") and not world:HasTag("porkland") end
test_game_type[RECIPE_GAME_TYPE.SW] = function(world) return world:HasTag("island") or world:HasTag("volcano") end
test_game_type[RECIPE_GAME_TYPE.HAM] = function(world) return world:HasTag("porkland") end

local function IsBoatTypeValid(boat_type)
    if boat_type == nil then return true end
    local world = TheWorld
    return test_boat_type[boat_type](world)
end

local function IsGameTypeValid(game_type)
    if game_type == nil or not IA_CONFIG.gamemode_recipes then return true end -- TODO: add a config
    local world = TheWorld
    return test_game_type[game_type](world)
end

local function InitilizeGameTypes()
    -- TODO: Some automation
end

return {
    --Internal use
    -- Initilize = InitilizeGameTypes,
    test_boat_type = test_boat_type,
    test_game_type = test_game_type,

    --Public use
    BOATMODE_RECIPES = BOATMODE_RECIPES,
    GAMEMODE_RECIPES = GAMEMODE_RECIPES,

    IsGameTypeValid = IsGameTypeValid,
    IsBoatTypeValid = IsBoatTypeValid,
}