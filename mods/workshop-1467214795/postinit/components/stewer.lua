local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Stewer = require("components/stewer")

local _Harvest = Stewer.Harvest
function Stewer:Harvest(...)
    if IA_CONFIG.oldwarly and self.done and self.gourmetcook and self.product ~= nil and PrefabExists(self.product .."_gourmet") then
		self.product = self.product .."_gourmet"
	end
	self.gourmetcook = nil
	local ret = _Harvest(self, ...)
	if self.inst.components.container ~= nil and self.inst:HasTag("flooded") then      
		self.inst.components.container.canbeopened = false
	end
	return ret
end

local _StopCooking = Stewer.StopCooking
function Stewer:StopCooking(...)
    if IA_CONFIG.oldwarly and self.gourmetcook and self.product ~= nil and PrefabExists(self.product .."_gourmet") then
		self.product = self.product .."_gourmet"
	end
	self.gourmetcook = nil
	return _StopCooking(self, ...)
end

local _OnSave = Stewer.OnSave
function Stewer:OnSave(...)
    local data, refs = _OnSave(self, ...)
	data.gourmetcook = self.gourmetcook
	return data, refs
end

local _OnLoad = Stewer.OnLoad
function Stewer:OnLoad(data, ...)
	_OnLoad(self, data, ...)
	self.gourmetcook = data.gourmetcook
end