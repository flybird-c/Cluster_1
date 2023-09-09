local IAENV = env
GLOBAL.setfenv(1, GLOBAL)
---------------------------------

local guaranteed_presets = {

}

local function CanSpawnPreset(guaranteed_preset, player)
    local climate = GetClimate(player)
    if guaranteed_preset.ia_climate and IsIAClimate(climate) then
        return true
    elseif IsDSTClimate(climate) then
        return true
    end
    return false
end

IAENV.AddComponentPostInit("flotsamgenerator", function(cmp)

    local _PickFlotsam
    local function PickFlotsam(spawnpoint, ...)
        if IsInIAClimate(spawnpoint) then
            return nil
        end
        return _PickFlotsam(spawnpoint, ...)
    end

    local _guaranteed_presets
    local _scheduledtasks
    local _GetSpawnPoint
    local _SpawnFlotsamForPlayer
    local function SpawnFlotsamForPlayer(player, reschedule, override_prefab, override_notrealflotsam, ...)
        
        local guaranteed_preset = _guaranteed_presets[override_prefab] or nil
        if guaranteed_preset and not CanSpawnPreset(guaranteed_preset, player) then
            return {}
        end
        if player:CanOnWater(true) and player:GetCurrentPlatform() == nil then
            local flotsam = nil
        
            local pt = player:GetPosition()

            local spawnpoint = _GetSpawnPoint(pt)
            if spawnpoint ~= nil then
                flotsam = cmp:SpawnFlotsam(spawnpoint, override_prefab, override_notrealflotsam)
            end
            if reschedule ~= nil then
                _scheduledtasks[player] = nil
                reschedule(player)
            end
        
            return flotsam
        end
        return _SpawnFlotsamForPlayer(player, reschedule, override_prefab, override_notrealflotsam, ...)
    end

    _PickFlotsam =  UpvalueHacker.GetUpvalue(cmp.SpawnFlotsam, "PickFlotsam")
    for i, v in ipairs(cmp.inst.event_listening["ms_playerjoined"][TheWorld]) do
        if UpvalueHacker.GetUpvalue(v, "StartGuaranteedSpawn") then
            _guaranteed_presets =  UpvalueHacker.GetUpvalue(v, "StartGuaranteedSpawn", "guaranteed_presets")
            for i,v in pairs(guaranteed_presets) do
                _guaranteed_presets[i] = v
            end
            _SpawnFlotsamForPlayer = UpvalueHacker.GetUpvalue(v, "ScheduleSpawn", "SpawnFlotsamForPlayer")
            _scheduledtasks = UpvalueHacker.GetUpvalue(_SpawnFlotsamForPlayer, "_scheduledtasks")
            _GetSpawnPoint = UpvalueHacker.GetUpvalue(_SpawnFlotsamForPlayer, "GetSpawnPoint")
            
            UpvalueHacker.SetUpvalue(cmp.SpawnFlotsam, PickFlotsam, "PickFlotsam")
            UpvalueHacker.SetUpvalue(v, SpawnFlotsamForPlayer, "ScheduleSpawn", "SpawnFlotsamForPlayer")
            break
        end
    end
    --reset
    cmp:ToggleUpdate()

    -- Hide this so we dont mess with other mods access to flotsam_prefabs
    gemrun("hidefn", PickFlotsam, _PickFlotsam)
end)
