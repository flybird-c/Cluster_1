require("behaviours/standstill")
require("behaviours/runaway")
require("behaviours/doaction")
require("behaviours/panic")
require("behaviours/wander")
require("behaviours/chaseandattack")

local BrainCommon = require("brains/braincommon")

local StungrayBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function StungrayBrain:OnStart()
    local root = PriorityNode(
    {
		BrainCommon.PanicTrigger(self.inst),
        ChaseAndAttack(self.inst, TUNING.STINKRAY_CHASE_TIME, TUNING.STINKRAY_CHASE_DIST),
        WhileNode(function() return self.inst.components.teamattacker.teamleader == nil end, "No Leader Wander Action",
            Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, 40)),
    }, .25)
    self.bt = BT(self.inst, root)
end

return StungrayBrain
