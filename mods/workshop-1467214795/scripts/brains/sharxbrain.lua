require("behaviours/wander")
require("behaviours/chaseandattack")
require("behaviours/panic")
require("behaviours/attackwall")
require("behaviours/minperiod")
require("behaviours/leash")
require("behaviours/faceentity")
require("behaviours/doaction")
require("behaviours/standstill")

local BrainCommon = require("brains/braincommon")

local SharxBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local SEE_DIST = 30

local MIN_FOLLOW_LEADER = 2
local MAX_FOLLOW_LEADER = 6
local TARGET_FOLLOW_LEADER = (MAX_FOLLOW_LEADER+MIN_FOLLOW_LEADER) / 2

local LEASH_RETURN_DIST = 10
local LEASH_MAX_DIST = 40

local HOUSE_MAX_DIST = 40
local HOUSE_RETURN_DIST = 50

local SIT_BOY_DIST = 10

local function EatFoodAction(inst)
    local notags = {"FX", "NOCLICK", "DECOR","INLIMBO"}
    -- local mustonetags = {"floating"}
    local target = FindEntity(inst, SEE_DIST, function(item) return inst.components.eater:CanEat(item) and item:IsOnOcean() and (item.components.floater and item.components.floater:IsFloating()) end, nil, notags--[[, mustonetags--]])
    if target then
        return BufferedAction(inst, target, ACTIONS.EAT)
    end
end

local function GetLeader(inst)
    return inst.components.follower and inst.components.follower.leader
end


local function GetWanderPoint(inst)
    local target = GetLeader(inst)

    if target == nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local players = FindPlayersInRange(x, y, z, 25)
        local randomtarget = (players and #players > 0 and math.random(#players)) or nil
        target = randomtarget and players[randomtarget]
    end

    if target and target:IsOnOcean() then
        return target:GetPosition()
    else
        return inst:GetPosition()
    end
end

local function HarvestAction(inst)
    local target = FindEntity(inst, SEE_DIST, function(item) return item.components.breeder and item.components.breeder.volume > 0 end)
    if target then
        return BufferedAction(inst, target, ACTIONS.HARVEST)
    end
end

function SharxBrain:OnStart()
    local root = PriorityNode(
    {
        BrainCommon.PanicTrigger(self.inst),

        ChaseAndAttack(self.inst, 100),

        DoAction(self.inst, HarvestAction, "harvest", true ),
        DoAction(self.inst, EatFoodAction, "eat food", true),
        Follow(self.inst, GetLeader, MIN_FOLLOW_LEADER, TARGET_FOLLOW_LEADER, MAX_FOLLOW_LEADER),
        FaceEntity(self.inst, GetLeader, GetLeader),

        Wander(self.inst, GetWanderPoint, 20),
    }, .25)

    self.bt = BT(self.inst, root)
end

return SharxBrain
