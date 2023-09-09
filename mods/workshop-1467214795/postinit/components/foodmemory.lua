local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local FoodMemory = require("components/foodmemory")

local _GetBaseFood = FoodMemory.GetBaseFood
function FoodMemory:GetBaseFood(prefab, ...)
    local prefab = string.gsub(prefab, "_gourmet", "", 1)
	return _GetBaseFood(self, prefab, ...)
end

--Note: foodinst is set in postinit/eater.lua
local _RememberFood = FoodMemory.RememberFood
function FoodMemory:RememberFood(...)
	if not self.restricttag or not self.foodinst or self.foodinst:HasTag(self.restricttag) then
		return _RememberFood(self, ...)
	end
end

local _GetFoodMultiplier = FoodMemory.GetFoodMultiplier
function FoodMemory:GetFoodMultiplier(prefab, ...)
	if not self.restricttag or not self.foodinst or self.foodinst:HasTag(self.restricttag) then
		return _GetFoodMultiplier(self, prefab, ...)
	elseif self.cookedmult and string.find(prefab, "cooked") then
		return self.cookedmult
	elseif self.driedmult and string.find(prefab, "dried") then
		return self.driedmult
	end
	return self.rawmult or 1
end