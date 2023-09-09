local IAENV = env
GLOBAL.setfenv(1, GLOBAL)
--------------------------------------------------------------

local ShadowCreatureBrain = require("brains/shadowcreaturebrain")

local targetatsea = UpvalueHacker.GetUpvalue(ShadowCreatureBrain.OnStart, "targetatsea")
local function IA_targetatsea(inst, ...)
    if inst.components.combat.target and inst.followtoboat then
        local target = inst.components.combat.target
        local x, y, z = target.Transform:GetWorldPosition()
        if target:CanOnWater(true) and target:GetCurrentPlatform() == nil and TheWorld.Map:IsOceanAtPoint(x, y, z, true) then
           return true
        end
    end
    if inst.components.combat.target and inst.followtoland then
        local target = inst.components.combat.target
        local x, y, z = target.Transform:GetWorldPosition()
        if target:GetCurrentPlatform() ~= nil or TheWorld.Map:IsVisualGroundAtPoint(x, y, z) then
           return true
        end
    end
    return targetatsea(inst, ...)
end

UpvalueHacker.SetUpvalue(ShadowCreatureBrain.OnStart, IA_targetatsea, "targetatsea")
