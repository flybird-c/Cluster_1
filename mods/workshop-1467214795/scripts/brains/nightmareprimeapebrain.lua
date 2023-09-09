require "behaviours/wander"
require "behaviours/panic"
require "behaviours/chaseandattack"

local BrainCommon = require("brains/braincommon")

local MAX_WANDER_DIST = 10

local MAX_CHASE_TIME = 60
local MAX_CHASE_DIST = 40


local NightmarePrimeapeBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function EquipWeapon(inst, weapon)
    if not weapon.components.equippable:IsEquipped() then
        inst.components.inventory:Equip(weapon)
    end
end

function NightmarePrimeapeBrain:OnStart()

    local root = PriorityNode(
    {
        BrainCommon.PanicTrigger(self.inst),

        SequenceNode({
            ActionNode(function() EquipWeapon(self.inst, self.inst.weaponitems.hitter) end, "Equip hitter"),
            ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST),
        }),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST),

    }, .25)
    self.bt = BT(self.inst, root)
end

return NightmarePrimeapeBrain
