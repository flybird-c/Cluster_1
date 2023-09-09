local IAENV = env
GLOBAL.setfenv(1, GLOBAL)
--------------------------------------------------------------

require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"

local STOP_RUN_DIST = 10
local SEE_PLAYER_DIST = 5

local AVOID_PLAYER_DIST = 3
local AVOID_PLAYER_STOP = 6

local SEE_BAIT_DIST = 20

WobsterBrain = require("brains/wobsterbrain")

local should_go_home = UpvalueHacker.GetUpvalue(WobsterBrain.OnStart, "should_go_home")
local function IA_should_go_home(inst, ...)
    if inst.sg:HasStateTag("trapped") then
        return false
    end
    -- if monsoon season then go home
    if IsInIAClimate(inst) and TheWorld.state.isspring then
        return true
    end
    return should_go_home(inst, ...)
end

UpvalueHacker.SetUpvalue(WobsterBrain.OnStart, IA_should_go_home, "should_go_home")

local CANT_TAGS = {"planted"}
local function EatFoodAction(inst)
    local target = FindEntity(inst, SEE_BAIT_DIST, function(item) return inst.components.eater and inst.components.eater:CanEat(item) and item.components.bait and not (item.components.inventoryitem and item.components.inventoryitem:IsHeld()) end, nil, CANT_TAGS)
    if target then
        local act = BufferedAction(inst, target, ACTIONS.EAT)
        act.validfn = function() return not (target.components.inventoryitem and target.components.inventoryitem:IsHeld()) end
        return act
    end
end

local function BrainScan(start, depth)
    depth = depth or 0
    for i,child_node in pairs(start.children or {}) do
        print(depth, string.rep("  ", depth) .. child_node.name)
        BrainScan(child_node, depth + 1)
    end
end

local function FindNode(start, name, ...)
    for i,child_node in pairs(start.children or {}) do
        if child_node.name == name then
            if not ... then return i, start end
            local index, node = FindNode(child_node, ...)
            if node then return index, node end
        end
    end
end

local function is_sailing(hunter)
    return hunter ~= nil and hunter:IsSailing()
end

IAENV.AddBrainPostInit("wobsterbrain", function(brain)
    local root = brain.bt.root
    
    local index, node = FindNode(root, "Parallel", "Priority", "Parallel", "Should Go Home")

    if node then
        table.insert(node.children, index + 1, DoAction(brain.inst, EatFoodAction))
        table.insert(node.children, index, RunAway(brain.inst, "player", AVOID_PLAYER_DIST, AVOID_PLAYER_STOP, is_sailing))
        table.insert(node.children, index, RunAway(brain.inst, "player", SEE_PLAYER_DIST, STOP_RUN_DIST, is_sailing, true))
    end
end)