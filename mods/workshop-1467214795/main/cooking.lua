local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

require("util")
local cooking = require("cooking")

IAENV.AddIngredientValues({"seaweed"}, {veggie = 1}, true, true)
IAENV.AddIngredientValues({"sweet_potato"}, {veggie = 1}, true)
IAENV.AddIngredientValues({"coffeebeans"}, {fruit = .5})
IAENV.AddIngredientValues({"coffeebeans_cooked"}, {fruit = 1})
IAENV.AddIngredientValues({"coconut_cooked", "coconut_halved"}, {fruit = 1,fat = 1})
IAENV.AddIngredientValues({"doydoyegg"}, {egg = 1}, true)
IAENV.AddIngredientValues({"dorsalfin"}, {inedible = 1})
IAENV.AddIngredientValues({"shark_fin", "fish_tropical", "solofish_dead", "swordfish_dead"}, {meat = 0.5,fish = 1})
IAENV.AddIngredientValues({"roe", "purple_grouper", "pondpurple_grouper", "pierrot_fish", "pondpierrot_fish", "neon_quattro", "pondneon_quattro"}, {meat = 0.5,fish = 1}, true)
IAENV.AddIngredientValues({"jellyfish", "jellyfish_dead", "jellyfish_cooked", "rainbowjellyfish", "rainbowjellyfish_dead", "rainbowjellyfish_cooked", "jellyjerky"}, {fish = 1, jellyfish = 1, monster = 1})
IAENV.AddIngredientValues({"limpets", "mussel"}, {fish = .5}, true)
IAENV.AddIngredientValues({"lobster"}, {fish = 2}, true)
IAENV.AddIngredientValues({"crab"}, {fish = .5})
IAENV.AddIngredientValues({"pondfish_tropical"}, (IA_CONFIG.pondfishable and cooking.ingredients["pondfish"].tags) or {fish = 1})

cooking.GetRecipe("cookpot", "batnosehat").test = function(cooker, names, tags) return names.batnose and (names.kelp or names.seaweed) and (tags.dairy and tags.dairy >= 1) end
cooking.GetRecipe("cookpot", "californiaroll").test = function(cooker, names, tags) return (names.seaweed and names.seaweed == 2 or names.kelp and names.kelp == 2 or names.kelp and names.seaweed) and (tags.fish and tags.fish >= 1) end
cooking.GetRecipe("cookpot", "barnaclesushi").test = function(cooker, names, tags) return (names.barnacle or names.barnacle_cooked) and (names.kelp or names.kelp_cooked or names.seaweed or names.seaweed_cooked) and tags.egg and tags.egg >= 1 end
cooking.GetRecipe("cookpot", "barnaclestuffedfishhead").test = function(cooker, names, tags) return (names.barnacle or names.barnacle_cooked or names.mussel or names.mussel_cooked) and tags.fish and tags.fish >= 1.25 end
cooking.GetRecipe("cookpot", "potatotornado").test = function(cooker, names, tags) return (names.potato or names.potato_cooked or names.sweet_potato or names.sweet_potato_cooked) and names.twigs and (not tags.monster or tags.monster <= 1) and not tags.meat and (tags.inedible and tags.inedible <= 2) end

