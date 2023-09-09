
local IAENV = env
GLOBAL.setfenv(1, GLOBAL)
--------------------------------------------------------------

local ShadowWaxwellBrain = require("brains/shadowwaxwellbrain")

local DIG_TAGS = {"magmarock", "magmarock_gold", "sanddune", "buriedtreasure"}
local _DIG_TAGS = UpvalueHacker.GetUpvalue(ShadowWaxwellBrain.OnStart, "DIG_TAGS")

for i,tag in pairs(DIG_TAGS) do
    table.insert(_DIG_TAGS, tag)
end

local ANY_TOWORK_MUSTONE_TAGS = {"HACK_workable"}
local _ANY_TOWORK_MUSTONE_TAGS = UpvalueHacker.GetUpvalue(ShadowWaxwellBrain.OnStart, "FindAnyEntityToWorkActionsOn", "ANY_TOWORK_MUSTONE_TAGS")

for i,tag in pairs(ANY_TOWORK_MUSTONE_TAGS) do
    table.insert(_ANY_TOWORK_MUSTONE_TAGS, tag)
end

local TOWORK_CANT_TAGS = {"limpet_rock"}
local _TOWORK_CANT_TAGS = UpvalueHacker.GetUpvalue(ShadowWaxwellBrain.OnStart, "FindAnyEntityToWorkActionsOn", "TOWORK_CANT_TAGS")

for i,tag in pairs(TOWORK_CANT_TAGS) do
    table.insert(_TOWORK_CANT_TAGS, tag)
end

local function GetLeader(inst)
    return inst.components.follower.leader
end

-- Ugh this is painful
local _FindAnyEntityToWorkActionsOn = UpvalueHacker.GetUpvalue(ShadowWaxwellBrain.OnStart, "FindAnyEntityToWorkActionsOn")
local _PickValidActionFrom = UpvalueHacker.GetUpvalue(_FindAnyEntityToWorkActionsOn, "PickValidActionFrom")
local IgnoreThis = UpvalueHacker.GetUpvalue(_FindAnyEntityToWorkActionsOn, "IgnoreThis")
local _FilterAnyWorkableTargets = UpvalueHacker.GetUpvalue(_FindAnyEntityToWorkActionsOn, "FilterAnyWorkableTargets")

-- Note: Storing globals in lua is much more effecient than calling the global constantly -Half
local HACK_ACTION = ACTIONS.HACK
local function PickValidActionFrom(target, ...)
    if target.components.hackable ~= nil and (target.components.workable == nil or target.components.hackable:CanBeHacked()) then
        return HACK_ACTION
    end

    return _PickValidActionFrom(target, ...)
end


local function FilterAnyWorkableTargets(targets, ignorethese, leader, worker, ...)
    -- Needed to stop conflicts with diggable
    for _, sometarget in ipairs(targets) do
        if ignorethese[sometarget] ~= nil and ignorethese[sometarget].worker ~= worker then
            -- Ignore me!
        elseif sometarget.components.burnable == nil or (not sometarget.components.burnable:IsBurning() and not sometarget.components.burnable:IsSmoldering()) then
            if sometarget:HasTag("HACK_workable") then
                if sometarget.components.hackable ~= nil and sometarget.components.hackable:GetHacksLeft() == 1 then
                    IgnoreThis(sometarget, ignorethese, leader, worker)
                end
                return sometarget
            end
        end
    end
    return _FilterAnyWorkableTargets(targets, ignorethese, leader, worker, ...)
end

local function FindAnyEntityToWorkActionsOn(inst, ignorethese, ...)
	if inst.sg:HasStateTag("busy") then
		return _FindAnyEntityToWorkActionsOn(inst, ignorethese, ...)
	end
    local leader = GetLeader(inst)
    if leader == nil then -- There is no purpose for a puppet without strings attached.
        return _FindAnyEntityToWorkActionsOn(inst, ignorethese, ...)
    end

    local target = inst.sg.statemem.target

    local action = nil
    if target ~= nil and target:IsValid() and not (target:IsInLimbo() or target:HasTag("NOCLICK") or target:HasTag("event_trigger")) and
        target:IsOnValidGround() and target.components.hackable ~= nil and target.components.hackable:CanBeHacked() and
        not (target.components.burnable ~= nil and (target.components.burnable:IsBurning() or target.components.burnable:IsSmoldering())) and
        target.entity:IsVisible() then
        -- Check if action is the one desired still.
        action = PickValidActionFrom(target)

        if action ~= nil and ignorethese[target] == nil then
            if target.components.hackable:GetHacksLeft() == 1 then
                IgnoreThis(target, ignorethese, leader, inst)
            end
            return BufferedAction(inst, target, action)
        end
    end

    return _FindAnyEntityToWorkActionsOn(inst, ignorethese, ...)
end

UpvalueHacker.SetUpvalue(_FindAnyEntityToWorkActionsOn, PickValidActionFrom, "PickValidActionFrom")
UpvalueHacker.SetUpvalue(_FindAnyEntityToWorkActionsOn, FilterAnyWorkableTargets, "FilterAnyWorkableTargets")
UpvalueHacker.SetUpvalue(ShadowWaxwellBrain.OnStart, FindAnyEntityToWorkActionsOn, "FindAnyEntityToWorkActionsOn")