local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local unpack = unpack

local RECIPE_GAMEMODE_DEFS = require("prefabs/recipe_gamemode_defs")

local IsBoatTypeValid = RECIPE_GAMEMODE_DEFS.IsBoatTypeValid
local IsGameTypeValid = RECIPE_GAMEMODE_DEFS.IsGameTypeValid

----------------------------------------------------------------------------------------
local Builder = require("components/builder")

--Zarklord: blindly replace this function, since idk what else to do...
function Builder:MakeRecipeAtPoint(recipe, pt, rot, skin)
    if recipe.placer ~= nil and
        self:KnowsRecipe(recipe.name) and
        self:IsBuildBuffered(recipe.name) and
        TheWorld.Map:CanDeployRecipeAtPoint(pt, recipe, rot, self.inst) then
        self:MakeRecipe(recipe, pt, rot, skin)
    end
end

local _GetIngredientWetness = Builder.GetIngredientWetness
function Builder:GetIngredientWetness(ingredients, ...)
    if IsInIAClimate(self.inst) then
        local _wetness = rawget(TheWorld.state, "wetness")
        TheWorld.state.wetness = TheWorld.state.islandwetness
        local rets = {_GetIngredientWetness(self, ingredients, ...)}
        TheWorld.state.wetness = _wetness
        return unpack(rets)
    end
    return _GetIngredientWetness(self, ingredients, ...)
end

local _KnowsRecipe = Builder.KnowsRecipe
function Builder:KnowsRecipe(recipe, ignore_tempbonus, ...)
    local rets = {_KnowsRecipe(self, recipe, ignore_tempbonus, ...)}
    if self.freebuildmode then return unpack(rets) end

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

    if not rets[1] and self.jellybrainhat then
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
    elseif rets[1] and not IsGameTypeValid(recipe.game_type) and not table.contains(self.recipes, recipe.name) then
        rets[1] = false
    end
    return unpack(rets)
end

local _CanLearn = Builder.CanLearn
function Builder:CanLearn(recname, ...)
    local rets = {_CanLearn(self, recname, ...)}
    if rets[1] then
        local recipe = GetValidRecipe(recname)
        rets[1] = recipe ~= nil and IsBoatTypeValid(recipe.boat_type)
    end
    return unpack(rets)
end

local _BufferBuild = Builder.BufferBuild
function Builder:BufferBuild(recname, ...)
    local recipe = GetValidRecipe(recname)
    local shouldevent = recipe ~= nil and recipe.placer ~= nil and not self:IsBuildBuffered(recname) and self:HasIngredients(recipe)-- and self:CanBuild(recname)
    local rets = {_BufferBuild(self, recname, ...)}
    if shouldevent then
        self.inst:PushEvent("bufferbuild", {recipe = recipe})
    end
    return unpack(rets)
end

local _isloading = setmetatable({}, {__mode = "k"}) --use a weak table so that we can't ever force these objects to stay in existance.

local _AddRecipe = Builder.AddRecipe
function Builder:AddRecipe(recname, ...)
    if not self.jellybrainhat or _isloading[self] then
        return _AddRecipe(self, recname, ...)
    end
end

local _OnLoad = Builder.OnLoad
function Builder:OnLoad(data, ...)
    _isloading[self] = true
    local rets = {_OnLoad(self, data, ...)}
    _isloading[self] = nil
    return unpack(rets)
end

local function onjellybrainhat(self, jellybrainhat)
    self.inst.replica.builder:SetIsJellyBrainHat(jellybrainhat)
end

IAENV.AddComponentPostInit("builder", function(cmp)

    addsetter(cmp, "jellybrainhat", onjellybrainhat)
    cmp.jellybrainhat = false

    --ignore flooded prototypers
    table.insert(cmp.exclude_tags, "flooded")
end)
