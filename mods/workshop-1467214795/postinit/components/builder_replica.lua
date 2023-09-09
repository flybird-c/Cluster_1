local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local unpack = unpack

local RECIPE_GAMEMODE_DEFS = require("prefabs/recipe_gamemode_defs")

local IsBoatTypeValid = RECIPE_GAMEMODE_DEFS.IsBoatTypeValid
local IsGameTypeValid = RECIPE_GAMEMODE_DEFS.IsGameTypeValid

----------------------------------------------------------------------------------------
local Builder = require("components/builder_replica")

--Zarklord: blindly replace this function, since idk what else to do...
function Builder:CanBuildAtPoint(pt, recipe, rot)
    return TheWorld.Map:CanDeployRecipeAtPoint(pt, recipe, rot, self.inst)
end

function Builder:SetIsJellyBrainHat(isjellybrainhat)
    if self.classified ~= nil then
        self.classified.isjellybrainhat:set(isjellybrainhat)
    end
end

local _KnowsRecipe = Builder.KnowsRecipe
function Builder:KnowsRecipe(recipe, ...)
    local rets = {_KnowsRecipe(self, recipe, ...)}
    if self.inst.components.builder == nil and self.classified ~= nil then
        if self.classified.isfreebuildmode:value() then return unpack(rets) end
        if type(recipe) == "string" then
            recipe = GetValidRecipe(recipe)
        end

        if recipe == nil then
            return unpack(rets)
        end

        if not IsBoatTypeValid(recipe.boat_type) then
            rets[1] = false
            return unpack(rets)
        end

        if not rets[1] and self.classified.isjellybrainhat:value() then
            local valid_tech = true
            for techname, level in pairs(recipe.level) do
                if level ~= 0 and (TECH.LOST[techname] or 0) == 0 then
                    valid_tech = false
                    break
                end
            end
            for i, v in ipairs(recipe.tech_ingredients) do
                if not self:HasTechIngredient(v) then
                    valid_tech = false
                    break
                end
            end
            if string.find(recipe.name, "hermitshop") then
                valid_tech = false
            end
            rets[1] = valid_tech and (recipe.builder_tag == nil or self.inst:HasTag(recipe.builder_tag))
        elseif rets[1] and not IsGameTypeValid(recipe.game_type) and (self.classified.recipes[recipe.name] == nil or not self.classified.recipes[recipe.name]:value()) then
            rets[1] = false
        end
    end
    return unpack(rets)
end

local _CanLearn = Builder.CanLearn
function Builder:CanLearn(recipename, ...)
    local rets = {_CanLearn(self, recipename, ...)}
    if self.inst.components.builder == nil and self.classified ~= nil then
        if rets[1] then
            local recipe = GetValidRecipe(recipename)
            rets[1] = recipe ~= nil and IsBoatTypeValid(recipe.boat_type)
        end
    end
    return unpack(rets)
end
