local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Trap = require("components/trap")

local _OnUpdate = Trap.OnUpdate
function Trap:OnUpdate(...)
	if (not self.water and IsOnLand(self.inst)) or (self.water and IsOnOcean(self.inst)) then
		return _OnUpdate(self, ...)
	end
end
