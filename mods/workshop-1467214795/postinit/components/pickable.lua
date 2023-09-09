local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local function picked(inst, data)
    if data and data.loot then
        if data.loot.components and data.loot.components.visualvariant then
            data.loot.components.visualvariant:CopyOf(data.plant or inst)
        end
    end
end

IAENV.AddComponentPostInit("pickable", function(cmp)
    cmp.inst:ListenForEvent("picked", picked)
    cmp.inst:ListenForEvent("pickedbyworld", picked) -- To be added in the next update :)
end)
