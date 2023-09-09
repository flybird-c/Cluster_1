local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Cookable = require("components/cookable")

local _Cook = Cookable.Cook
function Cookable:Cook(...)
    local prod = _Cook(self, ...)

	if prod.components.visualvariant then
		prod.components.visualvariant:CopyOf(self.inst)
	end

	return prod
end
