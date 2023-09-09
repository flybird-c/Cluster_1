require("behaviours/wander")
require("behaviours/panic")

local BrainCommon = require("brains/braincommon")

local MAX_WANDER_DIST = 40

local jellyfishBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function jellyfishBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", self.inst:GetPosition(), true)
end

function jellyfishBrain:OnStart()
    local root = PriorityNode(
    {
        BrainCommon.PanicTrigger(self.inst),

        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST)
    }, .25)
    self.bt = BT(self.inst, root)
end

return jellyfishBrain
