local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local WaterPhysics = require("components/waterphysics")

-- Weak water obstacles are not true obstacles and can dont collide with ia waves
function WaterPhysics:SetIsWeak(weak)
    self.isweak = weak
end

function WaterPhysics:IsWeak()
    return self.isweak
end
