local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Tackler = require("components/tackler")

local function _CheckEdge(x, z, dist, rot)
    rot = rot * DEGREES
    x = x + math.cos(rot) * dist
    z = z - math.sin(rot) * dist
    return not IsOnLand(x, 0, z)
end

local CheckEdge_old = Tackler.CheckEdge
function Tackler:CheckEdge(...)

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local rot = self.inst.Transform:GetRotation()
    --return true if it detects IA edge at any angle, or default edge at all angles
    return _CheckEdge(x, z, self.edgedistance, rot)
        or _CheckEdge(x, z, self.edgedistance, rot + 30)
        or _CheckEdge(x, z, self.edgedistance, rot - 30)
		or CheckEdge_old(self, ...)
end

-- IAENV.AddComponentPostInit("tackler", function(cmp)
-- end)
