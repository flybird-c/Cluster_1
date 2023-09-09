local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local GetRangeForTemperature
local AdjustLighting
local UpdateImages
local function temperaturedelta(inst, data)
	local ambient_temp = IsInIAClimate(inst) and TheWorld.state.islandtemperature or TheWorld.state.temperature
	local cur_temp = inst.components.temperature:GetCurrent()
	local range = GetRangeForTemperature(cur_temp, ambient_temp)
	AdjustLighting(inst, range, ambient_temp)

	if range <= 1 then
		if inst.lowTemp == nil or inst.lowTemp > cur_temp then
			inst.lowTemp = math.floor(cur_temp)
		end
		inst.highTemp = nil
	elseif range >= 5 then
		if inst.highTemp == nil or inst.highTemp < cur_temp then
			inst.highTemp = math.ceil(cur_temp)
		end
		inst.lowTemp = nil
	elseif inst.lowTemp ~= nil then
		if GetRangeForTemperature(inst.lowTemp, ambient_temp) >= 3 then
			inst.lowTemp = nil
		end
	elseif inst.highTemp ~= nil and GetRangeForTemperature(inst.highTemp, ambient_temp) <= 3 then
		inst.highTemp = nil
	end

	if range ~= inst.currentTempRange then
		UpdateImages(inst, range)

		if (inst.lowTemp ~= nil and range >= 3) or
			(inst.highTemp ~= nil and range <= 3) then
			inst.lowTemp = nil
			inst.highTemp = nil
			inst.components.fueled:SetPercent(inst.components.fueled:GetPercent() - 1 / TUNING.HEATROCK_NUMUSES)
		end
	end
end

-- Heatrock emits constant temperatures depending on the temperature range it's in
local emitted_temperatures = { -10, 10, 25, 40, 60 }

local function HeatFn(inst, observer)
    local range = GetRangeForTemperature(inst.components.temperature:GetCurrent(),
		IsInIAClimate(inst) and TheWorld.state.islandtemperature or TheWorld.state.temperature)
    if range <= 2 then
        inst.components.heater:SetThermics(false, true)
    elseif range >= 4 then
        inst.components.heater:SetThermics(true, false)
    else
        inst.components.heater:SetThermics(false, false)
    end
    return emitted_temperatures[range]
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("heatrock", function(inst)
	if TheWorld.ismastersim then
		if not inst.components.climatetracker then
			inst:AddComponent("climatetracker")
		end
		inst.components.climatetracker.period = 10
		
		for i, v in ipairs(inst.event_listening["temperaturedelta"][inst]) do
			GetRangeForTemperature = UpvalueHacker.GetUpvalue(v, "GetRangeForTemperature")
			AdjustLighting = UpvalueHacker.GetUpvalue(v, "AdjustLighting")
			UpdateImages = UpvalueHacker.GetUpvalue(v, "UpdateImages")
			if GetRangeForTemperature and AdjustLighting and UpdateImages then
				--TemperatureChange
				inst:RemoveEventCallback("temperaturedelta", v)
				inst:ListenForEvent("temperaturedelta", temperaturedelta)
				break
			end
		end
		
		inst.components.heater.heatfn = HeatFn
		inst.components.heater.carriedheatfn = HeatFn	
	end
end)
