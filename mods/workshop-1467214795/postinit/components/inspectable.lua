local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Inspectable = require("components/inspectable")

local _GetStatus = Inspectable.GetStatus
function Inspectable:GetStatus(viewer, ...)
	return _GetStatus(self, viewer, ...) or self.inst ~= viewer and self.inst:HasTag("flooded") and "FLOODED" or nil
end

local _GetDescription = Inspectable.GetDescription
function Inspectable:GetDescription(viewer, ...)
    local desc, filter_context, author = _GetDescription(self, viewer, ...)

    if desc ~= nil and (self.getspecialdescription or self.descriptionfn or self.description) and viewer ~= nil and viewer:HasTag("monkeyking") and CanEntitySeeTarget(viewer, self.inst) then
        return GetDescription(viewer, self.inst, self:GetStatus(viewer))
    end

    return desc, filter_context, author
end
