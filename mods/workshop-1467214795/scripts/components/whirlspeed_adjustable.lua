
local next = next

local SpeedAdjustable = Class(function(self, inst)

    self.inst = inst

	self.inst:AddTag("speed_adjustable")
	
    self._speed_adjusters = {}
	self.speed_adjusted = false
    
end)

function SpeedAdjustable:OnRemoveEntity()
	if self.inst:HasTag("speed_adjustable") then
		self.inst:RemoveTag("speed_adjustable")
	end
end

function SpeedAdjustable:IsSpeedAdjusted()
	return self.speed_adjusted
end

function SpeedAdjustable:Adjust(adjuster, value)
    if self._speed_adjusters[adjuster] ~= value then
	    self._speed_adjusters[adjuster] = value

        self.speed_adjusted = (next(self._speed_adjusters) ~= nil) or false
    end
end

return SpeedAdjustable
