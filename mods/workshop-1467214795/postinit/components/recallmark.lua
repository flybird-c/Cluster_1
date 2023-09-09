local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local unpack = unpack

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local RecallMark = require("components/recallmark")

local _Copy = RecallMark.Copy
function RecallMark:Copy(rhs, ...)
    local rets = {_Copy(self, rhs, ...)}

    rhs = rhs ~= nil and rhs.components.recallmark
	if rhs then
		self.recall_onwater = rhs.recall_onwater
	end
    
    return unpack(rets)
end

local _MarkPosition = RecallMark.MarkPosition
function RecallMark:MarkPosition(recall_x, recall_y, recall_z, recall_worldid, ...)
	if recall_x ~= nil and recall_y ~= nil and recall_z ~= nil then
		self.recall_onwater = TheWorld.Map:IsOceanAtPoint(recall_x, recall_y, recall_z, true)
	end
    return _MarkPosition(self, recall_x, recall_y, recall_z, recall_worldid, ...)
end

local _OnSave = RecallMark.OnSave
function RecallMark:OnSave(...)
    local data, refs = _OnSave(self, ...)
    data.recall_onwater = self.recall_onwater
    return data, refs
end

local _OnLoad = RecallMark.OnLoad
function RecallMark:OnLoad(data, ...)
    _OnLoad(self, data, ...)
    self.recall_onwater = data.recall_onwater
end
