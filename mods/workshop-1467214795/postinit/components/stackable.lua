local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local unpack = unpack

----------------------------------------------------------------------------------------
local Stackable = require("components/stackable")

local _Get = Stackable.Get
function Stackable:Get(num, ...)
    local rets = {_Get(self, num, ...)}

	if rets[1] and rets[1].components.visualvariant then
		rets[1].components.visualvariant:CopyOf(self.inst)
	end

    return unpack(rets)
end

