local IAENV = env
GLOBAL.setfenv(1, GLOBAL)
--------------------------------------------------------------

local OceanShadowCreatureBrain = require("brains/oceanshadowcreaturebrain")

local targetonland = UpvalueHacker.GetUpvalue(OceanShadowCreatureBrain.OnStart, "targetonland")
local function IA_targetonland(inst, ...)
    if inst.components.combat.target then
        local target = inst.components.combat.target
        if target:CanOnWater(true) and not target:GetCurrentPlatform() then
            return true
        end
    end
    return targetonland(inst, ...)
end

UpvalueHacker.SetUpvalue(OceanShadowCreatureBrain.OnStart, IA_targetonland, "targetonland")
