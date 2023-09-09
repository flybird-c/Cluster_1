require("behaviours/wander")
require("behaviours/runaway")
require("behaviours/doaction")
require("behaviours/panic")

local BrainCommon = require("brains/braincommon")

local STOP_RUN_DIST = 12
local SEE_PLAYER_DIST = 7

local AVOID_PLAYER_DIST = 5
local AVOID_PLAYER_STOP = 8

local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 30

local SEE_BAIT_DIST = 20
local MAX_IDLE_WANDER_DIST = TUNING.SOLOFISH_WANDER_DIST

local WANDER_DIST_DAY = 8
local WANDER_DIST_NIGHT = 4

local START_FACE_DIST = 4
local KEEP_FACE_DIST = 6

local START_FOLLOW_DIST = 13

local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 8
local TARGET_FOLLOW_DIST = 2

local SEE_LIGHT_DIST = 30

local SEE_FOOD_DIST = 10
local SEE_CORAL_DIST = 15
local KEEP_MINING_DIST = 10

local SHORE_MAX_FOLLOW_DIST = TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 13
local SHORE_TARGET_FOLLOW_DIST = TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 4

local BallphinBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self.afraid = false
end)


function BallphinBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()), true)
end

local wandertimes =
{
    minwalktime = 2,
    randwalktime =  2,
    minwaittime = 0.1,
    randwaittime = 0.1,
}

-- local function EatFoodAction(inst)
--     local notags = {"FX", "NOCLICK", "DECOR","INLIMBO"}
--     local target = FindEntity(inst, SEE_BAIT_DIST, function(item) return inst.components.eater:CanEat(item) and item.components.bait and not item:HasTag("planted") and not (item.components.inventoryitem and item.components.inventoryitem:IsHeld()) end, nil, notags)
--     if target then
--         local act = BufferedAction(inst, target, ACTIONS.EAT)
--         act.validfn = function() return not (target.components.inventoryitem and target.components.inventoryitem:IsHeld()) end
--         return act
--     end
-- end

local function GetCloesestPlatformPlayer(x, y, z, radius)
    local platform = TheWorld.Map:GetNearbyPlatformAtPoint(x, y, z, radius)
    local walkableplatform = platform and platform.components.walkableplatform or nil
	if walkableplatform == nil then return end

    local player = nil
    local rangesq = (radius + walkableplatform.platform_radius * 2) ^ 2
    for k in pairs(walkableplatform:GetPlayersOnPlatform()) do
        if k ~= nil and k.entity:IsVisible()then
            local distsq = k:GetDistanceSqToPoint(x, y, z)
            if distsq < rangesq then
                rangesq = distsq
                player = k
            end
        end
    end
    return player
end

local function GetLeader(inst)
    return inst.components.follower.leader
end

local function GetWanderDistFn(inst)
    return TheWorld.state.isday and WANDER_DIST_DAY or WANDER_DIST_NIGHT
end

local function GetFaceTargetFn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local target = FindClosestPlayerInRange(x, y, z, START_FACE_DIST) or GetCloesestPlatformPlayer(x, y, z, START_FACE_DIST)
    if target and not target:HasTag("notarget") then
        return target
    end
end

local function KeepFaceTargetFn(inst, target)
    return inst:GetDistanceSqToInst(target) <= KEEP_FACE_DIST*KEEP_FACE_DIST and not target:HasTag("notarget")
end

local function GetFollowTargetFn(inst)
    if not GetLeader(inst) then
        local x, y, z = inst.Transform:GetWorldPosition()
        local target = FindClosestPlayerInRange(x, y, z, START_FOLLOW_DIST) or GetCloesestPlatformPlayer(x, y, z, START_FOLLOW_DIST)
        if target and not target:HasTag("notarget") then
            return target
        end
    end
end

local function HasValidHome(inst)
    return inst.components.homeseeker
    and inst.components.homeseeker:HasHome()
end

local function GoHomeAction(inst)
    if not GetLeader(inst) and not inst.components.combat.target and HasValidHome(inst) then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

-- local function GetTraderFn(inst)
--     return FindEntity(inst, TRADE_DIST, function(target) return inst.components.trader:IsTryingToTradeWithMe(target) end, {"player"})
-- end

-- local function KeepTraderFn(inst, target)
--     return inst.components.trader:IsTryingToTradeWithMe(target)
-- end

