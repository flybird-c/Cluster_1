local IAENV = env
GLOBAL.setfenv(1, GLOBAL)
----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddComponentPostInit("frograin", function(cmp)
    local _SpawnFrogForPlayer, _fn_i, scope_fn = UpvalueHacker.GetUpvalue(cmp.SetSpawnTimes, "ToggleUpdate", "ScheduleSpawn", "SpawnFrogForPlayer")
    local _scheduledtasks = UpvalueHacker.GetUpvalue(_SpawnFrogForPlayer, "_scheduledtasks")
    debug.setupvalue(scope_fn, _fn_i, function(player, reschedule, ...)
        --There is no poisonfrograin... yet >:)  -M
        if not IA_CONFIG.poisonfrograin and IsInIAClimate(player) then
            _scheduledtasks[player] = nil
            return reschedule(player)
        end
        _SpawnFrogForPlayer(player, reschedule, ...)
    end)
end)
