require("behaviours/runaway")
require("behaviours/wander")
require("behaviours/doaction")
require("behaviours/panic")
require("behaviours/minperiod")

local BrainCommon = require("brains/braincommon")

local SEE_FOOD_DIST = 15
local SEE_STRUCTURE_DIST = 30

local NO_TAGS = {"FX", "NOCLICK", "DECOR", "INLIMBO", "doydoyegg"}
local PICKABLE_FOODS =
{
    "berries",
    "cave_banana",
    "carrot",
    "limpets",
    "blue_cap",
    "green_cap",
}

local function EatFoodAction(inst)  -- Look for food to eat
    -- print("doydoybrain EatFoodAction")

    local target = nil
    local action = nil

    if inst.sg:HasStateTag("busy") and not
    inst.sg:HasStateTag("wantstoeat") then
        return
    end

    if inst.components.inventory and inst.components.eater then
        target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        if target then return BufferedAction(inst,target,ACTIONS.EAT) end
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, SEE_FOOD_DIST, nil, NO_TAGS, inst.components.eater:GetEdibleTags())

    if not target then
        for k, v in pairs(ents) do
            if v and inst.components.eater:CanEat(v) and
            v:GetTimeAlive() > 5 and
            v.components.inventoryitem and not
            v.components.inventoryitem:IsHeld() and
            v:IsOnPassablePoint() then
                target = v
                break
            end
        end
    end

    if target then
        local action = BufferedAction(inst,target,ACTIONS.PICKUP)
        return action
    end
end

local function StealFoodAction(inst)  -- Look for things to take food from (EatFoodAction handles picking up/ eating)
    -- print("doydoybrain StealFoodAction")

    -- Food On Ground > Pots = Farms = Drying Racks > Plants

    local target = nil

    if inst.sg:HasStateTag("busy") or
    (inst.components.inventory and inst.components.inventory:IsFull()) then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, SEE_STRUCTURE_DIST, nil, NO_TAGS)
    -- Look for crop/ cookpots/ drying rack, harvest them.
    if not target then
        for k,item in pairs(ents) do
            if ((item.components.stewer and item.components.stewer:IsDone()) or
            (item.components.dryer and item.components.dryer:IsDone()) or
            (item.components.crop and item.components.crop:IsReadyForHarvest())) and
            item:IsOnPassablePoint() then
                target = item
                break
            end
        end
    end

    if target then
        return BufferedAction(inst, target, ACTIONS.HARVEST)
    end

    -- Berrybushes, carrots etc.
    if not target then
        for k, item in pairs(ents) do
            if item.components.pickable and
            item.components.pickable.caninteractwith and
            item.components.pickable:CanBePicked() and
            table.contains(PICKABLE_FOODS, item.components.pickable.product) and
            item:IsOnPassablePoint() then
                target = item
                break
            end
        end
    end

    if target then
        return BufferedAction(inst, target, ACTIONS.PICK)
    end
end

local function MateAction(inst)
    if inst:HasTag("mating") and inst.components.mateable and inst.components.mateable:PartnerValid() then
        return BufferedAction(inst, inst.components.mateable:GetPartner(), ACTIONS.MATE, nil, nil, nil, TUNING.DOYDOY_MATING_DANCE_DIST)
    end
end

local DoydoyBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function DoydoyBrain:OnStart()

    local eatnode = PriorityNode({DoAction(self.inst, StealFoodAction)}, 2)

    local root = PriorityNode(
    {
        -- These birds are so crazy for mating, they don't even care if they're on fire during the act. No wonder they went extinct.
        DoAction(self.inst, function() return MateAction(self.inst) end, "Mate", true),

        BrainCommon.PanicTrigger(self.inst),

        DoAction(self.inst, EatFoodAction),
        MinPeriod(self.inst, math.random(4,6), false, eatnode),
        Wander(self.inst, nil, 15),
    }, 1)

    self.bt = BT(self.inst, root)

end

return DoydoyBrain
