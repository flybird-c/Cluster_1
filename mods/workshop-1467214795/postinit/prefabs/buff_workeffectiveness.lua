local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

IAENV.AddPrefabPostInit("buff_workeffectiveness", function(inst)
    local work_attach = UpvalueHacker.GetUpvalue(inst.components.debuff.onattachedfn, "onattachedfn")
    local function new_attachedfn(inst, target)
        if target.components.workmultiplier ~= nil then
            target.components.workmultiplier:AddMultiplier(ACTIONS.HACK, TUNING.BUFF_WORKEFFECTIVENESS_MODIFIER, inst)
        end
        work_attach(inst, target)
    end
    UpvalueHacker.SetUpvalue(inst.components.debuff.onattachedfn, new_attachedfn, "onattachedfn")
    local work_detach = UpvalueHacker.GetUpvalue(inst.components.debuff.ondetachedfn, "ondetachedfn")
    local function new_detachedfn(inst, target)
        if target.components.workmultiplier ~= nil then
            target.components.workmultiplier:RemoveMultiplier(ACTIONS.HACK, inst)
        end
        work_detach(inst, target)
    end
    UpvalueHacker.SetUpvalue(inst.components.debuff.ondetachedfn, new_detachedfn, "ondetachedfn")
end)