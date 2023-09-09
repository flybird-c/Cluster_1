local IAENV = env
GLOBAL.setfenv(1, GLOBAL)
----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddComponentPostInit("butterflyspawner", function(cmp)
    local _SpawnButterflyForPlayer, _fn_i, scope_fn = UpvalueHacker.GetUpvalue(cmp.OnPostInit, "ToggleUpdate", "ScheduleSpawn", "SpawnButterflyForPlayer")
    local _scheduledtasks = UpvalueHacker.GetUpvalue(_SpawnButterflyForPlayer, "_scheduledtasks")
    debug.setupvalue(scope_fn, _fn_i, function(player, reschedule, ...)
        if IsInClimate(player, "volcano") then
            _scheduledtasks[player] = nil
            return reschedule(player)
        end
        _SpawnButterflyForPlayer(player, reschedule, ...)
    end)
end)
