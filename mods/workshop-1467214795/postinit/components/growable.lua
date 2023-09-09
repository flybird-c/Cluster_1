local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Growable = require("components/growable")

function Growable:SetOnGrowthFn(fn)
	self.ongrowthfn = fn
end

local _DoGrowth = Growable.DoGrowth
local function DoGrowth(self)
	_DoGrowth(self)
	
	local stage = self:GetNextStage()
	local lastStage = self.stage

	if self.ongrowthfn then
		self.ongrowthfn(self.inst, lastStage, stage)
	end
end
