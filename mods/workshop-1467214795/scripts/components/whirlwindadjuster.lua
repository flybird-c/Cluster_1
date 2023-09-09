
local SCREENDIST = 30
local WINDIMMUNE_TAGS = {"wind_immune"}
local ADJUSTABLE_TAGS = {"locomotor"}
local WINDTASK_UPDATE = 1/5

local next = next

if not (IA_CONFIG.windgustable and IA_CONFIG.windgustable.noitems) then
	table.insert(ADJUSTABLE_TAGS, "blowinwindgustitem")
end

if TUNING.SAILSTICK_BONUSSPEEDMULT ~= 1 then
	table.insert(ADJUSTABLE_TAGS, "speed_adjustable")
end

local WindAdjuster = Class(function(self, inst)

    self.inst = inst
    self.owner = nil

	self.adjusted = {}
end)
function WindAdjuster:RemoveAdjustments(list)
	for wind_adjusted,v in pairs(list) do
		if wind_adjusted ~= nil and wind_adjusted:IsValid() then
			if wind_adjusted.components.blowinwindgustitem then
				wind_adjusted.components.blowinwindgustitem:SetOverrideAngle(self, nil)
			elseif wind_adjusted.components.locomotor then
				wind_adjusted.components.locomotor:SetOverrideAngle(self, nil)
			elseif wind_adjusted.components.whirlspeed_adjustable then
				wind_adjusted.components.whirlspeed_adjustable:Adjust(self, nil)
			end
		end
	end
	self.adjusted = {}
end

function WindAdjuster:OnRemoveEntity()
	self:Stop()
end

function WindAdjuster:Start(owner)
	self.owner = owner
	if self.owner then
		if not self.owner.wind_updatetask then
			self.owner.wind_updatetask = owner:DoPeriodicTask(WINDTASK_UPDATE, function()
				local old_adjusted = self.adjusted
				local new_adjusted = {} 
				if TheWorld.state.hurricane and TheWorld.state.gustspeed > .1 and IsInIAClimate(self.owner) then
					local angle = self.owner.Transform:GetRotation()
					local x, y, z = self.owner.Transform:GetWorldPosition()
					local ents = TheSim:FindEntities(x, y, z, SCREENDIST, nil, WINDIMMUNE_TAGS, ADJUSTABLE_TAGS)
					for i, v in ipairs(ents) do
						if v ~= self.owner and v.entity:IsVisible() and not (v.components.floater and v.components.floater:IsFloating()) then
							if v.components.blowinwindgustitem then
								v.components.blowinwindgustitem:SetOverrideAngle(self, angle)
								new_adjusted[v] = true
								old_adjusted[v] = nil
							elseif v.components.locomotor then
								v.components.locomotor:SetOverrideAngle(self, angle)
								new_adjusted[v] = true
								old_adjusted[v] = nil
							elseif v.components.whirlspeed_adjustable then
								v.components.whirlspeed_adjustable:Adjust(self, true)
								new_adjusted[v] = true
								old_adjusted[v] = nil
							end
						end
					end
				end
				self:RemoveAdjustments(old_adjusted)
				self.adjusted = new_adjusted
			end)
		end
		if not self.owner.windowner_updatetask then --owner should update the fastest (same update time as sw)
			self.owner.windowner_updatetask = owner:DoPeriodicTask(FRAMES, function()
				if TheWorld.state.hurricane and TheWorld.state.gustspeed > .1 and IsInIAClimate(self.owner) then
					local angle = self.owner.Transform:GetRotation()
					--owner.components.windvisuals:SetOverrideAngle(self, angle)
					if self.owner.components.locomotor then
						self.owner.components.locomotor:SetOverrideAngle(self, angle)
					end
				end
			end)
		end
	end
end

function WindAdjuster:Stop()
	if self.owner then
		if self.owner.wind_updatetask then
			self.owner.wind_updatetask:Cancel()
			self.owner.wind_updatetask = nil
		end
		if self.owner.windowner_updatetask then
			self.owner.windowner_updatetask:Cancel()
			self.owner.windowner_updatetask = nil
		end
		if self.owner.components.locomotor then
			self.owner.components.locomotor:SetOverrideAngle(self, nil)
		end
	end
	self.owner = nil
	self:RemoveAdjustments(self.adjusted)
end

return WindAdjuster
