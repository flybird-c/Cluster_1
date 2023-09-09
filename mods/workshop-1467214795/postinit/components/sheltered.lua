local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Sheltered = require("components/sheltered")

local DRYSHELTER_MUSTTAGS = { "dryshelter" }
local DRYSHELTER_CANTTAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "stump", "burnt" }
local _OnUpdate = Sheltered.OnUpdate
function Sheltered:OnUpdate(...)
	_OnUpdate(self, ...)
	-- Handle palmleaf huts
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 2, DRYSHELTER_MUSTTAGS, DRYSHELTER_CANTTAGS)
	if #ents > 0 then
		self:SetSheltered(true, 1, true)
	end
end

local _SetSheltered = Sheltered.SetSheltered
function Sheltered:SetSheltered(issheltered, level, dryshelter, ...)
	-- Handle palmleaf huts
	if dryshelter and not self.waterproofness_nodryshelter then
		-- and self.inst.replica.sheltered and self.inst.replica.sheltered:IsSheltered()
		self.waterproofness_nodryshelter = self.waterproofness
		self.waterproofness = TUNING.WATERPROOFNESS_ABSOLUTE
	elseif self.waterproofness_nodryshelter then -- Only do this once so we don't interfere with dynamic char stats more than necessary
		self.waterproofness = self.waterproofness_nodryshelter
		self.waterproofness_nodryshelter = nil
	end

    if IsInIAClimate(self.inst) then
		local israining = TheWorld.state.israining
		local temperature = TheWorld.state.temperature
		TheWorld.state.israining = TheWorld.state.islandisraining
		TheWorld.state.temperature = TheWorld.state.islandtemperature

		_SetSheltered(self, issheltered, level, ...)

		TheWorld.state.israining = israining
		TheWorld.state.temperature = temperature
	else
		return _SetSheltered(self, issheltered, level, ...)
	end
end
