local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local easing = require("easing")

--@Mobbstar if you want to try and do the same cleanup here that I have done for the rest of the components,
--that would be really nice, I'm mainly scared about breaking all this since I don't understand the code. -Z

IAENV.AddComponentPostInit("weather", function(inst)
    local _world = TheWorld
    local _ismastersim = _world.ismastersim
    local _activatedplayer = nil

    --------------------------------------------------------------------------
    --[[ constants ]]
    --------------------------------------------------------------------------

    --We could fetch the actual upvalues, if any mod adds precip or lightning modes -M
    local PRECIP_MODE_NAMES =
    {
        "dynamic",
        "always",
        "never",
    }
    local PRECIP_MODES = table.invert(PRECIP_MODE_NAMES)
    local PRECIP_TYPE_NAMES =
    {
        "none",
        "rain",
    }
    local PRECIP_TYPES = table.invert(PRECIP_TYPE_NAMES)
    local LIGHTNING_MODE_NAMES =
    {
        "rain",
        "snow",
        "any",
        "always",
        "never",
    }
    local LIGHTNING_MODES = table.invert(LIGHTNING_MODE_NAMES)

    local PRECIP_RATE_SCALE = 10
    local MIN_PRECIP_RATE = .1
    --how fast clouds form
    -- NOTE: In sw mild and dry have no moisture gain at all, this is bad as
    -- percip will get stuck at the same value all season long
    -- so the values have been slightly modified to be more immersive
    local MOISTURE_RATES = {
        MIN = {
            autumn = 0,
            winter = 3,
            spring = 3,
            summer = 0,
        },
        MAX = {
            autumn = 0.1, --og: autumn = 0,
            winter = 3.75,
            spring = 3.75,
            summer = -0.2, --I figured making it dry this way is more fun -M
        }
    }

    --When the ceil is reached, it starts raining (or storming in hurricane season) (unit is average days till rain)
    local MOISTURE_CEIL_MULTIPLIERS =
    {
        autumn = 5.7, --5.5 in sw with dst changes
        winter = 5, --5.5 in sw with dst changes
        spring = 5.5,
        summer = 4, --3 in sw with dst changes
    }

    --When the floor is reached, it stops raining
    local MOISTURE_FLOOR_MULTIPLIERS =
    {
        autumn = 1,
        winter = 0.5,
        spring = 0.25,
        summer = 1,
    }

    -- values from SeasonManager:GetPeakIntensity()
    local PEAK_PRECIPITATION_RANGES =
    {
        autumn = { min = 0.3, max = 0.7 },
        winter = { min = 0.3, max = 0.7 },
        spring = { min = 1.0, max = 2.0 },
        summer = { min = 1.0, max = 1.0 }, -- DST changed this for RoG summer too
    }
    local DRY_THRESHOLD = TUNING.MOISTURE_DRY_THRESHOLD
    local WET_THRESHOLD = TUNING.MOISTURE_WET_THRESHOLD
    local MIN_WETNESS = 0
    local MAX_WETNESS = 100
    local MIN_WETNESS_RATE = 0
    local MAX_WETNESS_RATE = .75
    local MIN_DRYING_RATE = 0
    local MAX_DRYING_RATE = .3
    local OPTIMAL_DRYING_TEMPERATURE = 70
    local WETNESS_SYNC_PERIOD = 10
    local SNOW_LEVEL_SYNC_PERIOD = .1

    local SEASON_DYNRANGE_DAY = {
        autumn = .05,
        winter = .3,
        spring = .35,
        summer = .05,
    }
    local SEASON_DYNRANGE_NIGHT = {
        autumn = 0,
        winter = .5,
        spring = .25,
        summer = 0,
    }

    --[[ Hurricane constants ]]
    local GUST_PHASE_NAMES = {
    	"calm", --in SW called "wait"
    	"active",
    	"rampup",
    	"rampdown",
    }
    local GUST_PHASES = table.invert(GUST_PHASE_NAMES)

    --------------------------------------------------------------------------

    local _hailsound = false
    local _islandrainsound = false
    local _windsound = false

    local _rainfx
    local _snowfx
    local _pollenfx
    local _hasfx = false
    -- local function TryGetFX(player)
    	-- local pt = player and player:GetPosition() or {x=0,y=0,z=0}
    	-- for i,v in pairs( TheSim:FindEntities(pt.x, pt.y, pt.z, 1, {"FX"}) ) do
    		-- if v.prefab then
    			-- if v.prefab == "rain" then
    				-- _rainfx = v
    			-- elseif v.prefab == "snow" then
    				-- _snowfx = v
    			-- elseif v.prefab == "pollen" then
    				-- _pollenfx = v
    			-- end
    		-- end
    	-- end
    	-- local _hasfx = _rainfx ~= nil
    -- end
    -- TryGetFX(ThePlayer)
    for i,v in pairs( Ents ) do
    	if v.prefab then
    		if v.prefab == "rain" then
    			_rainfx = v
    		elseif v.prefab == "snow" then
    			_snowfx = v
    		elseif v.prefab == "pollen" then
    			_pollenfx = v
    		end
    	end
    end
    local _hasfx = _rainfx ~= nil
    local _hailfx = _hasfx and SpawnPrefab("hail") or nil

    local _season = "autumn"
    local _isIAClimate = false
    local _isDSTClimate = false
    local _isIslandClimate = false
    --local isVolcanoClimate = false

    --This is just a crude bandaid fix because other mods override inst.OnUpdate, but we need its upvalues -M
    local trueOnUpdate = inst.LongUpdate
    --local upvname, upvalue = debug.getupvalue(trueOnUpdate, 1) --TODO ideally loop through all using UpvalueHacker
    --while upvname == "_OnUpdate" or upvname == "OnUpdate_old" do
    	--trueOnUpdate = upvalue
    	--upvname, upvalue = debug.getupvalue(trueOnUpdate, 1)
    --end

    local StopAmbientRainSound_old = UpvalueHacker.GetUpvalue(trueOnUpdate, "StopAmbientRainSound")
    local StopTreeRainSound_old = UpvalueHacker.GetUpvalue(trueOnUpdate, "StopTreeRainSound")
    local StopUmbrellaRainSound_old = UpvalueHacker.GetUpvalue(trueOnUpdate, "StopUmbrellaRainSound")
    --TODO this should probably be generalised to "is regular climate"
    local StopAmbientRainSound = function(...) if _isDSTClimate then StopAmbientRainSound_old(...) end end
    local StopTreeRainSound = function(...) if _isDSTClimate then StopTreeRainSound_old(...) end end
    local StopUmbrellaRainSound = function(...) if _isDSTClimate then StopUmbrellaRainSound_old(...) end end
    UpvalueHacker.SetUpvalue(trueOnUpdate, StopAmbientRainSound, "StopAmbientRainSound")
    UpvalueHacker.SetUpvalue(trueOnUpdate, StopTreeRainSound, "StopTreeRainSound")
    UpvalueHacker.SetUpvalue(trueOnUpdate, StopUmbrellaRainSound, "StopUmbrellaRainSound")

    local StartAmbientRainSound = UpvalueHacker.GetUpvalue(trueOnUpdate, "StartAmbientRainSound")
    local StartTreeRainSound = UpvalueHacker.GetUpvalue(trueOnUpdate, "StartTreeRainSound")
    local StartUmbrellaRainSound = UpvalueHacker.GetUpvalue(trueOnUpdate, "StartUmbrellaRainSound")
    local SetWithPeriodicSync = UpvalueHacker.GetUpvalue(trueOnUpdate, "SetWithPeriodicSync")

    local function StartAmbientHailSound(intensity)
        if not _hailsound then
            _hailsound = true
            _world.SoundEmitter:PlaySound("ia/amb/rain/islandhailAMB", "hail")
        end
        _world.SoundEmitter:SetParameter("hail", "intensity", intensity)
    end

    local function StopAmbientHailSound()
        if _hailsound then
            _hailsound = false
            _world.SoundEmitter:KillSound("hail")
        end
    end

    local function StartAmbientIslandRainSound(intensity)
        if not _islandrainsound then
            _islandrainsound = true
            _world.SoundEmitter:PlaySound("ia/amb/rain/islandrainAMB", "islandrain")
        end
        _world.SoundEmitter:SetParameter("hail", "intensity", intensity)
    end

    local function StopAmbientIslandRainSound()
        if _islandrainsound then
            _islandrainsound = false
            _world.SoundEmitter:KillSound("islandrain")
        end
    end

    local function StartAmbientWindSound(intensity)
        if not _windsound then
            _windsound = true
            _world.SoundEmitter:PlaySound("ia/amb/rain/islandwindAMB", "wind")
        end
        _world.SoundEmitter:SetParameter("wind", "intensity", intensity)
    end

    local function StopAmbientWindSound()
        if _windsound then
            _windsound = false
            _world.SoundEmitter:KillSound("wind")
        end
    end

    --Common
    local _seasonprogress = 0
    local _true_seasonprogress = 0 --without the 0.5 start for friendly seasons

    --Master simulation
    local _moisturerateval = _ismastersim and 1 or nil
    local _moisturerateoffset = _ismastersim and 0 or nil
    local _moistureratemultiplier = _ismastersim and 1 or nil
    local _moistureceilmultiplier = _ismastersim and 1 or nil
    local _moisturefloormultiplier = _ismastersim and 1 or nil
    local _lightningtargets_island = _ismastersim and {} or nil
    local _lightningmode = UpvalueHacker.GetUpvalue(trueOnUpdate, "_lightningmode")
    --let's hope nobody notices that we basically generate twice as much lightning if both climates are active (unlikely)
    local _minlightningdelay_island = nil
    local _maxlightningdelay_island = nil
    local _nextlightningtime_island = _ismastersim and 5 or nil

    local _hurricane_gust_timer = 0.0 --needed by client for simulation
    local _hurricane_gust_period = 0.0 --needed by client for simulation
    local _hurricane_gust_angletimer = _ismastersim and 0.0 or nil

    local _hurricanetease_start = _ismastersim and 0 or nil
    local _hurricanetease_started = _ismastersim and false or nil

    --Network
    local _noisetime = UpvalueHacker.GetUpvalue(trueOnUpdate, "_noisetime")
    local _moisture_island = net_float(inst.inst.GUID, "weather._moisture_island")
    local _moisturerate_island = net_float(inst.inst.GUID, "weather._moisturerate_island")
    local _moistureceil_island = net_float(inst.inst.GUID, "weather._moistureceil_island", "moistureceil_islanddirty")
    local _moisturefloor_island = net_float(inst.inst.GUID, "weather._moisturefloor_island")
    local _peakprecipitationrate_island = net_float(inst.inst.GUID, "weather._peakprecipitationrate_island")
    local _wetness_island = net_float(inst.inst.GUID, "weather._wetness_island")
    local _wet_island = net_bool(inst.inst.GUID, "weather._wet_island", "wet_islanddirty")
    local _preciptypeisland = net_tinybyte(inst.inst.GUID, "weather._preciptypeisland", "preciptypeislanddirty")
    local _precipmode = UpvalueHacker.GetUpvalue(trueOnUpdate, "_precipmode")
    local _snowlevel = UpvalueHacker.GetUpvalue(trueOnUpdate, "_snowlevel")
    local _lightningtargets = UpvalueHacker.GetUpvalue(trueOnUpdate, "_lightningtargets")
    local _hail = net_bool(inst.inst.GUID, "weather._hail", "haildirty")
    local _hurricane = net_bool(inst.inst.GUID, "weather._hurricane", "hurricanedirty")
    local _hurricane_timer = net_float(inst.inst.GUID, "weather._hurricane_timer")
    local _hurricane_duration = net_float(inst.inst.GUID, "weather._hurricane_duration")
    local _hurricane_gust_speed = net_float(inst.inst.GUID, "weather._hurricane_gust_speed", "hurricane_gust_speeddirty")
    --note: _hurricane_gust_angle is a net_ushortint, so it is only whole, positive numbers
    local _hurricane_gust_angle = net_ushortint(inst.inst.GUID, "weather._hurricane_gust_angle", "hurricane_gust_angledirty")
    local _hurricane_gust_peak = net_float(inst.inst.GUID, "weather._hurricane_gust_peak")
    local _hurricane_gust_state = net_tinybyte(inst.inst.GUID, "weather._hurricane_gust_state")

    local CalculateMoistureRate_Island = _ismastersim and function()
        return _moisturerateval * _moistureratemultiplier + _moisturerateoffset
    end or nil

    local RandomizeMoistureCeil_Island = _ismastersim and function()
        return (1 + math.random()) * TUNING.TOTAL_DAY_TIME * _moistureceilmultiplier
    end or nil

    local RandomizeMoistureFloor_Island = _ismastersim and function()
        return (.25 + math.random() * .5) * _moisture_island:value() * _moisturefloormultiplier
    end or nil

    local RandomizePeakPrecipitationRate_Island = _ismastersim and function(season)
        local range = PEAK_PRECIPITATION_RANGES[season]
        return range.min + math.random() * (range.max-range.min)
    end or nil

    local StartPrecipitation_Island = _ismastersim and function()
        _nextlightningtime_island = GetRandomMinMax(_minlightningdelay_island or 5, _maxlightningdelay_island or 15)
    	_moisture_island:set(_moistureceil_island:value())
    	_moisturefloor_island:set(RandomizeMoistureFloor_Island(_season))
    	_peakprecipitationrate_island:set(RandomizePeakPrecipitationRate_Island(_season))
    	_preciptypeisland:set(PRECIP_TYPES.rain)
    end or nil

    local StopPrecipitation_Island = _ismastersim and function(moisture_override)
    	_moisture_island:set(moisture_override or _moisturefloor_island:value())
    	_moistureceil_island:set(RandomizeMoistureCeil_Island())
    	_preciptypeisland:set(PRECIP_TYPES.none)
    end or nil

    --------------------------------------------------------------------------
    --[[ HURRICANE ]]
    --------------------------------------------------------------------------

    local function CalculateHurricaneProgress_Island()
        if _hurricane:value() then
            return (_hurricane_timer:value() / _hurricane_duration:value())
        end
        return 0
    end

    local function CalculateHailRate_Island()
        if _hail:value() then
            local hailpercent = math.clamp((CalculateHurricaneProgress_Island() - TUNING.HURRICANE_PERCENT_HAIL_START) / (TUNING.HURRICANE_PERCENT_HAIL_END - TUNING.HURRICANE_PERCENT_HAIL_START), 0.0, 1.0)
            return TUNING.HURRICANE_HAIL_SCALE * math.sin(PI * hailpercent)
        end
        return 0
    end

    --TODO this has to be re-written to support client prediction better
    local function UpdateHurricaneWind(dt)
    	-- TheSim:ProfilerPush("hurricanewind")
    	local percent = CalculateHurricaneProgress_Island()

        --on the client aswell so the hailfx starts at the correct time
        -- IA change no hail in dryseason
        if _season ~= "autumn"  and _season ~= "summer" and (TUNING.HURRICANE_PERCENT_HAIL_START <= percent and percent <= TUNING.HURRICANE_PERCENT_HAIL_END) then
            if not _hail:value() then
                _hail:set(true)
            end
        elseif _hail:value() then
            _hail:set(false)
        end

    	if TUNING.HURRICANE_PERCENT_WIND_START <= percent and percent <= TUNING.HURRICANE_PERCENT_WIND_END then
    		_hurricane_gust_timer = _hurricane_gust_timer + dt
    		if _ismastersim then
    			--TODO This should almost certainly be a DoTaskInTime -M
    			--or test when exactly it changes in SW, might be cooler to make it change at sunset
    			_hurricane_gust_angletimer = _hurricane_gust_angletimer + dt
    			if _hurricane_gust_angletimer > 16*TUNING.SEG_TIME then
    				_hurricane_gust_angle:set(math.random(0,360))
    				_hurricane_gust_angletimer = 0
    			end
    		end

    		if _hurricane_gust_state:value() == GUST_PHASES.calm then
    			_hurricane_gust_speed:set(0)
    			if _hurricane_gust_timer >= _hurricane_gust_period then
    				-- print("GUST Ramp up")
    				_hurricane_gust_peak:set(GetRandomMinMax(TUNING.WIND_GUSTSPEED_PEAK_MIN, TUNING.WIND_GUSTSPEED_PEAK_MAX))
    				_hurricane_gust_timer = 0.0
    				_hurricane_gust_period = TUNING.WIND_GUSTRAMPUP_TIME
    				_hurricane_gust_state:set(GUST_PHASES.rampup)
    				_world:PushEvent("wind_rampup") --for wind_staff, NOTE: windguststart is the same thing
    				-- self.inst:PushEvent("windguststart")
    			end

    		elseif _hurricane_gust_state:value() == GUST_PHASES.rampup then
    			local peak = 0.5 * _hurricane_gust_peak:value()
    			local gustspeed = -peak * math.cos(PI * _hurricane_gust_timer / _hurricane_gust_period) + peak
    			SetWithPeriodicSync(_hurricane_gust_speed, gustspeed, 20, _ismastersim)
    			if _hurricane_gust_timer >= _hurricane_gust_period then
    				-- print("GUST Peak")
    				_hurricane_gust_timer = 0.0
    				_hurricane_gust_period = _ismastersim and GetRandomMinMax(TUNING.WIND_GUSTLENGTH_MIN, TUNING.WIND_GUSTLENGTH_MAX) or TUNING.WIND_GUSTLENGTH_MAX + 10
    				_hurricane_gust_state:set(GUST_PHASES.active)
    			end

    		elseif _hurricane_gust_state:value() == GUST_PHASES.active then
    			_hurricane_gust_speed:set(_hurricane_gust_peak:value())
    			if _hurricane_gust_timer >= _hurricane_gust_period then
    				-- print("GUST Ramp down")
    				_hurricane_gust_timer = 0.0
    				_hurricane_gust_period = TUNING.WIND_GUSTRAMPDOWN_TIME
    				_hurricane_gust_state:set(GUST_PHASES.rampdown)
    			end

    		elseif _hurricane_gust_state:value() == GUST_PHASES.rampdown then
    			local peak = 0.5 * _hurricane_gust_peak:value()
    			local gustspeed = peak * math.cos(PI * _hurricane_gust_timer / _hurricane_gust_period) + peak
    			SetWithPeriodicSync(_hurricane_gust_speed, gustspeed, 20, _ismastersim)
    			if _hurricane_gust_timer >= _hurricane_gust_period then
    				-- print("GUST Calm")
    				_hurricane_gust_timer = 0.0
    				_hurricane_gust_period = _ismastersim and GetRandomMinMax(TUNING.WIND_GUSTDELAY_MIN, TUNING.WIND_GUSTDELAY_MAX) or TUNING.WIND_GUSTDELAY_MAX + 10
    				_hurricane_gust_state:set(GUST_PHASES.calm)
                    -- self.inst:PushEvent("wind_rampdown")
    				-- self.inst:PushEvent("windgustend")
    			end
    		end
    	else
    		_hurricane_gust_timer = 0.0
    		_hurricane_gust_speed:set(0.0)
    	end
    	-- TheSim:ProfilerPop()
    end

    local function PushHurricane_Island()
        local data =
        {
            hailrate = CalculateHailRate_Island(),
            hurricane_progress = CalculateHurricaneProgress_Island(),
        }
    	_world:PushEvent("islandhurricanetick", data)
    end

    -- Only use this on mastersim unless its onload where the duration and time can accuratly be predicted
   local StartHurricaneStorm = function(duration_override, start_time)
    	if not _hurricane:value() then
    		print("Hurricane start")
            _hurricane_duration:set(duration_override or math.random(TUNING.HURRICANE_LENGTH_MIN, TUNING.HURRICANE_LENGTH_MAX))
            _hurricane_timer:set(start_time and math.min(start_time, _hurricane_duration:value()) or 0)
            if _ismastersim then
                StartPrecipitation_Island()
            end

            _hurricane_gust_speed:set(0.0)
            _hurricane_gust_timer = 0.0
    		_hurricane_gust_period = 0.0 --GetRandomWithVariance(10.0, 4.0)
            _hurricane_gust_peak:set(0.0) --GetRandomWithVariance(0.5, 0.25)
            _hurricane_gust_state:set(GUST_PHASES.calm)

            _hurricane:set(true)
            PushHurricane_Island()
    	end
    end

    local StopHurricaneStorm = function()
    	if _hurricane:value() then
    		print("Hurricane stop")
            _hurricane_gust_speed:set(0.0)
            _hurricane_gust_peak:set(0.0)
            _hurricane_gust_timer = 0.0
            _hurricane_gust_period = 0.0
            _hurricane_gust_state:set(GUST_PHASES.calm)
            _hurricane:set(false)
            _hail:set(false)
            if _ismastersim then
                StopPrecipitation_Island(0) --hurricanes keep the moisture at the ceiling throughout the storm then set it to zero afterwards
            end
            PushHurricane_Island()
    	end
    end

    --dunno if we really need tease, since hurricane no longer triggers precip either way -M
    --It starts a hurricane storm in mild too you doydoy!!!! --Half
    --this function has been merged with onupdate
    --function StartHurricaneTease(duration_override)
    --	StartHurricaneStorm(duration_override or TUNING.HURRICANE_TEASE_LENGTH)
    --  _hurricanetease_started = true
    --end

    --local function StopHurricaneTease()
    --	StopHurricaneStorm()
    --end

    --------------------------------------------------------------------------

    local function CalculatePrecipitationRate_Island()
        if _precipmode:value() == PRECIP_MODES.always then
            return .1 + perlin(0, _noisetime:value() * .1, 0) * .9
        elseif _preciptypeisland:value() ~= PRECIP_TYPES.none and _precipmode:value() ~= PRECIP_MODES.never then
            if _hurricane:value() then
                --Essentially hurricanes have a preset percip rate that sorta works like a percip mode (commented out code even shows a hurricane percip mode) and looks like a wavy hill. The value of the percip rate is based on the hurricanes progress with a start and stop point similarly to wind
                local rainpercent = math.clamp((CalculateHurricaneProgress_Island() - TUNING.HURRICANE_PERCENT_RAIN_START) / (TUNING.HURRICANE_PERCENT_RAIN_END - TUNING.HURRICANE_PERCENT_RAIN_START), 0.0, 1.0) --here it uses math.clamp along with the hurricanes progress to get the progress of the rain chunk of the hurricane progress from 0 -> 1
                return _season ~= "autumn" and (TUNING.HURRICANE_RAIN_SCALE * math.sin(PI * rainpercent) + 0.1 * math.sin(8.0 * PI * rainpercent)) or (0.4 * math.sin(8 * PI * rainpercent - PI/2) + 0.4) --here it sends a value based on the rainpercet/hurricane progress of that wavy hill
            else
                local p = (_moisture_island:value() - _moisturefloor_island:value()) / (_moistureceil_island:value() - _moisturefloor_island:value())
                p = math.max(0, math.min(1, p))
                local rate = MIN_PRECIP_RATE + (1 - MIN_PRECIP_RATE) * math.sin(p * PI)
                return math.min(rate, _peakprecipitationrate_island:value())
            end
        end
        return 0
    end

    --this is ONLY used in PushWeather
    local function CalculatePOP_Island()
        return (_preciptypeisland:value() ~= PRECIP_TYPES.none and 1)
            or ((_moistureceil_island:value() <= 0 or _moisture_island:value() <= _moisturefloor_island:value()) and 0)
            or (_moisture_island:value() < _moistureceil_island:value() and (_moisture_island:value() - _moisturefloor_island:value()) / (_moistureceil_island:value() - _moisturefloor_island:value()))
            or 1
    end

    --this is ONLY used in PushWeather
    local function CalculateLight_Island()
        if _precipmode:value() == PRECIP_MODES.never then
            return 1
        end

        local dynrange = _world.state.isday and SEASON_DYNRANGE_DAY[_season] or SEASON_DYNRANGE_NIGHT[_season]

        if _precipmode:value() == PRECIP_MODES.always then
            return 1 - dynrange
        end
        local p = 1 - math.min(math.max((_moisture_island:value() - _moisturefloor_island:value()) / (_moistureceil_island:value() - _moisturefloor_island:value()), 0), 1)
        if _preciptypeisland:value() ~= PRECIP_TYPES.none then
            p = easing.inQuad(p, 0, 1, 1)
        end
        return p * dynrange + 1 - dynrange
    end

    --this is ONLY called in OnUpdate
    local function CalculateWetnessRate_Island(temperature, preciprate)
    	return --Positive wetness rate when it's raining
    		(_preciptypeisland:value() == PRECIP_TYPES.rain and easing.inSine(preciprate, MIN_WETNESS_RATE, MAX_WETNESS_RATE, 1))
    		--Negative drying rate when it's not raining
    		or -math.clamp(easing.linear(temperature, MIN_DRYING_RATE, MAX_DRYING_RATE, OPTIMAL_DRYING_TEMPERATURE)
    					+ easing.inExpo(_wetness_island:value(), 0, 1, MAX_WETNESS),
    					.01, 1)
    end

    local function PushWeather_Island()
        local data =
        {
            moisture = _moisture_island:value(),
            pop = CalculatePOP_Island(),
            precipitationrate = CalculatePrecipitationRate_Island(),
            snowlevel = 0,
            wetness = _wetness_island:value(),
            light = CalculateLight_Island(),
    		-- gustspeed = _hurricane_gust_speed:value(),
        }
    	_world:PushEvent("islandweathertick", data)
    	if not _ismastersim then --update visuals directly, probably the cause of some weird subtle bugs
    		_world:PushEvent("weathertick", data)
    	end
    end

    --------------------------------------------------------------------------
    --[[ Event Callbacks ]]
    --------------------------------------------------------------------------

    local function OnSeasonTick_Island(src, data)
        _season = data.season
        _seasonprogress = data.progress

        local length = data.elapseddaysinseason + data.remainingdaysinseason
        _true_seasonprogress = data.elapseddaysinseason / length

        if _ismastersim then
    		--It rains less in the middle of summer
    		local p = 1 - math.sin(PI * data.progress)
    		_moisturerateval = MOISTURE_RATES.MIN[_season] + p * (MOISTURE_RATES.MAX[_season] - MOISTURE_RATES.MIN[_season])
    		_moisturerateoffset = 0

            _moisturerate_island:set(CalculateMoistureRate_Island())
            _moistureceilmultiplier = MOISTURE_CEIL_MULTIPLIERS[_season] or MOISTURE_CEIL_MULTIPLIERS.autumn
            _moisturefloormultiplier = MOISTURE_FLOOR_MULTIPLIERS[_season] or MOISTURE_FLOOR_MULTIPLIERS.autumn

            --here just so it starts in the first mild correctly
            if _season ~= "autumn" then
                _hurricanetease_start = 0
                _hurricanetease_started = false
            elseif _hurricanetease_start == 0 then
                --note lua math.random is stupid  and only increments by integers so we need to scale it up by the length then divide it by the length -_-
                _hurricanetease_start = math.random(TUNING.HURRICANE_TEASE_PERCENT_START_MIN * length, TUNING.HURRICANE_TEASE_PERCENT_START_MAX * length) / length
            end
        end
    end

    local function OnSeasonChange(src, new_season)
        if new_season ~= "winter" then
            StopHurricaneStorm()
        end
    end

    local function OnPlayerActivated(src, player)
        _activatedplayer = player
        if _hasfx then
            _hailfx.entity:SetParent(player.entity)
    		-- inst:OnUpdate(0)
    		--TODO How to clear snowflakes if _isIAClimate?
    		-- _snowfx.particles_per_tick = 0
    		-- _snowfx:PostInit()
    		-- _pollenfx.particles_per_tick = 0
    		-- _pollenfx:PostInit()
        end
    	-- player:DoTaskInTime(0,function() TryGetFX(player) end)
    end

    local function OnPlayerDeactivated(src, player)
        if _activatedplayer == player then
            _activatedplayer = nil
    		if _hasfx then
    			_hailfx.entity:SetParent(nil)
    		end
        end
    end

    --These three are for lightning control in particular
    local ChangeTable = _ismastersim and function(t1, t2, item)
    	for i, v in ipairs(t1) do
    		if v == item then
    			table.remove(t1, i)
    			--note: this makes item the last element in the ranking, so climate-hopping reduces your odds of getting struck by lightning
    			table.insert(t2, item)
    			return true
    		end
    	end
    end

    local OnClimateDirty = _ismastersim and function(player)
    	if IsInIAClimate(player) then
    		ChangeTable(_lightningtargets, _lightningtargets_island, player)
    	else
    		ChangeTable(_lightningtargets_island, _lightningtargets, player)
    	end
    end

    local OnPlayerJoined = _ismastersim and function(src, player)
    	if player then
    		-- inst:DoTaskInTime(0, function()
    			if IsInIAClimate(player) then
    				--remove and add to our stalky update table or sth idk
    				ChangeTable(_lightningtargets, _lightningtargets_island, player)
    			end
    		-- end)
    		src:ListenForEvent("climatechange", OnClimateDirty, player)
    	end
    end or nil

    local OnPlayerLeft = _ismastersim and function(src, player)
    	if player then
    		src:RemoveEventCallback("climatechange", OnClimateDirty, player)
    	end
        for i, v in ipairs(_lightningtargets_island) do
            if v == player then
                table.remove(_lightningtargets_island, i)
                return
            end
        end
    end or nil


    local OnForcePrecipitation = _ismastersim and function(src, enable)
        _moisture_island:set(enable ~= false and _moistureceil_island:value() or _moisturefloor_island:value())
    end or nil

    local OnSetMoistureScale = _ismastersim and function(src, data)
        _moistureratemultiplier = data or _moistureratemultiplier
        _moisturerate_island:set(CalculateMoistureRate_Island())
    end or nil

    local OnDeltaMoisture = _ismastersim and function(src, delta)
        _moisture_island:set(math.min(math.max(_moisture_island:value() + delta, _moisturefloor_island:value()), _moistureceil_island:value()))
    end or nil

    local OnDeltaMoistureCeil = _ismastersim and function(src, delta)
        _moistureceil_island:set(math.max(_moistureceil_island:value() + delta, _moisturefloor_island:value()))
    end or nil

    local OnDeltaWetness = _ismastersim and function(src, delta)
        _wetness_island:set(math.clamp(_wetness_island:value() + delta, MIN_WETNESS, MAX_WETNESS))
    end or nil

    local OnSetLightningDelay = _ismastersim and function(src, data)
        if _preciptypeisland:value() ~= PRECIP_TYPES.none and data.min and data.max then
            _nextlightningtime_island = GetRandomMinMax(data.min, data.max)
        end
        _minlightningdelay_island = data.min
        _maxlightningdelay_island = data.max
    end or nil

    local ForceResync = _ismastersim and function(netvar)
        netvar:set_local(netvar:value())
        netvar:set(netvar:value())
    end or nil
    local OnSimUnpaused = _ismastersim and function()
        --Force resync values that client may have simulated locally
        ForceResync(_moisture_island)
        ForceResync(_wetness_island)
    end or nil

    local OnForceHurricane = _ismastersim and function(src, enable)
        if enable ~= _hurricane:value() then
    		if enable then
    		    StartHurricaneStorm(type(enable) == "number" and enable or nil)
    		else
    			StopHurricaneStorm()
    		end
    	end
    end or nil

    local OnSetGustAngle = _ismastersim and function(src, angle)
    	angle = angle % 360
        if angle ~= _hurricane_gust_angle:value() then
    		_hurricane_gust_angle:set(angle)
    	end
    end or nil

    --------------------------------------------------------------------------
    --[[ Initialization ]]
    --------------------------------------------------------------------------

    --Initialize network variables
    _moisture_island:set(0)
    _moisturerate_island:set(0)
    _moistureceil_island:set(0)
    _moisturefloor_island:set(0)
    _preciptypeisland:set(PRECIP_TYPES.none)
    _peakprecipitationrate_island:set(1)
    _wetness_island:set(0)
    _wet_island:set(false)

    --Dedicated server does not need to spawn the local fx
    if _hasfx then
        _hailfx.particles_per_tick = 0
        _hailfx.splashes_per_tick = 0
    end

    --Register events
    inst.inst:ListenForEvent("seasontick", OnSeasonTick_Island, _world)
    inst.inst:ListenForEvent("playeractivated", OnPlayerActivated, _world)
    inst.inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated, _world)
    inst.inst:WatchWorldState("season", OnSeasonChange)

    --Register network variable sync events (worldstate)
    inst.inst:ListenForEvent("moistureceil_islanddirty", function() _world:PushEvent("moistureceil_islandchanged", _moistureceil_island:value()) end)
    inst.inst:ListenForEvent("preciptypeislanddirty", function() _world:PushEvent("precipitation_islandchanged", PRECIP_TYPE_NAMES[_preciptypeisland:value()]) end)
    inst.inst:ListenForEvent("wet_islanddirty", function() _world:PushEvent("wet_islandchanged", _wet_island:value()) end)
    inst.inst:ListenForEvent("haildirty", function() _world:PushEvent("hailchanged", _hail:value()) PushHurricane_Island() end)
    inst.inst:ListenForEvent("hurricanedirty", function() _world:PushEvent("hurricanechanged", _hurricane:value()) PushHurricane_Island() end)
    inst.inst:ListenForEvent("hurricane_gust_speeddirty", function() _world:PushEvent("gustspeedchanged", _hurricane_gust_speed:value()) end)
    inst.inst:ListenForEvent("hurricane_gust_angledirty", function() _world:PushEvent("gustanglechanged", _hurricane_gust_angle:value()) end)

    if _ismastersim then
        --Initialize master simulation variables
        _moisturerate_island:set(CalculateMoistureRate_Island())
        _moistureceil_island:set(RandomizeMoistureCeil_Island())

        --Register master simulation events
        inst.inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, _world)
        inst.inst:ListenForEvent("ms_playerleft", OnPlayerLeft, _world)
        inst.inst:ListenForEvent("ms_forceprecipitation", OnForcePrecipitation, _world)
        inst.inst:ListenForEvent("ms_forceprecipitation_island", OnForcePrecipitation, _world)
        inst.inst:ListenForEvent("ms_setmoisturescale", OnSetMoistureScale, _world)
        inst.inst:ListenForEvent("ms_deltamoisture", OnDeltaMoisture, _world)
        inst.inst:ListenForEvent("ms_deltamoisture_island", OnDeltaMoisture, _world)
        inst.inst:ListenForEvent("ms_deltamoistureceil", OnDeltaMoistureCeil, _world)
        inst.inst:ListenForEvent("ms_deltawetness", OnDeltaWetness, _world)
        inst.inst:ListenForEvent("ms_setlightningdelay", OnSetLightningDelay, _world)
        inst.inst:ListenForEvent("ms_simunpaused", OnSimUnpaused, _world)
        inst.inst:ListenForEvent("ms_forcehurricane", OnForceHurricane, _world)
        inst.inst:ListenForEvent("ms_setgustangle", OnSetGustAngle, _world)
    end
    PushWeather_Island()

    local OnRemoveEntity_old = inst.OnRemoveEntity
    if _hasfx then 
        function inst:OnRemoveEntity(...)
            if _hailfx.entity:IsValid() then
                _hailfx:Remove()
            end
            OnRemoveEntity_old(inst, ...)
        end 
    end

    --[[
        Client updates temperature, moisture, precipitation effects, and snow
        level on its own while server force syncs values periodically. Client
        cannot start, stop, or change precipitation on its own, and must wait
        for server syncs to trigger these events.
    --]]
    local OnUpdate_old = inst.OnUpdate
    function inst:OnUpdate(dt)
        local _climate = _activatedplayer and GetClimate(_activatedplayer)
    	_isIAClimate = _climate and IsIAClimate(_climate)
        _isDSTClimate = _climate and IsDSTClimate(_climate)
        --_isVolcanoClimate = _climate and IsClimate(_climate, "volcano") --hail is exclusive to island climates but nothings exclusive to the volcano
        _isIslandClimate = _climate and IsClimate(_climate, "island")

    	if _ismastersim
    	and (_world:HasTag("island") or _world:HasTag("volcano"))
    	and not _world:HasTag("forest") and not _world:HasTag("caves") then
    		SetWithPeriodicSync(_snowlevel, 0, SNOW_LEVEL_SYNC_PERIOD, _ismastersim)
    	end
    	if _ismastersim or _isDSTClimate then
    		OnUpdate_old(self, dt)
            if self.cannotsnow then
                TheWorld.Map:SetOverlayLerp(0)
            end
    	else
    		SetWithPeriodicSync(_noisetime, _noisetime:value() + dt, 30, _ismastersim)
    	end

    	if _ismastersim or _isIAClimate then
    		local preciprate = CalculatePrecipitationRate_Island()

    		if _hurricane:value() then
    			SetWithPeriodicSync(_hurricane_timer, _hurricane_timer:value() + dt, 100, _ismastersim)
    			if _hurricane_duration:value() <= _hurricane_timer:value() then
    				StopHurricaneStorm()
    			else
    				UpdateHurricaneWind(dt)
    			end
    		end

    		--Update moisture and toggle precipitation
            if _ismastersim and _season == "autumn" and not _hurricane:value() and _hurricanetease_start ~= 0 and not _hurricanetease_started and _true_seasonprogress >= _hurricanetease_start then
                --in sw if a hurricane is in mild it will act as a hurricane tease which only effects wind and percip, a hurricane will also start in mild if the seasonpercent is bigger than hurricanetease_start which is randomly created at the start of mild
                print("HurricaneTease start")
                _hurricanetease_started = true
    		    StartHurricaneStorm(TUNING.HURRICANE_TEASE_LENGTH)
            end
    		if _precipmode:value() == PRECIP_MODES.always then
    			if _ismastersim and _preciptypeisland:value() == PRECIP_TYPES.none then
                    if _season == "winter" and not _hurricane:value() then
                        StartHurricaneStorm()
                    else
    				    StartPrecipitation_Island()
                    end
    			end
    		elseif _precipmode:value() == PRECIP_MODES.never then
    			if _preciptypeisland:value() ~= PRECIP_TYPES.none and _ismastersim then
                    if _hurricane:value() then
                        StopHurricaneStorm()
                    else
                        StopPrecipitation_Island()
                    end
                end
    		elseif _preciptypeisland:value() ~= PRECIP_TYPES.none then
                if not _hurricane:value() then
                    --Dissipate moisture
                    local delta = preciprate * dt * PRECIP_RATE_SCALE
                    local moisture = math.max(_moisture_island:value() - delta, 0)
                    if moisture <= _moisturefloor_island:value() then
                        if _ismastersim then
                            StopPrecipitation_Island()
                        else
                            _moisture_island:set_local(math.min(_moisturefloor_island:value() + .001, _moisture_island:value()))
                        end
                    else
                        if _ismastersim and _season == "winter" then --Note: not in sw, but normal rain in wetseason is meh
                            -- if its raining in hurricane season without a storm the player must of jumped seasons using cheats as storms essentially replace rain completly in wetseason
                            -- so lets reset precip and start a short storm based on how much moisture is left
                            StartHurricaneStorm(TUNING.HURRICANE_BUFFER_LENGTH * (_moisture_island:value() - _moisturefloor_island:value()) / (_moistureceil_island:value() - _moisturefloor_island:value()))
                        end
                        SetWithPeriodicSync(_moisture_island, moisture, 100, _ismastersim)
                    end
                end
    		elseif _moistureceil_island:value() > 0 then
    			--Accumulate moisture
                local delta = _moisturerate_island:value() * dt
    			local moisture = _moisture_island:value() + delta
    			if moisture >= _moistureceil_island:value() + (delta < 0 and delta or 0) then
    				if _ismastersim then
                        --moisture hitting the ceil and percipmode being always is the same conditions as startprecip so just slap this guy right here
                        if _season == "winter" and not _hurricane:value() then
                            StartHurricaneStorm()
                        else
                            StartPrecipitation_Island()
                        end
    				else
    					_moisture_island:set_local(math.max(_moistureceil_island:value() - .001, _moisture_island:value()))
    				end
    			else
    				SetWithPeriodicSync(_moisture_island, math.max(moisture, 0), 100, _ismastersim)
    			end
    		end

    		--Update wetness
    		local wetrate = CalculateWetnessRate_Island(_world.state.islandtemperature, preciprate)
    		SetWithPeriodicSync(_wetness_island, math.clamp(_wetness_island:value() + wetrate * dt, MIN_WETNESS, MAX_WETNESS), WETNESS_SYNC_PERIOD, _ismastersim)
    		if _ismastersim then
    			if _wet_island:value() then
    				if _wetness_island:value() < DRY_THRESHOLD then
    					_wet_island:set(false)
    				end
    			elseif _wetness_island:value() > WET_THRESHOLD then
    				_wet_island:set(true)
    			end
    		end

    		if _ismastersim then
                -- In sw there are two lightning checks one runs wihen theres a hurricane storm the other runs when there isnt, this is simply a merge of them. Note: the lightning time is still reduced by the non hurricane one even if theres a hurricane so during a hurricane it actually removes dt * 2
                local lightning_check = 0
                if _lightningmode == LIGHTNING_MODES.always or
                    LIGHTNING_MODE_NAMES[_lightningmode] == PRECIP_TYPE_NAMES[_preciptypeisland:value()] or
                    (_lightningmode == LIGHTNING_MODES.any and _preciptypeisland:value() ~= PRECIP_TYPES.none) then

                    lightning_check = lightning_check + 1
                end
                local hurricane_percent
                if _hurricane:value() then
                    if _season ~= "autumn" then
                        if _lightningmode ~= LIGHTNING_MODES.never then
                            hurricane_percent = CalculateHurricaneProgress_Island()
                            --IA change lower rate of hurricane lightning in dryseason
                            if _season ~= "summer" then
                                lightning_check = lightning_check + 1
                            end
                        end
                    else
                        lightning_check = 0 --hurricane teases can never have lightning
                    end
                end
                
                if lightning_check > 0 then
                    if hurricane_percent == nil or (TUNING.HURRICANE_PERCENT_LIGHTNING_START <= hurricane_percent and hurricane_percent <= TUNING.HURRICANE_PERCENT_LIGHTNING_END) then
                        local lightning_dt = (dt * lightning_check) --dt is applied once per check
                        if _nextlightningtime_island > lightning_dt then
                            _nextlightningtime_island = _nextlightningtime_island - lightning_dt
                        else --at this point only one runs based on if its hurricane or not so just change the calculations accordingly
                            local lightningbase = hurricane_percent ~= nil and (0.4 * math.cos(2.0 * PI * math.clamp((1.0 / (TUNING.HURRICANE_PERCENT_LIGHTNING_END - TUNING.HURRICANE_PERCENT_LIGHTNING_START)) * (hurricane_percent - TUNING.HURRICANE_PERCENT_LIGHTNING_START), 0.0, 1.0)) + 0.6) or nil
                            local min = _minlightningdelay_island or lightningbase ~= nil and (2 * lightningbase + 2) or easing.linear(preciprate, 30, 10, 1)
                            local max = _maxlightningdelay_island or lightningbase ~= nil and (4 * lightningbase + 4) or (min + easing.linear(preciprate, 30, 10, 1))
                            _nextlightningtime_island = GetRandomMinMax(min, max)
                            if (preciprate > .75 * (lightningbase ~= nil and TUNING.HURRICANE_RAIN_SCALE or 1) and ((lightningbase ~= nil and math.random() < TUNING.HURRICANE_LIGHTNING_STRIKE_CHANCE) or (lightningbase == nil and _lightningmode == LIGHTNING_MODES.always))) and next(_lightningtargets_island) ~= nil then
                            
                                local targeti = math.min(math.floor(easing.inQuint(math.random(), 1, #_lightningtargets_island, 1)), #_lightningtargets_island)
                                local target = _lightningtargets_island[targeti]
                                table.remove(_lightningtargets_island, targeti)
                                table.insert(_lightningtargets_island, target)

                                local x, y, z = target.Transform:GetWorldPosition()
                                local radius = 2 + math.random() * 8
                                local theta = math.random() * 2 * PI
                                local pos = Vector3(x + radius * math.cos(theta), y, z + radius * math.sin(theta))
                                _world:PushEvent("ms_sendlightningstrike", pos)
                            else
                                SpawnPrefab(preciprate > .5 and "thunder_close" or "thunder_far")._islandthunder:set(true)
                            end
                        end
                    end
                end
    		end

    		if _isIAClimate then

    			--Update precipitation effects
    			if _preciptypeisland:value() == PRECIP_TYPES.rain then
    				local preciprate_sound = preciprate
    				if _activatedplayer == nil then
    					StartTreeRainSound(0)
    					StopUmbrellaRainSound_old()
    				elseif _activatedplayer.replica.sheltered ~= nil and _activatedplayer.replica.sheltered:IsSheltered() then
    					StartTreeRainSound(preciprate_sound)
    					StopUmbrellaRainSound_old()
    					preciprate_sound = preciprate_sound - .4
    				else
    					StartTreeRainSound(0)
    					if _activatedplayer.replica.inventory:EquipHasTag("umbrella") then
    						preciprate_sound = preciprate_sound - .4
    						StartUmbrellaRainSound()
    					else
    						StopUmbrellaRainSound_old()
    					end
    				end
                    if _season == "spring" then
                        StartAmbientIslandRainSound(math.min(preciprate_sound, 1))
                    else
                        StopAmbientIslandRainSound()
                    end
    				StartAmbientRainSound(preciprate_sound)
    				if _hasfx then
                        -- DST reduces rain fx but greenseason needs it: custom calculation squares peak to make mildseason rain mild and greenseason rain strong
                        _rainfx.particles_per_tick = 10 * preciprate * _peakprecipitationrate_island:value() ^ 2
                        _rainfx.splashes_per_tick = 8 * preciprate * _peakprecipitationrate_island:value()
    				end
    			else
    				StopAmbientHailSound()
    				StopAmbientRainSound_old()
                    StopAmbientIslandRainSound()
    				StopTreeRainSound_old()
    				StopUmbrellaRainSound_old()
    				if _hasfx then
    					_rainfx.particles_per_tick = 0
    					_rainfx.splashes_per_tick = 0
    				end
    			end

                --Update hail effects
                if _isIslandClimate and _hail:value() then
                    local hailrate = CalculateHailRate_Island()
                    StartAmbientHailSound(math.min(hailrate, 1))
                    if _hasfx then
                        -- DST reduces rain fx but hurricanes need the atmosphere
                        _hailfx.particles_per_tick = 6 * hailrate
                        _hailfx.splashes_per_tick = 5 * hailrate
                    end
                else
                    StopAmbientHailSound()
                    if _hasfx then
                        _hailfx.particles_per_tick = 0
                        _hailfx.splashes_per_tick = 0
                    end
                end

    			if _hurricane_gust_speed:value() > 0 then
    				StartAmbientWindSound(math.min(_hurricane_gust_speed:value(),1))
    			else
    				StopAmbientWindSound()
    			end

    			--Update pollen
    			if _hasfx then
    				_pollenfx.particles_per_tick = 0
    				_snowfx.particles_per_tick = 0
    			end
    		end

    		PushWeather_Island()
            if _hurricane:value() then
                PushHurricane_Island()
            end
    	end

        if not _isIAClimate then
            StopAmbientWindSound()
            StopAmbientHailSound()
            StopAmbientIslandRainSound()
            if _hasfx then
                _hailfx.particles_per_tick = 0
                _hailfx.splashes_per_tick = 0
            end
        end

    end

    inst.LongUpdate = inst.OnUpdate

    local OnSave_old = inst.OnSave
    if OnSave_old then function inst:OnSave()
    	local t = OnSave_old(self)
    	t.moisturerateval_island = _moisturerateval
    	t.moisturerateoffset_island = _moisturerateoffset
    	t.moistureratemultiplier_island = _moistureratemultiplier
    	t.moisturerate_island = _moisturerate_island:value()
    	t.moisture_island = _moisture_island:value()
    	t.moisturefloor_island = _moisturefloor_island:value()
    	t.moistureceilmultiplier_island = _moistureceilmultiplier
    	t.moisturefloormultiplier_island = _moisturefloormultiplier
    	t.moistureceil_island = _moistureceil_island:value()
    	t.preciptypeisland = PRECIP_TYPE_NAMES[_preciptypeisland:value()]
    	t.peakprecipitationrate_island = _peakprecipitationrate_island:value()
    	t.minlightningdelay_island = _minlightningdelay_island
    	t.maxlightningdelay_island = _maxlightningdelay_island
    	t.nextlightningtime_island = _nextlightningtime_island
    	t.wetness_island = _wetness_island:value()
    	t.wet_island = _wet_island:value() or nil
        t.hurricanetease_started = _hurricanetease_started
        t.hurricanetease_start = _hurricanetease_start
    	t.hurricane_timer = _ismastersim and _hurricane and _hurricane:value() and _hurricane_timer:value() or nil
    	t.hurricane_duration = _ismastersim and _hurricane and _hurricane:value() and _hurricane_duration:value() or nil
    	t.hurricane_gust_angle = _hurricane_gust_angle:value() or nil
        return t
    end end

    local OnLoad_old = inst.OnLoad
    if OnLoad_old then function inst:OnLoad(data)
    	OnLoad_old(self, data)
        _season = data.season or "autumn"
        _moisturerateval = data.moisturerateval_island or 1
        _moisturerateoffset = data.moisturerateoffset_island or 0
        _moistureratemultiplier = data.moistureratemultiplier_island or 1
        _moisturerate_island:set(data.moisturerate_island or CalculateMoistureRate_Island())
        _moisture_island:set(data.moisture_island or 0)
        _moisturefloor_island:set(data.moisturefloor_island or 0)
        _moistureceilmultiplier = data.moistureceilmultiplier_island or 1
        _moisturefloormultiplier = data.moisturefloormultiplier_island or 1
        _moistureceil_island:set(data.moistureceil_island or RandomizeMoistureCeil_Island())
        _preciptypeisland:set(PRECIP_TYPES[data.preciptypeisland] or PRECIP_TYPES.none)
        _peakprecipitationrate_island:set(data.peakprecipitationrate_island or 1)
        _minlightningdelay_island = data.minlightningdelay_island
        _maxlightningdelay_island = data.maxlightningdelay_island
        _nextlightningtime_island = data.nextlightningtime_island or 5
        _wetness_island:set(data.wetness_island or 0)
        _wet_island:set(data.wet_island == true)
    	_hurricane_gust_angle:set(data.hurricane_gust_angle or math.random(0, 360))
        _hurricanetease_started = _ismastersim and (data.hurricanetease_started or false) or nil
        _hurricanetease_start = _ismastersim and (data.hurricanetease_start or 0) or nil
    	if data.hurricane_duration and data.hurricane_timer then
    		StartHurricaneStorm(data.hurricane_duration, data.hurricane_timer)
    	end

    	PushWeather_Island()
    end end


    function inst:GetIADebugString()
        local preciprate = CalculatePrecipitationRate_Island()
        local hailrate = CalculateHailRate_Island()
        local wetrate = CalculateWetnessRate_Island(_world.state.islandtemperature, preciprate)
        local str =
        {
            string.format("moisture:%2.2f(%2.2f/%2.2f) + %2.2f", _moisture_island:value(), _moisturefloor_island:value(), _moistureceil_island:value(), _moisturerate_island:value()),
            string.format("preciprate:(%2.2f of %2.2f)", preciprate, _peakprecipitationrate_island:value()),
            string.format("wetness:%2.2f(%s%2.2f)%s", _wetness_island:value(), wetrate > 0 and "+" or "", wetrate, _wet_island:value() and " WET" or ""),
            string.format("hurricane:%2.2f/%2.2f(%s) %2.2f", _hurricane_timer:value(), _hurricane_duration:value(), GUST_PHASE_NAMES[_hurricane_gust_state:value()] or "unknown gust phase", hailrate),
        }

        if _ismastersim then
            table.insert(str, string.format("lightning:%2.2f (%s)", _nextlightningtime_island, LIGHTNING_MODE_NAMES[_lightningmode]))
        end

        return table.concat(str, ", ")
    end
end)
