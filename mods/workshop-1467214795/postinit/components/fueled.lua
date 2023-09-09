local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Fueled = require("components/fueled")

local _CanAcceptFuelItem = Fueled.CanAcceptFuelItem
function Fueled:CanAcceptFuelItem(item, ...)
    return _CanAcceptFuelItem(self, item, ...) or (self.accepting and item and item.components.fuel and (item.components.fuel.secondaryfueltype == self.fueltype or item.components.fuel.secondaryfueltype == self.secondaryfueltype))
end