-- local function GetHomePos(inst)
--     return HasValidHome(inst) and inst.components.homeseeker:GetHomePos()
-- end

-- local function GetNoLeaderHomePos(inst)
--     if GetLeader(inst) then
--         return nil
--     end
--     return GetHomePos(inst)
-- end

-- I don't bother checking this function -M
local function FindFoodAction(inst)
    local target = nil

    if inst.sg:HasStateTag("busy") then
        return
    end

    if inst.components.inventory and inst.components.eater then
        target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
    end

    local time_since_eat = inst.components.eater:TimeSinceLastEating()
    local noveggie = time_since_eat and time_since_eat < TUNING.PIG_MIN_POOP_PERIOD*4

    if not target and (not time_since_eat or time_since_eat > TUNING.PIG_MIN_POOP_PERIOD*2) then

        target = FindEntity(inst, SEE_FOOD_DIST, function(item)
                if item:GetTimeAlive() < 8 then return false end
                if item.prefab == "mandrake" then return false end
                if noveggie and item.components.edible and item.components.edible.foodtype ~= "MEAT" then
                    return false
                end
                if not item:IsOnOcean() then
                    return false
                end

                return inst.components.eater:CanEat(item)
            end)

    end

    if target then
        return BufferedAction(inst, target, ACTIONS.EAT)
    end

    if not target and (not time_since_eat or time_since_eat > TUNING.PIG_MIN_POOP_PERIOD*2) then
        target = FindEntity(inst, SEE_FOOD_DIST, function(item)
                if not item.components.shelf then return false end
                if not item.components.shelf.itemonshelf or not item.components.shelf.cantakeitem then return false end
                if noveggie and item.components.shelf.itemonshelf.components.edible and item.components.shelf.itemonshelf.components.edible.foodtype ~= "MEAT" then

                    return false
                end
                if not item:IsOnOcean() then
                    return false
                end

                return inst.components.eater:CanEat(item.components.shelf.itemonshelf)
            end)
    end

    if target then
        return BufferedAction(inst, target, ACTIONS.TAKEITEM)
    end

end

local function KeepMiningAction(inst)
    local leader = GetLeader(inst)
    return leader and leader:GetDistanceSqToInst(inst) <= KEEP_MINING_DIST*KEEP_MINING_DIST
    or FindEntity(inst, SEE_CORAL_DIST/3, function(item)
            return item.components.workable and item.components.workable.action == ACTIONS.MINE
        end)
end

local function StartMiningCondition(inst)
    local leader = GetLeader(inst)
    return leader and leader.sg
    and (leader.sg:HasStateTag("mining") or leader.sg:HasStateTag("premine"))
end

local function FindCoralToMineAction(inst)
    local target = FindEntity(inst, SEE_CORAL_DIST, function(item) return item.components.workable and item.components.workable.action == ACTIONS.MINE end)
    if target then
        return BufferedAction(inst, target, ACTIONS.MINE)
    end
end

-- local function SafeLightDist(inst, target)
--     return (target:HasTag("player") or target:HasTag("playerlight")
--         or (target.inventoryitem and target.inventoryitem:GetGrandOwner() and target.inventoryitem:GetGrandOwner():HasTag("player")))
--         and 4
--         or target.Light:GetCalculatedRadius() / 3
-- end

local function GetWanderPos(inst)
    if not GetLeader(inst) then
        return inst.components.knownlocations:GetLocation("herd")
    end
end

local function GetFollowPosition(inst, target)
    if not target then
        return nil
    end

    local leader_platform = target:GetCurrentPlatform()
    if not leader_platform then
        local lx, ly, lz = target.Transform:GetWorldPosition()
        local leader_position = Vector3(lx, ly, lz)
        if TheWorld.Map:IsOceanAtPoint(lx, ly, lz) then
            return leader_position
        else
            local swim_offset = FindSwimmableOffset(leader_position, 0, SHORE_TARGET_FOLLOW_DIST)
            if swim_offset then
                return leader_position + swim_offset
            else
                return inst:GetPosition()
            end
        end
    end

    -- From here on, our leader has a platform!
    local platform_velocity = Vector3(leader_platform.components.boatphysics.velocity_x or 0, 0, leader_platform.components.boatphysics.velocity_z or 0)
    local platform_speed_sq = platform_velocity:LengthSq()
    if platform_speed_sq > 1 then
        local offset = inst:GetFormationOffsetNormal(target, leader_platform, platform_velocity)

        return inst:GetPosition() + offset
    else
        local myx, myy, myz = inst.Transform:GetWorldPosition()
        local px, py, pz = leader_platform.Transform:GetWorldPosition()
        local direction_to_inst = Vector3(myx - px, myy - py, myz - pz):Normalize()
        local radius = leader_platform.components.walkableplatform and leader_platform.components.walkableplatform.platform_radius or SHORE_MAX_FOLLOW_DIST

        return leader_platform:GetPosition() + (direction_to_inst * radius)
    end
