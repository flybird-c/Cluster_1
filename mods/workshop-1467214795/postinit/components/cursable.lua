local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Cursable = require("components/cursable")

local _IsCursable = Cursable.IsCursable
function Cursable:IsCursable(item, ...)
    local curse = nil
    if item and item.components.curseditem then
        curse = item.components.curseditem.curse
    end

    if curse and self.inst:HasTag(curse.."_curseimmune") then
        return false
    end
    
    return _IsCursable(self, item, ...)
end

local _ApplyCurse = Cursable.ApplyCurse
function Cursable:ApplyCurse(item, curse, ...)
	if item and item.components.curseditem then
		curse = item.components.curseditem.curse
	end

    if curse and self.inst:HasTag(curse.."_curseimmune") then
        return false
    end

    return _ApplyCurse(self, item, curse, ...)
end

local _RemoveCurse = Cursable.RemoveCurse
function Cursable:RemoveCurse(curse, numofitems, dropitems, ...)

    if curse and self.inst:HasTag(curse.."_curseimmune") then
        return false
    end

    return _RemoveCurse(self, curse, numofitems, dropitems, ...)
end
