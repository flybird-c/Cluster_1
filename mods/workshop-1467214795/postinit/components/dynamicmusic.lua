local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local select = select
local debug = debug

IAENV.AddComponentPostInit("dynamicmusic", function(self, inst)
    if IA_CONFIG.dynamicmusic == false then
        return
    end

    local OnEnableDynamicMusic, OnPlayerActivated, StartPlayerListeners, StopBusy, StartBusy, StopDanger, OnAttacked, StartBusyTheme, BUSYTHEMES, StartTriggeredWater, StartOcean, StartDanger
    local function Setup()
        OnEnableDynamicMusic = inst:GetEventCallbacks("enabledynamicmusic", TheWorld)
        OnPlayerActivated = inst:GetEventCallbacks("playeractivated", inst, "scripts/components/dynamicmusic.lua")
    
        StartPlayerListeners = UpvalueHacker.GetUpvalue(OnPlayerActivated, "StartPlayerListeners")
    
        StopBusy = UpvalueHacker.GetUpvalue(OnEnableDynamicMusic, "StopBusy")
        StartBusy = UpvalueHacker.GetUpvalue(StartPlayerListeners, "StartBusy")
        StopDanger = UpvalueHacker.GetUpvalue(OnEnableDynamicMusic, "StopDanger")
        OnAttacked = UpvalueHacker.GetUpvalue(StartPlayerListeners, "OnAttacked")
        StartBusyTheme = UpvalueHacker.GetUpvalue(StartPlayerListeners, "StartFarming", "StartBusyTheme")
        BUSYTHEMES = UpvalueHacker.GetUpvalue(StartPlayerListeners, "StartFarming", "BUSYTHEMES")
        StartTriggeredWater = UpvalueHacker.GetUpvalue(StartPlayerListeners, "StartTriggeredWater")
        StartOcean = UpvalueHacker.GetUpvalue(StartTriggeredWater, "StartOcean")
        StartDanger = UpvalueHacker.GetUpvalue(OnAttacked, "StartDanger")

        assert(OnEnableDynamicMusic and OnPlayerActivated and StartPlayerListeners and StopBusy and StartBusy and StopDanger and OnAttacked and StartBusyTheme and BUSYTHEMES and StartTriggeredWater and StartOcean and StartDanger)
    end

    if not pcall(Setup) then return IA_MODULE_ERROR("dynamicmusic") end

    BUSYTHEMES.OCEAN_NIGHT = GetDictLength(BUSYTHEMES) + 1
    BUSYTHEMES.SURFING = GetDictLength(BUSYTHEMES) + 1
    BUSYTHEMES.SURFING_NIGHT = GetDictLength(BUSYTHEMES) + 1

    -- Optimization
    local _, i_busytask = UpvalueHacker.GetUpvalue(StartOcean, "_busytask")
    local _, i_busytheme = UpvalueHacker.GetUpvalue(StartOcean, "_busytheme")
    local _, i_extendtime = UpvalueHacker.GetUpvalue(StartOcean, "_extendtime")

    local get_busytask = function() return select(2, debug.getupvalue(StartOcean, i_busytask)) end
    local get_busytheme = function() return select(2, debug.getupvalue(StartOcean, i_busytheme)) end
    local get_extendtime = function() return select(2, debug.getupvalue(StartOcean, i_extendtime)) end

    local set_busytask = function(task) debug.setupvalue(StartOcean, i_busytask, task) end
    local set_busytheme = function(theme) debug.setupvalue(StartOcean, i_busytheme, theme) end
    local set_extendtime = function(time) debug.setupvalue(StartOcean, i_extendtime, time) end

    local _isenabled = nil
    local _soundemitter = nil

    local _isday = nil
    local _iscave = inst:HasTag("cave")
    local _iserupting = false
    local _playsIAmusic = false
    local _activatedplayer =  nil

    local soundAlias = {
        --busy
        ["dontstarve/music/music_work"] = "ia/music/music_work_season_1",
        ["dontstarve/music/music_work_winter"] = "ia/music/music_work_season_2",
        ["dontstarve_DLC001/music/music_work_spring"] = "ia/music/music_work_season_3",
        ["dontstarve_DLC001/music/music_work_summer"] = "ia/music/music_work_season_4",
        --combat
        ["dontstarve/music/music_danger"] = "ia/music/music_danger_season_1",
        ["dontstarve/music/music_danger_winter"] = "ia/music/music_danger_season_2",
        ["dontstarve_DLC001/music/music_danger_spring"] = "ia/music/music_danger_season_3",
        ["dontstarve_DLC001/music/music_danger_summer"] = "ia/music/music_danger_season_4",
        --epic
        ["dontstarve/music/music_epicfight"] = "ia/music/music_epicfight_season_1",
        ["dontstarve/music/music_epicfight_winter"] = "ia/music/music_epicfight_season_2",
        ["dontstarve_DLC001/music/music_epicfight_spring"] = "ia/music/music_epicfight_season_3",
        ["dontstarve_DLC001/music/music_epicfight_summer"] = "ia/music/music_epicfight_season_4",
        --stinger
        ["dontstarve/music/music_dawn_stinger"] = "ia/music/music_dawn_stinger",
        ["dontstarve/music/music_dusk_stinger"] = "ia/music/music_dusk_stinger",
    }

------------------------------Adding IA Climate Music---------------------------------
    local function IA_MusicSwap(_inst, climate)
        if IsIAClimate(climate) then
            if not _playsIAmusic then
                -- print("CHANGE TO IA MUSIC")
                for k, v in pairs(soundAlias) do
                    SetSoundAlias(k, v)
                end

                _playsIAmusic = true
                set_busytheme(nil)
            end
        elseif _playsIAmusic then
            -- print("CHANGE TO DST MUSIC")
            for k, v in pairs(soundAlias) do
                SetSoundAlias(k, nil)
            end

            _playsIAmusic = false
            set_busytheme(nil)
        end
    end
---------------------------------------------------------------------------------------


----------------------------------Adding Sailing Music---------------------------------

    local function IsOceanTheme(theme)
        return theme == BUSYTHEMES.OCEAN or theme == BUSYTHEMES.OCEAN_NIGHT or theme == BUSYTHEMES.SURFING or theme == BUSYTHEMES.SURFING_NIGHT
    end

    local function IA_StopOcean(player, data)
        if (type(data) == "table" and data.force_stop_music or TheWorld.has_ia_ocean) and IsOceanTheme(get_busytheme()) then
            StopBusy(inst)
        end
    end

    local function IA_StartOcean(player, theme, sound, duration, extendtime)
        local _extendtime = get_extendtime()
        if _extendtime == 0 or GetTime() >= _extendtime then -- Dont play during stingers
            StartBusyTheme(player, theme, sound, duration, extendtime)
        end
    end
    UpvalueHacker.SetUpvalue(StartTriggeredWater, IA_StartOcean, "StartOcean")

    local function GetOceanTheme(player, ship)
        if not ship then return end
        local day = _iscave or _isday
        if ship.sailing_music then
            if day then
                return BUSYTHEMES.SURFING, ship.sailing_music[1]
            elseif ship.sailing_music[2] then
                return BUSYTHEMES.SURFING_NIGHT, ship.sailing_music[2]
            end
        elseif IsInIAClimate(player) then
            if day then
                return BUSYTHEMES.OCEAN, "ia/music/music_sailing_day"
            else
                return BUSYTHEMES.OCEAN_NIGHT, "ia/music/music_sailing_night"
            end
        end
        if day then
            return BUSYTHEMES.OCEAN, "turnoftides/music/sailing"
        end
    end


    local function IA_StartTriggeredWater(player, data, ...)

        if _iserupting then
            return
        end

        local boat = data and data.ia_boat or player.replica.sailor and player.replica.sailor:GetBoat() or nil
        local platform = player:GetCurrentPlatform()

        local theme, sound = GetOceanTheme(player, platform or boat)
        if theme and sound then
            if platform then
                IA_StartOcean(player, theme, sound, 30)
            elseif boat then
                IA_StartOcean(player, theme, sound, 75)
            end
        else
            IA_StopOcean(player, {force = true})
        end
    end
    UpvalueHacker.SetUpvalue(StartPlayerListeners, IA_StartTriggeredWater, "StartTriggeredWater")

    local function IA_OnPhase(_inst, phase)
        _isday = phase == "day"
    end

---------------------------------------------------------------------------------------


--------------------------------Adding Volcano Music-----------------------------------
    local function StartErupt(player)
        if not _isenabled or not player or not IsInIAClimate(player) or not _soundemitter or _iserupting then
            return
        end

        StopBusy()
        StopDanger()

        _soundemitter:PlaySound("ia/music/music_volcano_active", "erupt")
        -- _soundemitter:KillSound("dawn")

        _iserupting = true
    end

    local function StopErupt()
        if _soundemitter then
            _soundemitter:KillSound("erupt")
            _iserupting = false
        end
    end

    local function OnPlayerArrive(_inst, player)
        if player and player == _activatedplayer and IsInClimate(player, "volcano") and _soundemitter then
            if _iserupting or player.player_classified.smokerate:value() > 0 then
                _soundemitter:PlaySound("ia/music/music_volcano_active")
            else
                _soundemitter:PlaySound("ia/music/music_volcano_dormant")
            end
            --Repurpose this as a delay before stingers or busy can start again
            set_extendtime(GetTime() + 15)
        end
    end
---------------------------------------------------------------------------------------

    local function IA_StartPlayerListeners(player)
        inst:ListenForEvent("climatechange", IA_MusicSwap, player)
        inst:ListenForEvent("stopboatmusic", IA_StopOcean, player)
        inst:ListenForEvent("playerentered", OnPlayerArrive)
        inst:ListenForEvent("OnVolcanoEruptionBegin", StartErupt, player)
        inst:ListenForEvent("OnVolcanoEruptionEnd", StopErupt, player)
        inst:ListenForEvent("KrakenEncounter", StartDanger, player)  --Danger music on Kraken spawn
    end

    local function IA_StopPlayerListeners(player)
        inst:RemoveEventCallback("climatechange", IA_MusicSwap, player)
        inst:RemoveEventCallback("stopboatmusic", IA_StopOcean, player)
        inst:RemoveEventCallback("got_off_platform", IA_StopOcean, player)
        inst:RemoveEventCallback("playerentered", OnPlayerArrive)
        inst:RemoveEventCallback("OnVolcanoEruptionBegin", StartErupt, player)
        inst:RemoveEventCallback("OnVolcanoEruptionEnd", StopErupt, player)
        inst:RemoveEventCallback("KrakenEncounter", StartDanger, player)
    end

    local function IA_StartSoundEmitter()
        if _soundemitter == nil then
            _soundemitter = TheFocalPoint.SoundEmitter
            if not _iscave then
                _isday = inst.state.isday
                inst:WatchWorldState("phase", IA_OnPhase)
            end
        end
    end

    local function IA_StopSoundEmitter()
        if _soundemitter ~= nil then
            StopErupt()
            inst:StopWatchingWorldState("phase", IA_OnPhase)
            _soundemitter = nil
        end
    end

    local function IA_OnPlayerActivated(_inst, player)
        if _activatedplayer == player then
            return
        elseif _activatedplayer ~= nil and _activatedplayer.entity:IsValid() then
            IA_StopPlayerListeners(_activatedplayer)
        end
        _activatedplayer = player
        IA_StopSoundEmitter()
        IA_StartSoundEmitter()
        IA_StartPlayerListeners(player)

        -- init
        IA_MusicSwap(player, GetClimate(player))
        player:DoTaskInTime(0, function() IA_MusicSwap(player, GetClimate(player)) end)
    end

    local function IA_OnPlayerDeactivated(_inst, player)
        IA_StopPlayerListeners(player)
        if player == _activatedplayer then
            _activatedplayer = nil
            IA_StopSoundEmitter()
        end
    end

    local function IA_OnEnableDynamicMusic(_inst, enable)
        if _isenabled ~= enable then
            if not enable and _soundemitter ~= nil then
                StopErupt()
            end
            _isenabled = enable
        end
    end

    inst:ListenForEvent("playeractivated", IA_OnPlayerActivated)
    inst:ListenForEvent("playerdeactivated", IA_OnPlayerDeactivated)
    inst:ListenForEvent("enabledynamicmusic", IA_OnEnableDynamicMusic)
end)
