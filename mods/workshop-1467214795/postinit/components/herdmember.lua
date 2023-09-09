local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local HerdMember = require("components/herdmember")

local _CreateHerd = HerdMember.CreateHerd
function HerdMember:CreateHerd()
    _CreateHerd(self)
    if self.herd and self.inst and self.createherdfn then
        self.createherdfn(self.inst, self.herd)
    end
end
