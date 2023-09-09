local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

IAENV.AddComponentPostInit("worldstate", function(cmp)
    --------------------------------------------------------------------------
    --[[ Private member functions ]]
    --------------------------------------------------------------------------

    local SetVariable
    for i, v in ipairs(cmp.inst.event_listening["temperaturetick"][TheWorld]) do
    	SetVariable = UpvalueHacker.GetUpvalue(v, "SetVariable")
    	if SetVariable then
    		break
    	end
    end
    if not SetVariable then return end

    --------------------------------------------------------------------------
    --[[ Private event handlers ]]
    --------------------------------------------------------------------------

    local function OnIslandTemperatureTick(src, temperature)
        SetVariable("islandtemperature", temperature)
    end

    local function OnIslandWeatherTick(src, data)
        SetVariable("islandmoisture", data.moisture)
        SetVariable("islandpop", data.pop)
        SetVariable("islandprecipitationrate", data.precipitationrate)
        SetVariable("islandwetness", data.wetness)
        -- SetVariable("gustspeed", data.gustspeed)
    end

    local function OnIslandMoistureCeilChanged(src, moistureceil)
        SetVariable("islandmoistureceil", moistureceil)
    end

    local function OnIslandPrecipitationChanged(src, preciptype)
        SetVariable("islandprecipitation", preciptype)
        SetVariable("islandisraining", preciptype == "rain", "islandrain")
    end

    local function OnHailChanged(src, hail)
        SetVariable("islandishailing", hail, "islandhail")
    end

    local function OnIslandWetChanged(src, wet)
        SetVariable("islandiswet", wet)
    end

    local function OnHurricaneChanged(src, b)
        SetVariable("hurricane", b)
    end

    local function OnHurricaneTick(src, data)
        SetVariable("hailrate", data.hailrate)
        SetVariable("hurricane_progress", data.hurricane_progress)
    end

    local function OnGustSpeedChanged(src, speed)
        SetVariable("gustspeed", speed)
    end

    local function OnGustAngleChanged(src, angle)
        SetVariable("gustangle", angle)
    end

    --------------------------------------------------------------------------
    --[[ Initialization ]]
    --------------------------------------------------------------------------
    --[[
        World state variables are initialized to default values that can be
        used by entities if there are no world components controlling those
        variables.  e.g. If there is no season component on the world, then
        everything will run in autumn state.
    --]]

    cmp.data.islandtemperature = TUNING.STARTING_TEMP
    cmp.data.islandmoisture = 0
    cmp.data.islandpop = 0
    cmp.data.islandprecipitationrate = 0
    cmp.data.islandwetness = 0
    cmp.data.islandmoistureceil = 0
    --cmp.data.islandprecipitation = "none"
    cmp.data.islandisraining = false
    cmp.data.islandishailing = false
    cmp.data.islandiswet = false
    cmp.data.hurricane = false
    cmp.data.hurricane_progress = 0
    cmp.data.hailrate = 0
    cmp.data.gustspeed = 0
    cmp.data.gustangle = 0

    cmp.inst:ListenForEvent("islandtemperaturetick", OnIslandTemperatureTick)
    cmp.inst:ListenForEvent("islandweathertick", OnIslandWeatherTick)
    cmp.inst:ListenForEvent("moistureceil_islandchanged", OnIslandMoistureCeilChanged)
    cmp.inst:ListenForEvent("precipitation_islandchanged", OnIslandPrecipitationChanged)
    cmp.inst:ListenForEvent("wet_islandchanged", OnIslandWetChanged)
    cmp.inst:ListenForEvent("hailchanged", OnHailChanged)
    cmp.inst:ListenForEvent("hurricanechanged", OnHurricaneChanged)
    cmp.inst:ListenForEvent("islandhurricanetick", OnHurricaneTick)
    cmp.inst:ListenForEvent("gustspeedchanged", OnGustSpeedChanged)
    cmp.inst:ListenForEvent("gustanglechanged", OnGustAngleChanged)

    cmp.inst:ListenForEvent("snowcoveredchanged", function(inst, show)
        TheSim:HideAnimOnEntitiesWithTag("Climate_island", "snow")
        TheSim:HideAnimOnEntitiesWithTag("Climate_volcano", "snow")
    end)
end)
