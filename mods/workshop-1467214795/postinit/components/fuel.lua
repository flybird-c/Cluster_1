local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local function onsecondaryfueltype(self, secondaryfueltype, old_secondaryfueltype)
    if old_secondaryfueltype ~= nil then
        self.inst:RemoveTag(old_secondaryfueltype.."_secondaryfuel")
    end
    if secondaryfueltype ~= nil then
        self.inst:AddTag(secondaryfueltype.."_secondaryfuel")
    end
end

IAENV.AddComponentPostInit("fuel", function(cmp)
    addsetter(cmp, "secondaryfueltype", onsecondaryfueltype)
end)
