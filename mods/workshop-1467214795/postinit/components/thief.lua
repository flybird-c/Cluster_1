local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Thief = require("components/thief")

function Thief:SetCanOpenContainers(canopen)
	self.canopencontainers = canopen
end

local _StealItem = Thief.StealItem
function Thief:StealItem(victim, ...)
	if not (victim.components.inventory and not victim.components.inventory.nosteal) and victim.components.container and not self.canopencontainers then
		return
	else
		_StealItem(self, victim, ...)
	end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddComponentPostInit("thief", function(cmp)
    cmp.canopencontainers = true
end)
