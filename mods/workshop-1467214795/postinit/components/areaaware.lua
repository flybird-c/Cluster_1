local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local AreaAware = require("components/areaaware")

local _OnRemoveFromEntity = AreaAware.OnRemoveFromEntity
function AreaAware:OnRemoveFromEntity(...)
	self.inst:RemoveEventCallback("embark", embark)
	return _OnRemoveFromEntity(self, ...)
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local function embark(inst)
    if inst.components.areaaware then
        inst.components.areaaware:UpdatePosition(inst.Transform:GetWorldPosition())
    end
end

IAENV.AddComponentPostInit("areaaware", function(cmp)
    --Not using this event makes the whole thing a bit less precise,
    --sometimes requiring people to sail a bit for the effects to stop.
    cmp.inst:ListenForEvent("embark", embark)
end)
