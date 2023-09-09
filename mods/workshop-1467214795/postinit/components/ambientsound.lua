local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

IAENV.AddComponentPostInit("ambientsound", function(cmp)
    local inst = cmp.inst

    local AMBIENT_SOUNDS--, WAVE_SOUNDS
    local function Setup()
        AMBIENT_SOUNDS = UpvalueHacker.GetUpvalue(cmp.OnUpdate, "AMBIENT_SOUNDS")

        assert(AMBIENT_SOUNDS)
    end

    if not pcall(Setup) then return IA_MODULE_ERROR("ambientsound") end

	local HURRICANE_SOUND = {}
	local VOLCANO_SOUNDS = {}

    local _reverb_override = nil
    local _old_reverb = nil

    local _SetReverbPreset = cmp.SetReverbPreset
    function cmp:SetReverbPreset(reverb, ...)
        if not _reverb_override then
            _SetReverbPreset(self, reverb, ...)
        end		
        _old_reverb = reverb
    end
    
    function cmp:SetReverbOveride(reverb)
        _reverb_override = reverb
        TheSim:SetReverbPreset(reverb)
    end
    
    function cmp:ClearReverbOveride()
        _reverb_override = nil	
        TheSim:SetReverbPreset(_old_reverb or "default")
    end

    local REVERB_OVERRIDES = {
        [CLIMATE_IDS.volcano] = "volcanolevel",
    }

    -- local WAVE_OVERRIDES = {
    --     [CLIMATE_IDS.volcano] = false,
    -- }

    -- Note: We dont support both at the same tiem
    local function AddHurricaneSound(tile, sound)
        local hurricane_tile = "HURRICANE_" .. INVERTED_WORLD_TILES[tile]
        AMBIENT_SOUNDS[ hurricane_tile ] = {
            sound = sound,
        }
        HURRICANE_SOUND[ tile ] = hurricane_tile
    end

    local function AddVolcanoSounds(tile, dormantsound, activesound)
        local volcano_tile = "VOLCANO_" .. INVERTED_WORLD_TILES[tile]
        AMBIENT_SOUNDS[ volcano_tile ] = {
            sound = dormantsound,
            summersound = activesound,
        }
        VOLCANO_SOUNDS[ tile ] = volcano_tile
    end

	local _worldstate = TheWorld.state

    AMBIENT_SOUNDS[ WORLD_TILES.JUNGLE ] = {
		sound="ia/amb/mild/jungleAMB",
		wintersound="ia/amb/wet/jungleAMB",
		springsound="ia/amb/green/jungleAMB",
		summersound="ia/amb/dry/jungleAMB",
    	rainsound = "ia/amb/rain/jungleAMB", 
    }
    AddHurricaneSound(WORLD_TILES.JUNGLE, "ia/amb/hurricane/jungleAMB")
    AMBIENT_SOUNDS[ WORLD_TILES.BEACH ] = {
		sound="ia/amb/mild/beachAMB", 
		wintersound="ia/amb/wet/beachAMB", 
		springsound="ia/amb/green/beachAMB", 
		summersound="ia/amb/dry/beachAMB",
    	rainsound = "ia/amb/rain/beachAMB", 
    }
    AddHurricaneSound(WORLD_TILES.BEACH, "ia/amb/hurricane/beachAMB")
    -- AMBIENT_SOUNDS[ WORLD_TILES.SWAMP ] = { --NOTE: Unused
	-- 	sound="ia/amb/mild/marshAMB", 
	-- 	wintersound="ia/amb/wet/marshAMB", 
	-- 	springsound="ia/amb/green/marshAMB", 
	-- 	summersound="ia/amb/dry/marshAMB",
    -- 	rainsound = "ia/amb/rain/marshAMB", 
    -- 	hurricanesound = "ia/amb/hurricane/marshAMB",
    -- }
    AMBIENT_SOUNDS[ WORLD_TILES.MAGMAFIELD ] = {
		sound="ia/amb/mild/rockyAMB", 
		wintersound="ia/amb/wet/rockyAMB", 
		springsound="ia/amb/green/rockyAMB", 
		summersound="ia/amb/dry/rockyAMB",
    	rainsound = "ia/amb/rain/rockyAMB", 
    }
    AddHurricaneSound(WORLD_TILES.MAGMAFIELD, "ia/amb/hurricane/rockyAMB")
    AMBIENT_SOUNDS[ WORLD_TILES.TIDALMARSH ] = {
		sound="ia/amb/mild/marshAMB", 
		wintersound="ia/amb/wet/marshAMB", 
		springsound="ia/amb/green/marshAMB", 
		summersound="ia/amb/dry/marshAMB",
    	rainsound = "ia/amb/rain/marshAMB", 
    }
    AddHurricaneSound(WORLD_TILES.TIDALMARSH, "ia/amb/hurricane/marshAMB")
    AMBIENT_SOUNDS[ WORLD_TILES.MEADOW ] = {
		sound="ia/amb/mild/grasslandAMB", 
		wintersound="ia/amb/wet/grasslandAMB", 
		springsound="ia/amb/green/grasslandAMB", 
		summersound="ia/amb/dry/grasslandAMB",
    	rainsound = "ia/amb/rain/grasslandAMB", 
    }
    AddHurricaneSound(WORLD_TILES.MEADOW, "ia/amb/hurricane/grasslandAMB")
    AMBIENT_SOUNDS[ WORLD_TILES.OCEAN_SHALLOW ] = {
		sound="ia/amb/mild/ocean_shallow", 
    	wintersound = "ia/amb/wet/ocean_shallowAMB", 
    	springsound = "ia/amb/green/ocean_shallowAMB", 
    	summersound = "ia/amb/dry/ocean_shallow", 
    	rainsound = "ia/amb/rain/ocean_shallowAMB", 
    }
    AddHurricaneSound(WORLD_TILES.OCEAN_SHALLOW, "ia/amb/hurricane/ocean_shallowAMB")
	AMBIENT_SOUNDS[ WORLD_TILES.OCEAN_SHALLOW_SHORE ] = {
    	sound="ia/amb/mild/waves", 
		wintersound="ia/amb/wet/waves", 
		springsound="ia/amb/green/waves", 
		summersound="ia/amb/dry/waves", 
		rainsound="ia/amb/rain/waves", 
    }
    AddHurricaneSound(WORLD_TILES.OCEAN_SHALLOW_SHORE, "ia/amb/hurricane/waves")
    AMBIENT_SOUNDS[ WORLD_TILES.OCEAN_MEDIUM ] = {
		sound="ia/amb/mild/ocean_shallow", 
		wintersound="ia/amb/wet/ocean_shallowAMB", 
		springsound="ia/amb/green/ocean_shallowAMB", 
		summersound="ia/amb/dry/ocean_shallow",
    	rainsound = "ia/amb/rain/ocean_shallowAMB", 
    }
    AddHurricaneSound(WORLD_TILES.OCEAN_MEDIUM, "ia/amb/hurricane/ocean_shallowAMB")
    AMBIENT_SOUNDS[ WORLD_TILES.OCEAN_DEEP ] = {
		sound="ia/amb/mild/ocean_deep", 
		wintersound="ia/amb/wet/ocean_deepAMB", 
		springsound="ia/amb/green/ocean_deepAMB", 
		summersound="ia/amb/dry/ocean_deep",
    	rainsound = "ia/amb/rain/ocean_deepAMB", 
    }
    AddHurricaneSound(WORLD_TILES.OCEAN_DEEP, "ia/amb/hurricane/ocean_deepAMB")
    AMBIENT_SOUNDS[ WORLD_TILES.OCEAN_SHIPGRAVEYARD ] = {
    	sound="ia/amb/mild/ocean_deep", 
		wintersound="ia/amb/wet/ocean_deepAMB", 
		springsound="ia/amb/green/ocean_deepAMB", 
		summersound="ia/amb/dry/ocean_deep",
    	rainsound = "ia/amb/rain/ocean_deepAMB", 
    }
    AddHurricaneSound(WORLD_TILES.OCEAN_SHIPGRAVEYARD, "ia/amb/hurricane/ocean_deepAMB")
    AMBIENT_SOUNDS[ WORLD_TILES.OCEAN_CORAL ] = {
		sound="ia/amb/mild/coral_reef", 
		wintersound="ia/amb/wet/coral_reef", 
		springsound="ia/amb/green/coral_reef", 
		summersound="ia/amb/dry/coral_reef",
    	rainsound = "ia/amb/rain/coral_reef", 
    }
    AddHurricaneSound(WORLD_TILES.OCEAN_CORAL, "ia/amb/hurricane/coral_reef")
    AMBIENT_SOUNDS[ WORLD_TILES.MANGROVE ] = {
		sound="ia/amb/mild/mangrove", 
		wintersound="ia/amb/wet/mangrove", 
		springsound="ia/amb/green/mangrove", 
		summersound="ia/amb/dry/mangrove",
    	rainsound = "ia/amb/rain/mangrove", 
    }
    AddHurricaneSound(WORLD_TILES.MANGROVE, "ia/amb/hurricane/mangrove")
    AMBIENT_SOUNDS[ WORLD_TILES.VOLCANO ] = {
    	sound = "ia/amb/volcano/ground_ash", 
    }
    AddVolcanoSounds(WORLD_TILES.VOLCANO, "ia/amb/volcano/dormant", "ia/amb/volcano/active")
    AMBIENT_SOUNDS[ WORLD_TILES.VOLCANO_ROCK ] = {
    	sound = "ia/amb/volcano/ground_ash", 
    }
    AddVolcanoSounds(WORLD_TILES.VOLCANO_ROCK, "ia/amb/volcano/dormant", "ia/amb/volcano/active")
    AMBIENT_SOUNDS[ WORLD_TILES.VOLCANO_LAVA ] = {
    	sound = "ia/amb/volcano/lava",
    }
    AMBIENT_SOUNDS[ WORLD_TILES.ASH ] = {
    	sound = "ia/amb/volcano/ground_ash", 
    }
    AddVolcanoSounds(WORLD_TILES.ASH, "ia/amb/volcano/dormant", "ia/amb/volcano/active")

	local _activatedplayer
	local function OnClimateChanged()
		if _activatedplayer then
            local climate = GetClimate(_activatedplayer)
			local _isVolcanoClimate = IsClimate(climate, "volcano")

            local reverb_override = REVERB_OVERRIDES[climate]
            if reverb_override ~= nil then
                cmp:SetReverbOveride(reverb_override)
            else
                cmp:ClearReverbOveride()
            end

			for tile, volcano_tile in pairs(VOLCANO_SOUNDS) do
				inst:PushEvent("overrideambientsound", {
                    tile = tile,
                    override = _isVolcanoClimate and volcano_tile or nil
                })
			end
		end
	end

	local function OnHurricaneChanged(hurricane)
		if _activatedplayer then
			for tile, hurricane_tile in pairs(HURRICANE_SOUND) do
				inst:PushEvent("overrideambientsound", {
                    tile = tile,
                    override = hurricane and hurricane_tile or nil,
                })
			end
		end
	end

	inst:ListenForEvent("playeractivated", function(src, player)
    	if player and _activatedplayer ~= player then
    		player:ListenForEvent("climatechange", OnClimateChanged)
    		player:DoTaskInTime(0, OnClimateChanged) --initialise
			player:DoTaskInTime(0, function() OnHurricaneChanged(_worldstate.hurricane) end)
    	end
    	_activatedplayer = player
    end)
    inst:ListenForEvent("playerdeactivated", function(src, player)
    	if player then
    		player:RemoveEventCallback("climatechange", OnClimateChanged)
    		if _activatedplayer == player then
    			_activatedplayer = nil
    		end
    	end
    end)
	inst:WatchWorldState("hurricanechanged", OnHurricaneChanged)
end)
