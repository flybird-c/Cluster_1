local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------


-- local _hit_event_animover = inst.states["hit"].events["animover"].fn
local function hit_event_animover(inst, ...)
    local pos = inst:GetPosition()
    local offset = FindWalkableOffset(pos, 2*math.pi*math.random(), 10, 12)

    if offset then
        pos = pos + offset
        inst.Transform:SetPosition(pos:Get())
    end

    inst.sg:GoToState("appear")
end


----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddStategraphPostInit("shadowcreature", function(sg)


-- _hit_event_animover = sg.states["hit"].events["animover"].fn
sg.states["hit"].events["animover"].fn = hit_event_animover


end)