end

local function GetFollowDistance(inst, target)
    if not target then
        return MAX_FOLLOW_DIST
    end

    local leader_platform = target:GetCurrentPlatform()
    if not leader_platform then
        if target:IsOnOcean() then
            return MAX_FOLLOW_DIST
        else
            return SHORE_MAX_FOLLOW_DIST
        end
    end

    local platform_speed_sq = (leader_platform.components.boatphysics.velocity_x or 0)^2 + (leader_platform.components.boatphysics.velocity_z or 0)^2
    if platform_speed_sq > TUNING.BALLPHIN_WALK_SPEED^2 then
        return TARGET_FOLLOW_DIST
    else
        return MAX_FOLLOW_DIST
    end
end

local function ShouldTriggerPanic(inst)
	return (inst.components.health ~= nil and inst.components.health.takingfiredamage)
		or (inst.components.hauntable ~= nil and inst.components.hauntable.panic)
        or inst.ballphin_panic_task ~= nil
end

local function ShouldGoHome(inst)
    return not GetLeader(inst) and HasValidHome(inst) and not TheWorld.state.isday
end

function BallphinBrain:OnStart()
    local root = PriorityNode(
    {

        WhileNode(function() return not self.inst.entity:IsVisible() end, "Hiding", StandStill(self.inst)),
        WhileNode(function() return not self.inst:HasTag("ballphinfriend") end, "Not a ballphinfriend", ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)),
        WhileNode(function() return self.inst:HasTag("ballphinfriend") end, "a ballphinfriend", ChaseAndAttack(self.inst, 100)),
        ChattyNode(self.inst, STRINGS.BALLPHIN_TALK_FIND_MEAT, DoAction(self.inst, FindFoodAction)),
        WhileNode(function() return ShouldTriggerPanic(self.inst) end, "IsAfraid",
            PriorityNode{
                ChattyNode(self.inst, STRINGS.BALLPHIN_TALK_FIND_LIGHT,
                    FindLight(self.inst, SEE_LIGHT_DIST)),
                ChattyNode(self.inst, STRINGS.BALLPHIN_TALK_PANIC,
                    Panic(self.inst)),
            },1),

        WhileNode(function() return ShouldGoHome(self.inst) end, "IsNight",
            PriorityNode{
                ChattyNode(self.inst, STRINGS.BALLPHIN_TALK_HOME,
                    DoAction(self.inst, GoHomeAction, "go home", true)),
            },1),
        -- Swapped to Leash for better follow positions. Works the same because the min dist was 0 -_-
        ChattyNode(self.inst, STRINGS.BALLPHIN_TALK_FOLLOWWILSON, Leash(self.inst, function() return GetFollowPosition(self.inst, GetLeader(self.inst)) end, function() return GetFollowDistance(self.inst, GetLeader(self.inst)) end, TARGET_FOLLOW_DIST)),
        Leash(self.inst, GetWanderPos, 30, 20),
        WhileNode(function() return TheWorld.state.isday end, "IsDay",
            PriorityNode{
                IfNode(function() return StartMiningCondition(self.inst) end, "mine",
                    WhileNode(function() return KeepMiningAction(self.inst) end, "keep mining",
                        LoopNode{
                            ChattyNode(self.inst, STRINGS.BALLPHIN_TALK_HELP_MINE_CORAL,
                            DoAction(self.inst, FindCoralToMineAction))}))
            },1),
        Leash(self.inst, function() return GetFollowPosition(self.inst, GetFollowTargetFn(self.inst)) end, function() return GetFollowDistance(self.inst, GetFollowTargetFn(self.inst)) end, TARGET_FOLLOW_DIST),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, GetWanderPos, GetWanderDistFn),
    }, .25)
    self.bt = BT(self.inst, root)
end

return BallphinBrain
