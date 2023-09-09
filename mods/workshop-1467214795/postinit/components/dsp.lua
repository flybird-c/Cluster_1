local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local DSPS = table.invert({
	"default",
	"tropical",
})

IAENV.AddComponentPostInit("dsp", function(cmp)
	local _worldstate = TheWorld.state

    local _OnUpdateSeasonDSP
    local _StartPlayerListeners
    for i, v in ipairs(cmp.inst.event_listening["playeractivated"][TheWorld]) do
		_StartPlayerListeners = UpvalueHacker.GetUpvalue(v, "StartPlayerListeners")
		if _StartPlayerListeners then
			_OnUpdateSeasonDSP = UpvalueHacker.GetUpvalue(_StartPlayerListeners, "OnUpdateSeasonDSP")
			if _OnUpdateSeasonDSP then
				break
			end
		end
    end
    if not _OnUpdateSeasonDSP then return end

    local UpdateSeasonDSP = UpvalueHacker.GetUpvalue(_OnUpdateSeasonDSP, "UpdateSeasonDSP")
    local LOWDSP = UpvalueHacker.GetUpvalue(UpdateSeasonDSP, "LOWDSP")
    local HIGHDSP = UpvalueHacker.GetUpvalue(UpdateSeasonDSP, "HIGHDSP")

    local LOWDSP_TROPICAL = {

    }

    local HIGHDSP_TROPICAL = {

    }

    local _activatedplayer
    local _useddsp = DSPS.default
    local function OnUpdateSeasonDSP(season, duration, ...)
    	if _activatedplayer then
        	local climate = GetClimate(_activatedplayer)
			if IsIAClimate(climate) then
				if _useddsp ~= DSPS.tropical then
					_useddsp = DSPS.tropical
        			UpvalueHacker.SetUpvalue(UpdateSeasonDSP, LOWDSP_TROPICAL, "LOWDSP")
                    UpvalueHacker.SetUpvalue(UpdateSeasonDSP, HIGHDSP_TROPICAL, "HIGHDSP")
				end
        	elseif IsDSTClimate(climate) and _useddsp ~= DSPS.default then
        		_useddsp = DSPS.default
                UpvalueHacker.SetUpvalue(UpdateSeasonDSP, LOWDSP, "LOWDSP")
                UpvalueHacker.SetUpvalue(UpdateSeasonDSP, HIGHDSP, "HIGHDSP")
        	end
        end
    	
    	return _OnUpdateSeasonDSP(season, duration, ...)
    end

    UpvalueHacker.SetUpvalue(_StartPlayerListeners, OnUpdateSeasonDSP, "OnUpdateSeasonDSP")

    local function onClimateDirty()
    	OnUpdateSeasonDSP(_worldstate.season, 10)
    end
    cmp.inst:ListenForEvent("playeractivated", function(src, player)
    	if player and _activatedplayer ~= player then
    		player:ListenForEvent("climatechange", onClimateDirty)
    		player:DoTaskInTime(0, function() OnUpdateSeasonDSP(_worldstate.season, .01) end) --initialise
    	end
    	_activatedplayer = player
    end)
    cmp.inst:ListenForEvent("playerdeactivated", function(src, player)
    	if player then
    		player:RemoveEventCallback("climatechange", onClimateDirty)
    		if _activatedplayer == player then
    			_activatedplayer = nil
    		end
    	end
    end)
end)
