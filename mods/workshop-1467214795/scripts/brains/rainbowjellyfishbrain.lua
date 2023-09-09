require("behaviours/wander")
require("behaviours/panic")
require("behaviours/migrate")

local BrainCommon = require("brains/braincommon")

local MAX_WANDER_DIST = 40

local RainbowJellyfishBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function RainbowJellyfishBrain:OnInitializationComplete()
    -- self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()), true)
end

function RainbowJellyfishBrain:OnStart()
    local migrationMgr = TheWorld.components.rainbowjellymigration

    local root = PriorityNode(
    {
		BrainCommon.PanicTrigger(self.inst),

        WhileNode(
            function() return migrationMgr ~= nil and migrationMgr:IsMigrationActive() end,
            "Migrating",
            PriorityNode({
                Migrate(self.inst, function() return self.inst.components.knownlocations:GetLocation("migration") end),
                Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("migration") end, MAX_WANDER_DIST * 0.25)
            }, 1)
        ),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST)
    }, 1)
    self.bt = BT(self.inst, root)
end

return RainbowJellyfishBrain
