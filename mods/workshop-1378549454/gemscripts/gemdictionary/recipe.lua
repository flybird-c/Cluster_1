--[[
Copyright (C) 2020 Zarklord

This file is part of Gem Core.

The source code of this program is shared under the RECEX
SHARED SOURCE LICENSE (version 1.0).
The source code is shared for referrence and academic purposes
with the hope that people can read and learn from it. This is not
Free and Open Source software, and code is not redistributable
without permission of the author. Read the RECEX SHARED
SOURCE LICENSE for details
The source codes does not come with any warranty including
the implied warranty of merchandise.
You should have received a copy of the RECEX SHARED SOURCE
LICENSE in the form of a LICENSE file in the root of the source
directory. If not, please refer to
<https://raw.githubusercontent.com/Recex/Licenses/master/SharedSourceLicense/LICENSE.txt>
]]

AddRecipePostInitAny = GEMENV.AddRecipePostInitAny
AddRecipePostInit = GEMENV.AddRecipePostInit

require("recipe")
local _Recipe_ctor = Recipe._ctor
function Recipe._ctor(self, name, ingredients, tab, level, placer, min_spacing, nounlock, numtogive, builder_tag, atlas, image, testfn, product, build_mode, build_distance, ...)
    self.gemdict_ingredients = {}
    for k, v in pairs(ingredients) do
        if IsGemDictIngredient(v.type) then
            table.insert(self.gemdict_ingredients, v)
            ingredients[k] = nil
        end
    end
    _Recipe_ctor(self, name, ingredients, tab, level, placer, min_spacing, nounlock, numtogive, builder_tag, atlas, image, testfn, product, build_mode, build_distance, ...)
end
gemrun("hidefn", Recipe._ctor, _Recipe_ctor)

local function FindAndConvertIngredient(self, ingredienttype)
    for i, v in ipairs(self.ingredients) do
        if v.type == ingredienttype then
            table.insert(self.gemdict_ingredients, GemDictIngredient(table.remove(self.ingredients, i)))
            return self.gemdict_ingredients[#self.gemdict_ingredients]
        end
    end
    for i, v in ipairs(self.gemdict_ingredients) do
        if v.signature == ("GEMDICT_"..ingredienttype) then
            return v
        end
    end
end

local function AddModifiedOutputFn(self, fn)
    if not self.modifiedoutputfns then
        self.modifiedoutputfns = {}
    end
    table.insert(self.modifiedoutputfns, fn)
end

local function HasGemDictIngredients(self)
    return #self.gemdict_ingredients > 0
end

GEMENV.AddGlobalClassPostConstruct("recipe", "Recipe", function(self)
    self.FindAndConvertIngredient = FindAndConvertIngredient
    self.AddModifiedOutputFn      = AddModifiedOutputFn
    self.HasGemDictIngredients    = HasGemDictIngredients
end)

for k, v in pairs(AllRecipes) do
    v.gemdict_ingredients = {}
    v.FindAndConvertIngredient = FindAndConvertIngredient
    v.AddModifiedOutputFn      = AddModifiedOutputFn
    v.HasGemDictIngredients    = HasGemDictIngredients
end