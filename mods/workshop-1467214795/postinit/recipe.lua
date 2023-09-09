local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

-------------------------------------------------------------------------------------------

local SW_ICONS = require("prefabs/visualvariant_defs").SW_ICONS
local PORK_ICONS = require("prefabs/visualvariant_defs").PORK_ICONS

local _GetImage = Ingredient.GetImage
function Ingredient:GetImage(...)
    if self.image == nil then
        local _world = TheWorld
        if _world:HasTag("porkland") and PORK_ICONS[self.type] ~= nil then
            self.image = PORK_ICONS[self.type]..".tex"
        elseif (_world:HasTag("island") or _world:HasTag("volcano")) and SW_ICONS[self.type] ~= nil then
            self.image = SW_ICONS[self.type]..".tex"
        end
    end
    return _GetImage(self, ...)
end
