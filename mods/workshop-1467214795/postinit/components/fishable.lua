local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Fishable = require("components/fishable")

--this component is stupid, very very stupid, about on par with its twin the fishingrod component
local _HookFish = Fishable.HookFish
function Fishable:HookFish(fisherman, ...)
    local fish = _HookFish(self, fisherman, ...)
    if fish.components.inventoryitem then
        fish.shouldsink = fish.components.inventoryitem.sinks
        fish.components.inventoryitem.sinks = false
    end
    return fish
end