local foods = {
    bisque =
    {
        test = function(cooker, names, tags) return names.limpets and names.limpets == 3 and tags.frozen end,
        priority = 30,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_HUGE,
        hunger = TUNING.CALORIES_MEDSMALL,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_TINY,
        cooktime = 1,
        card_def = {ingredients = {{"limpets", 3}, {"ice", 1}} },
    },

    jellyopop =
    {
        test = function(cooker, names, tags) return tags.jellyfish and tags.frozen and names.twigs end,
        priority = 20,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_SMALL,
        perishtime = TUNING.PERISH_SUPERFAST,
        sanity = 0,
        temperature = TUNING.COLD_FOOD_BONUS_TEMP,
        temperatureduration = TUNING.FOOD_TEMP_AVERAGE,
        cooktime = 0.5,
        potlevel = "low",
        oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_COLD_FOOD,
        card_def = {ingredients = {{"jellyfish", 1}, {"ice", 2}, {"twigs", 1}} },
    },

    wobsterbisque =
    {
        test = function(cooker, names, tags) return names.lobster and tags.frozen end,
        priority = 30,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_HUGE,
        hunger = TUNING.CALORIES_MED,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_SMALL,
        cooktime = 0.5,
        potlevel = "low",
    },

    wobsterdinner =
    {
        test = function(cooker, names, tags) return names.lobster and names.butter and not tags.meat and not tags.frozen end,
        priority = 25,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_HUGE,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_SLOW,
        sanity = TUNING.SANITY_HUGE,
        cooktime = 1,
        potlevel = "high",
    },

    sharkfinsoup =
    {
        test = function(cooker, names, tags) return names.shark_fin end,
        priority = 20,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_LARGE,
        hunger = TUNING.CALORIES_SMALL,
        perishtime = TUNING.PERISH_MED,
        sanity = -TUNING.SANITY_SMALL,
        naughtiness = 10,
        cooktime = 1,
        potlevel = "low",
        oneat_desc = "Considered naughty",
        card_def = {ingredients = {{"shark_fin", 1}, {"ice", 3}} },
    },

    coffee =
    {
        test = function(cooker, names, tags) return names.coffeebeans_cooked and (names.coffeebeans_cooked == 4 or (names.coffeebeans_cooked == 3 and (tags.dairy or tags.sweetener)))    end,
        priority = 30,
        -- foodtype = FOODTYPE.VEGGIE,
        foodtype = FOODTYPE.GOODIES, --Taffy and Ice Cream was changed to goodie in DST
        health = TUNING.HEALING_SMALL,
        hunger = TUNING.CALORIES_TINY,
        perishtime = TUNING.PERISH_MED,
        sanity = -TUNING.SANITY_TINY,
        caffeinedelta = TUNING.CAFFEINE_FOOD_BONUS_SPEED,
        caffeineduration = TUNING.FOOD_SPEED_LONG,
        cooktime = 0.5,
        potlevel = "low",
        oneat_desc = "Accelerates movement",
        card_def = {ingredients = {{"coffeebeans_cooked", 3}, {"honey", 1}} },
    },

    tropicalbouillabaisse =
    {
        test = function(cooker, names, tags) return (names.pondpurple_grouper or names.purple_grouper or names.purple_grouper_cooked) and (names.pondpierrot_fish or names.pierrot_fish or names.pierrot_fish_cooked) and (names.pondneon_quattro or names.neon_quattro or names.neon_quattro_cooked) and tags.veggie end,
        priority = 35,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_MED,
        cooktime = 2,
        potlevel = "low",
        boost_dry = true,
        boost_cool = true,
        boost_surf = true,
        oneat_desc = "Cools, accelerates, dries",
        card_def = {ingredients = {{"purple_grouper", 1}, {"neon_quattro", 1}, {"pierrot_fish", 1}, {"seaweed", 1} } },
    },

    caviar =
    {
        test = function(cooker, names, tags) return (names.roe or names.roe_cooked == 3) and tags.veggie end,
        priority = 20,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_SMALL,
        hunger = TUNING.CALORIES_SMALL,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_LARGE,
        cooktime = 2,
        card_def = {ingredients = {{"roe", 1}, {"seaweed", 3}} },
    },
}

local warlyfoods = {
    sweetpotatosouffle =
    {
        test = function(cooker, names, tags) return (names.sweet_potato and names.sweet_potato == 2) and tags.egg and tags.egg >= 2 end,
        priority = 30,
        foodtype = FOODTYPE.VEGGIE,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_MED,
        cooktime = 2,
        potlevel = "low",
        tags = { "masterfood" },
    },

    musselbouillabaise =
    {
        test = function(cooker, names, tags) return (names.mussel and names.mussel == 2) and tags.veggie and tags.veggie >= 2 end,
        priority = 30,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_MED,
        cooktime = 2,
        potlevel = "low",
        tags = { "masterfood" },
    },
}

