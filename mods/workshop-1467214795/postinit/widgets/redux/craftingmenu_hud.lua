local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local unpack = unpack

local RECIPE_GAMEMODE_DEFS = require("prefabs/recipe_gamemode_defs")

local BOATMODE_RECIPES = RECIPE_GAMEMODE_DEFS.BOATMODE_RECIPES
local GAMEMODE_RECIPES = RECIPE_GAMEMODE_DEFS.GAMEMODE_RECIPES
local IsBoatTypeValid = RECIPE_GAMEMODE_DEFS.IsBoatTypeValid
local IsGameTypeValid = RECIPE_GAMEMODE_DEFS.IsGameTypeValid

----------------------------------------------------------------------------------------

local CraftingMenuHUD = require("widgets/redux/craftingmenu_hud")

local _RebuildRecipes = CraftingMenuHUD.RebuildRecipes
function CraftingMenuHUD:RebuildRecipes(...)
    local rets = {_RebuildRecipes(self, ...)}
    if self.owner ~= nil and self.owner.replica.builder ~= nil then
        local builder = self.owner.replica.builder
        if not builder:IsFreeBuildMode() then 
            for game_type, recipes in pairs(GAMEMODE_RECIPES) do
                if not IsGameTypeValid(game_type) then
                    for name, recipe in pairs(recipes) do
                        local meta = self.valid_recipes[name].meta
                        if IsRecipeValid(name) and not builder:KnowsRecipe(recipe) then
                            meta.can_build = false
                            meta.build_state = "hide"
                            meta.out_of_world = true
                        end
                    end
                end
            end
            for boat_type, recipes in pairs(BOATMODE_RECIPES) do
                if not IsBoatTypeValid(boat_type) then
                    for name, recipe in pairs(recipes) do
                        local meta = self.valid_recipes[name].meta
                        if IsRecipeValid(name) then
                            meta.can_build = false
                            meta.build_state = "hide"
                            meta.out_of_world = true
                        end
                    end
                end
            end
        end
	end
    return unpack(rets)
end