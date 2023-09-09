local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local OceanColor = require("components/oceancolor")

local COLORS = UpvalueHacker.GetUpvalue(OceanColor.Initialize, "COLORS") or UpvalueHacker.GetUpvalue(OceanColor.OnPhaseChanged, "COLORS")

local _Initialize = OceanColor.Initialize
function OceanColor:Initialize(...)
    --@Mobbstar I'm confused about this, since it seems to be a permananent affect if the world has an island tag.
    --shouldn't this be some conditionally enabled thing? -Z
    if self.inst and self.inst:HasTag("island") then
        COLORS.default.color = {.5, .5, .4, 1} --gentle fog colour, not too bright
    end
    return _Initialize(self, ...)
end