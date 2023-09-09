local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Childspawner = require("components/childspawner")

local _DoSpawnChild = Childspawner.DoSpawnChild
function Childspawner:DoSpawnChild(target, prefab, radius, ...)
    if self.inst.prefab == "spiderden" and (prefab == "spider_warrior" or self.childname == "spider_warrior") and IsInIAClimate(self.inst) then
        local _childname = rawget(self, "childname")
        self.childname = "tropical_spider_warrior"
        local child = _DoSpawnChild(self, target, "tropical_spider_warrior", radius, ...)
        self.childname = _childname
        return child
    end
    return _DoSpawnChild(self, target, prefab, radius, ...)
end

--ballphinhouses can regen up to one ballphin but can hold an infinite amount due to the blackhole magic of collage dorms -Half
local _AddChildrenInside = Childspawner.AddChildrenInside
function Childspawner:AddChildrenInside(count, ...)
    if self.allowmorethanmaxchildren then
        if self.childreninside == 0 and self.onoccupied then
            self.onoccupied(self.inst)
        end
        self.childreninside = self.childreninside + count
        self.childreninside = math.min(1000, self.childreninside)--large limit that should never be reached just in case
        if self.onaddchild ~= nil then
            self.onaddchild(self.inst, count)
        end

        self:TryStopUpdate() --try to stop the update because regening conditions might be invalid now.
        self:StartUpdate() --try to start the update because spawning conditions might be valid now.
    else
        _AddChildrenInside(self, count, ...)
    end
end

