local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Lighter = require("components/lighter")

local _Light = Lighter.Light
function Lighter:Light(target, ...)
    if target.components.burnable and target:HasTag("allowinventoryburning") and target:HasTag("INLIMBO") then
        target:RemoveTag("INLIMBO")
        target.components.burnable:RestoreLimbo() --see postinit/burnable.lua -Z
    end
    return _Light(self, target, ...)
end
