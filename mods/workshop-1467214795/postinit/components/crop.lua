local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Crop = require("components/crop")

local DAYLIGHT_SEARCH_RANGE = 30

local _Fertilize = Crop.Fertilize
function Crop:Fertilize(fertilizer, doer, ...)
    if IsInIAClimate(self.inst) then
		if self.inst.components.burnable ~= nil then
			self.inst.components.burnable:StopSmoldering()
		end

		if not (TheWorld.state.iswinter and TheWorld.state.islandtemperature <= 0) then --This is one of two lines we needed to change for temperature
			if fertilizer.components.fertilizer ~= nil then
				if doer ~= nil and
					doer.SoundEmitter ~= nil and
					fertilizer.components.fertilizer.fertilize_sound ~= nil then
					doer.SoundEmitter:PlaySound(fertilizer.components.fertilizer.fertilize_sound)
				end
				self.growthpercent = self.growthpercent + fertilizer.components.fertilizer.fertilizervalue * self.rate
			end
			self.inst.AnimState:SetPercent("grow", self.growthpercent)
			if self.growthpercent >= 1 then
				self.inst.AnimState:PlayAnimation("grow_pst")
				self:Mature()
				self.task:Cancel()
				self.task = nil
			end
			if fertilizer.components.finiteuses ~= nil then
				fertilizer.components.finiteuses:Use()
			else
				fertilizer.components.stackable:Get():Remove()
			end
			return true
		end
	else
		return _Fertilize( self, fertilizer, doer, ...)
	end
end

local _DoGrow = Crop.DoGrow
function Crop:DoGrow(dt, nowither, ...)
    if IsInIAClimate(self.inst) then
		if not self.inst:HasTag("withered") then 
			self.inst.AnimState:SetPercent("grow", self.growthpercent)

			local shouldgrow = nowither or not TheWorld.state.isnight
			if not shouldgrow then
				local x,y,z = self.inst.Transform:GetWorldPosition()
				local ents = TheSim:FindEntities(x,0,z, DAYLIGHT_SEARCH_RANGE, { "daylight", "lightsource" })
				for i,v in ipairs(ents) do
					local lightrad = v.Light:GetCalculatedRadius() * .7
					if v:GetDistanceSqToPoint(x,y,z) < lightrad * lightrad then
						shouldgrow = true
						break
					end
				end
			end
			if shouldgrow then
				local temp_rate =
					(TheWorld.state.islandtemperature < TUNING.MIN_CROP_GROW_TEMP and 0) or --This is one of two lines we needed to change for temperature
					(TheWorld.state.israining and 1 + TUNING.CROP_RAIN_BONUS * TheWorld.state.precipitationrate) or
					(TheWorld.state.isspring and 1 + TUNING.SPRING_GROWTH_MODIFIER / 3) or
					1
				self.growthpercent = self.growthpercent + dt * self.rate * temp_rate
				self.cantgrowtime = 0
			else
				self.cantgrowtime = self.cantgrowtime + dt
				if self.cantgrowtime > TUNING.CROP_DARK_WITHER_TIME
					and self.inst.components.witherable then
					self.inst.components.witherable:ForceWither()
				end
			end

			if self.growthpercent >= 1 then
				self.inst.AnimState:PlayAnimation("grow_pst")
				self:Mature()
				if self.task ~= nil then
					self.task:Cancel()
					self.task = nil
				end
			end
		end
	else
		return _DoGrow(self, dt, nowither, ...)
    end
end