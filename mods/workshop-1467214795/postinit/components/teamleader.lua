local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local TeamLeader = require("components/teamleader")

function TeamLeader:SetKeepThreatFn(fn)
    self.keepthreatfn = fn
end

function TeamLeader:KeepThreat()
    if self.threat and self.keepthreatfn then
        return self.keepthreatfn(self.inst, self.threat)
    else
        return true
    end
end

local _OnUpdate = TeamLeader.OnUpdate
local function OnUpdate(self, ...)
    _OnUpdate(self, ...)

    if self.inst and self.inst:IsValid() then
        if self.threat and not self:KeepThreat() then
            self:DisbandTeam()
        end
    end
end