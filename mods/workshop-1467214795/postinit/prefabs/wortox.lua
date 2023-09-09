local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function SailingCanBlinkTo(pt)
    return TheWorld.Map:IsOceanAtPoint(pt.x, pt.y, pt.z) and not TheWorld.Map:IsGroundTargetBlocked(pt)
end

local BLINKFOCUS_MUST_TAGS = { "blinkfocus" }

local _ReticuleTargetFn = nil
local function ReticuleTargetFn(inst, ...)
    if not inst:IsSailing() then
        return _ReticuleTargetFn(inst, ...)
    end

    local rotation = inst.Transform:GetRotation()
    local pos = inst:GetPosition()

    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.CONTROLLER_BLINKFOCUS_DISTANCE, BLINKFOCUS_MUST_TAGS)
    for _, v in ipairs(ents) do
        local epos = v:GetPosition()
        if distsq(pos, epos) > TUNING.CONTROLLER_BLINKFOCUS_DISTANCESQ_MIN then
            local angletoepos = inst:GetAngleToPoint(epos)
            local angleto = math.abs(anglediff(rotation, angletoepos))
            if angleto < TUNING.CONTROLLER_BLINKFOCUS_ANGLE then
                return epos
            end
        end
    end
    rotation = rotation * DEGREES

    pos.y = 0
    for r = 13, 4, -.5 do
        local offset = FindSwimmableOffset(pos, rotation, r, 1, false, true, SailingCanBlinkTo)
        if offset ~= nil then
            pos.x = pos.x + offset.x
            pos.z = pos.z + offset.z
            return pos
        end
    end
    for r = 13.5, 16, .5 do
        local offset = FindSwimmableOffset(pos, rotation, r, 1, false, true, SailingCanBlinkTo)
        if offset ~= nil then
            pos.x = pos.x + offset.x
            pos.z = pos.z + offset.z
            return pos
        end
    end
    pos.x = pos.x + math.cos(rotation) * 13
    pos.z = pos.z - math.sin(rotation) * 13
    return pos
end

local _GetPointSpecialActions = nil
local function GetPointSpecialActions(inst, pos, useitem, right, ...)
    if not inst:IsSailing() then
        return _GetPointSpecialActions(inst, pos, useitem, right, ...)
    end

    if right and useitem == nil and SailingCanBlinkTo(pos) and inst.CanSoulhop and inst:CanSoulhop() then
        return { ACTIONS.BLINK }
    end
    return {}
end

IAENV.AddPrefabPostInit("wortox", function(inst)
    inst:AddTag("allow_special_point_action_on_impassable")

    if not _ReticuleTargetFn then
        _ReticuleTargetFn = inst.components.reticule.targetfn
    end
    inst.components.reticule.targetfn = ReticuleTargetFn

    if not _GetPointSpecialActions then
        for i, v in ipairs(inst.event_listening["setowner"][inst]) do
            if UpvalueHacker.GetUpvalue(v, "GetPointSpecialActions") then
                _GetPointSpecialActions = UpvalueHacker.GetUpvalue(v, "GetPointSpecialActions")
                UpvalueHacker.SetUpvalue(v, GetPointSpecialActions, "GetPointSpecialActions")
                break
            end
        end
    end
end)