if IA_CONFIG.oldwarly then
    -- Upgrade Monstertartare
    local monstertartare = cooking.GetRecipe("portablecookpot", "monstertartare")
    if monstertartare then
        monstertartare.test = function(cooker, names, tags) return tags.monster and tags.monster >= 2 and tags.egg and tags.veggie end
        monstertartare.health = TUNING.HEALING_SMALL
        monstertartare.hunger = TUNING.CALORIES_LARGE
        monstertartare.perishtime = TUNING.PERISH_MED
        monstertartare.sanity = TUNING.SANITY_SMALL
        monstertartare.cooktime = 2
    end
end

----------------------------------------------------------------------------------------

for name, recipe in pairs (foods) do
    recipe.name = name
    recipe.weight = recipe.weight or 1
    recipe.priority = recipe.priority or 0
    recipe.cookbook_atlas = "images/ia_cookbook.xml"
    IAENV.AddCookerRecipe("cookpot", recipe)
    IAENV.AddCookerRecipe("portablecookpot", recipe)
    IAENV.AddCookerRecipe("archive_cookpot", recipe)

    if recipe.card_def then
        AddRecipeCard("cookpot", recipe)
    end
end

for name, recipe in pairs(warlyfoods) do
    recipe.name = name
    recipe.weight = recipe.weight or 1
    recipe.priority = recipe.priority or 0
    recipe.cookbook_atlas = "images/ia_cookbook.xml"
    IAENV.AddCookerRecipe("portablecookpot", recipe)
end

-- spice it!
local spicedfoods = shallowcopy(require("spicedfoods"))
GenerateSpicedFoods(foods)
GenerateSpicedFoods(warlyfoods)
local ia_spiced = {}
local new_spicedfoods = require("spicedfoods")
for k,v in pairs(new_spicedfoods) do
    if not spicedfoods[k] then
        ia_spiced[k] = v
    end
end
for k,v in pairs(ia_spiced) do
    new_spicedfoods[k] = nil --do not let the game make the prefabs
    IAENV.AddCookerRecipe("portablespicer", v)
end

IA_PREPAREDFOODS = MergeMaps(foods, warlyfoods, ia_spiced)

----------------------------------------------------------------------------------------

--The following makes "portablecookpot" a synonym of "cookpot" and also implements Warly's unique recipes
local CalculateRecipe_old = cooking.CalculateRecipe
cooking.CalculateRecipe = function(cooker, names, ...)
    -- Spicer wetgoop fix! (in the unlikely case somebody has Gourmet food and a spicer at the same time)
    for k, v in pairs(names) do
        if v:sub(-8) == "_gourmet" then
            names[k] = v:sub(1, -9)
        end
    end

    if not IA_CONFIG.oldwarly then return CalculateRecipe_old(cooker, names, ...) end

    if cooker == "portablecookpot" then cooker = "cookpot" end
    local ret
    if cooking.enableWarly and cooker == "cookpot" then
        --TODO This includes meatballs n shit now
        ret = {CalculateRecipe_old("portablecookpot", names, ...)} --get Warly recipe
    end
    if not ret or not ret[1] then
        ret = {CalculateRecipe_old(cooker, names, ...)}
    end
    return unpack(ret)
end

--This can be called when the food is done, thus don't use cooking.enableWarly
local GetRecipe_old = cooking.GetRecipe
cooking.GetRecipe = function(cooker, ...)
    if not IA_CONFIG.oldwarly then return GetRecipe_old(cooker, ...) end

    if cooker == "portablecookpot" then cooker = "cookpot" end
    -- local ret
    -- if cooking.enableWarly and cooker == "cookpot" then
        -- ret = GetRecipe_old("portablecookpot", ...)
    -- end
    -- ret = ret or GetRecipe_old(cooker, ...) or GetRecipe_old("portablecookpot", ...)
    return GetRecipe_old(cooker, ...) or GetRecipe_old("portablecookpot", ...)
end
local IsModCookingProduct_old = IsModCookingProduct
IsModCookingProduct = function(cooker, ...)
    -- if not IA_CONFIG.oldwarly then return IsModCookingProduct_old(cooker, ...) end

    if cooker == "portablecookpot" then cooker = "cookpot" end
    return IsModCookingProduct_old(cooker, ...) or IsModCookingProduct_old("portablecookpot", ...)
end
