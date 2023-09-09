require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/chaseandram"
require "behaviours/chaseandattack"
require "behaviours/standandattack"
require "behaviours/leash"

local MAX_CHASE_TIME = 10
local GIVE_UP_DIST = 20
local MAX_CHARGE_DIST = 60

local wandertimes =
{
    minwalktime = 5,
    randwalktime =  3,
    minwaittime = 0,
    randwaittime = 0,
}

local function GetWanderPos(inst)
    if inst:IsNearPlayer(60, true) then
        return inst:GetNearestPlayer(true):GetPosition()
    elseif inst.components.knownlocations:GetLocation("home") then
        return inst.components.knownlocations:GetLocation("home")
    elseif inst.components.knownlocations:GetLocation("spawnpoint") then
        return inst.components.knownlocations:GetLocation("spawnpoint")
    end
end

local function GetNewHome(inst)
    if inst.forgethometask then
        inst.forgethometask:Cancel()
        inst.forgethometask = nil
    end
    -- Pick a point to go to that is some distance away from here.
    local targetPos = Vector3(inst.Transform:GetWorldPosition())
    local wanderAwayPoint = GetWanderAwayPoint(targetPos)
    if wanderAwayPoint then
        inst.components.knownlocations:RememberLocation("home", wanderAwayPoint)
    end

    inst.forgethometask = inst:DoTaskInTime(30, function() inst.components.knownlocations:ForgetLocation("home") end)
end

local function GetHomePos(inst)
    if not inst.components.knownlocations:GetLocation("home") then
        GetNewHome(inst)
    end
    return inst.components.knownlocations:GetLocation("home")
end

local TwisterBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function TwisterBrain:OnStart()
    local root =
        PriorityNode(
        {
            WhileNode(function() return self.inst.sg:HasStateTag("running") or 
                (self.inst.CanCharge and self.inst.components.combat.target and self.inst.components.combat.target:GetPosition():Dist(self.inst:GetPosition()) >= TUNING.TWISTER_ATTACK_RANGE) end, 
                "Charge Behaviours", ChaseAndRam(self.inst, MAX_CHASE_TIME, GIVE_UP_DIST, MAX_CHARGE_DIST)),
            WhileNode(function() return not self.inst.CanCharge or (self.inst.components.combat.target and self.inst.components.combat.target:GetPosition():Dist(self.inst:GetPosition()) < TUNING.TWISTER_ATTACK_RANGE) end, "Attack Behaviours", ChaseAndAttack(self.inst, nil, nil, nil, nil, true)),
            WhileNode(function() return self.inst.shouldGoAway end, "Should Leave", Wander(self.inst, GetHomePos, 20)),
            Wander(self.inst, GetWanderPos, 20, wandertimes),
        }, .25)
    
    self.bt = BT(self.inst, root)
end

function TwisterBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", Point(self.inst.Transform:GetWorldPosition()))
end

return TwisterBrain
