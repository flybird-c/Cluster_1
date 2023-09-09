local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local FrostyBreather = require("components/frostybreather")

--This is, strictly speaking, very improper and inaccurate, but since this is just negligible fx, it should be fine -M
local _OnTemperatureChanged = FrostyBreather.OnTemperatureChanged
function FrostyBreather:OnTemperatureChanged(temperature)
    if IsInIAClimate(self.inst) then
		temperature = TheWorld.state.islandtemperature
	end
	return _OnTemperatureChanged(self, temperature)
end