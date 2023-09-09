local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local _DoCheckTemp
local function DoCheckTemp(inst, ...)
    local _temperature = rawget(TheWorld.state, "temperature")
    if IsInIAClimate(inst) then
        TheWorld.state.temperature = TheWorld.state.islandtemperature
    end
    if _DoCheckTemp ~= nil then
        _DoCheckTemp(inst, ...)
    end
    if not inst:HasTag("burnt") and inst:HasTag("flooded") then
        inst.AnimState:SetPercent("meter", math.random())
    end
    TheWorld.state.temperature = _temperature
end

IAENV.AddPrefabPostInit("winterometer", function(inst)
    inst:AddComponent("floodable")

    if not TheWorld.ismastersim then
        return
    end

    inst.components.floodable:SetFX("shock_machines_fx", 5)

    if not _DoCheckTemp then
        local StartCheckTemp = inst:GetEventCallbacks("animover")
        _DoCheckTemp = UpvalueHacker.GetUpvalue(StartCheckTemp, "DoCheckTemp")
        UpvalueHacker.SetUpvalue(StartCheckTemp, DoCheckTemp, "DoCheckTemp")
    end

    -- reset
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end

    inst:PushEvent("animover")
end)

