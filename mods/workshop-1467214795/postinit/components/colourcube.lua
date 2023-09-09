local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local CUBES = table.invert({
	"default",
	"island",
	"volcano",
})

IAENV.AddComponentPostInit("colourcube", function(cmp)

    local OnOverrideCCPhaseFn, _UpdateAmbientCCTable, _SEASON_COLOURCUBES
    local function Setup()
        for i, v in ipairs(cmp.inst.event_listening["playeractivated"][TheWorld]) do
            OnOverrideCCPhaseFn = UpvalueHacker.GetUpvalue(v, "OnOverrideCCPhaseFn")
            if OnOverrideCCPhaseFn then
                break
            end
        end

        -- _OnPlayerActivated = UpvalueHacker.GetUpvalue(OnOverrideCCPhaseFn, "OnPlayerActivated")
        _UpdateAmbientCCTable = UpvalueHacker.GetUpvalue(OnOverrideCCPhaseFn, "UpdateAmbientCCTable")
        -- _Blend = UpvalueHacker.GetUpvalue(_UpdateAmbientCCTable, "Blend")
        _SEASON_COLOURCUBES = UpvalueHacker.GetUpvalue(_UpdateAmbientCCTable, "SEASON_COLOURCUBES")
        assert(OnOverrideCCPhaseFn and _UpdateAmbientCCTable and _SEASON_COLOURCUBES)
    end

    if not pcall(Setup) then return IA_MODULE_ERROR("colourcube") end


    local SEASON_COLOURCUBES_ISLAND = {
    	autumn = {	
    		day = resolvefilepath("images/colour_cubes/sw_mild_day_cc.tex"),
    		dusk = resolvefilepath("images/colour_cubes/SW_mild_dusk_cc.tex"),
    		night = resolvefilepath("images/colour_cubes/SW_mild_dusk_cc.tex"),
    		full_moon = resolvefilepath("images/colour_cubes/purple_moon_cc.tex"),
    	},
    	winter = {
    		day = resolvefilepath("images/colour_cubes/SW_wet_day_cc.tex"),
    		dusk = resolvefilepath("images/colour_cubes/SW_wet_dusk_cc.tex"),
    		night = resolvefilepath("images/colour_cubes/SW_wet_dusk_cc.tex"),
    		full_moon = resolvefilepath("images/colour_cubes/purple_moon_cc.tex"),
    	},
    	spring = {
    		day = resolvefilepath("images/colour_cubes/sw_green_day_cc.tex"),
    		dusk = resolvefilepath("images/colour_cubes/sw_green_dusk_cc.tex"),
    		night = resolvefilepath("images/colour_cubes/sw_green_dusk_cc.tex"),
    		full_moon = resolvefilepath("images/colour_cubes/purple_moon_cc.tex"),
    	},
    	summer = {
    		day = resolvefilepath("images/colour_cubes/SW_dry_day_cc.tex"),
    		dusk = resolvefilepath("images/colour_cubes/SW_dry_dusk_cc.tex"),
    		night = resolvefilepath("images/colour_cubes/SW_dry_dusk_cc.tex"),
    		full_moon = resolvefilepath("images/colour_cubes/purple_moon_cc.tex"),
    	},
    }

	local dormant = resolvefilepath("images/colour_cubes/sw_volcano_cc.tex")
	local active = resolvefilepath("images/colour_cubes/sw_volcano_active_cc.tex")

	local SEASON_COLOURCUBES_VOLCANO = {
		autumn = { --defaults to this if the season is missing
			day = dormant,
			dusk = dormant,
			night = dormant,
			full_moon = dormant
		},
		summer = { --vm is active during dry season (summer)
			day = active,
			dusk = active,
			night = active,
			full_moon = active
		},
	}

    local _activatedplayer
    local _showencc = CUBES.default
    local function UpdateAmbientCCTable(blendtime)
    	if _activatedplayer then
        	local climate = GetClimate(_activatedplayer)
			if IsClimate(climate, "volcano") then
				if _showencc ~= CUBES.volcano then
					_showencc = CUBES.volcano
        			UpvalueHacker.SetUpvalue(_UpdateAmbientCCTable, SEASON_COLOURCUBES_VOLCANO, "SEASON_COLOURCUBES")
				end
            elseif IsClimate(climate, "island") then
        		if _showencc ~= CUBES.island then
					_showencc = CUBES.island
        			UpvalueHacker.SetUpvalue(_UpdateAmbientCCTable, SEASON_COLOURCUBES_ISLAND, "SEASON_COLOURCUBES")
        		end
        	elseif IsDSTClimate(climate) and _showencc ~= CUBES.default then
        		_showencc = CUBES.default
        		UpvalueHacker.SetUpvalue(_UpdateAmbientCCTable, _SEASON_COLOURCUBES, "SEASON_COLOURCUBES")
        	end
        end
    	
    	return _UpdateAmbientCCTable(blendtime)
    end

    UpvalueHacker.SetUpvalue(OnOverrideCCPhaseFn, UpdateAmbientCCTable, "UpdateAmbientCCTable")

    local function onClimateDirty()
    	UpdateAmbientCCTable(10)
    end
    cmp.inst:ListenForEvent("playeractivated", function(src, player)
    	if player and _activatedplayer ~= player then
    		player:ListenForEvent("climatechange", onClimateDirty)
    		player:DoTaskInTime(0, function() UpdateAmbientCCTable(.01) end) --initialise
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
