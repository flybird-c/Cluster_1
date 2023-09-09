local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local FireDetector = require("components/firedetector")

--oceanic and volcanic witherables are immune to fire, cannot be restored when withered and due to the way they work are always counted as withered towards the firedetector component. So just stop it from targeting them altogether -Half
local Ignore_Tags = {"witherable_volcanic", "witherable_oceanic"}
local _NoTags = UpvalueHacker.GetUpvalue(FireDetector.ActivateEmergencyMode, "OnDetectEmergencyTargets", "NOTAGS")
for i,tag in pairs(Ignore_Tags) do
    table.insert(_NoTags, tag)
end
