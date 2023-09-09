local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local function TestDrowning(inst)
    if inst.components.drownable and inst.components.drownable:ShouldDrown() and inst.sg ~= nil then
        inst.sg:GoToState("sink")
    end
end

IAENV.AddPrefabPostInit("wobybig", function(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(0, TestDrowning)
end)
