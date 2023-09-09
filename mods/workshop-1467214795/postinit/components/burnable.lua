local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Burnable = require("components/burnable")

local _SpawnFX = Burnable.SpawnFX
function Burnable:SpawnFX(...)
    if self.nofx then
        return
    end
    return _SpawnFX(self, ...)
end

local _Ignite = Burnable.Ignite
function Burnable:Ignite(...)
    if self.restorelimbo then
        self.inst:AddTag("INLIMBO")
        self.restorelimbo = nil
    end
    return _Ignite(self, ...)
end

local _IsBurning = Burnable.IsBurning
function Burnable:IsBurning(...)
    if self.inst:HasTag("ignoreburning") then --this might break other things? --Z hopefully it won't since only inv items should get this tag.
        return false
    end
    return _IsBurning(self, ...)
end

function Burnable:SetIgnoreBurning(ignore)
    if ignore then
        self.inst:AddTag("ignoreburning")
    else
        self.inst:RemoveTag("ignoreburning")
    end
end

function Burnable:RestoreLimbo() --see postinit/lighter.lua -Z
    self.restorelimbo = true
end

function Burnable:SetAllowInventoryBurning(allow)
    if allow then
        self.inst:AddTag("allowinventoryburning")
    else
        self.inst:RemoveTag("allowinventoryburning")
    end
end