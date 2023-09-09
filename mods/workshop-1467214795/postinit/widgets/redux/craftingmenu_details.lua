local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local unpack = unpack

local RECIPE_GAMEMODE_DEFS = require("prefabs/recipe_gamemode_defs")

local IsBoatTypeValid = RECIPE_GAMEMODE_DEFS.IsBoatTypeValid
local IsGameTypeValid = RECIPE_GAMEMODE_DEFS.IsGameTypeValid

----------------------------------------------------------------------------------------

local CraftingMenuDetails = require("widgets/redux/craftingmenu_details")

function CraftingMenuDetails:_GetWorldHintTextForRecipe(player, recipe)
    if not IsBoatTypeValid(recipe.boat_type) then
        return "NEEDSBOATMODE" .. INVERTED_RECIPE_BOAT_TYPE[recipe.boat_type]
    end
    if not IsGameTypeValid(recipe.game_type) then
        return "NEEDSGAMEMODE" .. INVERTED_RECIPE_GAME_TYPE[recipe.game_type]
    end
end

local __GetHintTextForRecipe = CraftingMenuDetails._GetHintTextForRecipe
function CraftingMenuDetails:_GetHintTextForRecipe(player, recipe, ...)
    return not player.replica.builder:KnowsRecipe(recipe) and self:_GetWorldHintTextForRecipe(player, recipe) or __GetHintTextForRecipe(self, player, recipe, ...) or nil
end

local _UpdateBuildButton = CraftingMenuDetails.UpdateBuildButton
function CraftingMenuDetails:UpdateBuildButton(from_pin_slot, ...)
    local rets = {_UpdateBuildButton(self, from_pin_slot, ...)}
    self.first_sub_ingredient_to_craft = nil

    if self.data == nil then
        return _UpdateBuildButton(self, from_pin_slot, ...)
    end

    local recipe = self.data.recipe
    local meta = self.data.meta

    local teaser = self.build_button_root.teaser
    local button = self.build_button_root.button

    if meta.out_of_world then
        local required_worldmode = self:_GetWorldHintTextForRecipe(self.owner, recipe)
        local str = STRINGS.UI.CRAFTING[required_worldmode]

        teaser:SetSize(20)
        teaser:UpdateOriginalSize()
        teaser:SetMultilineTruncatedString(str, 2, (self.panel_width / 2) * 0.8, nil, false, true)

        teaser:Show()
        button:Hide()
    end
    return unpack(rets)
end