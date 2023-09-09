local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local unpack = unpack

----------------------------------------------------------------------------------------
local Explosive = require("components/explosive")

local _OnBurnt = Explosive.OnBurnt
function Explosive:OnBurnt(...)
    local pos = self.inst ~= nil and self.inst:GetPosition() or nil
    local rets = {_OnBurnt(self, ...)}
    TheWorld:PushEvent("explosion_heard", pos)
    return unpack(rets)
end
